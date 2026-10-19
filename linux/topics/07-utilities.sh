# =============================================================================
# System utilities and general aliases
# Linux-specific where needed: --max-depth instead of -d; ports points
# to the standard Linux serial device paths. battery requires: apt install acpi
# =============================================================================

# ll: long listing with human-readable sizes and hidden files
alias ll="ls -lah --color=auto"
# la: list all files including hidden, no size details - a quicker scan when only names matter
alias la="ls -A --color=auto"
alias grep='grep --color=auto'
alias mkdir="mkdir -pv"

# Linux uses --max-depth instead of macOS -d
alias duh="du -h --max-depth=1 | sort -hr"

alias psgrep="ps aux | grep"

alias serve="python3 -m http.server 8080"
alias pubip="curl -s ifconfig.me"
alias weather="curl -s wttr.in"

# battery: charge percentage and status. Requires: apt install acpi
battery() {
    acpi -b
}

# please: rerun the last command with sudo, for when it was left off the first time
alias please='sudo $(fc -ln -1)'

# cheat: instant command cheatsheet from cheat.sh, no browser needed
cheat() {
    curl -s "cheat.sh/${1:?Usage: cheat <command>}"
}

# _open_search: internal helper, every quick-launcher below reduces to this
_open_search() {
    local base="$1"; shift
    xdg-open "${base}$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(' '.join(sys.argv[1:])))" "$@")"
}

# google: open the default browser straight to a Google search for the given query
google() { _open_search "https://www.google.com/search?q=" "$@"; }

# gh-search: search all of GitHub (code and repos), not only issues in the signed-in account's repos
gh-search() { _open_search "https://github.com/search?q=" "$@"; }

# so: search Stack Overflow directly
so() { _open_search "https://stackoverflow.com/search?q=" "$@"; }

# mdn: search MDN Web Docs, the standard reference for JS/CSS/HTML
mdn() { _open_search "https://developer.mozilla.org/en-US/search?q=" "$@"; }

# npmjs: jump straight to a package's npm page
npmjs() { xdg-open "https://www.npmjs.com/package/${1:?Usage: npmjs <package>}"; }

# pypi: jump straight to a package's PyPI page, the Python equivalent of npmjs
pypi() { xdg-open "https://pypi.org/project/${1:?Usage: pypi <package>}/"; }

# caniuse: check browser support for a web feature
caniuse() { _open_search "https://caniuse.com/?search=" "$@"; }

# leetcode: jump straight to a problem page by its slug
leetcode() { xdg-open "https://leetcode.com/problems/${1:?Usage: leetcode <slug>}/"; }

# neetcode: jump straight to a problem page by its slug
neetcode() { xdg-open "https://neetcode.io/problems/${1:?Usage: neetcode <slug>}"; }

# codeforces: open a path under codeforces.com, defaults to the zaccesss profile
codeforces() { xdg-open "https://codeforces.com/${1:-profile/zaccesss}"; }

# translate: quick Google Translate lookup, auto-detects the source language
translate() { _open_search "https://translate.google.com/?sl=auto&tl=en&op=translate&text=" "$@"; }

# regex101: open regex101.com for quick regex testing
alias regex101='xdg-open "https://regex101.com"'

# vt: search VirusTotal for a hash, IP or domain
vt() { _open_search "https://www.virustotal.com/gui/search/" "$@"; }

# shodan: search Shodan
shodan() { _open_search "https://www.shodan.io/search?query=" "$@"; }

# cve: jump straight to a CVE's NVD detail page
cve() { xdg-open "https://nvd.nist.gov/vuln/detail/${1:?Usage: cve <id>}"; }

# maps: search Google Maps
maps() { _open_search "https://www.google.com/maps/search/" "$@"; }

# yt: search YouTube
yt() { _open_search "https://www.youtube.com/results?search_query=" "$@"; }

# wiki: search Wikipedia
wiki() { _open_search "https://en.wikipedia.org/wiki/Special:Search?search=" "$@"; }

