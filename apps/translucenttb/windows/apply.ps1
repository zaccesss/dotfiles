# merges the tracked TranslucentTB settings into its live settings.json.
# usage: .\apply.ps1 [-Theme <theme>] [-Settings <path to settings.json>] [-Machine <computer name>]
#   (the settings file defaults to the Store package's RoamingState folder and the machine to this PC)
#
# .\machines\<computer name>.json holds the values one PC keeps for itself, such as its own desktop
# look. they are laid over .\settings.json, so applying the shared file never replaces them.
#
# TranslucentTB has no themes of its own. -Theme is accepted so the bootstrap's apps stage can call
# every app script the same way; it is ignored. only the keys in .\settings.json are written and any
# other key in the live file is left as it was. TranslucentTB watches its settings file and applies
# most changes while it runs, so it is never asked to quit; the taskbar line only appears after it
# restarts. nothing is backed up: the repo holds every value this writes.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Theme', Justification = 'the apps stage passes -Theme to every app script')]
param(
    [string]$Theme = 'deep-dark',
    [string]$Settings = (Join-Path $env:LOCALAPPDATA 'Packages\28017CharlesMilette.TranslucentTB_v826wp6bftszj\RoamingState\settings.json'),
    [string]$Machine = $env:COMPUTERNAME
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path (Split-Path -Parent (Split-Path -Parent $Settings)))) {
    [Console]::Error.WriteLine('TranslucentTB is not installed. Install it with winget install CharlesMilette.TranslucentTB.')
    exit 1
}
# the file only exists once TranslucentTB has started and written its defaults
if (-not (Test-Path $Settings)) {
    Write-Output 'skipped: TranslucentTB has not been started yet. Start it once, then run this again.'
    exit 0
}
Write-Output "Settings: $Settings"

$want = Get-Content (Join-Path $PSScriptRoot 'settings.json') -Raw | ConvertFrom-Json
$machineFile = Join-Path $PSScriptRoot "machines\$Machine.json"
if ($Machine -and (Test-Path $machineFile)) {
    foreach ($section in (Get-Content $machineFile -Raw | ConvertFrom-Json).PSObject.Properties) {
        if ($section.Value -is [pscustomobject] -and $want.($section.Name) -is [pscustomobject]) {
            foreach ($entry in $section.Value.PSObject.Properties) {
                $want.($section.Name) | Add-Member -NotePropertyName $entry.Name -NotePropertyValue $entry.Value -Force
            }
        } else {
            $want | Add-Member -NotePropertyName $section.Name -NotePropertyValue $section.Value -Force
        }
    }
    Write-Output "Machine: $Machine, with its own values from machines\$Machine.json"
}
$live = Get-Content $Settings -Raw | ConvertFrom-Json
$changes = 0

# walks the tracked values one level of objects deep, which is how TranslucentTB nests them
foreach ($section in $want.PSObject.Properties) {
    if ($section.Value -is [pscustomobject]) {
        if ($null -eq $live.PSObject.Properties[$section.Name]) {
            $live | Add-Member -NotePropertyName $section.Name -NotePropertyValue ([pscustomobject]@{})
        }
        $target = $live.($section.Name)
        foreach ($entry in $section.Value.PSObject.Properties) {
            $old = $target.PSObject.Properties[$entry.Name]
            $status = if ($null -eq $old) { 'added    ' } elseif ("$($old.Value)" -eq "$($entry.Value)") { 'unchanged' } else { 'changed  ' }
            if ($status -ne 'unchanged') {
                $target | Add-Member -NotePropertyName $entry.Name -NotePropertyValue $entry.Value -Force
                $changes++
            }
            Write-Output "  $status  $($section.Name).$($entry.Name)"
        }
    } else {
        $old = $live.PSObject.Properties[$section.Name]
        $status = if ($null -eq $old) { 'added    ' } elseif ("$($old.Value)" -eq "$($section.Value)") { 'unchanged' } else { 'changed  ' }
        if ($status -ne 'unchanged') {
            $live | Add-Member -NotePropertyName $section.Name -NotePropertyValue $section.Value -Force
            $changes++
        }
        Write-Output "  $status  $($section.Name)"
    }
}

if ($changes) { $live | ConvertTo-Json -Depth 10 | Set-Content -Path $Settings -Encoding utf8 }
Write-Output 'Done. TranslucentTB applies most changes while it runs; restart it to show the taskbar line.'
