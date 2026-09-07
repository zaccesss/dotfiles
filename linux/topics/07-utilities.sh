# =============================================================================
# System utilities and general aliases
# Linux-specific where needed: --max-depth instead of -d; ports points
# to the standard Linux serial device paths.
# =============================================================================

# ll: long listing with human-readable sizes and hidden files
alias ll="ls -lah --color=auto"
# la: list all files including hidden, no size details - quicker scan when I only need names
alias la="ls -A --color=auto"
alias grep='grep --color=auto'
alias mkdir="mkdir -pv"

# Linux uses --max-depth instead of macOS -d
alias duh="du -h --max-depth=1 | sort -hr"

alias psgrep="ps aux | grep"

alias serve="python3 -m http.server 8080"
alias pubip="curl -s ifconfig.me"
alias weather="curl -s wttr.in"

# path: print each PATH entry on its own line - easier to scan than one long colon-separated string
path() {
    echo "$PATH" | tr ':' '\n'
}

# bigfiles: show the N largest files under the current directory (default 10)
bigfiles() {
    du -ah . 2>/dev/null | sort -hr | head -n "${1:-10}"
}
