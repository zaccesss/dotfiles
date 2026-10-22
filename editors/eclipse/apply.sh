#!/usr/bin/env bash
# merges the tracked Eclipse preferences into one workspace's instance scope.
# usage: apply.sh [--theme <theme> | --no-theme] [workspace]   (defaults to ~/eclipse-workspace)
#
# --theme imports one of the eight Zacess themes from theme/ (editor
# and Terminal view colours, plus the tab outlines for the two Deep Contrast
# themes) and sets the matching Light or Dark workbench theme. It takes a short
# name (deep-dark, deep-light, hc-dark, hc-light, dark, light, cream, yellow),
# an id (deep-contrast-dark) or the full name. the default is deep-dark.
#
# the values live in prefs/, which apply.ps1 reads too, so no value is written
# out in more than one place. nothing is backed up: the repo holds every value
# it writes. every key it does not track is left as it was.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
prefs="$here/prefs"
themes="$here/theme"
theme="deep-dark"
while [ $# -gt 0 ]; do
  case "$1" in
    --theme) theme="${2:?--theme needs a theme name}"; shift 2 ;;
    --theme=*) theme="${1#--theme=}"; shift ;;
    --no-theme) theme=""; shift ;;
    *) break ;;
  esac
done
workspace="${1:-$HOME/eclipse-workspace}"

# theme_name <short name, id or full name>: prints the theme's full name and
# whether it is dark. a name it does not know fails
theme_name() {
  local key
  key="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/^zacess[ -]//' -e 's/ /-/g')"
  case "$key" in
    deep-dark|deep-contrast-dark) echo "Zacess Deep Contrast Dark|dark" ;;
    deep-light|deep-contrast-light) echo "Zacess Deep Contrast Light|light" ;;
    hc-dark|high-contrast-dark) echo "Zacess High Contrast Dark|dark" ;;
    hc-light|high-contrast-light) echo "Zacess High Contrast Light|light" ;;
    dark) echo "Zacess Dark|dark" ;;
    light) echo "Zacess Light|light" ;;
    cream) echo "Zacess Cream|light" ;;
    yellow|yellow-on-black) echo "Zacess Yellow on Black|dark" ;;
    *) return 1 ;;
  esac
}

if [ -n "$theme" ]; then
  if ! picked="$(theme_name "$theme")"; then
    echo "Unknown theme: $theme" >&2
    echo "Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow." >&2
    exit 1
  fi
fi
settings="$workspace/.metadata/.plugins/org.eclipse.core.runtime/.settings"

# macOS pgrep leaves out its own ancestors unless given -a, so an app whose built-in terminal
# runs this script would look closed. procps pgrep on Linux has no such exclusion and its -a
# means something else
pgrep_flags=()
if [ "$(uname -s)" = Darwin ]; then
  pgrep_flags=(-a)
fi

# eclipse holds these files in memory and writes them back on exit, so a merge
# made while it runs is silently lost
if pgrep ${pgrep_flags[@]+"${pgrep_flags[@]}"} -x eclipse >/dev/null 2>&1; then
  echo "Eclipse is running. Quit it first, then run this again." >&2
  exit 1
fi

# a mistyped path would otherwise create a stray workspace, so the workspace
# must already have been opened by eclipse once
if [ ! -d "$workspace/.metadata" ]; then
  echo "No Eclipse workspace at $workspace (no .metadata folder)." >&2
  echo "Start Eclipse once with that workspace, quit it, then run this again." >&2
  exit 1
fi

mkdir -p "$settings"

# merge_file <fragment> <target>: replaces or appends each key=value line from
# the fragment and leaves every other line of the target alone. awk reads both
# files directly, so the backslashes in the key binding XML are never
# reinterpreted.
merge_file() {
  local fragment="$1" target="$2" tmp
  tmp="$(mktemp)"
  [ -f "$target" ] || printf 'eclipse.preferences.version=1\n' > "$target"
  awk -v name="$(basename "$target")" '
    function key(line) { return substr(line, 1, index(line, "=") - 1) }
    NR == FNR {
      if ($0 ~ /^[[:space:]]*(#|$)/) next
      k = key($0)
      if (!(k in want)) order[++n] = k
      want[k] = $0
      next
    }
    {
      k = index($0, "=") ? key($0) : ""
      if (k != "" && (k in want)) {
        if (k in done) next
        if ($0 == want[k]) print "  unchanged  " name "  " k > "/dev/stderr"
        else print "  changed    " name "  " k > "/dev/stderr"
        print want[k]
        done[k] = 1
        next
      }
      print
    }
    END {
      for (i = 1; i <= n; i++) {
        if (!(order[i] in done)) {
          print "  added      " name "  " order[i] > "/dev/stderr"
          print want[order[i]]
        }
      }
    }
  ' "$fragment" "$target" > "$tmp"
  # writing through the existing file keeps its permissions, where mv would
  # carry over mktemp's owner-only mode
  cmp -s "$tmp" "$target" || cat "$tmp" > "$target"
  rm -f "$tmp"
}

for fragment in "$prefs"/*.prefs; do
  merge_file "$fragment" "$settings/$(basename "$fragment")"
done

# an .epf file is what File > Import > Preferences reads: one
# /instance/<plugin>/<key>=<value> line per preference. each line goes into
# that plugin's fragment, then merges like the tracked prefs above
if [ -n "$theme" ]; then
  name="${picked%|*}"
  mode="${picked#*|}"
  split="$(mktemp -d)"
  for epf in "$themes/$name.epf" "$themes/$name borders.epf"; do
    [ -f "$epf" ] || continue
    awk -v dir="$split" '
      /^\/instance\// {
        rest = substr($0, 11)
        slash = index(rest, "/")
        print substr(rest, slash + 1) >> (dir "/" substr(rest, 1, slash - 1) ".prefs")
      }
    ' "$epf"
  done
  if [ "$mode" = dark ]; then
    echo "themeid=org.eclipse.e4.ui.css.theme.e4_dark" > "$split/org.eclipse.e4.ui.css.swt.theme.prefs"
  else
    echo "themeid=org.eclipse.e4.ui.css.theme.e4_default" > "$split/org.eclipse.e4.ui.css.swt.theme.prefs"
  fi
  for fragment in "$split"/*.prefs; do
    merge_file "$fragment" "$settings/$(basename "$fragment")"
  done
  rm -rf "$split"
  echo "Theme: $name with Eclipse's ${mode} workbench theme"
fi

echo "Done. Start Eclipse to pick up the changes."
