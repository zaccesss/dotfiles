#!/usr/bin/env bash
# merges the tracked Arduino IDE 2 settings into settings.json and installs the Zacess themes.
# usage: apply.sh [--theme <theme>] [--config-dir <dir>]
#   (the config folder defaults to ~/.arduinoIDE; Linux also checks the Flatpak's copy)
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the themes come from the pinned Zacess Themes .vsix in ../shared/theme-package.json, checked
# against its SHA-256 digest and dropped into <config>/plugins, which Arduino IDE 2 loads like a
# VS Code extension. only the keys in ../shared/settings.json are written; every other setting
# is left as it was. nothing is backed up: the repo holds every value this writes.
#
# mac/apply.sh and linux/apply.sh are the same file.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shared="$here/../shared"
theme="deep-dark"
config=""
while [ $# -gt 0 ]; do
  case "$1" in
    --theme) theme="${2:?--theme needs a theme name}"; shift 2 ;;
    --theme=*) theme="${1#--theme=}"; shift ;;
    --config-dir) config="${2:?--config-dir needs a folder}"; shift 2 ;;
    --config-dir=*) config="${1#--config-dir=}"; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

theme_name() {
  local key
  key="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/^zacess[ -]//' -e 's/ /-/g')"
  case "$key" in
    deep-dark|deep-contrast-dark) echo "Zacess Deep Contrast Dark" ;;
    deep-light|deep-contrast-light) echo "Zacess Deep Contrast Light" ;;
    hc-dark|high-contrast-dark) echo "Zacess High Contrast Dark" ;;
    hc-light|high-contrast-light) echo "Zacess High Contrast Light" ;;
    dark) echo "Zacess Dark" ;;
    light) echo "Zacess Light" ;;
    cream) echo "Zacess Cream" ;;
    yellow|yellow-on-black) echo "Zacess Yellow on Black" ;;
    *) return 1 ;;
  esac
}

if ! name="$(theme_name "$theme")"; then
  echo "Unknown theme: $theme" >&2
  echo "Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow." >&2
  exit 1
fi

# Fedora installs Arduino IDE from Flathub, whose sandbox keeps its own home folder
if [ -z "$config" ]; then
  for candidate in "$HOME/.arduinoIDE" "$HOME/.var/app/cc.arduino.IDE2/.arduinoIDE"; do
    if [ -f "$candidate/settings.json" ]; then config="$candidate"; break; fi
  done
fi
if [ -z "$config" ] || [ ! -f "$config/settings.json" ]; then
  echo "No Arduino IDE settings found (looked for ~/.arduinoIDE/settings.json and the Flatpak copy)." >&2
  echo "Start Arduino IDE once, quit it, then run this again or pass --config-dir." >&2
  exit 1
fi

# macOS pgrep leaves out its own ancestors unless given -a, so an app whose built-in terminal
# runs this script would look closed. procps pgrep on Linux has no such exclusion and its -a
# means something else
pgrep_flags=()
if [ "$(uname -s)" = Darwin ]; then
  pgrep_flags=(-a)
fi

# the IDE holds its settings in memory and writes them back on exit, so a merge made while it
# runs is lost
if pgrep ${pgrep_flags[@]+"${pgrep_flags[@]}"} -if 'arduino-ide|Arduino IDE' >/dev/null 2>&1; then
  echo "Arduino IDE is running. Quit it first, then run this again." >&2
  exit 1
fi

echo "Settings: $config"
python3 - "$shared/theme-package.json" "$config" <<'PYEOF'
import hashlib, json, pathlib, sys, urllib.request

package = json.loads(pathlib.Path(sys.argv[1]).read_text())
plugins = pathlib.Path(sys.argv[2]) / "plugins"
plugins.mkdir(exist_ok=True)
target = plugins / f"{package['name']}-{package['version']}.vsix"
if target.exists() and hashlib.sha256(target.read_bytes()).hexdigest() == package["sha256"]:
    print(f"  unchanged  plugins  {target.name}")
else:
    data = urllib.request.urlopen(package["url"], timeout=60).read()
    if hashlib.sha256(data).hexdigest() != package["sha256"]:
        sys.exit("The Zacess Themes download does not match its pinned checksum, so it was not installed")
    target.write_bytes(data)
    print(f"  added      plugins  {target.name}")
# an older version left beside it would load a second copy of every theme
for old in plugins.glob(f"{package['name']}-*.vsix"):
    if old != target:
        old.unlink()
        print(f"  removed    plugins  {old.name}")
PYEOF

python3 - "$shared/settings.json" "$config/settings.json" "$name" <<'PYEOF'
import json, pathlib, sys

want = json.loads(pathlib.Path(sys.argv[1]).read_text())
want["workbench.colorTheme"] = sys.argv[3]
path = pathlib.Path(sys.argv[2])
current = json.loads(path.read_text() or "{}")
for key, value in want.items():
    if key not in current:
        print(f"  added      settings.json  {key}")
    elif current[key] != value:
        print(f"  changed    settings.json  {key}")
    else:
        print(f"  unchanged  settings.json  {key}")
    current[key] = value
text = json.dumps(current, indent=2) + "\n"
if path.read_text() != text:
    path.write_text(text)
PYEOF

# the sketchbook is ~/dev/projects/arduino, the projects folder every editor shares. it holds the
# installed libraries too, so moving an existing sketchbook there is a step of its own (README)
python3 - "$config/arduino-cli.yaml" <<'PYEOF'
import pathlib, re, sys

cli = pathlib.Path(sys.argv[1])
sketchbook = pathlib.Path.home() / "dev" / "projects" / "arduino"
if not sketchbook.is_dir():
    sketchbook.mkdir(parents=True)
    print(f"  added      folder  {sketchbook}")
yaml = cli.read_text() if cli.exists() else ""
line = re.search(r"(?m)^(\s+user:[ \t]*)(.*)$", yaml)
if line and line.group(2) == str(sketchbook):
    print("  unchanged  arduino-cli.yaml  directories.user")
else:
    if line:
        yaml = yaml[:line.start(2)] + str(sketchbook) + yaml[line.end(2):]
    elif re.search(r"(?m)^directories:", yaml):
        yaml = re.sub(r"(?m)^(directories:\n)", lambda m: f"{m.group(1)}    user: {sketchbook}\n", yaml, count=1)
    else:
        yaml = yaml.rstrip() + f"\ndirectories:\n    user: {sketchbook}\n"
    cli.write_text(yaml)
    print(f"  {'changed  ' if line else 'added    '}  arduino-cli.yaml  directories.user")
PYEOF

echo "Theme: $name"
echo "Done. Start Arduino IDE to pick up the changes."
