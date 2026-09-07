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

# path: print each PATH entry on its own line - easier to scan than one long semicolon-separated string
function path { $env:Path -split ';' }

# bigfiles: show the N largest files under the current directory (default 10)
function bigfiles {
    param([int]$Count = 10)
    Get-ChildItem -Recurse -File -ErrorAction SilentlyContinue |
        Sort-Object Length -Descending |
        Select-Object -First $Count FullName, @{N = 'Size'; E = { "{0:N2} MB" -f ($_.Length / 1MB) } }
}
