#!/usr/bin/env bash
#
# offline tests for mac/defaults.sh. `defaults` and `killall` are stubs: `defaults` keeps its values
# in a small file, so capture and apply run end to end without touching the Mac. Runs on the stock
# macOS bash 3.2 and on Linux.

set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly SCRIPT="$REPO_ROOT/mac/defaults.sh"
WORK_DIR="$(mktemp -d)"
readonly WORK_DIR
trap 'rm -rf "$WORK_DIR"' EXIT

TESTS_RUN=0
pass() { TESTS_RUN=$((TESTS_RUN + 1)); printf 'ok %d - %s\n' "$TESTS_RUN" "$1"; }
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }
assert_contains() { [[ "$2" == *"$1"* ]] || fail "${3:-output} should contain: $1"; }
assert_not_contains() { [[ "$2" != *"$1"* ]] || fail "${3:-output} should not contain: $1"; }

STUBS="$WORK_DIR/bin"
HOME_DIR="$WORK_DIR/home"
CALLS="$WORK_DIR/calls.log"
DB="$WORK_DIR/defaults.db"
mkdir -p "$STUBS" "$HOME_DIR"

# defaults keeps "domain|key|type|value" lines; write can be told to refuse one domain
cat > "$STUBS/defaults" <<EOF
#!/bin/bash
db="$DB"
touch "\$db"
printf 'defaults %s\n' "\$*" >> "$CALLS"
case "\$1" in
    read-type)
        line=\$(grep -F "\$2|\$3|" "\$db" | tail -1) || exit 1
        [ -n "\$line" ] || exit 1
        echo "Type is \$(echo "\$line" | cut -d'|' -f3)" ;;
    read)
        line=\$(grep -F "\$2|\$3|" "\$db" | tail -1) || exit 1
        [ -n "\$line" ] || exit 1
        echo "\$line" | cut -d'|' -f4- ;;
    write)
        [ "\$2" = "\${DEFAULTS_REFUSE:-none}" ] && exit 1
        d="\$2"; k="\$3"
        case "\$4" in
            -bool) t=boolean; v="\$5" ;;
            -int) t=integer; v="\$5" ;;
            -float) t=float; v="\$5" ;;
            -dict)
                # stored the way defaults read prints a dictionary, on one line
                t=dictionary; shift 4; v="{"
                while [ \$# -gt 0 ]; do n="\$1"; shift; [ "\$1" = -float ] && shift; v="\$v \$n = \$1;"; shift; done
                v="\$v }" ;;
            *) t=string; v="\$5" ;;
        esac
        grep -v -F "\$d|\$k|" "\$db" > "\$db.tmp" || true
        mv "\$db.tmp" "\$db"
        echo "\$d|\$k|\$t|\$v" >> "\$db" ;;
esac
EOF
printf '#!/bin/bash\nprintf "killall %%s\\n" "$*" >> "%s"\n' "$CALLS" > "$STUBS/killall"
chmod +x "$STUBS/defaults" "$STUBS/killall"

VALUES="$WORK_DIR/defaults.tsv"
run() {
    : > "$CALLS"
    PATH="$STUBS:/usr/bin:/bin" HOME="$HOME_DIR" \
    DEFAULTS_TRACKED_FILE="$REPO_ROOT/mac/tracked.txt" DEFAULTS_VALUES_FILE="$VALUES" \
        /bin/bash "$SCRIPT" "$@"
}

printf '%s\n' \
    "com.apple.dock|autohide|boolean|1" \
    "com.apple.dock|tilesize|float|48" \
    "com.apple.screencapture|location|string|~/Pictures/Shots" \
    "com.apple.universalaccess|increaseContrast|boolean|1" > "$DB"

run --capture >/dev/null
captured="$(cat "$VALUES")"
[[ "$(head -1 "$VALUES")" == "$(printf 'domain\tkey\ttype\tvalue')" ]] || fail "the file should start with a header row"
assert_contains "$(printf 'com.apple.dock\tautohide\tboolean\t1')" "$captured" "capture"
assert_contains "$(printf 'com.apple.dock\ttilesize\tfloat\t48')" "$captured" "capture"
assert_not_contains "show-recents" "$captured" "capture"
pass "capture records only keys that are set, with their types, under a header row"

run >/dev/null
assert_not_contains "defaults write" "$(cat "$CALLS")" "calls"
assert_not_contains "killall" "$(cat "$CALLS")" "calls"
pass "applying on the Mac it came from writes nothing and restarts nothing"

printf '%s\n' "com.apple.screencapture|location|string|$HOME_DIR/Pictures/Shots" "com.apple.dock|autohide|boolean|1" "com.apple.dock|tilesize|float|48" "com.apple.universalaccess|increaseContrast|boolean|1" > "$DB"
run >/dev/null
assert_not_contains "defaults write com.apple.screencapture" "$(cat "$CALLS")" "calls"
pass "a path stored with ~ and the same path spelt out count as equal"

: > "$DB"
run >/dev/null
calls="$(cat "$CALLS")"
assert_contains "defaults write com.apple.dock tilesize -float 48" "$calls" "calls"
assert_contains "killall Dock" "$calls" "calls"
[[ -d "$HOME_DIR/Pictures/Shots" ]] || fail "the screenshot folder was not created"
pass "a fresh Mac gets every captured setting, the screenshot folder and a Dock restart"

: > "$DB"
output="$(DEFAULTS_REFUSE=com.apple.universalaccess run 2>&1)"
assert_contains "com.apple.universalaccess increaseContrast = 1" "$output"
assert_contains "System Settings" "$output"
pass "settings macOS refuses are listed for System Settings instead of failing the run"

printf '%s\n' 'com.apple.universalaccess|cursorFill|dictionary|{ alpha = 1; blue = 0; green = "0.98"; red = "0.99"; }' > "$DB"
run --capture >/dev/null
assert_contains "$(printf 'com.apple.universalaccess\tcursorFill\tcolour\t0.99 0.98 0 1')" "$(cat "$VALUES")" "capture"
pass "a colour dictionary is captured as red, green, blue and alpha on one line"

run >/dev/null
assert_not_contains "defaults write" "$(cat "$CALLS")" "calls"
: > "$DB"
run >/dev/null
assert_contains "defaults write com.apple.universalaccess cursorFill -dict red -float 0.99 green -float 0.98 blue -float 0 alpha -float 1" "$(cat "$CALLS")" "calls"
pass "a colour matching the Mac is left alone and a missing one is written as a typed dictionary"

: > "$DB"
output="$(DEFAULTS_REFUSE=com.apple.universalaccess run 2>&1)"
assert_contains "cursorFill = 0.99 0.98 0 1 (red green blue alpha)" "$output"
pass "a refused colour is listed for System Settings with its channels named"

awk -F'\t' 'NR > 1 && NF && (NF != 4 || $3 !~ /^(boolean|integer|float|string|colour)$/) { bad = 1 } END { exit bad }' "$REPO_ROOT/mac/defaults.tsv" \
    || fail "mac/defaults.tsv has a malformed row"
pass "the committed mac/defaults.tsv has four valid fields on every row"

printf '\nAll %d tests passed.\n' "$TESTS_RUN"
