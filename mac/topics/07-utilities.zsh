# =============================================================================
# System utilities and general aliases
# Day-to-day shell utilities that don't belong to any specific language or
# tool. I keep these separate from language aliases so they're easy to find.
# =============================================================================

# ll: long listing with human-readable sizes and hidden files - my default for inspecting a directory
alias ll="ls -lahG"
# la: list all files including hidden, no size details - quicker scan when I only need names
alias la="ls -AG"

alias grep='grep --color=auto'

# Always create parent directories and print what was created
alias mkdir="mkdir -pv"

# Disk usage of the current directory sorted by size - I use this to find what's eating space
alias duh="du -h -d 1 | sort -hr"

# Process search shortcut
alias psgrep="ps aux | grep"

# Quick HTTP server from the current folder - I use this for frontend testing without a full dev server
alias serve="python3 -m http.server 8080"

# Public IP - useful when configuring SSH access, port forwarding or checking VPN routing
alias pubip="curl -s ifconfig.me"

# Terminal weather via wttr.in
alias weather="curl -s wttr.in"

# path: print each PATH entry on its own line - easier to scan than one long colon-separated string
path() {
    echo "$PATH" | tr ':' '\n'
}

# bigfiles: show the N largest files under the current directory (default 10)
bigfiles() {
    du -ah . 2>/dev/null | sort -hr | head -n "${1:-10}"
}
