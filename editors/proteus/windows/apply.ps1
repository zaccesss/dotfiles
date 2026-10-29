# sets Proteus 8's schematic, PCB layout and graph viewer colours to one of the Zacess themes.
# usage: .\apply.ps1 [-Theme <theme>] [-Project <.pdsprj file or folder> ...]
#
# -Theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark. -Theme proteus puts back Proteus's own colours: its default schematic colours and its
# Black Paper set for the PCB layout and graphs.
#
# PCB layout and graphs: every theme in ..\shared\themes becomes a colour set beside Proteus's own
# Black Paper and White Paper, so all eight can be picked inside Proteus too. the chosen one
# becomes the active set. Proteus's own sets are never touched.
#
# schematic: Proteus copies its colours from a design template into each new design, so the
# chosen theme is written into every template in Proteus's Templates folder and every new design
# starts in it. an existing design keeps the colours it was made with; -Project rewrites the
# colours inside the named .pdsprj files (or every one under a folder) and nothing else in them.
# a design's own colours can still be changed in Proteus from the Template menu.
#
# nothing is backed up: the repo holds every value this writes.
param(
    [string]$Theme = 'deep-dark',
    [string[]]$Project = @()
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'template.ps1')

$themeNames = [ordered]@{
    'deep-dark' = 'Zacess Deep Contrast Dark'; 'deep-contrast-dark' = 'Zacess Deep Contrast Dark'
    'deep-light' = 'Zacess Deep Contrast Light'; 'deep-contrast-light' = 'Zacess Deep Contrast Light'
    'hc-dark' = 'Zacess High Contrast Dark'; 'high-contrast-dark' = 'Zacess High Contrast Dark'
    'hc-light' = 'Zacess High Contrast Light'; 'high-contrast-light' = 'Zacess High Contrast Light'
    'dark' = 'Zacess Dark'; 'light' = 'Zacess Light'; 'cream' = 'Zacess Cream'
    'yellow' = 'Zacess Yellow on Black'; 'yellow-on-black' = 'Zacess Yellow on Black'
}
$key = ($Theme.ToLowerInvariant() -replace '^zacess[ -]', '') -replace ' ', '-'
# "proteus" puts back Proteus's own colours: its default schematic colours and its Black Paper set
$name = if ($key -in 'proteus', 'default') { 'Proteus' } else { $themeNames[$key] }
if (-not $name) {
    [Console]::Error.WriteLine("Unknown theme: $Theme")
    [Console]::Error.WriteLine('Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream, yellow or proteus.')
    exit 1
}

$root = 'HKCU:\Software\Labcenter Electronics\Proteus 8 Professional'
if (-not (Test-Path "$root\ARES\Colour Sets")) {
    [Console]::Error.WriteLine('No Proteus 8 settings found. Start Proteus once, open the PCB layout, quit it, then run this again.')
    exit 1
}
# Proteus writes its settings back when it exits, so a change made while it runs is lost
if (Get-Process -Name 'PDS' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('Proteus is running. Quit it first, then run this again.')
    exit 1
}

$changes = 0
$active = if ($name -eq 'Proteus') { 'BLACK_PAPER' } else { $null }
$sets = @()
foreach ($file in Get-ChildItem (Join-Path $PSScriptRoot '..\shared\themes') -Filter '*.json') {
    $data = Get-Content $file.FullName -Raw | ConvertFrom-Json
    if ($data.name -eq $name) { $active = $data.set }
    $sets += $data.set
    foreach ($app in 'ARES', 'GVIEW') {
        $path = "$root\$app\Colour Sets\$($data.set)"
        if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        $existing = Get-Item -Path $path
        foreach ($property in $data.values.PSObject.Properties) {
            # GetValue reads a DWORD as a signed 32-bit number, where Get-ItemProperty widens it
            $old = $existing.GetValue($property.Name)
            # JSON reads numbers as 64 bits; the registry keeps them as 32-bit DWORDs
            $value = if ($property.Value -is [string]) { $property.Value } else { [int32]$property.Value }
            if ($null -ne $old -and "$old" -ceq "$value") { continue }
            $kind = if ($value -is [string]) { 'String' } else { 'DWord' }
            New-ItemProperty -Path $path -Name $property.Name -Value $value -PropertyType $kind -Force | Out-Null
            $changes++
        }
    }
}
Write-Output "  $(if ($changes) { 'changed  ' } else { 'unchanged' })  colour sets  $changes values in ARES and GVIEW"
# Zacess sets under an older or cut-short name, which Proteus would list beside the current ones
foreach ($app in 'ARES', 'GVIEW') {
    foreach ($old in Get-ChildItem "$root\$app\Colour Sets" | Where-Object { $_.PSChildName -like 'ZACESS_*' -and $_.PSChildName -notin $sets }) {
        Remove-Item $old.PSPath -Recurse
        Write-Output "  removed    $app  old colour set $($old.PSChildName)"
    }
}
foreach ($app in 'ARES', 'GVIEW') {
    $settings = "$root\$app\Settings"
    if (-not (Test-Path $settings)) { New-Item -Path $settings -Force | Out-Null }
    $old = (Get-ItemProperty -Path $settings -Name 'Active Colour Set' -ErrorAction SilentlyContinue).'Active Colour Set'
    $status = if ($old -ceq $active) { 'unchanged' } else { 'changed  ' }
    Set-ItemProperty -Path $settings -Name 'Active Colour Set' -Value $active
    Write-Output "  $status  $app  Active Colour Set"
}

