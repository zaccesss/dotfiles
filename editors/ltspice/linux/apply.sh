#!/usr/bin/env bash
# sets LTspice's schematic, waveform and netlist colours to one of the Zacess themes.
# usage: apply.sh [--theme <theme>] [LTspice ini file]
#   (on Linux LTspice runs under Wine, so the ini defaults to the Wine prefix's
#   AppData/Roaming/LTspice.ini (LTspiceXVII.ini from older versions))
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark. the work is done by ../shared/apply.py; nothing is backed up.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
theme="deep-dark"
while [ $# -gt 0 ]; do
  case "$1" in
    --theme) theme="${2:?--theme needs a theme name}"; shift 2 ;;
    --theme=*) theme="${1#--theme=}"; shift ;;
    *) break ;;
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

ini="${1:-}"
if [ -z "$ini" ]; then
  roaming="${WINEPREFIX:-$HOME/.wine}/drive_c/users/$USER/AppData/Roaming"
  for candidate in "$roaming/LTspice.ini" "$roaming/LTspiceXVII.ini"; do
    if [ -f "$candidate" ]; then ini="$candidate"; break; fi
  done
fi
if [ -z "$ini" ] || [ ! -f "$ini" ]; then
  echo "No LTspice.ini found in the Wine prefix. Start LTspice once, quit it, then run this again or pass the ini path." >&2
  exit 1
fi

# LTspice writes its ini back when it exits, so a change made while it runs is lost. under Wine
# its process keeps the Windows name; a looser match would find this script's own path
if pgrep -ix 'ltspice\.exe|xviix64\.exe|xviix86\.exe' >/dev/null 2>&1; then
  echo "LTspice is running. Quit it first, then run this again." >&2
  exit 1
fi

python3 -B "$here/../shared/apply.py" "$name" "$ini"
echo "Done. Start LTspice to pick up the changes."
