#!/usr/bin/env bash
# sets up Obsidian with the Zacess theme in one vault and opens that vault by default.
# usage: apply.sh [--theme <theme>] [vault folder]
#   (the vault defaults to OBSIDIAN_VAULT, the same variable zt reads)
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark. the work is done by ../shared/apply.py; nothing is backed up. the vault list is
# ~/.config/obsidian/obsidian.json (the Flatpak's copy when md.obsidian.Obsidian is installed).
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

vault="${1:-${OBSIDIAN_VAULT:-}}"
if [ -z "$vault" ]; then
  echo "Name the vault: pass its folder or set OBSIDIAN_VAULT, for example ~/Documents/MyVault." >&2
  exit 1
fi
list="$HOME/.config/obsidian/obsidian.json"
if [ -d "$HOME/.var/app/md.obsidian.Obsidian" ]; then
  list="$HOME/.var/app/md.obsidian.Obsidian/config/obsidian/obsidian.json"
fi

# Obsidian writes appearance.json and obsidian.json back while it runs
if pgrep -x obsidian >/dev/null 2>&1 || pgrep -f 'md\.obsidian\.Obsidian' >/dev/null 2>&1; then
  echo "Obsidian is running. Quit it first, then run this again." >&2
  exit 1
fi

python3 -B "$here/../shared/apply.py" "$name" "$vault" "$list"
echo "Done. Start Obsidian to pick up the changes."