# godocs: jump straight to a Go package's page on pkg.go.dev - named with an 's' since
# godoc is already the local `go doc` wrapper in 34-go.sh
godocs() { xdg-open "https://pkg.go.dev/${1:?Usage: godocs <package>}"; }

# crates: jump straight to a Rust package's page on crates.io
crates() { xdg-open "https://crates.io/crates/${1:?Usage: crates <package>}"; }

# dockerhub: search Docker Hub for an image
dockerhub() { _open_search "https://hub.docker.com/search?q=" "$@"; }

# packagist: jump straight to a PHP/Composer package's page
packagist() { xdg-open "https://packagist.org/packages/${1:?Usage: packagist <vendor/package>}"; }

# rubygems: jump straight to a Ruby gem's page
rubygems() { xdg-open "https://rubygems.org/gems/${1:?Usage: rubygems <package>}"; }

# nugetpkg: jump straight to a .NET package's page on NuGet
nugetpkg() { xdg-open "https://www.nuget.org/packages/${1:?Usage: nugetpkg <package>}"; }

# mvnrepo: search Maven Central for a Java/Kotlin package
mvnrepo() { _open_search "https://mvnrepository.com/search?q=" "$@"; }

# hexpm: jump straight to an Elixir package's page on Hex.pm
hexpm() { xdg-open "https://hex.pm/packages/${1:?Usage: hexpm <package>}"; }

# archive: open the Wayback Machine's history for a URL
archive() { xdg-open "https://web.archive.org/web/*/${1:?Usage: archive <url>}"; }

# bundlephobia: check an npm package's real bundle-size cost before adding it as a dependency
bundlephobia() { xdg-open "https://bundlephobia.com/package/${1:?Usage: bundlephobia <package>}"; }

# path: print each PATH entry on its own line - easier to scan than one long colon-separated string
path() {
    echo "$PATH" | tr ':' '\n'
}

# bigfiles: show the N largest files under the current directory (default 10)
bigfiles() {
    du -ah . 2>/dev/null | sort -hr | head -n "${1:-10}"
}

# zipf: zip a file or folder into a same-named .zip in the current directory.
# the counterpart to extract in 08-community.sh, which already unpacks a zip
# among other archive formats, so there was no equivalent for creating one
zipf() {
    local target="${1:?Usage: zipf <file-or-folder>}"
    zip -r "${target%/}.zip" "$target"
}

# termtheme: Ptyxis' light or dark High Contrast palette. auto follows the desktop's light and dark
# setting; dark and light pin one. Inside OrbStack the terminal belongs to the Mac, so it says so
termtheme() {
    local mode="${1:-status}"
    if [[ -d /opt/orbstack-guest ]]; then
        echo "This shell runs in the Mac's terminal; run termtheme on the Mac instead"
        return 0
    fi
    if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        echo "This shell runs in Windows Terminal; run termtheme in PowerShell instead"
        return 0
    fi
    if ! gsettings list-keys org.gnome.Ptyxis 2>/dev/null | grep -qx interface-style; then
        echo -e "${RED}Ptyxis is not installed; termtheme sets Ptyxis, the terminal in Ubuntu 25.10 and later${RESET}"
        return 1
    fi
    case "$mode" in
        auto) gsettings set org.gnome.Ptyxis interface-style system
              echo -e "${GREEN}Ptyxis now follows the desktop's light and dark${RESET}" ;;
        dark|light) gsettings set org.gnome.Ptyxis interface-style "$mode"
              echo -e "${GREEN}Ptyxis stays ${mode}${RESET}" ;;
        status) case "$(gsettings get org.gnome.Ptyxis interface-style)" in
                    "'system'") echo "auto: following the desktop's light and dark" ;;
                    *) echo "fixed: $(gsettings get org.gnome.Ptyxis interface-style | tr -d "'")" ;;
                esac ;;
        *) echo "Usage: termtheme [dark|light|auto]  (no argument shows the current mode)"
           return 1 ;;
    esac
}

