#!/usr/bin/env bash
# merges the tracked STM32CubeIDE preferences into one workspace's instance scope.
# usage: apply.sh [--theme <theme> | --no-theme] [workspace]
#   (defaults to the newest ~/STM32CubeIDE/workspace_<version> that STM32CubeIDE has opened)
#
# --theme merges one of the eight Zacess themes from ../shared/theme (editor, C
# syntax and Terminal colours, plus the tab outlines for the two Deep Contrast
# themes) and sets the matching Light or Dark workbench theme. It takes a short
# name (deep-dark, deep-light, hc-dark, hc-light, dark, light, cream, yellow),
# an id (deep-contrast-dark) or the full name. the default is deep-dark.
#
# mac/apply.sh and linux/apply.sh are the same file. the values live in
# ../shared/prefs, plus an optional prefs/ folder next to this script for keys
# that only hold on one platform (its font strings), so no value is written
# out in more than one place. nothing is backed up: the repo holds every value
# it writes. every key it does not track is left as it was.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shared="$here/../shared/prefs"
themes="$here/../shared/theme"
overlay="$here/prefs"
theme="deep-dark"
while [ $# -gt 0 ]; do
  case "$1" in
    --theme) theme="${2:?--theme needs a theme name}"; shift 2 ;;
    --theme=*) theme="${1#--theme=}"; shift ;;
    --no-theme) theme=""; shift ;;
    *) break ;;
  esac
done

# STM32CubeIDE names its default workspace after its own version, so the newest
# one it has opened is the one in use
workspace="${1:-}"
if [ -z "$workspace" ]; then
  for candidate in "$HOME"/STM32CubeIDE/workspace_*; do
    [ -d "$candidate/.metadata" ] || continue
    if [ -z "$workspace" ] || [ "$candidate" -nt "$workspace" ]; then
      workspace="$candidate"
    fi
  done
  if [ -z "$workspace" ]; then
    echo "No STM32CubeIDE workspace under $HOME/STM32CubeIDE." >&2
    echo "Start STM32CubeIDE once, quit it, then run this again or pass the workspace path." >&2
    exit 1
  fi
fi

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

# STM32CubeIDE holds these files in memory and writes them back on exit, so a
# merge made while it runs is silently lost
if pgrep ${pgrep_flags[@]+"${pgrep_flags[@]}"} -ix stm32cubeide >/dev/null 2>&1; then
  echo "STM32CubeIDE is running. Quit it first, then run this again." >&2
  exit 1
fi

# a mistyped path would otherwise create a stray workspace, so the workspace
# must already have been opened by STM32CubeIDE once
if [ ! -d "$workspace/.metadata" ]; then
  echo "No STM32CubeIDE workspace at $workspace (no .metadata folder)." >&2
  echo "Start STM32CubeIDE once with that workspace, quit it, then run this again." >&2
  exit 1
fi

mkdir -p "$settings"
echo "Workspace: $workspace"

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

for fragment in "$shared"/*.prefs "$overlay"/*.prefs; do
  [ -f "$fragment" ] || continue
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
  echo "Theme: $name with the ${mode} workbench theme"
fi

echo "Done. Start STM32CubeIDE to pick up the changes."
