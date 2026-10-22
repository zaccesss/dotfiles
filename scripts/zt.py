#!/usr/bin/env python3
"""zt: switch every installed editor and terminal to one Zacess theme at once (macOS and Linux).

    zt <theme>                     fix that theme everywhere and stop following the system
    zt auto [dark] [light]         follow the system light and dark appearance, Deep Contrast by default
    zt list                        the eight themes and their short names
    zt current                     the mode zt last set and what each tool is on now

Each tool is edited in place and only for its theme setting; a tool that is not installed is skipped.
Tools that keep settings in memory (JetBrains IDEs, Eclipse) are only changed while they are closed,
since they write their settings back on exit. Windows has its own version in windows/scripts/zt.ps1.
"""

import json
import os
import platform
import re
import shutil
import subprocess
import sys
import uuid
import xml.etree.ElementTree as ET
from pathlib import Path

THEMES = [
    # id, short name, full name, appearance
    ("deep-contrast-dark", "deep-dark", "Zacess Deep Contrast Dark", "dark"),
    ("deep-contrast-light", "deep-light", "Zacess Deep Contrast Light", "light"),
    ("high-contrast-dark", "hc-dark", "Zacess High Contrast Dark", "dark"),
    ("high-contrast-light", "hc-light", "Zacess High Contrast Light", "light"),
    ("dark", "dark", "Zacess Dark", "dark"),
    ("light", "light", "Zacess Light", "light"),
    ("cream", "cream", "Zacess Cream", "light"),
    ("yellow-on-black", "yellow", "Zacess Yellow on Black", "dark"),
]
DEFAULT_DARK = "deep-contrast-dark"
DEFAULT_LIGHT = "deep-contrast-light"

HOME = Path.home()
MAC = platform.system() == "Darwin"
XDG_CONFIG = Path(os.environ.get("XDG_CONFIG_HOME") or HOME / ".config")
XDG_STATE = Path(os.environ.get("XDG_STATE_HOME") or HOME / ".local" / "state")
STATE_FILE = XDG_STATE / "zacess" / "theme"
ECLIPSE_WORKSPACE = Path(os.environ.get("ZT_ECLIPSE_WORKSPACE") or HOME / "eclipse-workspace")
# the theme folder of an eclipse-config clone, where its README puts one
ECLIPSE_THEMES = Path(os.environ.get("ZT_ECLIPSE_THEMES") or HOME / ".eclipse-config-src" / "theme")
TERMINAL_HELPER = HOME / ".local" / "bin" / "terminal-appearance"
TERMINAL_AGENT = "local.terminal-config.appearance"
TERMINAL_AGENT_PLIST = HOME / "Library" / "LaunchAgents" / f"{TERMINAL_AGENT}.plist"
ITERM_PROFILES = HOME / "Library" / "Application Support" / "iTerm2" / "DynamicProfiles"
ITERM_AUTO_GUID = str(uuid.uuid5(uuid.NAMESPACE_URL, "terminal-config/zacess-auto"))

if sys.stdout.isatty() and not os.environ.get("NO_COLOR"):
    # terminal colour slots rather than fixed colours, so the output reads in every theme
    OK, SKIP, BOLD, RESET = "\033[32m", "\033[33m", "\033[1m", "\033[0m"
else:
    OK = SKIP = BOLD = RESET = ""


class Theme:
    def __init__(self, row):
        self.id, self.short, self.name, self.appearance = row

    @property
    def dark(self):
        return self.appearance == "dark"


def find_theme(word):
    key = word.strip().lower().replace(" ", "-")
    key = re.sub(r"^zacess-", "", key)
    for row in THEMES:
        if key in (row[0], row[1]):
            return Theme(row)
    return None


def report(tool, message, changed=True):
    colour = OK if changed else SKIP
    print(f"  {BOLD}{tool:<16}{RESET} {colour}{message}{RESET}")


def run(*args, **kwargs):
    return subprocess.run(list(args), capture_output=True, text=True, **kwargs)


def running(pattern):
    return run("pgrep", "-if", pattern).returncode == 0


