#!/usr/bin/env bash
#
# macOS preferences, captured from a Mac as they really are and replayed on the next one.
#
#   bash mac/defaults.sh             apply defaults.tsv, writing only values that differ
#   bash mac/defaults.sh --capture   record this Mac's values for the keys in tracked.txt
#
# Nothing is hard-coded: tracked.txt names the keys and defaults.tsv holds the values a real Mac
# has. A setting chosen on purpose (contrast, pointer size, input behaviour) therefore comes across
# exactly as chosen. A key nobody set is left at the system default. Written for the bash 3.2 that
# ships with macOS, since it runs on a new Mac before Homebrew exists.

set -Eeuo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACKED_FILE="${DEFAULTS_TRACKED_FILE:-$HERE/tracked.txt}"
VALUES_FILE="${DEFAULTS_VALUES_FILE:-$HERE/defaults.tsv}"

info() { printf '[INFO] %s\n' "$*"; }
ok() { printf '[ OK ] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*" >&2; }

# maps the type `defaults read-type` reports to the flag `defaults write` takes. Lists and general
# dictionaries are left out on purpose: none of the tracked keys use them and replaying them would
# need per-key care. Colour dictionaries are the one exception, handled by colour_of below
type_flag() {
    case "$1" in
        boolean) printf -- '-bool\n' ;;
        integer) printf -- '-int\n' ;;
        float) printf -- '-float\n' ;;
        string) printf -- '-string\n' ;;
        *) return 1 ;;
    esac
}

# a colour such as the pointer fill is a dictionary of red, green, blue and alpha. It is stored as
# those four numbers in that order, so the values file stays one line per setting. Any other
# dictionary fails here and is skipped
colour_of() {
    tr ';{}' '\n  ' | awk -F'=' '
        { gsub(/[ "\t]/, "", $1); gsub(/[ "\t]/, "", $2) }
        $1 == "red" { r = $2 } $1 == "green" { g = $2 } $1 == "blue" { b = $2 } $1 == "alpha" { a = $2 }
        END { if (r == "" || g == "" || b == "" || a == "") exit 1; print r " " g " " b " " a }'
}

# `defaults read` prints booleans as 1 and 0, which `defaults write -bool` accepts back as is
capture() {
    local domain key value kind count=0
    local tmp
    tmp="$(mktemp)"

    # a plain header row and no comments, so GitHub shows the file as a searchable table
    printf 'domain\tkey\ttype\tvalue\n' > "$tmp"

    while read -r domain key; do
        [[ -z "$domain" || "$domain" == \#* ]] && continue

        # a key that is not set makes read-type fail, which only means there is nothing to record.
        # The failure is absorbed inside the substitution because bash 3.2 fires the ERR trap there
        # even when the caller handles it
        kind="$(defaults read-type "$domain" "$key" 2>/dev/null || true)"
        [[ -n "$kind" ]] || continue
        kind="${kind#Type is }"
        if [[ "$kind" == "dictionary" ]]; then
            value="$(defaults read "$domain" "$key" 2>/dev/null | colour_of 2>/dev/null || true)"
            [[ -n "$value" ]] || continue
            printf '%s\t%s\tcolour\t%s\n' "$domain" "$key" "$value" >> "$tmp"
            count=$((count + 1))
            continue
        fi
        type_flag "$kind" >/dev/null || continue

        value="$(defaults read "$domain" "$key" 2>/dev/null || true)"
        # a home path is stored with ~ so the file works for any user name
        value="${value/#$HOME/~}"

        printf '%s\t%s\t%s\t%s\n' "$domain" "$key" "$kind" "$value" >> "$tmp"
        count=$((count + 1))
    done < "$TRACKED_FILE"

    mv "$tmp" "$VALUES_FILE"
    ok "Captured ${count} settings into ${VALUES_FILE}"
}

RESTART_DOCK=0
RESTART_FINDER=0
RESTART_UI_SERVER=0
UNWRITABLE=()

note_restart() {
    case "$1" in
        com.apple.dock) RESTART_DOCK=1 ;;
        com.apple.finder|com.apple.desktopservices) RESTART_FINDER=1 ;;
        com.apple.screencapture|com.apple.menuextra.clock) RESTART_UI_SERVER=1 ;;
    esac
}

apply_setting() {
    local domain="$1" key="$2" kind="$3" value="$4"
    local flag current

    if [[ "$kind" == "colour" ]]; then
        apply_colour "$domain" "$key" "$value"
        return 0
    fi

    flag="$(type_flag "$kind")" || return 0

    # a path may be stored either with ~ or spelt out in full; both mean the same folder, so
    # neither form is rewritten into the other
    current="$(defaults read "$domain" "$key" 2>/dev/null || true)"
    if [[ "$current" == "$value" || "$current" == "${value/#\~/$HOME}" ]]; then
        return 0
    fi

    # screenshots fail silently when their folder does not exist yet
    if [[ "$domain" == "com.apple.screencapture" && "$key" == "location" ]]; then
        mkdir -p "${value/#\~/$HOME}"
    fi

    if defaults write "$domain" "$key" "$flag" "$value" 2>/dev/null; then
        info "Set ${domain} ${key} to ${value}"
        note_restart "$domain"
    else
        UNWRITABLE+=("${domain} ${key} = ${value}")
    fi
}

apply_colour() {
    local domain="$1" key="$2" value="$3"
    local current red green blue alpha

    current="$(defaults read "$domain" "$key" 2>/dev/null | colour_of 2>/dev/null || true)"
    [[ "$current" == "$value" ]] && return 0

    read -r red green blue alpha <<< "$value"
    if defaults write "$domain" "$key" -dict red -float "$red" green -float "$green" \
        blue -float "$blue" alpha -float "$alpha" 2>/dev/null; then
        info "Set ${domain} ${key} to ${value}"
        note_restart "$domain"
    else
        UNWRITABLE+=("${domain} ${key} = ${value} (red green blue alpha)")
    fi
}

apply() {
    if [[ ! -f "$VALUES_FILE" ]]; then
        warn "No captured settings at ${VALUES_FILE}; run with --capture on a set-up Mac first"
        return 0
    fi

    local domain key kind value
    while IFS=$'\t' read -r domain key kind value; do
        [[ -z "$domain" || "$domain" == \#* || "$domain" == "domain" ]] && continue
        apply_setting "$domain" "$key" "$kind" "$value"
    done < "$VALUES_FILE"

    # restarting only what changed means a run on a Mac that already matches never flickers the
    # Dock or closes Finder windows
    if (( RESTART_DOCK )); then killall Dock 2>/dev/null || true; fi
    if (( RESTART_FINDER )); then killall Finder 2>/dev/null || true; fi
    if (( RESTART_UI_SERVER )); then killall SystemUIServer 2>/dev/null || true; fi

    if (( ${#UNWRITABLE[@]} > 0 )); then
        warn "macOS did not allow these to be set from a script; set them in System Settings:"
        local entry
        for entry in "${UNWRITABLE[@]}"
        do
            warn "  ${entry}"
        done
    fi

    ok "macOS settings match the captured ones"
}

case "${1:-}" in
    --capture) capture ;;
    "") apply ;;
    *) printf 'Usage: %s [--capture]\n' "$0" >&2; exit 2 ;;
esac
