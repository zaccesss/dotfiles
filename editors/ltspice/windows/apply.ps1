# sets LTspice's schematic, waveform and netlist colours to one of the Zacess themes.
# usage: .\apply.ps1 [-Theme <theme>] [-Ini <path to LTspice.ini>]
#   (the ini defaults to %APPDATA%\LTspice.ini (LTspiceXVII.ini from older versions))
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# only the colour entries in ..\shared\themes\<name>.ini change. LTspice writes the start of its
# ini as UTF-16 and the rest as plain bytes, so each entry is replaced byte for byte and every
# other byte is left as it was. nothing is backed up: the repo holds every value this writes.
param(
    [string]$Theme = 'deep-dark',
    [string]$Ini
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

if (-not $Ini) {
    $Ini = @("$env:APPDATA\LTspice.ini", "$env:APPDATA\LTspiceXVII.ini") | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $Ini -or -not (Test-Path $Ini)) {
    [Console]::Error.WriteLine('No LTspice.ini found. Start LTspice once, quit it, then run this again or pass -Ini.')
    exit 1
}
# LTspice writes its ini back when it exits, so a change made while it runs is lost
if (Get-Process -Name 'LTspice', 'XVIIx64', 'XVIIx86' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('LTspice is running. Quit it first, then run this again.')
    exit 1
}
Write-Output "Settings: $Ini"

# latin-1 maps every byte to one character and back, so a UTF-16 start followed by plain bytes
# survives untouched. LTspice 26 writes the whole file as UTF-16, which is read as UTF-16 instead;
# its byte order mark is kept as the first character, so writing it back puts the mark back
$bytes = [IO.File]::ReadAllBytes($Ini)
$latin = [Text.Encoding]::GetEncoding(28591)
$encoding = $latin
if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
    $wide = [Text.Encoding]::Unicode.GetString($bytes)
    if ($wide -match '(?m)^\[Colors\]\r?$') { $encoding = [Text.Encoding]::Unicode }
}
$text = $encoding.GetString($bytes)
$original = $text
if ($text -notmatch '(?m)^\[Colors\]\r?$') {
    [Console]::Error.WriteLine("$Ini has no [Colors] section yet. Open the colour settings in LTspice once, quit it, then run this again.")
    exit 1
}
foreach ($line in Get-Content (Join-Path $PSScriptRoot "..\shared\themes\$name.ini")) {
    if ($line -notmatch '^([A-Za-z0-9]+)=(\d+)$') { continue }
    $entry, $value = $Matches[1], $Matches[2]
    $pattern = "(?m)^$([regex]::Escape($entry))=(\d+)(\r?)$"
    $found = [regex]::Match($text, $pattern)
    if ($found.Success) {
        $status = if ($found.Groups[1].Value -eq $value) { 'unchanged' } else { 'changed  ' }
        $text = [regex]::Replace($text, $pattern, "$entry=$value`$2", 1)
    } else {
        $status = 'added    '
        $text = [regex]::Replace($text, '(?m)^\[Colors\](\r?)$', "[Colors]`$1`n$entry=$value`$1", 1)
    }
    Write-Output "  $status  [Colors]  $entry"
}
if ($text -cne $original) { [IO.File]::WriteAllBytes($Ini, $encoding.GetBytes($text)) }

Write-Output "Theme: $name"
Write-Output 'Done. Start LTspice to pick up the changes.'
