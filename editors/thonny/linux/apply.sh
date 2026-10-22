#!/usr/bin/env bash
# installs the Zacess themes into Thonny and sets its theme, font and editor settings.
# usage: apply.sh [--theme <theme>]
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the work is done by ../shared/apply.py run with the Python that has Thonny installed (the
# system one for a dnf or apt install, the Flatpak's own for org.thonny.Thonny), which knows where
# that Thonny reads plugins and settings. only the tracked [view] keys and the interpreter change;
# nothing is backed up.
#
# Thonny runs code in its own virtual environment, ~/.venvs/thonny, so packages from
# Tools > Manage packages stay out of the system Python. it is made only when it is missing, with
# uv when it is installed (Python 3.15), otherwise python3.15 or python3. it is never rebuilt. the
# Flatpak's sandbox cannot run a Python from outside it, so a Flatpak Thonny keeps its own.
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

# Thonny writes configuration.ini back when it exits, so a change made while it runs is lost.
# the pattern names Thonny's own launchers, since a bare "thonny" would match this script's path
if pgrep -f 'python3? .*-m thonny|/bin/thonny( |$)|org\.thonny\.Thonny' >/dev/null 2>&1; then
  echo "Thonny is running. Quit it first, then run this again." >&2
  exit 1
fi

# checked from / so a folder named thonny in the current directory is not mistaken for Thonny.
# apt and dnf put Thonny in the distribution's Python, which is no longer the python3 on PATH once
# uv's Python comes first (the bootstrap makes it the default), so /usr/bin/python3 is tried too
thonny_python=""
for candidate in python3 /usr/bin/python3; do
  if (cd / && "$candidate" -c 'import thonny.misc_utils') >/dev/null 2>&1; then
    thonny_python="$candidate"
    break
  fi
done
if [ -n "$thonny_python" ]; then
  venv="$HOME/.venvs/thonny"
  if [ -x "$venv/bin/python3" ]; then
    echo "  unchanged  venv  $venv"
  elif command -v uv >/dev/null 2>&1; then
    uv venv --quiet --seed --python 3.15 "$venv"
    echo "  added      venv  $venv"
  else
    base="$(command -v python3.15 || command -v python3)"
    "$base" -m venv --upgrade-deps "$venv"
    echo "  added      venv  $venv"
  fi
  (cd / && "$thonny_python" -B "$here/../shared/apply.py" "$here/settings.json" --theme "$name" --interpreter "$venv/bin/python3")
elif command -v flatpak >/dev/null 2>&1 && flatpak info org.thonny.Thonny >/dev/null 2>&1; then
  flatpak run --command=python3 org.thonny.Thonny -B "$here/../shared/apply.py" "$here/settings.json" --theme "$name"
else
  echo "No Thonny found. Install it (sudo apt install thonny, sudo dnf install thonny or the org.thonny.Thonny Flatpak), start it once, then run this again." >&2
  exit 1
fi
echo "Done. Start Thonny to pick up the changes."
