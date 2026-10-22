# gives the AMD Vivado text editor one of the eight Zacess themes and Geist Mono.
# usage: .\apply.ps1 [-Theme <theme>] [-ConfigDir <folder>]
#   (the config folder defaults to the newest %APPDATA%\Xilinx\Vivado\<version>)
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# Vivado keeps Tools > Settings in <config>\vivado.xml and writes it back on exit. this merges the
# text editor's CODE_EDITOR_* colours, its syntax styles for every language and its font name
# from ..\shared\themes into that file and leaves every other setting (device views, layouts, the
# window theme) as it was. Java on Windows knows the font by its short family name, GeistMono NFM.
# the keys come from AMD's UG893 and a published Vivado theme, not yet from a real install: see
# the README. when Vivado has never been started there is nothing to change, so the script says
# so and stops without an error. nothing is backed up: the repo holds every value this writes.
param(
    [string]$Theme = 'deep-dark',
    [string]$ConfigDir = ''
)

$ErrorActionPreference = 'Stop'
$shared = Join-Path $PSScriptRoot '..\shared'
$font = 'GeistMono NFM'

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

if (-not $ConfigDir) {
    $base = Join-Path $env:APPDATA 'Xilinx\Vivado'
    if (Test-Path $base) {
        $newest = Get-ChildItem $base -Directory | Where-Object { $_.Name -match '^20\d\d\.\d+' } |
            Sort-Object { [version]($_.Name -replace '[^\d.]', '') } | Select-Object -Last 1
        if ($newest) { $ConfigDir = $newest.FullName }
    }
}
$settings = if ($ConfigDir) { Join-Path $ConfigDir 'vivado.xml' } else { '' }
if (-not $settings -or -not (Test-Path $settings)) {
    Write-Output 'Vivado is not set up here (no vivado.xml under %APPDATA%\Xilinx\Vivado\<version>), skipped.'
    Write-Output 'Install Vivado, start it once, quit it, then run this again or pass -ConfigDir.'
    exit 0
}

# Vivado holds its settings in memory and writes vivado.xml back on exit, so a change made while
# it runs is lost
if (Get-Process -Name vivado -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('Vivado is running. Quit it first, then run this again.')
    exit 1
}
Write-Output "Settings: $settings"

$themeData = Get-Content (Join-Path $shared "themes\zacess-$id.json") -Raw | ConvertFrom-Json
$sections = @('code_editor_syntax_styles') + (@('Generic', 'Verilog', 'VHDL', 'XDC', 'Tcl', 'TSM', 'SyntaxCheck') |
    ForEach-Object { "code_editor_syntax_styles_$_" })

$xml = New-Object Xml.XmlDocument
$xml.PreserveWhitespace = $false
$xml.Load($settings)
$root = $xml.DocumentElement

# an XmlElement enumerates its children when it leaves a function, so the helper only makes a
# missing element and each caller picks the element up itself
function Add-Missing($parent, $name) {
    if ($null -eq $parent.SelectSingleNode($name)) { [void]$parent.AppendChild($xml.CreateElement($name)) }
}

Add-Missing $root 'general_color'
$colours = $root.SelectSingleNode('general_color')
foreach ($property in $themeData.general_color.PSObject.Properties) {
    Add-Missing $colours $property.Name
    $colours.SelectSingleNode($property.Name).SetAttribute('color', $property.Value)
}
Add-Missing $root 'general'
$general = $root.SelectSingleNode('general')
foreach ($section in $sections) {
    Add-Missing $general $section
    $node = $general.SelectSingleNode($section)
    $node.RemoveAll()
    foreach ($style in $themeData.syntax_styles) {
        $element = $xml.CreateElement('syntax_style')
        foreach ($property in $style.PSObject.Properties | Sort-Object Name) {
            $element.SetAttribute($property.Name, $property.Value)
        }
        $node.AppendChild($element) | Out-Null
    }
}
$fontNode = $general.SelectSingleNode('CODE_EDITOR_FONT')
if ($null -eq $fontNode) {
    $fontNode = $general.AppendChild($xml.CreateElement('CODE_EDITOR_FONT'))
    $fontNode.SetAttribute('font_size', '14')
}
$fontNode.SetAttribute('font_name', $font)

$writerSettings = New-Object Xml.XmlWriterSettings
$writerSettings.Indent = $true
$writerSettings.IndentChars = '    '
$writerSettings.Encoding = New-Object Text.UTF8Encoding $false
$buffer = New-Object IO.MemoryStream
$writer = [Xml.XmlWriter]::Create($buffer, $writerSettings)
$xml.Save($writer)
$writer.Dispose()
$text = $writerSettings.Encoding.GetString($buffer.ToArray()) + "`n"
if ([IO.File]::ReadAllText($settings) -ceq $text) {
    Write-Output '  unchanged  vivado.xml  text editor colours, syntax styles and font'
} else {
    [IO.File]::WriteAllText($settings, $text, $writerSettings.Encoding)
    Write-Output '  changed    vivado.xml  text editor colours, syntax styles and font'
}

Write-Output "Theme: zacess-$id"
Write-Output 'Done. Start Vivado to pick up the changes. Its window theme (Tools > Settings > Display) is not changed: pick the dark or light one by hand to match.'
