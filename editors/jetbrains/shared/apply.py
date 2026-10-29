"""Installs the Zacess Themes plugin into every JetBrains IDE, applies the tracked settings and sets the theme.

Run by mac/apply.sh and linux/apply.sh (and so by the bootstraps' apps stage) with the system python3.

usage: apply.py [--theme <theme>] [--config-dir <JetBrains config root>]

Every IDE that has been started once has a config folder under ~/Library/Application Support/JetBrains
(macOS) or ~/.config/JetBrains (Linux). For each one:
- the Zacess Themes plugin is installed when it is missing, with the IDE's own `installPlugins`
  command (the launcher comes from the IDE's product-info.json); with no launcher found or when
  that command leaves nothing behind, the pinned release in theme-package.json is checked against
  its digest and unpacked into <config>/plugins
- the colour schemes, file template, custom keymap and the two font files from this folder are
  copied in, byte for byte
- the custom keymap is made the active one (options/<os>/keymap.xml) once the VSCode keymap
  plugin, its parent, is there
- laf.xml and colors.scheme.xml are written by shell/scripts/zt.py's own function, so zt and this
  write the same files
- new projects default to ~/dev/projects (options/ide.general.xml), the projects folder every
  editor shares, as JetBrains' own $USER_HOME$ macro so the file reads the same on every machine
The IDEs write their settings back on exit, so nothing changes while one of them runs.
"""

import hashlib
import io
import json
import os
import platform
import re
import shutil
import subprocess
import sys
import urllib.request
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
# the tracked settings sit in the folder above: colors, file-templates, keymaps and options
FOLDER = HERE.parent
# editors/jetbrains/shared sits three levels below the clone's root, beside shell/scripts/zt.py
sys.path.insert(0, str(HERE.parents[2] / "shell" / "scripts"))
import zt  # noqa: E402

HOME = Path.home()
MAC = platform.system() == "Darwin"
OS_FOLDER = "mac" if MAC else "linux"
KEYMAP = "JetBrains Custom (VSCode-based) mac" if MAC else "JetBrains Custom (VSCode-based) windows-linux"
KEYMAP_PLUGIN = "com.intellij.plugins.vscodekeymap"
PROJECTS = HOME / "dev" / "projects"
PROJECTS_VALUE = "$USER_HOME$/dev/projects"
PACKAGE = json.loads((HERE / "theme-package.json").read_text(encoding="utf-8"))

args = sys.argv[1:]
options = {}
for flag in ("--theme", "--config-dir"):
    if flag in args:
        i = args.index(flag)
        options[flag] = args[i + 1]
        del args[i:i + 2]
    for arg in [a for a in args if a.startswith(flag + "=")]:
        options[flag] = arg.split("=", 1)[1]
        args.remove(arg)
if args:
    sys.exit(f"Unknown option: {args[0]}")

theme = zt.find_theme(options.get("--theme", "deep-dark"))
if theme is None:
    sys.exit(f"Unknown theme: {options['--theme']}\n"
             "Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow.")
dark = theme if theme.dark else zt.find_theme(zt.DEFAULT_DARK)
light = theme if not theme.dark else zt.find_theme(zt.DEFAULT_LIGHT)

root = Path(options["--config-dir"]).expanduser() if "--config-dir" in options else zt.JETBRAINS_CONFIG
dirs = [d for d, _ in zt.jetbrains_dirs(root)]
if not dirs:
    print(f"JetBrains: no IDE has been started yet (no config folder with options/ under {root}), skipped.")
    print("Install an IDE, start it once, quit it, then run this again or pass --config-dir.")
    sys.exit(0)
if zt.running(zt.JETBRAINS_PROCESS):
    print("A JetBrains IDE is running. Quit it first, then run this again.", file=sys.stderr)
    sys.exit(1)
print(f"Settings: {root}")