def system_is_dark():
    if MAC:
        return run("defaults", "read", "-g", "AppleInterfaceStyle").stdout.strip() == "Dark"
    if "KDE" in os.environ.get("XDG_CURRENT_DESKTOP", "").upper():
        for tool in ("kreadconfig6", "kreadconfig5"):
            if shutil.which(tool):
                scheme = run(tool, "--file", "kdeglobals", "--group", "General", "--key", "ColorScheme").stdout
                return "dark" in scheme.lower()
    if shutil.which("gsettings"):
        out = run("gsettings", "get", "org.gnome.desktop.interface", "color-scheme")
        if out.returncode == 0:
            return "dark" in out.stdout
    # with no desktop to ask (a server, WSL or OrbStack) dark is the default
    return True


# ---------------------------------------------------------------------------------------------------
# JSON with comments (VS Code and Zed both allow them): values are swapped in the text itself, so
# comments, key order and spacing stay as they were. the result is parsed before it is saved
# ---------------------------------------------------------------------------------------------------

def strip_jsonc(text):
    out, i, in_string = [], 0, False
    while i < len(text):
        c = text[i]
        if in_string:
            out.append(c)
            if c == "\\":
                out.append(text[i + 1])
                i += 1
            elif c == '"':
                in_string = False
        elif c == '"':
            in_string = True
            out.append(c)
        elif text.startswith("//", i):
            while i < len(text) and text[i] != "\n":
                i += 1
            continue
        elif text.startswith("/*", i):
            i = text.index("*/", i) + 1
        else:
            out.append(c)
        i += 1
    return re.sub(r",(\s*[}\]])", r"\1", "".join(out))


def parse_jsonc(text):
    return json.loads(strip_jsonc(text) or "{}")


VALUE = r'(?:"(?:[^"\\]|\\.)*"|true|false|null|-?\d+(?:\.\d+)?|\{[^{}]*\})'


def set_key(text, key, value):
    pattern = re.compile(r'("' + re.escape(key) + r'"\s*:\s*)' + VALUE)
    match = pattern.search(text)
    if match:
        line_start = text.rfind("\n", 0, match.start()) + 1
        pad = re.match(r"[ \t]*", text[line_start:]).group(0)
        old = match.group(0)[len(match.group(1)):]
        rendered = json.dumps(value) if not isinstance(value, dict) else render_object(value, pad, old)
        return text[:match.start()] + match.group(1) + rendered + text[match.end():]
    rendered = json.dumps(value) if not isinstance(value, dict) else render_object(value)
    # a new key goes first, after the opening brace, with the file's own indent
    indent = re.search(r'\n([ \t]+)"', text)
    pad = indent.group(1) if indent else "    "
    brace = text.index("{")
    return text[:brace + 1] + f'\n{pad}"{key}": {rendered},' + text[brace + 1:]


def render_object(value, pad="", old=""):
    # an object that was already spread over lines keeps that shape (and its trailing comma), so a linked
    # settings file in a config repo only changes where a value really changed
    if "\n" not in old:
        inner = ", ".join(f"{json.dumps(k)}: {json.dumps(v)}" for k, v in value.items())
        return "{ " + inner + " }"
    inside = re.search(r"\n([ \t]+)\S", old)
    step = inside.group(1) if inside else pad + "  "
    trailing = "," if re.search(r",\s*}\s*$", old) else ""
    lines = [f"{step}{json.dumps(k)}: {json.dumps(v)}" for k, v in value.items()]
    return "{\n" + ",\n".join(lines) + trailing + "\n" + pad + "}"


def edit_jsonc(path, changes):
    text = path.read_text()
    original = text
    for key, value in changes.items():
        text = set_key(text, key, value)
    parse_jsonc(text)
    if text != original:
        # writing through the path keeps a symlinked settings file linked
        with open(path, "w") as f:
            f.write(text)
    return text != original


# ---------------------------------------------------------------------------------------------------
# the tools
# ---------------------------------------------------------------------------------------------------

