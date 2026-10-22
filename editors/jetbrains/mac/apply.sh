#!/usr/bin/env bash
# installs the Zacess Themes plugin into every JetBrains IDE, applies the tracked settings and sets
# the theme.
# usage: apply.sh [--theme <theme>] [--config-dir <JetBrains config root>]
#   (the root defaults to ~/Library/Application Support/JetBrains on the Mac and ~/.config/JetBrains
#   on Linux or $XDG_CONFIG_HOME/JetBrains when that is set)
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the work is done by ../shared/apply.py with the system python3: the theme plugin through each
# IDE's own installPlugins command (or the pinned release in ../shared/theme-package.json), the
# colour schemes, file template, keymap and fonts in this folder copied in, laf.xml and
# colors.scheme.xml written by shell/scripts/zt.py's own function and new projects pointed at
# ~/dev/projects. only those files change; nothing is backed up: the repo holds every value this
# writes.
#
# the IDEs write their settings back on exit, so the script refuses to run while one is open.
#
# mac/apply.sh and linux/apply.sh are the same file.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# run from / so a folder named zt in the current directory is never imported instead of zt.py
cd /
exec python3 -B "$here/../shared/apply.py" "$@"
