# =============================================================================
# Community tools and advanced utilities
# Linux-specific where needed: dns-flush uses systemd-resolve, copy/paste
# use xclip; cdf is omitted (no Finder) and targz uses stat -c%s.
# Global pipe aliases (alias -g) are zsh-only and are not included here.
# =============================================================================

# extract: unpack any archive without remembering the right tar/unzip flags
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
            *)           echo -e "${RED}Cannot extract '$1': format not recognised${RESET}" ;;
        esac
    else
        echo -e "${RED}'$1' is not a valid file${RESET}"
    fi
}

# targz: create a .tar.gz from a file or directory
# Uses stat -c%s (Linux) instead of stat -f%z (macOS)
targz() {
    local tmp="${1%/}.tar"
    tar -cvf "$tmp" --exclude=".DS_Store" "$1" || return 1
    local size
    size=$(stat -c%s "$tmp" 2>/dev/null)
    local cmd
    if hash pigz 2>/dev/null; then cmd="pigz"; else cmd="gzip"; fi
    echo "Compressing ($((size / 1000)) kB) using $cmd..."
    "$cmd" -v "$tmp" || return 1
    [[ -f "$tmp" ]] && rm "$tmp"
}

# gz: show original vs gzip-compressed size of a file
gz() {
    local orig gzip ratio
    orig=$(wc -c < "$1")
    gzip=$(gzip -c "$1" | wc -c)
    ratio=$(echo "scale=1; $gzip * 100 / $orig" | bc)
    printf "orig: %d bytes\ngzip: %d bytes (%s%%)\n" "$orig" "$gzip" "$ratio"
}

# dataurl: encode a file as a base64 data URL
dataurl() {
    local mime
    mime=$(file -b --mime-type "$1")
    [[ "$mime" == text/* ]] && mime="${mime};charset=utf-8"
    echo "data:${mime};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# envup: export every variable from a .env file into the current shell session
envup() {
    local file="${1:-.env}"
    [[ -f "$file" ]] || { echo -e "${RED}No $file found${RESET}"; return 1; }
    # shellcheck disable=SC2046
    export $(grep -v '^ *#' "$file" | grep -v '^$' | xargs)
    echo -e "${GREEN}Loaded $file${RESET}"
}

# digga: show all DNS records for a domain in a readable format
digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

# dns-flush: flush the Linux DNS cache via systemd-resolved
dns-flush() {
    if command -v resolvectl >/dev/null 2>&1; then
        sudo resolvectl flush-caches
    elif command -v systemd-resolve >/dev/null 2>&1; then
        sudo systemd-resolve --flush-caches
    else
        echo -e "${RED}No known DNS cache manager found (tried resolvectl, systemd-resolve)${RESET}"
        return 1
    fi
    echo -e "${GREEN}DNS cache flushed${RESET}"
}

# Clipboard shortcuts - requires xclip to be installed (sudo apt install xclip)
alias clipcopy="xclip -selection clipboard"
alias paste="xclip -selection clipboard -o"

# HTTP method shortcuts - quick curl calls without typing flags
GET()    { curl -sS "$@"; }
POST()   { curl -sS -X POST "$@"; }
PUT()    { curl -sS -X PUT "$@"; }
DELETE() { curl -sS -X DELETE "$@"; }
HEAD()   { curl -sS -I "$@"; }

# change-extension: batch rename file extensions in the current directory
# Usage: change-extension erb haml
change-extension() {
    local old="$1" new="$2"
    for f in *."$old"; do mv "$f" "${f%.$old}.$new"; done
}

# o: open a file or directory in the default GUI app - defaults to the current directory.
# Backgrounded and silenced since xdg-open prints noise from whatever handler it launches.
o() {
    xdg-open "${1:-.}" >/dev/null 2>&1 &
}

# backup: copy a file to a timestamped .bak alongside it before I risk editing it
backup() {
    local file="${1:?Usage: backup <file>}"
    cp "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)"
}

# please: re-run the last command with sudo - saves retyping it after a "permission denied"
# shellcheck disable=SC2046
alias please='sudo $(fc -ln -1)'
