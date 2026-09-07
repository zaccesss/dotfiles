# =============================================================================
# Modern CLI tools
# Additions alongside the real commands, not replacements for them, cat/ls/grep/cd
# all keep working exactly as before. Install (Debian/Ubuntu):
#   sudo apt install fzf zoxide bat eza ripgrep
# =============================================================================

# zoxide: frecency-based cd. z <partial-name> jumps to the best match, zi is the
# interactive picker when more than one match is close. Guarded, unlike Starship's
# own eval line, since these 5 tools are new additions not everyone has installed yet.
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

# fzf: fuzzy-find a file, open the pick in $EDITOR
ff() { local f; f=$(fzf --preview 'bat --color=always {}') && [ -n "$f" ] && "${EDITOR:-code}" "$f"; }

# fcd: fuzzy-find a directory, cd into the pick
fcd() { local d; d=$(find . -type d 2>/dev/null | fzf) && [ -n "$d" ] && cd "$d" || return; }

# fh: fuzzy-search shell history, run the pick
fh() { eval "$(history | fzf --tac | sed 's/^[ ]*[0-9]*[ ]*//')"; }

# eza: syntax-aware ls with icons and git status, opt-in alongside the real ls/ll/la
alias ez="eza"
alias ezl="eza -lah --git"
alias ezt="eza --tree --level=2"

# rg2: ripgrep. Named rg2, not rg, since rg is already 29-ruby.sh's "rails generate"
alias rg2="rg"

# col: extract a whitespace-separated column from piped text, e.g. `ps aux | col 2`
col() { awk "{print \$$1}"; }

# replace: in-place find-and-replace in a file (GNU sed)
replace() {
    local old="${1:?Usage: replace <old> <new> <file>}" new="${2:?}" file="${3:?}"
    sed -i "s/${old}/${new}/g" "$file"
}

# whatport: show what process is listening on a given port
whatport() { lsof -i ":${1:?Usage: whatport <port>}"; }

# killport: kill whatever process is listening on a given port
killport() { lsof -ti ":${1:?Usage: killport <port>}" | xargs kill -9; }

# notify: run a command, send a desktop notification with its exit status when
# done. I use this for a build or long-running script I want to walk away from.
notify() {
    "$@"
    local status=$?
    notify-send "$*" "exit $status"
    return $status
}
