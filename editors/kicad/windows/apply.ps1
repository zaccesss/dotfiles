# installs the eight Zacess colour themes for KiCad and makes one of them the theme of every editor.
# usage: .\apply.ps1 [-Theme <theme>] [-ConfigDir <folder>]
#   (the config folder defaults to the newest version folder under %APPDATA%\kicad; when
#   KICAD_CONFIG_HOME is set it is used instead, as it is by KiCad itself)
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the theme files go into <config>\colors, where KiCad lists them under Preferences > Colors. the
# chosen one is written to appearance.color_theme in each editor's settings file that already
# has the key. nothing else in those files changes. when KiCad has never been started there
# is nothing to change, so the script says so and stops without an error. nothing is backed up:
# the repo holds every value this writes.
param(
    [string]$Theme = 'deep-dark',
    [string]$ConfigDir = ''
)

$ErrorActionPreference = 'Stop'
$shared = Join-Path $PSScriptRoot '..\shared'

$themeIds = [ordered]@{
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
$chosen = "zacess-$id"

if (-not $ConfigDir) {
    $base = if ($env:KICAD_CONFIG_HOME) { $env:KICAD_CONFIG_HOME } else { Join-Path $env:APPDATA 'kicad' }
    if (Test-Path $base) {
        # the newest version folder is the one the installed KiCad reads
        $newest = Get-ChildItem $base -Directory | Where-Object { $_.Name -match '^\d+\.\d+$' } |
            Sort-Object { [version]$_.Name } | Select-Object -Last 1
        if ($newest) { $ConfigDir = $newest.FullName }
    }
}
if (-not $ConfigDir -or -not (Test-Path $ConfigDir)) {
    Write-Output 'KiCad is not set up here (no version folder under %APPDATA%\kicad), skipped.'
    Write-Output 'Install KiCad, start it once, quit it, then run this again or pass -ConfigDir.'
    exit 0
}

# KiCad holds its settings in memory and writes every file back on exit, so a change made while
# any of its editors runs is lost
$running = Get-Process -Name kicad, eeschema, pcbnew, gerbview, pl_editor, pcb_calculator, bitmap2component -ErrorAction SilentlyContinue
if ($running) {
    [Console]::Error.WriteLine('KiCad is running. Quit it and every editor it opened, then run this again.')
    exit 1
}
Write-Output "Settings: $ConfigDir"

$utf8 = New-Object Text.UTF8Encoding $false
$colors = Join-Path $ConfigDir 'colors'
New-Item -ItemType Directory -Force $colors | Out-Null
foreach ($file in Get-ChildItem (Join-Path $shared 'colors') -Filter 'zacess-*.json' | Sort-Object Name) {
    $target = Join-Path $colors $file.Name
    $text = [IO.File]::ReadAllText($file.FullName)
    if (-not (Test-Path $target)) {
        $status = 'added    '
    } elseif ([IO.File]::ReadAllText($target) -cne $text) {
        $status = 'changed  '
    } else {
        Write-Output "  unchanged  colors  $($file.Name)"
        continue
    }
    [IO.File]::WriteAllText($target, $text, $utf8)
    Write-Output "  $status  colors  $($file.Name)"
}

$touched = 0
foreach ($file in Get-ChildItem $ConfigDir -Filter '*.json' | Sort-Object Name) {
    try {
        $data = Get-Content $file.FullName -Raw | ConvertFrom-Json -AsHashtable
    } catch {
        continue
    }
    if ($data -isnot [Collections.IDictionary] -or $data['appearance'] -isnot [Collections.IDictionary] -or -not $data['appearance'].Contains('color_theme')) {
        continue
    }
    $touched++
    if ($data['appearance']['color_theme'] -ceq $chosen) {
        Write-Output "  unchanged  $($file.Name)  appearance.color_theme"
        continue
    }
    $data['appearance']['color_theme'] = $chosen
    [IO.File]::WriteAllText($file.FullName, ($data | ConvertTo-Json -Depth 32) + "`n", $utf8)
    Write-Output "  changed    $($file.Name)  appearance.color_theme"
}
if (-not $touched) {
    Write-Output '  no editor settings yet: start KiCad once, quit it, then run this again'
}

Write-Output "Theme: $chosen"
Write-Output 'Done. Start KiCad to pick up the changes. An editor opened for the first time later starts on KiCad''s default, so run this again after that.'