def product_infos():
    """Each installed IDE by its config folder name: (product-info.json contents, launcher path)."""
    if MAC:
        roots = [Path("/Applications"), HOME / "Applications", HOME / "Applications" / "JetBrains Toolbox"]
        found = [p for r in roots if r.is_dir() for p in r.glob("*.app/Contents/Resources/product-info.json")]
    else:
        data = Path(os.environ.get("XDG_DATA_HOME") or HOME / ".local" / "share")
        roots = [data / "JetBrains" / "Toolbox" / "apps", HOME / "dev" / "tools" / "jetbrains", Path("/opt"), Path("/usr/local")]
        # Toolbox 2 keeps an IDE in apps/<name>, the old Toolbox in apps/<name>/<channel>/<build>
        found = [p for r in roots if r.is_dir() for depth in ("*", "*/*", "*/*/*") for p in r.glob(f"{depth}/product-info.json")]
    infos = {}
    for path in found:
        try:
            info = json.loads(path.read_text(encoding="utf-8"))
        except ValueError:
            continue
        launch = (info.get("launch") or [{}])[0]
        if info.get("dataDirectoryName") and launch.get("launcherPath"):
            infos.setdefault(info["dataDirectoryName"], (info, (path.parent / launch["launcherPath"]).resolve()))
    return infos


def plugin_ids(plugins):
    """The ids of the plugins in a config folder's plugins/: each a jar or a folder of jars under lib/."""
    ids = set()
    if not plugins.is_dir():
        return ids
    for item in plugins.iterdir():
        jars = sorted((item / "lib").glob("*.jar")) if item.is_dir() else ([item] if item.suffix == ".jar" else [])
        for jar in jars:
            try:
                with zipfile.ZipFile(jar) as archive:
                    if "META-INF/plugin.xml" not in archive.namelist():
                        continue
                    manifest = archive.read("META-INF/plugin.xml").decode("utf-8", "replace")
            except (zipfile.BadZipFile, OSError):
                continue
            # a plugin with no <id> is known by its <name>, as the IDE itself does
            match = re.search(r"<id>\s*([^<]+?)\s*</id>", manifest) or re.search(r"<name>\s*([^<]+?)\s*</name>", manifest)
            if match:
                ids.add(match.group(1))
            break
    return ids


def theme_plugin_version(d):
    """The version of the Zacess Themes plugin in d's plugins/ folder (None when it is not there)."""
    for jar in sorted((d / "plugins" / PACKAGE["folder"] / "lib").glob("*.jar")):
        try:
            with zipfile.ZipFile(jar) as archive:
                manifest = archive.read("META-INF/plugin.xml").decode("utf-8", "replace")
        except (KeyError, zipfile.BadZipFile, OSError):
            continue
        match = re.search(r"<version>\s*([^<]+?)\s*</version>", manifest)
        if match:
            return match.group(1)
    return None


def has_theme_plugin(d):
    places = [d / "plugins" / PACKAGE["folder"], HOME / ".local" / "share" / "JetBrains" / d.name / PACKAGE["folder"]]
    return any(p.is_dir() for p in places) or PACKAGE["id"] in plugin_ids(d / "plugins")


release = None


def pinned_release():
    """The release zip from theme-package.json, downloaded once and checked against its digest."""
    global release
    if release is None:
        data = urllib.request.urlopen(PACKAGE["url"], timeout=60).read()
        if hashlib.sha256(data).hexdigest() != PACKAGE["sha256"]:
            sys.exit("The Zacess Themes download does not match its pinned checksum, so it was not installed")
        release = data
    return release


def install_theme_plugin(d, infos):
    launcher = infos.get(d.name, (None, None))[1]
    if launcher is not None and launcher.exists():
        # the IDE starts without a window, installs from the Marketplace and exits
        result = subprocess.run([str(launcher), "installPlugins", PACKAGE["id"]], capture_output=True, text=True, timeout=900)
        if has_theme_plugin(d):
            print(f"  added      {d.name}  plugins/{PACKAGE['folder']} (from the Marketplace, by {launcher.name} installPlugins)")
            return
        reason = f"{launcher.name} installPlugins left nothing behind, exit {result.returncode}"
    else:
        reason = "no launcher found for it"
    with zipfile.ZipFile(io.BytesIO(pinned_release())) as archive:
        if not all(name.startswith(PACKAGE["folder"] + "/") for name in archive.namelist()):
            sys.exit("The Zacess Themes release zip does not unpack into its own folder, so it was not installed")
        (d / "plugins").mkdir(exist_ok=True)
        archive.extractall(d / "plugins")
    print(f"  added      {d.name}  plugins/{PACKAGE['folder']} (from the pinned release {PACKAGE['version']}, {reason})")


def copy_file(d, source, relative):
    target = d / relative
    wanted = source.read_bytes()
    if not target.exists():
        status = "added    "
    elif target.read_bytes() != wanted:
        status = "changed  "
    else:
        status = "unchanged"
    if status != "unchanged":
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(wanted)
    print(f"  {status}  {d.name}  {relative}")


