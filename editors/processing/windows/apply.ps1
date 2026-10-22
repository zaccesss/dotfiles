# puts one of the eight Zacess themes in Processing's sketchbook and sets Geist Mono as its editor font.
# usage: .\apply.ps1 [-Theme <theme>] [-Prefs <preferences.txt>]
#   (preferences.txt defaults to %APPDATA%\Processing\preferences.txt)
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# Processing loads theme.txt from the sketchbook folder over whichever built-in theme is picked,
# so the chosen theme is written there. a theme.txt this script did not write is never replaced.
# the editor font is merged into preferences.txt under its GDI family name, GeistMono NFM, since
# Java on Windows looks fonts up by that name. every other line is left as it was and nothing is
# backed up: the repo holds every value this writes.
param(
    [string]$Theme = 'deep-dark',
    [string]$Prefs = (Join-Path $env:APPDATA 'Processing\preferences.txt')
)

$ErrorActionPreference = 'Stop'

$themeIds = @{
    'deep-dark' = 'deep-contrast-dark'; 'deep-contrast-dark' = 'deep-contrast-dark'
    'deep-light' = 'deep-contrast-light'; 'deep-contrast-light' = 'deep-contrast-light'
    'hc-dark' = 'high-contrast-dark'; 'high-contrast-dark' = 'high-contrast-dark'
    'hc-light' = 'high-contrast-light'; 'high-contrast-light' = 'high-contrast-light'
    'dark' = 'dark'; 'light' = 'light'; 'cream' = 'cream'
    'yellow' = 'yellow-on-black'; 'yellow-on-black' = 'yellow-on-black'
}
$key = ($Theme.ToLowerInvariant() -replace '^zacess[ -]', '') -replace ' ', '-'
$id = $themeIds[$key]
if (-not $id) {
    [Console]::Error.WriteLine("Unknown theme: $Theme")
    [Console]::Error.WriteLine('Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow.')
    exit 1
}

if (-not (Test-Path $Prefs)) {
    Write-Output "Processing is not set up here (no $Prefs), skipped."
    Write-Output 'Start Processing once, quit it, then run this again or pass -Prefs.'
    exit 0
}
# Processing holds its preferences in memory and writes them back on exit, so a change made while
# it runs is lost
if (Get-Process -Name 'Processing' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('Processing is running. Quit it first, then run this again.')
    exit 1
}
Write-Output "Preferences: $Prefs"
$utf8 = New-Object Text.UTF8Encoding $false

$lines = [IO.File]::ReadAllLines($Prefs)
# the sketchbook is ~\dev\projects\processing, the projects folder every editor shares. it holds
# the installed libraries, modes and tools too, so moving an existing sketchbook there is a step of
# its own (README)
$sketchbook = Join-Path $env:USERPROFILE 'dev\projects\processing'
if (-not (Test-Path $sketchbook)) {
    New-Item -ItemType Directory -Force $sketchbook | Out-Null
    Write-Output "  added      folder  $sketchbook"
}
$want = [ordered]@{ 'sketchbook.path.four' = $sketchbook -replace '\\', '/' }

$target = Join-Path $sketchbook 'theme.txt'
$text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot "..\shared\themes\zacess-$id.txt"))
if (Test-Path $target) {
    $old = [IO.File]::ReadAllText($target)
    if (-not $old.StartsWith('# Zacess theme for Processing')) {
        [Console]::Error.WriteLine("$target is a theme this script did not write, so it was left alone. Move it out of the sketchbook to use a Zacess theme.")
        exit 1
    }
    $status = if ($old -ceq $text) { 'unchanged' } else { 'changed  ' }
} else {
    $status = 'added    '
}
if ($status -ne 'unchanged') { [IO.File]::WriteAllText($target, $text, $utf8) }
Write-Output "  $status  $target"

# the Mac and Linux font name in ..\shared\preferences.txt is not one Windows knows, so only the
# keys are shared and the value is the GDI family name
$want['editor.font.family'] = 'GeistMono NFM'
$out = New-Object Collections.Generic.List[string]
$done = @{}
foreach ($line in $lines) {
    $name = if ($line -match '^([^=]+)=') { $Matches[1] } else { $null }
    if ($name -and $want.Contains($name)) {
        Write-Output "  $(if ($line -ceq "$name=$($want[$name])") { 'unchanged' } else { 'changed  ' })  preferences.txt  $name"
        $out.Add("$name=$($want[$name])"); $done[$name] = $true
    } else {
        $out.Add($line)
    }
}
$added = $false
foreach ($name in $want.Keys) {
    if (-not $done[$name]) { Write-Output "  added      preferences.txt  $name"; $out.Add("$name=$($want[$name])"); $added = $true }
}
# Processing keeps the file sorted by key, so a new key goes where it would put it
$result = if ($added) { @($out | Sort-Object { $_ } -CaseSensitive) } else { @($out) }
if (($result -join "`n") -cne ($lines -join "`n")) { [IO.File]::WriteAllLines($Prefs, [string[]]$result, $utf8) }

Write-Output "Theme: $(($text -split "`r?`n")[0] -replace '^# Zacess theme for Processing: ', '')"
Write-Output 'Done. Start Processing to pick up the changes.'
