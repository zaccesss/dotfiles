# sets Zotero's light or dark mode, reader theme and text size to match one of the Zacess themes.
# usage: .\apply.ps1 [-Theme <theme>] [-ProfileDir <profile folder>]
#   (the profile defaults to the one under %APPDATA%\Zotero\Zotero\Profiles)
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# Zotero has no custom interface colours, so each Zacess theme maps to Zotero's dark or light mode
# and the nearest built-in reader theme (..\shared\themes.json). the values go in a marked block
# of the profile's user.js, which Zotero reads on every start; the rest of user.js and prefs.js is
# left as it was. nothing is backed up: the repo holds every value this writes.
param(
    [string]$Theme = 'deep-dark',
    [string]$ProfileDir
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

if (-not $ProfileDir) {
    $ProfileDir = Get-ChildItem (Join-Path $env:APPDATA 'Zotero\Zotero\Profiles') -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName 'prefs.js') } | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $ProfileDir -or -not (Test-Path (Join-Path $ProfileDir 'prefs.js'))) {
    [Console]::Error.WriteLine('No Zotero profile found. Start Zotero once, quit it, then run this again or pass -ProfileDir.')
    exit 1
}
# Zotero rewrites prefs.js when it exits, so a change made while it runs is lost
if (Get-Process -Name 'zotero' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('Zotero is running. Quit it first, then run this again.')
    exit 1
}
Write-Output "Profile: $ProfileDir"

$want = [ordered]@{}
foreach ($source in @((Join-Path $PSScriptRoot '..\shared\prefs.json'))) {
    (Get-Content $source -Raw | ConvertFrom-Json).PSObject.Properties | ForEach-Object { $want[$_.Name] = $_.Value }
}
(Get-Content (Join-Path $PSScriptRoot '..\shared\themes.json') -Raw | ConvertFrom-Json).$name.PSObject.Properties |
    ForEach-Object { $want[$_.Name] = $_.Value }

$begin = '// zacess: managed by the Zacess apply script, edits inside this block are replaced'
$end = '// zacess: end'
$lines = foreach ($k in $want.Keys) {
    $v = $want[$k]
    $literal = if ($v -is [string]) { '"' + ($v -replace '\\', '\\' -replace '"', '\"') + '"' } elseif ($v -is [bool]) { "$v".ToLower() } else { "$v" }
    "user_pref(`"$k`", $literal);"
}
$block = (@($begin) + $lines + @($end)) -join "`n"

$userJs = Join-Path $ProfileDir 'user.js'
$old = if (Test-Path $userJs) { [IO.File]::ReadAllText($userJs) -replace "`r`n", "`n" } else { '' }
# every earlier block goes (whatever its first line says) and one block takes its place
$pattern = '(?s)// zacess: managed[^\n]*\n.*?// zacess: end\n?'
$rest = ([regex]::Replace($old, $pattern, '')).Trim()
$new = (($rest, $block) | Where-Object { $_ }) -join "`n"
$new = $new.TrimEnd() + "`n"
foreach ($k in $want.Keys) {
    $line = ($lines | Where-Object { $_ -like "user_pref(`"$k`",*" })
    $status = if ($old.Contains($line)) { 'unchanged' } elseif ($old.Contains("user_pref(`"$k`",")) { 'changed  ' } else { 'added    ' }
    Write-Output "  $status  user.js  $k"
}
if ($new -cne $old) { [IO.File]::WriteAllText($userJs, $new, (New-Object Text.UTF8Encoding $false)) }

Write-Output "Theme: $name"
Write-Output 'Done. Start Zotero to pick up the changes.'
