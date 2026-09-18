# =============================================================================
# System utilities and general aliases
# Linux-specific where needed: --max-depth instead of -d; ports points
# to the standard Linux serial device paths. battery requires: apt install acpi
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

# battery: charge percentage and status. Requires: apt install acpi
battery() {
    acpi -b
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
    xdg-open "${base}$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(' '.join(sys.argv[1:])))" "$@")"
}

# google: open the default browser straight to a Google search for the given query
google() { _open_search "https://www.google.com/search?q=" "$@"; }

# gh-search: search GitHub itself (code and repos), not just my own repos' issues
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

# codeforces: open a path under codeforces.com, defaults to my own profile
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
# The counterpart to extract in 08-community.sh, which already unpacks a zip
# among other archive formats, so there was no equivalent for creating one
zipf() {
    local target="${1:?Usage: zipf <file-or-folder>}"
    zip -r "${target%/}.zip" "$target"
}