def vscode(fixed, dark, light, now):
    path = (HOME / "Library" / "Application Support" / "Code" / "User" / "settings.json" if MAC
            else XDG_CONFIG / "Code" / "User" / "settings.json")
    if not path.exists():
        return report("VS Code", "not installed, skipped", False)
    if fixed:
        edit_jsonc(path, {"workbench.colorTheme": fixed.name, "window.autoDetectColorScheme": False})
        return report("VS Code", fixed.name)
    edit_jsonc(path, {"workbench.colorTheme": now.name, "window.autoDetectColorScheme": True,
                      "workbench.preferredDarkColorTheme": dark.name,
                      "workbench.preferredLightColorTheme": light.name})
    report("VS Code", f"following the system: {dark.name} or {light.name}")


def zed(fixed, dark, light, now):
    path = XDG_CONFIG / "zed" / "settings.json"
    if not path.exists():
        return report("Zed", "not installed, skipped", False)
    current = parse_jsonc(path.read_text()).get("theme")
    pair = current if isinstance(current, dict) else {}
    if fixed:
        value = {"mode": fixed.appearance,
                 "light": fixed.name if not fixed.dark else pair.get("light", Theme(THEMES[1]).name),
                 "dark": fixed.name if fixed.dark else pair.get("dark", Theme(THEMES[0]).name)}
        edit_jsonc(path, {"theme": value})
        return report("Zed", fixed.name)
    edit_jsonc(path, {"theme": {"mode": "system", "light": light.name, "dark": dark.name}})
    report("Zed", f"following the system: {dark.name} or {light.name}")


def jetbrains_dirs():
    base = (HOME / "Library" / "Application Support" / "JetBrains" if MAC else XDG_CONFIG / "JetBrains")
    if not base.is_dir():
        return []
    dirs = []
    for d in sorted(base.iterdir()):
        if not (d / "options").is_dir():
            continue
        plugin_places = [d / "plugins" / "zacess-themes",
                         HOME / ".local" / "share" / "JetBrains" / d.name / "zacess-themes"]
        dirs.append((d, any(p.is_dir() for p in plugin_places)))
    return dirs


def jetbrains(fixed, dark, light, now):
    dirs = jetbrains_dirs()
    if not dirs:
        return report("JetBrains", "not installed, skipped", False)
    pattern = (r"/Applications/.*\.app/Contents/MacOS/(idea|pycharm|webstorm|clion|dataspell|goland|"
               r"phpstorm|rubymine|rustrover|rider|studio)" if MAC else
               # only the IDE launchers: the Toolbox app and its jetbrainsd helper run all the time
               r"/bin/(idea|pycharm|webstorm|clion|dataspell|goland|phpstorm|rubymine|rustrover|rider|studio)(\.sh)?( |$)")
    if running(pattern):
        return report("JetBrains", "an IDE is open, skipped: close it and run zt again", False)
    shown = fixed or now
    for d, has_plugin in dirs:
        if not has_plugin:
            report(f"  {d.name}", "Zacess Themes plugin not installed, skipped", False)
            continue
        laf = d / "options" / "laf.xml"
        root = ET.parse(laf).getroot() if laf.exists() else ET.Element("application")
        comp = root.find("component[@name='LafManager']")
        if comp is None:
            comp = ET.SubElement(root, "component", name="LafManager")
        for child in list(comp):
            # a remembered scheme per theme would win over the theme's own scheme
            if child.tag in ("laf", "lafs-to-previous-schemes") or (not fixed and child.tag.startswith("preferred-")):
                comp.remove(child)
        comp.set("autodetect", "false" if fixed else "true")
        ET.SubElement(comp, "laf", themeId=f"zacess-{shown.id}")
        if not fixed:
            ET.SubElement(comp, "preferred-light-laf", themeId=f"zacess-{light.id}")
            ET.SubElement(comp, "preferred-dark-laf", themeId=f"zacess-{dark.id}")
        ET.indent(root, space="  ")
        ET.ElementTree(root).write(laf, encoding="unicode")
        scheme = d / "options" / "colors.scheme.xml"
        root = ET.parse(scheme).getroot() if scheme.exists() else ET.Element("application")
        comp = root.find("component[@name='EditorColorsManagerImpl']")
        if comp is None:
            comp = ET.SubElement(root, "component", name="EditorColorsManagerImpl")
        node = comp.find("global_color_scheme")
        if node is None:
            node = ET.SubElement(comp, "global_color_scheme")
        node.set("name", shown.name)
        ET.indent(root, space="  ")
        ET.ElementTree(root).write(scheme, encoding="unicode")
        report(f"  {d.name}", shown.name if fixed else f"Sync with OS: {dark.name} or {light.name}")


