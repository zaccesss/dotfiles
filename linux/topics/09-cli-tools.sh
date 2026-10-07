# =============================================================================
# Modern CLI tools
# Additions alongside the real commands, not replacements for them, cat/ls/grep/cd
# all keep working exactly as before. Install (Debian/Ubuntu):
#   sudo apt install fzf zoxide bat eza ripgrep
# =============================================================================

# ripgrep: defaults such as smart-case and hidden files go in ~/.ripgreprc (see cli-tools-config).
# rg only reads that file through this env var
[[ -f "$HOME/.ripgreprc" ]] && export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# zoxide: frecency-based cd. z <partial-name> jumps to the best match, zi is the
# interactive picker when more than one match is close. Guarded, unlike Starship's
# own eval line, since these 5 tools are new additions not everyone has installed yet.
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

# fzf colours as terminal colour names (-1 is the terminal's own text and background), the same as
# the macOS fzf.zsh in the CLI tools config, so fzf follows the terminal's light or dark palette
if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="rg --files --hidden --glob '!.git/*'"
fi
export FZF_DEFAULT_OPTS="--height=60% --layout=reverse --border --bind=ctrl-/:toggle-preview
  --color=bg:-1,bg+:-1,fg:-1,fg+:-1:bold:reverse --color=hl:yellow:bold,hl+:yellow:bold
  --color=pointer:yellow,marker:yellow --color=prompt:-1,spinner:-1,info:-1"

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

# rg2: ripgrep under its earlier name, kept so old habits still work. rg itself is ripgrep
# again since the Rails generator moved to rgen
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
# done. Useful for a build or long-running script that does not need watching.
notify() {
    "$@"
    local status=$?
    notify-send "$*" "exit $status"
    return $status
}

# typw: rebuild a Typst document every time it is saved
typw() { typst watch "${1:?Usage: typw <file.typ>}"; }

# linkcheck: check every link in the Markdown and HTML under a folder (default: here)
linkcheck() { lychee --no-progress "${1:-.}"; }
