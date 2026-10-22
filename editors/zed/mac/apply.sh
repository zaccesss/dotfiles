#!/usr/bin/env bash
# installs the Zacess theme file into Zed's themes folder and sets the theme in settings.json.
# usage: apply.sh [--theme <theme>] [--config-dir <dir>]
#   (the config folder defaults to ~/.config/zed or $XDG_CONFIG_HOME/zed when that is set; Linux also checks the
#   Flatpak's copy)
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the work is done by ../shared/apply.py with the system python3. it reuses shell/scripts/zt.py
# for the theme block and the JSON-with-comments editing, so a linked settings.json keeps its
# comments and layout and zt and this write the same value. the tracked settings.json itself is
# linked or copied into place (the Mac bootstrap's configs stage links it), never replaced here.
#
# Zed reloads its settings and themes while it runs, so unlike the other apply scripts this one
# never checks whether Zed is open.
#
# mac/apply.sh and linux/apply.sh are the same file.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# run from / so a folder named zt in the current directory is never imported instead of zt.py
cd /
exec python3 -B "$here/../shared/apply.py" "$@"