def neovim(fixed, dark, light, now):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text((fixed.id if fixed else f"auto {dark.id} {light.id}") + "\n")
    if not shutil.which("nvim"):
        return report("Neovim", "not installed, theme saved for later", False)
    report("Neovim", (fixed.name if fixed else "following the system") + ", on next focus or start")


def eclipse(fixed, dark, light, now):
    settings = ECLIPSE_WORKSPACE / ".metadata" / ".plugins" / "org.eclipse.core.runtime" / ".settings"
    if not settings.is_dir():
        return report("Eclipse", "no workspace, skipped", False)
    if running(r"/eclipse( |$)|Eclipse.*\.app/Contents/MacOS/eclipse"):
        return report("Eclipse", "open, skipped: quit it and run zt again", False)
    theme = fixed or now
    epfs = [ECLIPSE_THEMES / f"{theme.name}.epf", ECLIPSE_THEMES / f"{theme.name} borders.epf"]
    if not epfs[0].exists():
        return report("Eclipse", f"no theme files in {ECLIPSE_THEMES}, skipped", False)
    fragments = {"org.eclipse.e4.ui.css.swt.theme": {
        "themeid": "org.eclipse.e4.ui.css.theme.e4_dark" if theme.dark else "org.eclipse.e4.ui.css.theme.e4_default"}}
    for epf in epfs:
        if not epf.exists():
            continue
        for line in epf.read_text().splitlines():
            if not line.startswith("/instance/") or "=" not in line:
                continue
            plugin, _, rest = line[len("/instance/"):].partition("/")
            key, _, value = rest.partition("=")
            fragments.setdefault(plugin, {})[key] = value
    for plugin, keys in fragments.items():
        target = settings / f"{plugin}.prefs"
        lines = target.read_text().splitlines() if target.exists() else ["eclipse.preferences.version=1"]
        done = set()
        out = []
        for line in lines:
            key = line.split("=", 1)[0] if "=" in line else None
            if key in keys:
                if key not in done:
                    out.append(f"{key}={keys[key]}")
                    done.add(key)
                continue
            out.append(line)
        out += [f"{k}={v}" for k, v in keys.items() if k not in done]
        target.write_text("\n".join(out) + "\n")
    note = "" if fixed else " (Eclipse cannot follow the system, so this matches it now)"
    report("Eclipse", theme.name + note)


