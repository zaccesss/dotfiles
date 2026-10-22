"""Installs the Zacess theme file into Zed's themes folder and sets the theme in settings.json.

Run by mac/apply.sh and linux/apply.sh (and so by the bootstraps' apps stage) with the system python3.

usage: apply.py [--theme <theme>] [--config-dir <folder>]

The tracked settings.json is linked or copied into place (the Mac bootstrap's configs stage links
it), never replaced here: this only installs the theme file and changes the theme block, through zt.py's own JSONC
editing, so a linked file keeps its comments and layout. The theme file is the one Zacess Themes
ships for Zed, kept here while the extension store still has an older version; once the installed
extension reaches the pinned version the local copy is removed so the themes never load twice.
"""

import json
import os
import platform
import re
import shutil
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
# editors/zed/shared sits three levels below the clone's root, beside shell/scripts/zt.py
sys.path.insert(0, str(HERE.parents[2] / "shell" / "scripts"))
import zt  # noqa: E402

HOME = Path.home()
MAC = platform.system() == "Darwin"
FLATPAK = HOME / ".var" / "app" / "dev.zed.Zed"
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

if "--config-dir" in options:
    config = Path(options["--config-dir"]).expanduser()
else:
    config = zt.XDG_CONFIG / "zed"
    # Fedora can run Zed from Flathub, whose sandbox keeps its own config folder
    if not config.exists() and (FLATPAK / "config" / "zed").exists():
        config = FLATPAK / "config" / "zed"

apps = [Path("/Applications/Zed.app"), HOME / "Applications" / "Zed.app", HOME / ".local" / "zed.app", FLATPAK]
if not (config.is_dir() or shutil.which("zed") or any(p.exists() for p in apps)):
    print("Zed is not installed, skipped.")
    print("Install Zed, start it once, then run this again or pass --config-dir.")
    sys.exit(0)

# installed extensions live in Zed's data folder, not beside its settings
if config.is_relative_to(FLATPAK):
    data = FLATPAK / "data" / "zed"
elif MAC:
    data = HOME / "Library" / "Application Support" / "Zed"
else:
    data = Path(os.environ.get("XDG_DATA_HOME") or HOME / ".local" / "share") / "zed"


def version_tuple(text):
    return tuple(int(n) for n in re.findall(r"\d+", text))


manifest = data / "extensions" / "installed" / PACKAGE["name"] / "extension.toml"
match = re.search(r'(?m)^version\s*=\s*"([^"]+)"', manifest.read_text(encoding="utf-8")) if manifest.exists() else None
extension = match.group(1) if match else None
covered = extension is not None and version_tuple(extension) >= version_tuple(PACKAGE["version"])

print(f"Settings: {config}")
themes = config / "themes"
for source in sorted((HERE / "themes").glob("*.json")):
    target = themes / source.name
    if covered:
        # the extension now carries these themes, so a second copy would list each theme twice
        if target.exists():
            target.unlink()
            print(f"  removed    themes  {source.name} (Zacess Themes {extension} is installed as an extension)")
        else:
            print(f"  unchanged  themes  {source.name} not needed (Zacess Themes {extension} is installed as an extension)")
        continue
    wanted = source.read_bytes()
    if not target.exists():
        status = "added    "
    elif target.read_bytes() != wanted:
        status = "changed  "
    else:
        status = "unchanged"
    if status != "unchanged":
        themes.mkdir(parents=True, exist_ok=True)
        target.write_bytes(wanted)
    print(f"  {status}  themes  {source.name}")

settings = config / "settings.json"
if settings.exists():
    current = zt.parse_jsonc(settings.read_text(encoding="utf-8")).get("theme")
    dark = theme if theme.dark else zt.find_theme(zt.DEFAULT_DARK)
    light = theme if not theme.dark else zt.find_theme(zt.DEFAULT_LIGHT)
    changed = zt.edit_jsonc(settings, {"theme": zt.zed_theme(current, theme, dark, light)})
    print(f"  {'changed  ' if changed else 'unchanged'}  settings.json  theme")
else:
    print("  skipped    settings.json  not here yet: link or copy editors/zed/settings.json there (see the README)")

print(f"Theme: {theme.name}")
print("Done. Zed reloads its settings and themes while it runs, so nothing needs restarting.")
