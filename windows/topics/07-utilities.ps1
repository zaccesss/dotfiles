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

# path: print each PATH entry on its own line - easier to scan than one long semicolon-separated string
function path { $env:Path -split ';' }

# bigfiles: show the N largest files under the current directory (default 10)
function bigfiles {
    param([int]$Count = 10)
    Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First $Count FullName, @{N = 'Size'; E = { "{0:N2} MB" -f ($_.Length / 1MB) } }
}
