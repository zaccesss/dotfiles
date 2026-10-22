#!/usr/bin/env bash
# installs the eight Zacess colour themes for KiCad and makes one of them the theme of every editor.
# usage: apply.sh [--theme <theme>] [--config-dir <dir>]
#   (the config folder defaults to the newest version folder KiCad has made: ~/Library/Preferences/kicad/<version>
#   on the Mac, ~/.config/kicad/<version> on Linux, then the Flathub copy; KICAD_CONFIG_HOME wins
#   when it is set, as it does for KiCad itself)
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the theme files go into <config>/colors, where KiCad lists them under Preferences > Colors. the
# chosen one is written to appearance.color_theme in each editor's settings file that already
# has the key (schematic, symbol, PCB, footprint, GerbView, 3D viewer and the rest). nothing
# else in those files changes. nothing is backed up: the repo holds every value this writes.
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

theme_id() {
  local key
  key="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/^zacess[ -]//' -e 's/ /-/g')"
  case "$key" in
    deep-dark|deep-contrast-dark) echo "deep-contrast-dark" ;;
    deep-light|deep-contrast-light) echo "deep-contrast-light" ;;
    hc-dark|high-contrast-dark) echo "high-contrast-dark" ;;
    hc-light|high-contrast-light) echo "high-contrast-light" ;;
    dark) echo "dark" ;;
    light) echo "light" ;;
    cream) echo "cream" ;;
    yellow|yellow-on-black) echo "yellow-on-black" ;;
    *) return 1 ;;
  esac
}

if ! id="$(theme_id "$theme")"; then
  echo "Unknown theme: $theme" >&2
  echo "Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow." >&2
  exit 1
fi

# the newest version folder is the one the installed KiCad reads; older ones stay as KiCad left them
newest() {
  [ -d "$1" ] || return 0
  find "$1" -mindepth 1 -maxdepth 1 -type d -name '[0-9]*.[0-9]*' 2>/dev/null | sort -V | tail -n 1
}

if [ -z "$config" ]; then
  for base in "${KICAD_CONFIG_HOME:-}" "$HOME/Library/Preferences/kicad" "$HOME/.config/kicad" \
              "$HOME/.var/app/org.kicad.KiCad/config/kicad"; do
    [ -n "$base" ] || continue
    found="$(newest "$base")"
    if [ -n "$found" ]; then config="$found"; break; fi
  done
fi
if [ -z "$config" ] || [ ! -d "$config" ]; then
  echo "KiCad is not set up here (no version folder under ~/Library/Preferences/kicad, ~/.config/kicad or the Flatpak's copy), skipped."
  echo "Start KiCad once, quit it, then run this again or pass --config-dir."
  exit 0
fi

# macOS pgrep leaves out its own ancestors unless given -a, so an app whose built-in terminal
# runs this script would look closed. procps pgrep on Linux has no such exclusion and its -a
# means something else
pgrep_flags=()
if [ "$(uname -s)" = Darwin ]; then
  pgrep_flags=(-a)
fi

# KiCad holds its settings in memory and writes every file back on exit, so a change made while
# any of its editors runs is lost
if pgrep ${pgrep_flags[@]+"${pgrep_flags[@]}"} -f 'KiCad/.*\.app/Contents/MacOS/|(^|/)(kicad|eeschema|pcbnew|gerbview|pl_editor|pcb_calculator|bitmap2component)( |$)' >/dev/null 2>&1; then
  echo "KiCad is running. Quit it and every editor it opened, then run this again." >&2
  exit 1
fi

echo "Settings: $config"
python3 - "$shared/colors" "$config" "zacess-$id" <<'PYEOF'
import json, pathlib, sys

source, config, chosen = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
colors = config / "colors"
colors.mkdir(exist_ok=True)
for theme in sorted(source.glob("zacess-*.json")):
    target = colors / theme.name
    text = theme.read_text()
    if not target.exists():
        print(f"  added      colors  {theme.name}")
    elif target.read_text() != text:
        print(f"  changed    colors  {theme.name}")
    else:
        print(f"  unchanged  colors  {theme.name}")
        continue
    target.write_text(text)

touched = 0
for path in sorted(config.glob("*.json")):
    try:
        data = json.loads(path.read_text())
    except ValueError:
        continue
    appearance = data.get("appearance") if isinstance(data, dict) else None
    if not isinstance(appearance, dict) or "color_theme" not in appearance:
        continue
    touched += 1
    if appearance["color_theme"] == chosen:
        print(f"  unchanged  {path.name}  appearance.color_theme")
        continue
    appearance["color_theme"] = chosen
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    print(f"  changed    {path.name}  appearance.color_theme")
if not touched:
    print("  no editor settings yet: start KiCad once, quit it, then run this again")
PYEOF

echo "Theme: zacess-$id"
echo "Done. Start KiCad to pick up the changes. An editor opened for the first time later starts on KiCad's default, so run this again after that."
