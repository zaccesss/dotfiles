# installs the Zacess themes in Notepad++ and makes one of them the active theme.
# usage: .\apply.ps1 [-Theme <theme>] [-ConfigDir <folder>]
#   (the config folder defaults to %APPDATA%\Notepad++)
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# the themes from ..\themes are copied into <config>\themes. config.xml turns Notepad++'s dark
# mode on or off to match and names the chosen theme for that mode; every other setting is left
# as it was. nothing is backed up: the repo holds every value this writes.
param(
    [string]$Theme = 'deep-dark',
    [string]$ConfigDir = (Join-Path $env:APPDATA 'Notepad++')
)

$ErrorActionPreference = 'Stop'
$themes = Join-Path $PSScriptRoot '..\themes'

$themeNames = [ordered]@{
    'deep-dark' = @('Zacess Deep Contrast Dark', 'dark'); 'deep-contrast-dark' = @('Zacess Deep Contrast Dark', 'dark')
    'deep-light' = @('Zacess Deep Contrast Light', 'light'); 'deep-contrast-light' = @('Zacess Deep Contrast Light', 'light')
    'hc-dark' = @('Zacess High Contrast Dark', 'dark'); 'high-contrast-dark' = @('Zacess High Contrast Dark', 'dark')
    'hc-light' = @('Zacess High Contrast Light', 'light'); 'high-contrast-light' = @('Zacess High Contrast Light', 'light')
    'dark' = @('Zacess Dark', 'dark'); 'light' = @('Zacess Light', 'light'); 'cream' = @('Zacess Cream', 'light')
    'yellow' = @('Zacess Yellow on Black', 'dark'); 'yellow-on-black' = @('Zacess Yellow on Black', 'dark')
}
$key = ($Theme.ToLowerInvariant() -replace '^zacess[ -]', '') -replace ' ', '-'
$picked = $themeNames[$key]
if (-not $picked) {
    [Console]::Error.WriteLine("Unknown theme: $Theme")
    [Console]::Error.WriteLine('Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow.')
    exit 1
}
$name, $mode = $picked

$configFile = Join-Path $ConfigDir 'config.xml'
if (-not (Test-Path $configFile)) {
    [Console]::Error.WriteLine("No Notepad++ settings at $configFile.")
    [Console]::Error.WriteLine('Start Notepad++ once, quit it, then run this again or pass -ConfigDir.')
    exit 1
}
# Notepad++ writes config.xml back when it exits, so a change made while it runs is lost
if (Get-Process -Name 'notepad++' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('Notepad++ is running. Quit it first, then run this again.')
    exit 1
}
Write-Output "Settings: $ConfigDir"

$target = Join-Path $ConfigDir 'themes'
New-Item -ItemType Directory -Force $target | Out-Null
foreach ($file in Get-ChildItem $themes -Filter 'Zacess *.xml') {
    $dest = Join-Path $target $file.Name
    $status = if (-not (Test-Path $dest)) { 'added    ' } elseif ((Get-FileHash $dest).Hash -eq (Get-FileHash $file.FullName).Hash) { 'unchanged' } else { 'changed  ' }
    if ($status -ne 'unchanged') { Copy-Item $file.FullName $dest -Force }
    Write-Output "  $status  themes  $($file.Name)"
}

$raw = [IO.File]::ReadAllText($configFile)
[xml]$config = $raw
$configs = $config.NotepadPlus.GUIConfigs
function Set-Attribute($node, [string]$attribute, [string]$value, [string]$label) {
    $old = $node.GetAttribute($attribute)
    $status = if ($old -ceq $value) { 'unchanged' } elseif ($old) { 'changed  ' } else { 'added    ' }
    $node.SetAttribute($attribute, $value)
    Write-Output "  $status  config.xml  $label"
}
# Notepad++ picks the theme for its dark or light mode by file name and rewrites stylerTheme from
# that on exit, so only the mode and its theme name are set
$dark = $configs.GUIConfig | Where-Object { $_.name -eq 'DarkMode' }
if ($dark) {
    Set-Attribute $dark 'enable' $(if ($mode -eq 'dark') { 'yes' } else { 'no' }) 'DarkMode enable'
    Set-Attribute $dark "$($mode)ThemeName" "$name.xml" "DarkMode $($mode)ThemeName"
}

$settings = New-Object Xml.XmlWriterSettings
$settings.Indent = $true
$settings.Encoding = New-Object Text.UTF8Encoding $false
$buffer = New-Object IO.StringWriter
$writer = [Xml.XmlWriter]::Create($buffer, $settings)
$config.Save($writer)
$writer.Close()
$text = $buffer.ToString() -replace 'encoding="utf-16"', 'encoding="UTF-8"'
if ($text -cne $raw) { [IO.File]::WriteAllText($configFile, $text, (New-Object Text.UTF8Encoding $false)) }

Write-Output "Theme: $name with Notepad++'s $mode mode"
Write-Output 'Done. Start Notepad++ to pick up the changes.'
