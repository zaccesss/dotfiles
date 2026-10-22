#!/usr/bin/env bash
# installs the Zacess Xcode themes, the key bindings file and the recorded
# Xcode preferences, then prints what changed.
# usage: apply.sh [--dry-run]
#
# everything comes from this folder: the themes from theme/, the key bindings
# from KeyBindings/ and the preferences from prefs.txt, so no other clone is
# needed. --dry-run prints what would change and writes nothing.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
prefs="$here/prefs.txt"
themes="$here/theme"
bindings="$here/KeyBindings"
dry_run=0
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run|-n) dry_run=1; shift ;;
    -h|--help) sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

domain="com.apple.dt.Xcode"
userdata="$HOME/Library/Developer/Xcode/UserData"
changes=0

# xcode holds its preferences in memory and writes them back while it runs,
# so a value set now could be overwritten the moment it saves. a dry run
# writes nothing, so it may run alongside xcode. -a: macOS pgrep leaves out its own ancestors
# otherwise, so run from a terminal inside Xcode it would report Xcode as closed
if [ "$dry_run" -eq 0 ] && pgrep -a -x Xcode >/dev/null 2>&1; then
  echo "Xcode is running. Quit it first, then run this again." >&2
  exit 1
fi

# copy_file <source> <target folder>: copies one file and reports whether it
# was added, changed or already the same
copy_file() {
  local source="$1" target state
  target="$2/$(basename "$1")"
  if [ ! -e "$target" ]; then
    state="added"
  elif ! cmp -s "$source" "$target"; then
    state="changed"
  else
    echo "  unchanged  $(basename "$target")"
    return
  fi
  if [ "$dry_run" -eq 0 ]; then
    mkdir -p "$2"
    cp "$source" "$target"
  fi
  printf '  %-10s %s\n' "$state" "$(basename "$target")"
  changes=$((changes + 1))
}

# the eight classic .xccolortheme files sit beside the .xcworkspacecolortheme
# that xcode 27 writes when one of them is imported, so a new mac needs no
# manual import for the theme recorded in DVTWorkspaceThemeSettings
echo "Themes"
for file in "$themes"/*.xccolortheme "$themes"/*.xcworkspacecolortheme; do
  [ -f "$file" ] || continue
  copy_file "$file" "$userdata/FontAndColorThemes"
done

echo "Key bindings"
for file in "$bindings"/*.idekeybindings; do
  [ -f "$file" ] || continue
  copy_file "$file" "$userdata/KeyBindings"
done

# the domain is saved before the first write, so any change can be undone with
# defaults import
backup=""
backup_domain() {
  [ -n "$backup" ] && return
  mkdir -p "$userdata/Backups"
  backup="$userdata/Backups/$domain-$(date +%Y%m%d-%H%M%S).plist"
  defaults export "$domain" "$backup" 2>/dev/null || true
  echo "  backed up the current preferences to $backup"
}

echo "Preferences"
while read -r type key value; do
  case "$type" in ''|'#'*) continue ;; esac
  case "$type" in
    string|bool|int|data) ;;
    *) echo "  $key: unknown type $type in prefs.txt" >&2; exit 1 ;;
  esac
  if [ "$type" = data ]; then
    # defaults shortens data when it prints it, so the full value is read back
    # through plutil as hex
    current="$(defaults export "$domain" - 2>/dev/null | plutil -extract "$key" raw -o - - 2>/dev/null | base64 -d 2>/dev/null | xxd -p | tr -d '\n' || true)"
  else
    current="$(defaults read "$domain" "$key" 2>/dev/null || true)"
  fi
  want="$value"
  # defaults prints a boolean as 1 or 0 but writes it from true or false
  if [ "$type" = bool ]; then
    case "$value" in
      true) want=1 ;;
      false) want=0 ;;
      *) echo "  $key: $value is not true or false" >&2; exit 1 ;;
    esac
  fi
  if [ "$current" = "$want" ]; then
    echo "  unchanged  $key"
    continue
  fi
  if [ "$dry_run" -eq 0 ]; then
    backup_domain
    defaults write "$domain" "$key" "-$type" "$value"
  fi
  if [ "$type" = data ]; then
    if [ -n "$current" ]; then was="a different value"; else was="unset"; fi
    echo "  set        $key (was $was)"
  else
    echo "  set        $key = $value (was ${current:-unset})"
  fi
  changes=$((changes + 1))
done < "$prefs"

if [ "$changes" -eq 0 ]; then
  echo "Xcode matches the recorded setup."
elif [ "$dry_run" -eq 1 ]; then
  echo "Dry run: $changes change(s) would be made. Nothing was written."
else
  echo "Done: $changes change(s). Start Xcode to pick them up."
fi
