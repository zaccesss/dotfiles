# merges the tracked Arduino IDE 2 settings into settings.json and installs the Zacess themes.
# usage: .\apply.ps1 [-Theme <theme>] [-ConfigDir <folder>]
#   (the config folder defaults to %USERPROFILE%\.arduinoIDE)
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the themes come from the pinned Zacess Themes .vsix in ..\shared\theme-package.json, checked
# against its SHA-256 digest and dropped into <config>\plugins, which Arduino IDE 2 loads like a
# VS Code extension. only the keys in ..\shared\settings.json are written; every other setting
# is left as it was. nothing is backed up: the repo holds every value this writes.
param(
    [string]$Theme = 'deep-dark',
    [string]$ConfigDir = (Join-Path $env:USERPROFILE '.arduinoIDE')
)

$ErrorActionPreference = 'Stop'
$shared = Join-Path $PSScriptRoot '..\shared'

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

$settingsFile = Join-Path $ConfigDir 'settings.json'
if (-not (Test-Path $settingsFile)) {
    [Console]::Error.WriteLine("No Arduino IDE settings at $settingsFile.")
    [Console]::Error.WriteLine('Start Arduino IDE once, quit it, then run this again or pass -ConfigDir.')
    exit 1
}

# the IDE holds its settings in memory and writes them back on exit, so a merge made while it
# runs is lost
if (Get-Process -Name 'Arduino IDE' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('Arduino IDE is running. Quit it first, then run this again.')
    exit 1
}
Write-Output "Settings: $ConfigDir"

$package = Get-Content (Join-Path $shared 'theme-package.json') -Raw | ConvertFrom-Json
$plugins = Join-Path $ConfigDir 'plugins'
New-Item -ItemType Directory -Force $plugins | Out-Null
$target = Join-Path $plugins "$($package.name)-$($package.version).vsix"
if ((Test-Path $target) -and (Get-FileHash $target -Algorithm SHA256).Hash -eq $package.sha256) {
    Write-Output "  unchanged  plugins  $(Split-Path $target -Leaf)"
} else {
    $download = Join-Path ([IO.Path]::GetTempPath()) "zacess-themes-$PID.vsix"
    try {
        Invoke-WebRequest -Uri $package.url -OutFile $download -UseBasicParsing
        if ((Get-FileHash $download -Algorithm SHA256).Hash -ne $package.sha256) {
            [Console]::Error.WriteLine('The Zacess Themes download does not match its pinned checksum, so it was not installed')
            exit 1
        }
        Move-Item $download $target -Force
    } finally {
        Remove-Item $download -Force -ErrorAction SilentlyContinue
    }
    Write-Output "  added      plugins  $(Split-Path $target -Leaf)"
}
# an older version left beside it would load a second copy of every theme
Get-ChildItem $plugins -Filter "$($package.name)-*.vsix" | Where-Object { $_.FullName -ne $target } | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Output "  removed    plugins  $($_.Name)"
}

$want = Get-Content (Join-Path $shared 'settings.json') -Raw | ConvertFrom-Json -AsHashtable
$want['workbench.colorTheme'] = $name
$raw = Get-Content $settingsFile -Raw
$current = if ($raw) { $raw | ConvertFrom-Json -AsHashtable } else { [ordered]@{} }
foreach ($k in $want.Keys) {
    $old = if ($current.Contains($k)) { $current[$k] | ConvertTo-Json -Depth 10 -Compress } else { $null }
    $new = $want[$k] | ConvertTo-Json -Depth 10 -Compress
    $status = if ($null -eq $old) { 'added    ' } elseif ($old -ceq $new) { 'unchanged' } else { 'changed  ' }
    Write-Output "  $status  settings.json  $k"
    $current[$k] = $want[$k]
}
$text = ($current | ConvertTo-Json -Depth 10) + "`n"
if ($raw -cne $text) { [IO.File]::WriteAllText($settingsFile, $text, (New-Object Text.UTF8Encoding $false)) }

# the sketchbook is ~\dev\projects\arduino, the projects folder every editor shares. it holds the
# installed libraries too, so moving an existing sketchbook there is a step of its own (README)
$sketchbook = Join-Path $env:USERPROFILE 'dev\projects\arduino'
if (-not (Test-Path $sketchbook)) {
    New-Item -ItemType Directory -Force $sketchbook | Out-Null
    Write-Output "  added      folder  $sketchbook"
}
$cli = Join-Path $ConfigDir 'arduino-cli.yaml'
$yaml = if (Test-Path $cli) { [IO.File]::ReadAllText($cli) } else { '' }
$line = [regex]::Match($yaml, '(?m)^(\s+user:[ \t]*)(.*?)\r?$')
$status = if (-not $line.Success) { 'added    ' } elseif ($line.Groups[2].Value -eq $sketchbook) { 'unchanged' } else { 'changed  ' }
if ($status -ne 'unchanged') {
    $yaml = if ($line.Success) { $yaml.Remove($line.Groups[2].Index, $line.Groups[2].Length).Insert($line.Groups[2].Index, $sketchbook) }
            elseif ($yaml -match '(?m)^directories:') { $yaml -replace '(?m)^(directories:\r?\n)', "`$1    user: $sketchbook`n" }
            else { $yaml.TrimEnd() + "`ndirectories:`n    user: $sketchbook`n" }
    [IO.File]::WriteAllText($cli, $yaml, (New-Object Text.UTF8Encoding $false))
}
Write-Output "  $status  arduino-cli.yaml  directories.user"

Write-Output "Theme: $name"
Write-Output 'Done. Start Arduino IDE to pick up the changes.'