def terminal_app(fixed, dark, light, now):
    if not MAC:
        return
    profiles = run("defaults", "read", "com.apple.Terminal", "Window Settings").stdout
    wanted = fixed or now
    if f'"{wanted.name}" =' not in profiles:
        return report("Terminal.app", "Zacess profiles not installed (run terminal-config's mac/install.sh), skipped", False)
    uid = os.getuid()
    run("launchctl", "bootout", f"gui/{uid}/{TERMINAL_AGENT}")
    if TERMINAL_AGENT_PLIST.exists():
        TERMINAL_AGENT_PLIST.unlink()
    if run("pgrep", "-x", "Terminal").returncode == 0:
        script = f'''tell application "Terminal"
            set default settings to settings set "{wanted.name}"
            set startup settings to settings set "{wanted.name}"
            repeat with w in windows
                try
                    repeat with t in tabs of w
                        set n to name of current settings of t
                        if n starts with "Zacess" or n starts with "High Contrast" then set current settings of t to settings set "{wanted.name}"
                    end repeat
                end try
            end repeat
        end tell'''
        run("osascript", "-e", script)
    else:
        run("defaults", "write", "com.apple.Terminal", "Default Window Settings", "-string", wanted.name)
        run("defaults", "write", "com.apple.Terminal", "Startup Window Settings", "-string", wanted.name)
    if fixed:
        return report("Terminal.app", fixed.name)
    if f'"{dark.name}" =' not in profiles or f'"{light.name}" =' not in profiles:
        return report("Terminal.app", f"{now.name}; the pair's profiles are not all installed, so it stays fixed", False)
    if not TERMINAL_HELPER.exists():
        return report("Terminal.app", f"{now.name}; the switching helper is missing (run terminal-config's mac/install.sh)", False)
    TERMINAL_AGENT_PLIST.parent.mkdir(parents=True, exist_ok=True)
    TERMINAL_AGENT_PLIST.write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>{TERMINAL_AGENT}</string>
    <key>ProgramArguments</key><array><string>{TERMINAL_HELPER}</string><string>{dark.name}</string><string>{light.name}</string></array>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><true/>
