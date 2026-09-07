# =============================================================================
# Shell scripting tools
# I write a lot of shell scripts for automation, CI and dotfiles maintenance.
# I use shellcheck and shfmt to catch common mistakes and keep style consistent.
# Requires: brew install shellcheck shfmt
# =============================================================================

# sc: run shellcheck on a script or all scripts in the current directory
sc() {
    if [[ -n "$1" ]]; then
        shellcheck "$@"
    else
        find . \( -name "*.sh" -o -name "*.bash" \) -print0 | xargs -0 shellcheck 2>/dev/null
    fi
}

# scwatch: run shellcheck every time a .sh file changes (requires fswatch)
scwatch() {
    fswatch -o . | xargs -n1 -I{} shellcheck "${1:-*.sh}"
}

# shfmt: format a shell script in place
alias sfmt="shfmt -i 4 -w"

# sfmtdiff: preview formatting changes without writing them
alias sfmtdiff="shfmt -i 4 -d"

# sfmtcheck: exit non-zero if any file would be reformatted (good for CI)
alias sfmtcheck="shfmt -i 4 -l"

# zshn: syntax-check a zsh script without running it
zshn() { zsh -n "${1:?Usage: zshn <file.zsh>}"; }

# bashn: syntax-check a bash script without running it
bashn() { bash -n "${1:?Usage: bashn <file.sh>}"; }

# sc-all: syntax-check every .zsh and .sh file in the dotfiles repo
sc-all() {
    echo "Checking .sh files..."
    find "$DOTFILES" -name "*.sh" -print0 | xargs -0 shellcheck 2>/dev/null || true
    echo "Syntax-checking .zsh files..."
    find "$DOTFILES" -name "*.zsh" | while read -r f; do
        zsh -n "$f" && echo "OK: $f" || echo "FAIL: $f"
    done
}
