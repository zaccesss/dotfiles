# =============================================================================
# System utilities
# Windows-specific where needed: duh uses Get-ChildItem, psgrep uses
# Get-Process and weather uses Invoke-WebRequest.
# =============================================================================

# la: list all files including hidden - names only, quick scan
function la   { Get-ChildItem -Force -Name }
# ll: full listing with sizes and dates - my default for inspecting a directory
function ll   { Get-ChildItem -Force | Format-Table -AutoSize }
function duh  { Get-ChildItem | ForEach-Object { "{0,10} {1}" -f (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum, $_.Name } | Sort-Object }
function psgrep { param([string]$p) Get-Process | Where-Object { $_.Name -like "*$p*" } }

# Quick HTTP server from the current folder
function serve  { python -m http.server 8080 }

# Public IP
function pubip  { Invoke-RestMethod -Uri "https://ifconfig.me" }

# Terminal weather
function weather { (Invoke-WebRequest -Uri "wttr.in?format=3").Content }

# battery: charge percentage and status
function battery { Get-CimInstance -ClassName Win32_Battery | Select-Object EstimatedChargeRemaining, BatteryStatus }

# please: rerun the last command elevated, for when I forget to run PowerShell as admin
function please {
    $lastCmd = (Get-History)[-1].CommandLine
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit", "-Command", $lastCmd
}

# cheat: instant command cheatsheet from cheat.sh, no browser needed
function cheat {
    param([string]$Command)
    (Invoke-WebRequest -Uri "https://cheat.sh/$Command" -UseBasicParsing).Content
}

# _open_search: internal helper, every quick-launcher below reduces to this
function _open_search {
    param([string]$Base, [Parameter(ValueFromRemainingArguments = $true)][string[]]$Query)
    $encoded = [System.Uri]::EscapeDataString($Query -join ' ')
    Start-Process "$Base$encoded"
}

# google: open the default browser straight to a Google search for the given query
function google { _open_search "https://www.google.com/search?q=" @args }

# gh-search: search GitHub itself (code and repos), not just my own repos' issues
function gh-search { _open_search "https://github.com/search?q=" @args }

# so: search Stack Overflow directly
function so { _open_search "https://stackoverflow.com/search?q=" @args }

# mdn: search MDN Web Docs, the standard reference for JS/CSS/HTML
function mdn { _open_search "https://developer.mozilla.org/en-US/search?q=" @args }

# npmjs: jump straight to a package's npm page
function npmjs { param([string]$Package) Start-Process "https://www.npmjs.com/package/$Package" }

# pypi: jump straight to a package's PyPI page, the Python equivalent of npmjs
function pypi { param([string]$Package) Start-Process "https://pypi.org/project/$Package/" }

# caniuse: check browser support for a web feature
function caniuse { _open_search "https://caniuse.com/?search=" @args }

# leetcode: jump straight to a problem page by its slug
function leetcode { param([string]$Slug) Start-Process "https://leetcode.com/problems/$Slug/" }

# neetcode: jump straight to a problem page by its slug
function neetcode { param([string]$Slug) Start-Process "https://neetcode.io/problems/$Slug" }

# codeforces: open a path under codeforces.com, defaults to my own profile
function codeforces { param([string]$Path = "profile/zaccesss") Start-Process "https://codeforces.com/$Path" }

# translate: quick Google Translate lookup, auto-detects the source language
function translate { _open_search "https://translate.google.com/?sl=auto&tl=en&op=translate&text=" @args }

# regex101: open regex101.com for quick regex testing
function regex101 { Start-Process "https://regex101.com" }

# vt: search VirusTotal for a hash, IP or domain
function vt { _open_search "https://www.virustotal.com/gui/search/" @args }

# shodan: search Shodan
function shodan { _open_search "https://www.shodan.io/search?query=" @args }

# cve: jump straight to a CVE's NVD detail page
function cve { param([string]$Id) Start-Process "https://nvd.nist.gov/vuln/detail/$Id" }

# maps: search Google Maps
function maps { _open_search "https://www.google.com/maps/search/" @args }

# yt: search YouTube
function yt { _open_search "https://www.youtube.com/results?search_query=" @args }

# wiki: search Wikipedia
function wiki { _open_search "https://en.wikipedia.org/wiki/Special:Search?search=" @args }

# godocs: jump straight to a Go package's page on pkg.go.dev - named with an 's' since
# godoc is already the local `go doc` wrapper in 34-go.ps1
function godocs { param([string]$Package) Start-Process "https://pkg.go.dev/$Package" }

# crates: jump straight to a Rust package's page on crates.io
function crates { param([string]$Package) Start-Process "https://crates.io/crates/$Package" }

# dockerhub: search Docker Hub for an image
function dockerhub { _open_search "https://hub.docker.com/search?q=" @args }

# packagist: jump straight to a PHP/Composer package's page
function packagist { param([string]$Package) Start-Process "https://packagist.org/packages/$Package" }

# rubygems: jump straight to a Ruby gem's page
function rubygems { param([string]$Package) Start-Process "https://rubygems.org/gems/$Package" }

# nugetpkg: jump straight to a .NET package's page on NuGet
function nugetpkg { param([string]$Package) Start-Process "https://www.nuget.org/packages/$Package" }

# mvnrepo: search Maven Central for a Java/Kotlin package
function mvnrepo { _open_search "https://mvnrepository.com/search?q=" @args }

# hexpm: jump straight to an Elixir package's page on Hex.pm
function hexpm { param([string]$Package) Start-Process "https://hex.pm/packages/$Package" }

# archive: open the Wayback Machine's history for a URL
function archive { param([string]$Url) Start-Process "https://web.archive.org/web/*/$Url" }

# bundlephobia: check an npm package's real bundle-size cost before adding it as a dependency
function bundlephobia { param([string]$Package) Start-Process "https://bundlephobia.com/package/$Package" }

# path: print each PATH entry on its own line - easier to scan than one long semicolon-separated string
function path { $env:Path -split ';' }

# bigfiles: show the N largest files under the current directory (default 10)
function bigfiles {
    param([int]$Count = 10)
    Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First $Count FullName, @{N = 'Size'; E = { "{0:N2} MB" -f ($_.Length / 1MB) } }
}

# zipf: zip a file or folder into a same-named .zip in the current directory.
# The counterpart to extract in 08-community.ps1, which already unpacks a zip
# among other archive formats, so there was no equivalent for creating one
function zipf {
    param([string]$Target)
    Compress-Archive -Path $Target -DestinationPath "$($Target.TrimEnd('\', '/')).zip"
}
