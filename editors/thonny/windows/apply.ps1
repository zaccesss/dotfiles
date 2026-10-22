# installs the Zacess theme plugin into Thonny and sets its theme and font.
# usage: .\apply.ps1 [-Theme <theme>] [-Thonny <folder Thonny is installed in>]
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the work is done by ..\shared\apply.py run with Thonny's own Python, which knows where that
# Thonny version reads plugins and settings. only the tracked [view] keys and the interpreter
# change; nothing is backed up: the repo holds every value this writes.
#
# Thonny runs code in its own virtual environment, %USERPROFILE%\.venvs\thonny, so packages from
# Tools > Manage packages stay out of the system Python. it is made from Python 3.15 through the
# Python install manager (py -V:3.15) only when it is missing. it is never rebuilt.
param(
    [string]$Theme = 'deep-dark',
    [string]$Thonny,
    [string]$Venv = (Join-Path $env:USERPROFILE '.venvs\thonny')
)

$ErrorActionPreference = 'Stop'

$themeNames = [ordered]@{
    'deep-dark' = 'Zacess Deep Contrast Dark'; 'deep-contrast-dark' = 'Zacess Deep Contrast Dark'
    'deep-light' = 'Zacess Deep Contrast Light'; 'deep-contrast-light' = 'Zacess Deep Contrast Light'
    'hc-dark' = 'Zacess High Contrast Dark'; 'high-contrast-dark' = 'Zacess High Contrast Dark'
    'hc-light' = 'Zacess High Contrast Light'; 'high-contrast-light' = 'Zacess High Contrast Light'
    'dark' = 'Zacess Dark'; 'light' = 'Zacess Light'; 'cream' = 'Zacess Cream'
    'yellow' = 'Zacess Yellow on Black'; 'yellow-on-black' = 'Zacess Yellow on Black'
}
$key = ($Theme.ToLowerInvariant() -replace '^zacess[ -]', '') -replace ' ', '-'
$name = $themeNames[$key]
if (-not $name) {
    [Console]::Error.WriteLine("Unknown theme: $Theme")
    [Console]::Error.WriteLine('Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow.')
    exit 1
}

if (-not $Thonny) {
    $Thonny = @("${env:ProgramFiles(x86)}\Thonny", "$env:ProgramFiles\Thonny", "$env:LOCALAPPDATA\Programs\Thonny") |
        Where-Object { Test-Path (Join-Path $_ 'python.exe') } | Select-Object -First 1
}
if (-not $Thonny -or -not (Test-Path (Join-Path $Thonny 'python.exe'))) {
    [Console]::Error.WriteLine('No Thonny install found. Pass -Thonny with the folder that holds thonny.exe and python.exe.')
    exit 1
}
# Thonny writes configuration.ini back when it exits, so a change made while it runs is lost
if (Get-Process -Name 'thonny' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('Thonny is running. Quit it first, then run this again.')
    exit 1
}

$venvPython = Join-Path $Venv 'Scripts\python.exe'
if (Test-Path $venvPython) {
    Write-Output "  unchanged  venv  $Venv"
} else {
    $base = $null
    if (Get-Command py -ErrorAction SilentlyContinue) { $base = (& py -V:3.15 -c 'import sys; print(sys.executable)' 2>$null) }
    if (-not $base -or -not (Test-Path $base)) {
        [Console]::Error.WriteLine('No Python 3.15 for the Thonny venv. Install it with: py install 3.15')
        exit 1
    }
    & $base -m venv --upgrade-deps $Venv
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $venvPython)) { [Console]::Error.WriteLine("Could not make the venv at $Venv."); exit 1 }
    Write-Output "  added      venv  $Venv"
}

& (Join-Path $Thonny 'python.exe') -B (Join-Path $PSScriptRoot '..\shared\apply.py') (Join-Path $PSScriptRoot 'settings.json') --theme $name --interpreter $venvPython
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Output 'Done. Start Thonny to pick up the changes.'
