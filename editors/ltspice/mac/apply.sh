#!/usr/bin/env bash
# sets the native Mac LTspice's schematic, waveform and netlist colours to one of the Zacess themes.
# usage: apply.sh [--theme <theme>]
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the Mac app (LTspice 17 for macOS) keeps no LTspice.ini: its settings live in the
# com.analog.LTspice.App preferences, under slightly different names. the colours come from the
# same ../shared/themes files as Windows and Linux and are translated here: Grid becomes
# GridColor, InActiveAxis becomes InActiveAxisColor and the five netlist colours become
# NetlistEditorColor0 to 4. SchematicColor13 has no Mac counterpart and is skipped. every other
# preference is left as it was; nothing is backed up.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
theme="deep-dark"
while [ $# -gt 0 ]; do
  case "$1" in
    --theme) theme="${2:?--theme needs a theme name}"; shift 2 ;;
    --theme=*) theme="${1#--theme=}"; shift ;;
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

domain="com.analog.LTspice.App"
if ! defaults read "$domain" >/dev/null 2>&1; then
  echo "No LTspice preferences yet. Start LTspice once, quit it, then run this again." >&2
  exit 1
fi

# LTspice holds its preferences in memory and writes them back when it quits, so a change made
# while it runs is lost
# -a: macOS pgrep leaves out its own ancestors otherwise, so an app whose built-in
# terminal runs this script would look closed
if pgrep -a -f 'LTspice\.app/Contents/MacOS/LTspice' >/dev/null 2>&1; then
  echo "LTspice is running. Quit it first, then run this again." >&2
  exit 1
fi

echo "Settings: ~/Library/Preferences/$domain.plist"
python3 - "$here/../shared/themes/$name.ini" "$domain" <<'PYEOF'
import plistlib, re, subprocess, sys

theme, domain = sys.argv[1], sys.argv[2]
mac_names = {"Grid": "GridColor", "InActiveAxis": "InActiveAxisColor",
             "NetlistNormalTextColor": "NetlistEditorColor0", "NetlistCommentTextColor": "NetlistEditorColor1",
             "NetlistDotcmdTextColor": "NetlistEditorColor2", "ContinuationLineColor": "NetlistEditorColor3",
             "NetlistBackgroundColor": "NetlistEditorColor4"}
skip = {"SchematicColor13"}
# defaults is used rather than the plist file, since cfprefsd caches the file and would overwrite it
current = plistlib.loads(subprocess.run(["defaults", "export", domain, "-"], check=True,
                                        capture_output=True).stdout)
for line in open(theme, encoding="ascii").read().splitlines():
    match = re.fullmatch(r"([A-Za-z0-9]+)=(\d+)", line)
    if not match or match.group(1) in skip:
        continue
    key, value = mac_names.get(match.group(1), match.group(1)), int(match.group(2))
    old = current.get(key)
    status = "added    " if old is None else ("unchanged" if old == value else "changed  ")
    if old != value:
        subprocess.run(["defaults", "write", domain, key, "-int", str(value)], check=True)
    print(f"  {status}  preferences  {key}")
PYEOF
echo "Theme: $name"
echo "Done. Start LTspice to pick up the changes."
