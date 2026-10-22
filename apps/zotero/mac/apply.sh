#!/usr/bin/env bash
# sets Zotero's light or dark mode, reader theme and text size to match one of the Zacess themes.
# usage: apply.sh [--theme <theme>] [profile folder]
#   (the profile defaults to the one under ~/Library/Application Support/Zotero/Profiles)
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

# Zotero rewrites prefs.js when it exits, so a change made while it runs is lost
# -a: macOS pgrep leaves out its own ancestors otherwise, so an app whose built-in
# terminal runs this script would look closed
if pgrep -a -f 'Zotero\.app/Contents/MacOS/zotero' >/dev/null 2>&1; then
  echo "Zotero is running. Quit it first, then run this again." >&2
  exit 1
fi

python3 -B "$here/../shared/apply.py" "$name" "$@"
echo "Done. Start Zotero to pick up the changes."