# the schematic colours for every slot a template holds: the theme's own colour or its fallback for a
# style Proteus's default template does not have
$schematic = if ($name -eq 'Proteus') {
    # a style only some templates carry goes back to Proteus's plain black on white
    [pscustomobject]@{
        colours = Get-Content (Join-Path $PSScriptRoot '..\shared\base\schematic_default.json') -Raw | ConvertFrom-Json
        fallback = [pscustomobject]@{ line = '#000000'; fill = '#ffffff'; text = '#000000' }
    }
} else {
    (Get-Content (Join-Path $PSScriptRoot "..\shared\themes\$name.json") -Raw | ConvertFrom-Json).schematic
}
function Get-WantedColours([byte[]]$Bytes) {
    $want = [ordered]@{}
    foreach ($slot in (Get-TemplateSlots $Bytes).Keys) {
        $own = $schematic.colours.$slot
        $want[$slot] = if ($own) { $own }
                       elseif ($slot -like 'text.*') { $schematic.fallback.text }
                       elseif ($slot -like '*.line') { $schematic.fallback.line }
                       else { $schematic.fallback.fill }
    }
    $want
}

$templates = Join-Path $env:ProgramData 'Labcenter Electronics\Proteus 8 Professional\Templates'
# reading every template's colour slots takes most of a second, so the theme and each template's
# size and write time are noted once they are done. a later run for the same theme skips them
# while none has changed, so zt stays quick
$note = Join-Path $env:LOCALAPPDATA 'zacess\proteus-templates'
$stamp = { param($files) @($name) + @($files | Sort-Object Name | ForEach-Object { "$($_.Name)|$($_.Length)|$($_.LastWriteTimeUtc.Ticks)" }) -join "`n" }
$dtf = @(Get-ChildItem $templates -Filter '*.DTF' -ErrorAction SilentlyContinue)
if ($dtf -and (Test-Path $note) -and [IO.File]::ReadAllText($note) -ceq (& $stamp $dtf)) {
    Write-Output "  unchanged  templates $($dtf.Count) templates, already in $name"
} else {
    foreach ($file in $dtf) {
        $bytes = [IO.File]::ReadAllBytes($file.FullName)
        if (-not (Get-TemplateSlots $bytes)) { Write-Output "  skipped    template  $($file.Name): not laid out as expected"; continue }
        $changed = Write-TemplateColours $bytes (Get-WantedColours $bytes)
        if ($changed) { [IO.File]::WriteAllBytes($file.FullName, $bytes) }
        Write-Output "  $(if ($changed) { 'changed  ' } else { 'unchanged' })  template  $($file.Name)$(if ($changed) { ": $changed colours" })"
    }
    if ($dtf) {
        New-Item -ItemType Directory -Force (Split-Path $note) | Out-Null
        [IO.File]::WriteAllText($note, (& $stamp @(Get-ChildItem $templates -Filter '*.DTF')))
    }
}

if ($Project) {
    Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
    $files = foreach ($item in $Project) {
        if (Test-Path $item -PathType Container) { Get-ChildItem $item -Recurse -Filter '*.pdsprj' } else { Get-Item $item }
    }
    foreach ($file in $files) {
        # a project is a zip; the schematic and its colours are in ROOT.DSN, every other entry is left alone
        try {
            $zip = [IO.Compression.ZipFile]::Open($file.FullName, 'Update')
        } catch {
            # 0x400000 is FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS: a cloud-synced file that is only online
            $why = if ([int]$file.Attributes -band 0x400000) { 'online only and could not be downloaded, so keep it on this device and run this again' } else { 'not a readable project file' }
            Write-Output "  skipped    project   $($file.FullName): $why"
            continue
        }
        try {
            $entry = $zip.GetEntry('ROOT.DSN')
            if (-not $entry) { Write-Output "  skipped    project   $($file.FullName): no schematic"; continue }
            $buffer = New-Object IO.MemoryStream
            $stream = $entry.Open(); $stream.CopyTo($buffer); $stream.Close()
            $bytes = $buffer.ToArray()
            if (-not (Get-TemplateSlots $bytes)) { Write-Output "  skipped    project   $($file.FullName): not laid out as expected"; continue }
            $changed = Write-TemplateColours $bytes (Get-WantedColours $bytes)
            if ($changed) {
                $stream = $entry.Open(); $stream.SetLength(0); $stream.Write($bytes, 0, $bytes.Length); $stream.Close()
            }
            Write-Output "  $(if ($changed) { 'changed  ' } else { 'unchanged' })  project   $($file.FullName)$(if ($changed) { ": $changed colours" })"
        } finally {
            $zip.Dispose()
        }
    }
}

Write-Output "Theme: $name ($active)"
Write-Output 'Done. Start Proteus to pick up the changes.'