# update: everything in one go (apt or dnf, Homebrew if present, global npm packages and uv or
# pipx tools). lists what is out of date first and only upgrades after a yes, since an upgrade
# can change a tool's behaviour mid-project.
update() {
    echo -e "${CYAN}Checking for updates...${RESET}"
    if command -v apt >/dev/null; then
        sudo apt update -qq && echo -e "${BOLD}${MAGENTA}apt${RESET}" && apt list --upgradable 2>/dev/null | tail -n +2
    elif command -v dnf >/dev/null; then
        echo -e "${BOLD}${MAGENTA}dnf${RESET}"; dnf check-update -q
    fi
    command -v brew >/dev/null && { brew update >/dev/null 2>&1; echo -e "${BOLD}${MAGENTA}Homebrew${RESET}"; brew outdated --verbose; }
    command -v npm >/dev/null && { echo -e "${BOLD}${MAGENTA}npm (global)${RESET}"; npm outdated -g --depth=0; }
    read -r -p "Upgrade all of these? [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]] || return
    if command -v apt >/dev/null; then sudo apt upgrade -y; elif command -v dnf >/dev/null; then sudo dnf upgrade -y; fi
    command -v brew >/dev/null && brew upgrade && brew cleanup
    command -v npm >/dev/null && npm update -g
    command -v uv >/dev/null && uv tool upgrade --all
    command -v pipx >/dev/null && pipx upgrade-all
    echo -e "${GREEN}Up to date.${RESET}"
}

# _clipboard_copy: copy stdin to the clipboard with whatever this machine has. WSL comes first
# because the Windows clipboard is the one that matters there and clip.exe is always on the PATH;
# wl-copy and xclip each need their display server running, so a headless machine falls through
_clipboard_copy() {
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qsi microsoft /proc/version; then
        clip.exe
    elif [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy >/dev/null 2>&1; then
        wl-copy
    elif [[ -n "${DISPLAY:-}" ]] && command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard
    else
        return 1
    fi
}

# copyout: run a command, show its output as normal and copy all of it (output and errors) to the
# clipboard, so a whole result or error can go into an issue or a message without selecting it by
# hand. the command's own exit status is kept, so copyout still works in a && chain
copyout() {
    if (( $# == 0 )); then
        echo "Usage: copyout <command...>"
        return 1
    fi
    local tmp rc lines word=lines
    tmp="$(mktemp)"
    "$@" 2>&1 | tee "$tmp"
    # PIPESTATUS holds the command's status rather than tee's
    rc=${PIPESTATUS[0]}
    if _clipboard_copy < "$tmp"; then
        lines=$(awk 'END { print NR }' "$tmp")
        (( lines == 1 )) && word=line
        echo -e "${GREEN}copied ${lines} ${word} to the clipboard${RESET}" >&2
    else
        echo -e "${YELLOW}No clipboard found: install wl-clipboard (Wayland) or xclip (X11) to use copyout${RESET}" >&2
    fi
    rm -f "$tmp"
    return "$rc"
}

# logrun: run a command with its output live on screen and saved to ~/logs, named by date, time and
# command, so a long build or install can be read back after the terminal has scrolled past it.
# the exit status is the command's own, not tee's
logrun() {
    if (( $# == 0 )); then
        echo "Usage: logrun <command...>"
        return 1
    fi
    local name log rc
    # command skips the mkdir alias above, whose -v would print the folder on every run
    command mkdir -p "$HOME/logs"
    # only the command's base name, made safe for a file name, so ./build.sh or a path adds no folders
    name="${1##*/}"
    name="${name//[^A-Za-z0-9._-]/_}"
    log="$HOME/logs/$(date +%Y-%m-%d_%H%M%S)-${name}.log"
    "$@" 2>&1 | tee "$log"
    rc=${PIPESTATUS[0]}
    echo -e "${CYAN}log saved to ${log}${RESET}" >&2
    return "$rc"
}
