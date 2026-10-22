#!/usr/bin/env bash
# installs the Zacess themes into Thonny and sets its theme, font and editor settings.
# usage: apply.sh [--theme <theme>] [path to Thonny.app]
#   (the app defaults to /Applications/Thonny.app, then ~/Applications/Thonny.app)
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the work is done by ../shared/apply.py run with the Python bundled inside Thonny.app, which
# imports thonny and so knows where that Thonny reads plugins and settings
# (~/Library/Thonny). only the tracked [view] keys and the interpreter change; nothing is backed up.
#
# Thonny runs code in its own virtual environment, ~/.venvs/thonny, so packages from
# Tools > Manage packages stay out of the system Python. it is made from Homebrew's python@3.15
# only when it is missing. it is never rebuilt.
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

app="${1:-}"
if [ -z "$app" ]; then
  for candidate in /Applications/Thonny.app "$HOME/Applications/Thonny.app"; do
    if [ -d "$candidate" ]; then app="$candidate"; break; fi
  done
fi
python="${app:+$app/Contents/Frameworks/Python.framework/Versions/Current/bin/python3}"
if [ -z "$python" ] || [ ! -x "$python" ]; then
  echo "No Thonny.app found. Install it (brew install --cask thonny), start it once, then run this again or pass the app's path." >&2
  exit 1
fi

# Thonny writes configuration.ini back when it exits, so a change made while it runs is lost.
# the pattern names the app's own bundle, since a bare "thonny" would match this script's path
# -a: macOS pgrep leaves out its own ancestors otherwise, so an app whose built-in
# terminal runs this script would look closed
if pgrep -a -f 'Thonny\.app/Contents/' >/dev/null 2>&1; then
  echo "Thonny is running. Quit it first, then run this again." >&2
  exit 1
fi

venv="$HOME/.venvs/thonny"
if [ -x "$venv/bin/python3" ]; then
  echo "  unchanged  venv  $venv"
else
  base=""
  if command -v brew >/dev/null 2>&1 && [ -x "$(brew --prefix python@3.15 2>/dev/null)/bin/python3.15" ]; then
    base="$(brew --prefix python@3.15)/bin/python3.15"
  fi
  if [ -z "$base" ]; then
    echo "No Python 3.15 for the Thonny venv. Install it with: brew install python@3.15" >&2
    exit 1
  fi
  "$base" -m venv --upgrade-deps "$venv"
  echo "  added      venv  $venv"
fi

# run from / so a folder named thonny in the current directory is not imported instead
(cd / && "$python" -B "$here/../shared/apply.py" "$here/settings.json" --theme "$name" --interpreter "$venv/bin/python3")
echo "Done. Start Thonny to pick up the changes."
