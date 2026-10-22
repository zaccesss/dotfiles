#!/usr/bin/env bash
# installs the eight Zacess themes for Nextpad++ and makes one of them the active theme.
# usage: apply.sh [--theme <theme>]
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# Nextpad++ reads extra themes from ~/.nextpad++/themes and keeps the active one, by name, in its
# own preferences (org.nextpadplusplus.mac). colour and font overrides made in its Style
# Configurator for the Default Style sit on top of any theme and would hide it, so those three
# are cleared; every other override, the text size included, is kept. the editor font becomes
# GeistMono Nerd Font Mono. nothing is backed up: the repo holds every value this writes.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shared="$here/../shared"
domain="org.nextpadplusplus.mac"
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

if [ ! -d "/Applications/Nextpad++.app" ] && [ ! -d "$HOME/Applications/Nextpad++.app" ]; then
  echo "Nextpad++ is not installed, skipped."
  exit 0
fi

# Nextpad++ writes its preferences back while it runs, so the active theme only changes while it
# is closed
# -a: macOS pgrep leaves out its own ancestors otherwise, so an app whose built-in
# terminal runs this script would look closed
if pgrep -a -f 'Nextpad\+\+\.app/Contents/MacOS/' >/dev/null 2>&1; then
  echo "Nextpad++ is running. Quit it first, then run this again." >&2
  exit 1
fi

themes="$HOME/.nextpad++/themes"
mkdir -p "$themes"
for file in "$shared"/themes/Zacess*.xml; do
  target="$themes/$(basename "$file")"
  if [ ! -f "$target" ]; then
    echo "  added      themes  $(basename "$file")"
  elif ! cmp -s "$file" "$target"; then
    echo "  changed    themes  $(basename "$file")"
  else
    echo "  unchanged  themes  $(basename "$file")"
    continue
  fi
  cp "$file" "$target"
done

current="$(defaults read "$domain" NPPActiveTheme 2>/dev/null || true)"
if [ "$current" = "$name" ]; then
  echo "  unchanged  preferences  NPPActiveTheme"
else
  defaults write "$domain" NPPActiveTheme -string "$name"
  echo "  changed    preferences  NPPActiveTheme"
fi

# defaults cannot delete one entry of a dictionary, so the preferences are exported, edited and
# imported whole: the Default Style's colour and font overrides go and the editor font (kept on
# its own as styleFontName) becomes Geist Mono
python3 - "$domain" "GeistMono Nerd Font Mono" <<'PYEOF'
import plistlib, subprocess, sys

domain, font = sys.argv[1], sys.argv[2]
prefs = plistlib.loads(subprocess.run(["defaults", "export", domain, "-"], capture_output=True, check=True).stdout)
changed = False
overrides = prefs.get("NPPStyleOverrides") or {}
for key in ("global|Default Style|fg", "global|Default Style|bg", "global|Default Style|fontName"):
    if key in overrides:
        del overrides[key]
        changed = True
        print(f"  removed    preferences  NPPStyleOverrides {key}")
if "NPPStyleOverrides" in prefs:
    prefs["NPPStyleOverrides"] = overrides
if prefs.get("styleFontName") == font:
    print("  unchanged  preferences  styleFontName")
else:
    prefs["styleFontName"] = font
    changed = True
    print("  changed    preferences  styleFontName")
if changed:
    subprocess.run(["defaults", "import", domain, "-"], input=plistlib.dumps(prefs), check=True)
PYEOF

echo "Theme: $name"
echo "Done. Start Nextpad++ to pick up the changes."