def set_active_keymap(d, info):
    bundled = info.get("bundledPlugins", []) if info else []
    if KEYMAP_PLUGIN not in bundled and KEYMAP_PLUGIN not in plugin_ids(d / "plugins") and not (d / "plugins" / "keymap-vscode").is_dir():
        # the custom keymap's parent comes from that plugin, so without it the keymap would not load
        print(f"  skipped    {d.name}  options/{OS_FOLDER}/keymap.xml (install {KEYMAP_PLUGIN} first)")
        return
    file = d / "options" / OS_FOLDER / "keymap.xml"
    current = ET.parse(file).getroot().find(".//active_keymap") if file.exists() else None
    if current is not None and current.get("name") == KEYMAP:
        print(f"  unchanged  {d.name}  options/{OS_FOLDER}/keymap.xml")
        return
    file.parent.mkdir(parents=True, exist_ok=True)
    file.write_text(f'<application>\n  <component name="KeymapManager">\n    <active_keymap name="{KEYMAP}" />\n  </component>\n</application>',
                    encoding="utf-8")
    print(f"  {'changed  ' if current is not None else 'added    '}  {d.name}  options/{OS_FOLDER}/keymap.xml")


def set_theme(d):
    files = [d / "options" / "laf.xml", d / "options" / "colors.scheme.xml"]
    before = [f.read_text(encoding="utf-8") if f.exists() else None for f in files]
    zt.jetbrains_theme_files(d, theme, dark, light, theme)
    for f, old in zip(files, before):
        new = f.read_text(encoding="utf-8")
        status = "added    " if old is None else ("unchanged" if old == new else "changed  ")
        print(f"  {status}  {d.name}  options/{f.name}")


def set_project_directory(d):
    file = d / "options" / "ide.general.xml"
    tree_root = ET.parse(file).getroot() if file.exists() else ET.Element("application")
    comp = tree_root.find("component[@name='GeneralSettings']")
    if comp is None:
        comp = ET.SubElement(tree_root, "component", name="GeneralSettings")
    option = comp.find("option[@name='defaultProjectDirectory']")
    if option is not None and option.get("value") == PROJECTS_VALUE:
        print(f"  unchanged  {d.name}  options/ide.general.xml defaultProjectDirectory")
        return
    status = "changed  " if option is not None else "added    "
    if option is None:
        option = ET.SubElement(comp, "option", name="defaultProjectDirectory")
    option.set("value", PROJECTS_VALUE)
    ET.indent(tree_root, space="  ")
    ET.ElementTree(tree_root).write(file, encoding="unicode")
    print(f"  {status}  {d.name}  options/ide.general.xml defaultProjectDirectory")


infos = product_infos()
if not PROJECTS.is_dir():
    PROJECTS.mkdir(parents=True)
    print(f"  added      folder  {PROJECTS}")
for d in dirs:
    info = infos.get(d.name, (None, None))[0]
    installed = theme_plugin_version(d)
    if installed is not None and installed != PACKAGE["version"]:
        # an older copy in plugins/ is never updated by the IDE when it came from the pinned release,
        # so it is replaced by the pinned one. the IDE loads it on its next start
        shutil.rmtree(d / "plugins" / PACKAGE["folder"])
        with zipfile.ZipFile(io.BytesIO(pinned_release())) as archive:
            archive.extractall(d / "plugins")
        print(f"  changed    {d.name}  plugins/{PACKAGE['folder']} {installed} to {PACKAGE['version']} (restart the IDE to load it)")
    elif has_theme_plugin(d):
        print(f"  unchanged  {d.name}  plugins/{PACKAGE['folder']}")
    else:
        install_theme_plugin(d, infos)
    for scheme in sorted((FOLDER / "colors").glob("*.icls")):
        copy_file(d, scheme, f"colors/{scheme.name}")
    copy_file(d, FOLDER / "file-templates" / "Class.java", "fileTemplates/internal/Class.java")
    copy_file(d, FOLDER / "keymaps" / f"{KEYMAP}.xml", f"keymaps/{KEYMAP}.xml")
    set_active_keymap(d, info)
    for name in ("editor-font.xml", "terminal-font.xml"):
        copy_file(d, FOLDER / "options" / name, f"options/{name}")
    set_theme(d)
    set_project_directory(d)

print(f"Theme: {theme.name}")
print("Done. Start the IDEs to pick up the changes.")
