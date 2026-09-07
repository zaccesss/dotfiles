# =============================================================================
# Community tools and advanced utilities
# These functions are inspired by the broader dotfiles community (mathiasbynens,
# holman, thoughtbot and others). I've adapted each one to fit my workflow
# and added first-person comments explaining when I actually use them.
# =============================================================================

# extract: unpack any archive without remembering the right tar/unzip flags.
# I use this constantly - no more googling "how do I untar a .tar.xz".
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.tar.xz)    tar xJf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "${RED}Cannot extract '$1': format not recognised${RESET}" ;;
        esac
    else
        echo "${RED}'$1' is not a valid file${RESET}"
    fi
}

# targz: create a .tar.gz from a file or directory.
# Automatically picks pigz if available for faster compression.
targz() {
    local tmp="${1%/}.tar"
    tar -cvf "$tmp" --exclude=".DS_Store" "$1" || return 1
    local size
    size=$(stat -f%z "$tmp" 2>/dev/null)
    local cmd
    if hash pigz 2>/dev/null; then cmd="pigz"; else cmd="gzip"; fi
    echo "Compressing ($((size / 1000)) kB) using $cmd..."
    "$cmd" -v "$tmp" || return 1
    [[ -f "$tmp" ]] && rm "$tmp"
}

# gz: show the original size and gzip-compressed size of a file side by side.
# I use this to decide whether compressing something is actually worth it.
gz() {
    local orig gzip ratio
    orig=$(wc -c < "$1")
    gzip=$(gzip -c "$1" | wc -c)
    ratio=$(echo "scale=1; $gzip * 100 / $orig" | bc)
    printf "orig: %d bytes\ngzip: %d bytes (%s%%)\n" "$orig" "$gzip" "$ratio"
}

# dataurl: encode a file as a base64 data URL.
# I use this when I need to embed a small image or font directly in CSS/HTML.
dataurl() {
    local mime
    mime=$(file -b --mime-type "$1")
    [[ "$mime" == text/* ]] && mime="${mime};charset=utf-8"
    echo "data:${mime};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# envup: export every variable from a .env file into the current shell session.
# I use this instead of copy-pasting exports when running scripts locally
# that normally read from environment variables in CI or production.
envup() {
    local file="${1:-.env}"
    [[ -f "$file" ]] || { echo "${RED}No $file found${RESET}"; return 1; }
    # shellcheck disable=SC2046
    export $(grep -v '^ *#' "$file" | grep -v '^$' | xargs)
    echo "${GREEN}Loaded $file${RESET}"
}

# digga: show all DNS records for a domain in a readable format.
# Much cleaner than the default dig output which is full of noise.
digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

# dns-flush: flush the macOS DNS cache.
# The command changes almost every macOS release - I keep this here so I
# never have to google it again.
dns-flush() {
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    echo "DNS cache flushed"
}

# cdf: cd to the directory currently open in the frontmost Finder window.
# I use this when I've navigated somewhere in Finder and want to open a
# terminal at that location without retyping the full path.
cdf() {
    local target
    target=$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
    if [[ -n "$target" ]]; then
        cd "$target" || return
    else
        echo "${YELLOW}No Finder window is open${RESET}"
    fi
}

# Clipboard shortcuts - pipe anything into clipcopy or run paste to read the clipboard
alias clipcopy="pbcopy"
alias paste="pbpaste"

# HTTP method shortcuts - quick curl calls without typing flags.
# I use these when testing APIs from the terminal during development.
GET()    { curl -sS "$@"; }
POST()   { curl -sS -X POST "$@"; }
PUT()    { curl -sS -X PUT "$@"; }
DELETE() { curl -sS -X DELETE "$@"; }
HEAD()   { curl -sS -I "$@"; }

# Global pipe shortcuts (zsh only) - type: ls G pattern  instead of  ls | grep pattern.
# These save a lot of typing when chaining commands.
alias -g G='| grep'
alias -g H='| head'
alias -g T='| tail'
alias -g L='| less'
alias -g N='| wc -l'

# change-extension: batch rename file extensions in the current directory.
# Usage: change-extension erb haml
# I use this when migrating template files between formats in a project.
change-extension() {
    local old="$1" new="$2"
    for f in *."$old"; do mv "$f" "${f%.$old}.$new"; done
}

# o: open a file or directory in the default GUI app - defaults to the current directory
o() {
    open "${1:-.}"
}

# backup: copy a file to a timestamped .bak alongside it before I risk editing it
backup() {
    local file="${1:?Usage: backup <file>}"
    cp "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)"
}

# please: re-run the last command with sudo - saves retyping it after a "permission denied"
# shellcheck disable=SC2046
alias please='sudo $(fc -ln -1)'
