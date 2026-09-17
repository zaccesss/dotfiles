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

# battery: charge percentage and health, the two things I actually check day to day
battery() {
    pmset -g batt
}

# please: rerun the last command with sudo, for when I forget it the first time
alias please='sudo $(fc -ln -1)'

# cheat: instant command cheatsheet from cheat.sh, no browser needed
cheat() {
    curl -s "cheat.sh/${1:?Usage: cheat <command>}"
}

# _open_search: internal helper, every quick-launcher below reduces to this
_open_search() {
    local base="$1"; shift
    open -a "Google Chrome" "${base}$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(' '.join(sys.argv[1:])))" "$@")"
}

# google: open Chrome straight to a Google search for the given query, no manual typing into the address bar
google() { _open_search "https://www.google.com/search?q=" "$@"; }

# gh-search: search GitHub itself (code and repos), not just my own repos' issues
gh-search() { _open_search "https://github.com/search?q=" "$@"; }

# so: search Stack Overflow directly
so() { _open_search "https://stackoverflow.com/search?q=" "$@"; }

# mdn: search MDN Web Docs, the standard reference for JS/CSS/HTML
mdn() { _open_search "https://developer.mozilla.org/en-US/search?q=" "$@"; }

# npmjs: jump straight to a package's npm page
npmjs() { open -a "Google Chrome" "https://www.npmjs.com/package/${1:?Usage: npmjs <package>}"; }

# pypi: jump straight to a package's PyPI page, the Python equivalent of npmjs
pypi() { open -a "Google Chrome" "https://pypi.org/project/${1:?Usage: pypi <package>}/"; }

# caniuse: check browser support for a web feature
caniuse() { _open_search "https://caniuse.com/?search=" "$@"; }

# leetcode: jump straight to a problem page by its slug
leetcode() { open -a "Google Chrome" "https://leetcode.com/problems/${1:?Usage: leetcode <slug>}/"; }

# neetcode: jump straight to a problem page by its slug
neetcode() { open -a "Google Chrome" "https://neetcode.io/problems/${1:?Usage: neetcode <slug>}"; }

# codeforces: open a path under codeforces.com, defaults to my own profile
codeforces() { open -a "Google Chrome" "https://codeforces.com/${1:-profile/zaccesss}"; }

# translate: quick Google Translate lookup, auto-detects the source language
translate() { _open_search "https://translate.google.com/?sl=auto&tl=en&op=translate&text=" "$@"; }

# regex101: open regex101.com for quick regex testing
alias regex101='open -a "Google Chrome" "https://regex101.com"'

# path: print each PATH entry on its own line - easier to scan than one long colon-separated string
path() {
    echo "$PATH" | tr ':' '\n'
}

# bigfiles: show the N largest files under the current directory (default 10)
bigfiles() {
    du -ah . 2>/dev/null | sort -hr | head -n "${1:-10}"
}
