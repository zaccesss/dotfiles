# =============================================================================
# Modern CLI tools
# Additions alongside the real commands, not replacements for them. Install:
#   winget install fzf zoxide sharkdp.bat eza-community.eza BurntSushi.ripgrep.MSVC
# =============================================================================

# zoxide: frecency-based cd. z <partial-name> jumps to the best match, zi is the
# interactive picker when more than one match is close. Guarded, unlike Starship's
# own eval line, since these 5 tools are new additions not everyone has installed yet.
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ff: fuzzy-find a file, open the pick in $EDITOR
function ff {
    $f = fzf --preview "bat --color=always {}"
    if ($f) { code $f }
}

# fcd: fuzzy-find a directory, cd into the pick
function fcd {
    $d = Get-ChildItem -Recurse -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName | fzf
    if ($d) { Set-Location $d }
}

# fh: fuzzy-search PowerShell history, run the pick
function fh {
    $cmd = Get-History | Select-Object -ExpandProperty CommandLine | fzf
    if ($cmd) { Invoke-Expression $cmd }
}

# eza: syntax-aware ls with icons and git status, opt-in alongside the real ll/la
function ez  { eza @args }
function ezl { eza -lah --git @args }
function ezt { eza --tree --level=2 @args }

# rg2: ripgrep. Named rg2, not rg, since rg is already 29-ruby.ps1's "rails generate"
function rg2 { rg @args }

# col: extract a whitespace-separated column from piped text, e.g. `Get-Process | col 2`
function col {
    param([int]$N)
    process { ($_ -split '\s+' | Where-Object { $_ -ne '' })[$N - 1] }
}

# replace: in-place find-and-replace in a file
function replace {
    param([Parameter(Mandatory)][string]$Old, [Parameter(Mandatory)][string]$New, [Parameter(Mandatory)][string]$File)
    (Get-Content $File) -replace [regex]::Escape($Old), $New | Set-Content $File
}

# whatport: show what process is listening on a given port
function whatport {
    param([Parameter(Mandatory)][int]$Port)
    Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
        Select-Object LocalAddress, LocalPort, State, OwningProcess |
        ForEach-Object { $_ | Add-Member -NotePropertyName ProcessName -NotePropertyValue (Get-Process -Id $_.OwningProcess).ProcessName -PassThru }
}

# killport: kill whatever process is listening on a given port
function killport {
    param([Parameter(Mandatory)][int]$Port)
    Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty OwningProcess -Unique |
        ForEach-Object { Stop-Process -Id $_ -Force }
}

# notify: run a command, show a toast (or a fallback beep) with its exit status
# when done. I use this for a build or long-running script I want to walk away from.
function notify {
    & $args[0] $args[1..($args.Count - 1)]
    $status = $LASTEXITCODE
    if (Get-Command New-BurntToastNotification -ErrorAction SilentlyContinue) {
        New-BurntToastNotification -Text "$($args -join ' ')", "exit $status"
    } else {
        [System.Media.SystemSounds]::Asterisk.Play()
        Write-Host "$($args -join ' ') - exit $status" -ForegroundColor Cyan
    }
}