</dict>
</plist>
''')
    run("launchctl", "bootstrap", f"gui/{uid}", str(TERMINAL_AGENT_PLIST))
    report("Terminal.app", f"following the system: {dark.name} or {light.name}")


def iterm2(fixed, dark, light, now):
    if not MAC:
        return
    source = ITERM_PROFILES / "zacess.json"
    if not source.exists():
        installed = Path("/Applications/iTerm.app").exists() or (HOME / "Applications" / "iTerm.app").exists()
        return report("iTerm2", "Zacess profiles not installed, skipped" if installed else "not installed, skipped", False)
    profiles = {p["Name"]: p for p in json.loads(source.read_text())["Profiles"]}
    auto_file = ITERM_PROFILES / "zacess-auto.json"
    if fixed:
        guid = profiles[fixed.name]["Guid"]
        if auto_file.exists():
            auto_file.unlink()
    else:
        auto = {"Name": "Zacess Auto", "Guid": ITERM_AUTO_GUID, "Dynamic Profile Parent Name": "Default",
                "Use Separate Colors for Light and Dark Mode": True, "Use Bright Bold": False}
        for theme, suffix in ((dark, " (Dark)"), (light, " (Light)")):
            for key, value in profiles[theme.name].items():
                if key.endswith("Color"):
                    auto[key + suffix] = value
        auto_file.write_text(json.dumps({"Profiles": [auto]}, indent=2) + "\n")
        guid = ITERM_AUTO_GUID
    run("defaults", "write", "com.googlecode.iterm2", "Default Bookmark Guid", "-string", guid)
    note = " (iTerm2 is open: new windows use it after a restart)" if run("pgrep", "-x", "iTerm2").returncode == 0 else ""
    report("iTerm2", (fixed.name if fixed else f"Zacess Auto: {dark.name} or {light.name}") + note)


def kitty(fixed, dark, light, now):
    folder = Path(os.environ.get("KITTY_CONFIG_DIRECTORY") or XDG_CONFIG / "kitty")
    conf = folder / "kitty.conf"
    if not conf.exists() or not shutil.which("kitty") and not Path("/Applications/kitty.app").exists():
        return report("Kitty", "not installed, skipped", False)
    wanted = fixed or dark
    if not (folder / f"zacess-{wanted.id}.conf").exists():
        return report("Kitty", "Zacess theme files not in the Kitty folder, skipped", False)
    text = conf.read_text()
    line = f"include zacess-{wanted.id}.conf"
    if re.search(r"^include\s+zacess-[\w-]+\.conf\s*$", text, flags=re.M):
        text = re.sub(r"^include\s+zacess-[\w-]+\.conf\s*$", line, text, count=1, flags=re.M)
    else:
        text = text.rstrip("\n") + f"\n{line}\n"
    conf.write_text(text)
    autos = {"dark-theme.auto.conf": dark, "light-theme.auto.conf": light, "no-preference-theme.auto.conf": dark}
    for name, theme in autos.items():
        target = folder / name
        if fixed:
            # only files zt wrote are removed, recognised by the theme name on their first line
            if target.exists() and target.read_text().startswith("# Zacess"):
                target.unlink()
        else:
            target.write_text((folder / f"zacess-{theme.id}.conf").read_text())
    # kitty reloads its config on SIGUSR1
    run("pkill", "-USR1", "-x", "kitty")
    report("Kitty", fixed.name if fixed else f"following the system: {dark.name} or {light.name}")


def alacritty(fixed, dark, light, now):
    conf = XDG_CONFIG / "alacritty" / "alacritty.toml"
    if not conf.exists():
        return report("Alacritty", "not installed, skipped", False)
    wanted = fixed or now
    text = conf.read_text()
    if not re.search(r"zacess-[\w-]+\.toml", text):
        return report("Alacritty", "no Zacess import in alacritty.toml, skipped", False)
    conf.write_text(re.sub(r"zacess-[\w-]+\.toml", f"zacess-{wanted.id}.toml", text, count=1))
    note = "" if fixed else " (Alacritty cannot follow the system, so this matches it now)"
    report("Alacritty", wanted.name + note)


def ghostty(fixed, dark, light, now):
    conf = XDG_CONFIG / "ghostty" / "config"
    themes = XDG_CONFIG / "ghostty" / "themes"
    if not conf.exists():
        return report("Ghostty", "not installed, skipped", False)
    if not (themes / f"zacess-{(fixed or dark).id}").exists():
        return report("Ghostty", "Zacess theme files not in ghostty/themes, skipped", False)
    value = f"zacess-{fixed.id}" if fixed else f"light:zacess-{light.id},dark:zacess-{dark.id}"
    text = conf.read_text()
    if re.search(r"^theme\s*=.*$", text, flags=re.M):
        text = re.sub(r"^theme\s*=.*$", f"theme = {value}", text, count=1, flags=re.M)
    else:
        text = text.rstrip("\n") + f"\ntheme = {value}\n"
    conf.write_text(text)
    report("Ghostty", (fixed.name if fixed else f"following the system: {dark.name} or {light.name}")
           + ", in new windows")


def warp(fixed, dark, light, now):
    if not (HOME / ".warp").is_dir():
        return
    report("Warp", "set by hand: Settings > Appearance > Themes", False)


TOOLS = [vscode, zed, jetbrains, neovim, eclipse, terminal_app, iterm2, kitty, alacritty, ghostty, warp]


def name_of(theme_id):
    theme = find_theme(theme_id.replace("zacess-", "")) if theme_id else None
    return theme.name if theme else (theme_id or "not set")


def read_epf(path):
    keys = {}
    for line in path.read_text().splitlines():
        if line.startswith("/instance/") and "=" in line:
            plugin, _, rest = line[len("/instance/"):].partition("/")
            key, _, value = rest.partition("=")
            keys[(plugin, key)] = value
    return keys


def read_prefs(settings, plugin):
    path = settings / f"{plugin}.prefs"
    if not path.exists():
        return {}
    return dict(line.split("=", 1) for line in path.read_text().splitlines() if "=" in line)


# each reader returns what the tool is on now, in the same words zt prints when it sets it
def current_vscode():
    path = (HOME / "Library" / "Application Support" / "Code" / "User" / "settings.json" if MAC
            else XDG_CONFIG / "Code" / "User" / "settings.json")
    if not path.exists():
        return None
    data = parse_jsonc(path.read_text())
    if data.get("window.autoDetectColorScheme"):
        return (f"following the system: {data.get('workbench.preferredDarkColorTheme')} or "
                f"{data.get('workbench.preferredLightColorTheme')}")
    return f"fixed: {data.get('workbench.colorTheme', 'default')}"


def current_zed():
    path = XDG_CONFIG / "zed" / "settings.json"
    if not path.exists():
        return None
    value = parse_jsonc(path.read_text()).get("theme")
    if isinstance(value, dict):
        mode = value.get("mode", "system")
        if mode == "system":
            return f"following the system: {value.get('dark')} or {value.get('light')}"
        return f"fixed: {value.get(mode)}"
    return f"fixed: {value or 'default'}"


def current_jetbrains():
    out = []
    for d, has_plugin in jetbrains_dirs():
        laf = d / "options" / "laf.xml"
        scheme = d / "options" / "colors.scheme.xml"
        comp = ET.parse(laf).getroot().find("component[@name='LafManager']") if laf.exists() else None
        node = ET.parse(scheme).getroot().find(".//global_color_scheme") if scheme.exists() else None
        editor = node.get("name") if node is not None else "default"
        if comp is not None and comp.get("autodetect") == "true":
            dark = comp.find("preferred-dark-laf")
            light = comp.find("preferred-light-laf")
            text = (f"Sync with OS: {name_of(dark.get('themeId') if dark is not None else '')} or "
                    f"{name_of(light.get('themeId') if light is not None else '')}")
        else:
            laf_node = comp.find("laf") if comp is not None else None
            text = f"fixed: {name_of(laf_node.get('themeId') if laf_node is not None else '')}"
        out.append((d.name, f"{text}, editor {editor}" + ("" if has_plugin else " (no Zacess plugin)")))
    return out


def current_neovim():
    if not STATE_FILE.exists():
        return f"fixed: {Theme(THEMES[0]).name} (no state file, the default)"
    words = STATE_FILE.read_text().split()
    if words and words[0] == "auto":
        return f"following the system: {name_of(words[1] if len(words) > 1 else DEFAULT_DARK)} or " \
               f"{name_of(words[2] if len(words) > 2 else DEFAULT_LIGHT)}"
    return f"fixed: {name_of(words[0] if words else DEFAULT_DARK)}"


def current_eclipse():
    settings = ECLIPSE_WORKSPACE / ".metadata" / ".plugins" / "org.eclipse.core.runtime" / ".settings"
    if not settings.is_dir():
        return None
    # Eclipse keeps no theme name, so the editor colours are compared with each theme's file
    best, best_score, found = None, 0.0, False
    cache = {}
    for row in THEMES:
        theme = Theme(row)
        epf = ECLIPSE_THEMES / f"{theme.name}.epf"
        if not epf.exists():
            continue
        found = True
        keys = read_epf(epf)
        hits = 0
        for (plugin, key), value in keys.items():
            if plugin not in cache:
                cache[plugin] = read_prefs(settings, plugin)
            hits += cache[plugin].get(key) == value
        score = hits / len(keys) if keys else 0
        if score > best_score:
            best, best_score = theme, score
    if not found:
        return "no Zacess theme files to compare with"
    if not best:
        return "not a Zacess theme"
    workbench = read_prefs(settings, "org.eclipse.e4.ui.css.swt.theme").get("themeid", "")
    look = "Dark" if workbench.endswith("e4_dark") else "Light"
    if best_score == 1:
        return f"fixed: {best.name}, {look} workbench"
    return f"not a Zacess theme (closest {best.name}, {round(best_score * 100)}% of its colours), {look} workbench"


def current_terminal_app():
    if not MAC:
        return None
    name = run("defaults", "read", "com.apple.Terminal", "Default Window Settings").stdout.strip()
    if TERMINAL_AGENT_PLIST.exists():
        args = re.findall(r"<string>([^<]*)</string>", TERMINAL_AGENT_PLIST.read_text())[2:4]
        return f"following the system: {' or '.join(args) if args else 'default pair'} (now {name})"
    return f"fixed: {name}"


def current_iterm2():
    if not MAC or not (ITERM_PROFILES / "zacess.json").exists():
        return None
    guid = run("defaults", "read", "com.googlecode.iterm2", "Default Bookmark Guid").stdout.strip()
    if guid == ITERM_AUTO_GUID:
        return "following the system: the Zacess Auto profile"
    names = {p["Guid"]: p["Name"] for p in json.loads((ITERM_PROFILES / "zacess.json").read_text())["Profiles"]}
    return f"fixed: {names.get(guid, 'a profile that is not a Zacess one')}"


def current_kitty():
    folder = Path(os.environ.get("KITTY_CONFIG_DIRECTORY") or XDG_CONFIG / "kitty")
    conf = folder / "kitty.conf"
    if not conf.exists():
        return None
    if (folder / "dark-theme.auto.conf").exists():
        return "following the system through the auto theme files"
    m = re.search(r"^include\s+zacess-([\w-]+)\.conf", conf.read_text(), flags=re.M)
    return f"fixed: {name_of(m.group(1)) if m else 'no Zacess include'}"


def current_alacritty():
    conf = XDG_CONFIG / "alacritty" / "alacritty.toml"
    if not conf.exists():
        return None
    m = re.search(r"zacess-([\w-]+)\.toml", conf.read_text())
    return f"fixed: {name_of(m.group(1)) if m else 'no Zacess import'}"


def current_ghostty():
    conf = XDG_CONFIG / "ghostty" / "config"
    if not conf.exists():
        return None
    m = re.search(r"^theme\s*=\s*(.+)$", conf.read_text(), flags=re.M)
    if not m:
        return "fixed: default"
    value = m.group(1).strip()
    if "light:" in value:
        pairs = dict(part.split(":", 1) for part in value.split(","))
        return f"following the system: {name_of(pairs.get('dark', ''))} or {name_of(pairs.get('light', ''))}"
    return f"fixed: {name_of(value)}"


def show_current():
    print(current_neovim().replace("fixed:", "zt state: fixed", 1).replace("following the system", "zt state: following the system", 1))
    readers = [("VS Code", current_vscode), ("Zed", current_zed), ("Neovim", current_neovim),
               ("Eclipse", current_eclipse), ("Terminal.app", current_terminal_app), ("iTerm2", current_iterm2),
               ("Kitty", current_kitty), ("Alacritty", current_alacritty), ("Ghostty", current_ghostty)]
    for tool, reader in readers:
        try:
            value = reader()
        except Exception as error:  # a config that cannot be read is reported, never fatal
            value = f"could not read: {error}"
        if value:
            report(tool, value, False)
        if tool == "Zed":
            for ide, text in current_jetbrains():
                report(f"  {ide}", text, False)


def main(argv):
    if not argv or argv[0] in ("-h", "--help", "help"):
        print(__doc__.strip())
        return 0
    command = argv[0]
    if command == "list":
        current = STATE_FILE.read_text().split() if STATE_FILE.exists() else [DEFAULT_DARK]
        for row in THEMES:
            theme = Theme(row)
            mark = " *" if theme.id in current else ""
            print(f"  {theme.short:<11} {theme.name}{mark}")
        return 0
    if command == "current":
        show_current()
        return 0
    if command == "auto":
        dark = find_theme(argv[1]) if len(argv) > 1 else find_theme(DEFAULT_DARK)
        light = find_theme(argv[2]) if len(argv) > 2 else find_theme(DEFAULT_LIGHT)
        if not dark or not light:
            print("Unknown theme. Run zt list for the names.", file=sys.stderr)
            return 1
        now = dark if system_is_dark() else light
        print(f"{BOLD}Following the system{RESET}: {dark.name} in dark mode, {light.name} in light mode "
              f"(now {now.appearance})")
        fixed = None
    else:
        fixed = find_theme(" ".join(argv))
        if not fixed:
            print(f"Unknown theme: {' '.join(argv)}. Run zt list for the names.", file=sys.stderr)
            return 1
        dark = fixed if fixed.dark else find_theme(DEFAULT_DARK)
        light = fixed if not fixed.dark else find_theme(DEFAULT_LIGHT)
        now = fixed
        print(f"{BOLD}{fixed.name}{RESET} everywhere, not following the system")
    for tool in TOOLS:
        try:
            tool(fixed, dark, light, now)
        except Exception as error:  # one broken config never stops the other tools
            report(tool.__name__, f"failed: {error}", False)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
