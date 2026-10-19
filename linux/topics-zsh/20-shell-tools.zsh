# =============================================================================
# Shell scripting tools - shellcheck, shfmt, syntax checking
# Requires: apt install shellcheck  and  go install mvdan.cc/sh/v3/cmd/shfmt@latest
# =============================================================================

sc() {
    if [[ -n "$1" ]]; then
        shellcheck "$@"
    else
        find . \( -name "*.sh" -o -name "*.bash" \) -print0 | xargs -0 shellcheck 2>/dev/null
    fi
}

# scwatch: run shellcheck every time a .sh file changes (requires fswatch,
# cross-platform and installable via apt just like on mac)
scwatch() {
    fswatch -o . | xargs -n1 -I{} shellcheck "${1:-*.sh}"
}

alias sfmt="shfmt -i 4 -w"
alias sfmtdiff="shfmt -i 4 -d"
alias sfmtcheck="shfmt -i 4 -l"

bashn() { bash -n "${1:?Usage: bashn <file.sh>}"; }

# zshn: syntax-check a zsh script without running it - the repo's mac/topics/*.zsh
# files still need checking from a Linux box even though this shell itself is bash
zshn() { zsh -n "${1:?Usage: zshn <file.zsh>}"; }

sc-all() {
    echo "Checking .sh files..."
    find "$DOTFILES" -name "*.sh" -print0 | xargs -0 shellcheck 2>/dev/null || true
    if command -v zsh &>/dev/null; then
        echo "Syntax-checking .zsh files..."
        find "$DOTFILES" -name "*.zsh" | while read -r f; do
            zsh -n "$f" && echo "OK: $f" || echo "FAIL: $f"
        done
    fi
}
