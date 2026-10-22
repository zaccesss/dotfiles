# merges the tracked Eclipse preferences into one workspace's instance scope.
# usage: .\apply.ps1 [-Workspace <path>] [-Theme <theme> | -NoTheme]
#   (the workspace defaults to %USERPROFILE%\eclipse-workspace)
#
# the values live in prefs\, the same files apply.sh reads, so no value is
# written out in more than one place. nothing is backed up: the repo holds
# every value it writes. every key it does not track is left as it was.
#
# -Theme imports one of the eight Zacess themes from theme\ (editor
# and Terminal view colours, plus the tab outlines for the two Deep Contrast
# themes) and sets the matching Light or Dark workbench theme. It takes a short
# name (deep-dark, deep-light, hc-dark, hc-light, dark, light, cream, yellow),
# an id (deep-contrast-dark) or the full name. the default is deep-dark.
#
# it also adds PowerShell 7 to the Terminal view's list of local shells.
param(
    [string]$Workspace = (Join-Path $env:USERPROFILE 'eclipse-workspace'),
    [string]$Theme = 'deep-dark',
    [switch]$NoTheme
)

$ErrorActionPreference = 'Stop'

$prefs = Join-Path $PSScriptRoot 'prefs'
$themes = Join-Path $PSScriptRoot 'theme'

$themeNames = [ordered]@{
    'deep-dark' = @('Zacess Deep Contrast Dark', 'dark'); 'deep-contrast-dark' = @('Zacess Deep Contrast Dark', 'dark')
    'deep-light' = @('Zacess Deep Contrast Light', 'light'); 'deep-contrast-light' = @('Zacess Deep Contrast Light', 'light')
    'hc-dark' = @('Zacess High Contrast Dark', 'dark'); 'high-contrast-dark' = @('Zacess High Contrast Dark', 'dark')
    'hc-light' = @('Zacess High Contrast Light', 'light'); 'high-contrast-light' = @('Zacess High Contrast Light', 'light')
    'dark' = @('Zacess Dark', 'dark'); 'light' = @('Zacess Light', 'light'); 'cream' = @('Zacess Cream', 'light')
    'yellow' = @('Zacess Yellow on Black', 'dark'); 'yellow-on-black' = @('Zacess Yellow on Black', 'dark')
}
$picked = $null
if (-not $NoTheme) {
    $key = ($Theme.ToLowerInvariant() -replace '^zacess[ -]', '') -replace ' ', '-'
    $picked = $themeNames[$key]
    if (-not $picked) {
        [Console]::Error.WriteLine("Unknown theme: $Theme")
        [Console]::Error.WriteLine('Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow.')
        exit 1
    }
}

$settings = Join-Path $Workspace '.metadata\.plugins\org.eclipse.core.runtime\.settings'

# eclipse holds these files in memory and writes them back on exit, so a merge
# made while it runs is silently lost
if (Get-Process -Name 'eclipse' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('Eclipse is running. Quit it first, then run this again.')
    exit 1
}

# a mistyped path would otherwise create a stray workspace, so the workspace
# must already have been opened by eclipse once
if (-not (Test-Path (Join-Path $Workspace '.metadata') -PathType Container)) {
    [Console]::Error.WriteLine("No Eclipse workspace at $Workspace (no .metadata folder).")
    [Console]::Error.WriteLine('Start Eclipse once with that workspace, quit it, then run this again.')
    exit 1
}

New-Item -ItemType Directory -Force $settings | Out-Null

function Get-PrefKey([string]$line) {
    $i = $line.IndexOf('=')
    if ($i -lt 0) { return $null }
    return $line.Substring(0, $i)
}

# replaces or appends each key=value line from the fragment and leaves every
# other line of the target alone. lines are compared as plain text, so the
# backslashes in the key binding XML are never reinterpreted.
function Merge-PrefFile([string]$fragment, [string]$target) {
    $name = Split-Path $target -Leaf
    $want = [ordered]@{}
    foreach ($line in [IO.File]::ReadAllLines($fragment)) {
        if ($line -match '^\s*(#|$)') { continue }
        $want[(Get-PrefKey $line)] = $line
    }

    if (-not (Test-Path $target)) {
        [IO.File]::WriteAllLines($target, [string[]]@('eclipse.preferences.version=1'))
    }
    $old = [IO.File]::ReadAllLines($target)
    $done = @{}
    $new = [Collections.Generic.List[string]]::new()

    foreach ($line in $old) {
        $key = Get-PrefKey $line
        if ($null -ne $key -and $want.Contains($key)) {
            if ($done.ContainsKey($key)) { continue }
            $status = if ($line -ceq $want[$key]) { 'unchanged' } else { 'changed  ' }
            Write-Output "  $status  $name  $key"
            $new.Add($want[$key])
            $done[$key] = $true
            continue
        }
        $new.Add($line)
    }
    foreach ($key in $want.Keys) {
        if (-not $done.ContainsKey($key)) {
            Write-Output "  added      $name  $key"
            $new.Add($want[$key])
        }
    }

    if (($old -join "`n") -cne ($new.ToArray() -join "`n")) {
        [IO.File]::WriteAllLines($target, $new.ToArray())
    }
}

foreach ($fragment in Get-ChildItem -Path $prefs -Filter '*.prefs' -File) {
    Merge-PrefFile $fragment.FullName (Join-Path $settings $fragment.Name)
}

# an .epf file is what File > Import > Preferences reads: one
# /instance/<plugin>/<key>=<value> line per preference. each line goes into
# that plugin's fragment, then merges like the tracked prefs above
if ($picked) {
    $name, $mode = $picked
    $split = Join-Path ([IO.Path]::GetTempPath()) ("eclipse-theme-" + [guid]::NewGuid())
    New-Item -ItemType Directory -Force $split | Out-Null
    foreach ($epf in @((Join-Path $themes "$name.epf"), (Join-Path $themes "$name borders.epf"))) {
        if (-not (Test-Path $epf)) { continue }
        foreach ($line in [IO.File]::ReadAllLines($epf)) {
            if (-not $line.StartsWith('/instance/')) { continue }
            $rest = $line.Substring(10)
            $slash = $rest.IndexOf('/')
            [IO.File]::AppendAllLines((Join-Path $split ($rest.Substring(0, $slash) + '.prefs')), [string[]]@($rest.Substring($slash + 1)))
        }
    }
    $themeId = if ($mode -eq 'dark') { 'org.eclipse.e4.ui.css.theme.e4_dark' } else { 'org.eclipse.e4.ui.css.theme.e4_default' }
    [IO.File]::WriteAllLines((Join-Path $split 'org.eclipse.e4.ui.css.swt.theme.prefs'), [string[]]@("themeid=$themeId"))
    foreach ($fragment in Get-ChildItem -Path $split -Filter '*.prefs' -File) {
        Merge-PrefFile $fragment.FullName (Join-Path $settings $fragment.Name)
    }
    Remove-Item -Recurse -Force $split
    Write-Output "Theme: $name with Eclipse's $mode workbench theme"
}

# the Terminal view's local shells live outside the .prefs files. its plain
# button always starts ComSpec (Command Prompt), so PowerShell 7 is listed here
# and picked from the button's dropdown. the path is PowerShell's launcher in
# WindowsApps, which keeps working when PowerShell updates
$executables = Join-Path $Workspace '.metadata\.plugins\org.eclipse.terminal.view.ui\.executables'
$dataFile = Join-Path $executables 'data.properties'
$pwsh = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\pwsh.exe'
# java properties files escape a backslash and a colon
$escaped = $pwsh.Replace('\', '\\').Replace(':', '\:')
$pwshEntry = [ordered]@{ Name = 'PowerShell 7'; Path = $escaped; Args = '-NoLogo'; Translate = 'false' }
New-Item -ItemType Directory -Force $executables | Out-Null
$current = if (Test-Path $dataFile) { [IO.File]::ReadAllLines($dataFile) } else { @() }

# each shell is a group of <index>.<field>=<value> lines. the shells already listed (Git Bash or a
# WSL distribution, say) are kept with every field; PowerShell 7 goes first and the rest move down
$other = [Collections.Generic.List[string]]::new()
$groups = [Collections.Generic.SortedDictionary[int, object]]::new()
foreach ($line in $current) {
    if ($line -match '^(\d+)\.([^=]+)=(.*)$') {
        $index = [int]$Matches[1]
        if (-not $groups.ContainsKey($index)) { $groups[$index] = [ordered]@{} }
        $groups[$index][$Matches[2]] = $Matches[3]
    } else {
        $other.Add($line)
    }
}
$hasPwsh = $false
foreach ($group in $groups.Values) {
    if ($group['Name'] -eq 'PowerShell 7') { $hasPwsh = $true }
}
if ($hasPwsh) {
    Write-Output '  unchanged  Terminal view  PowerShell 7'
} else {
    $lines = [Collections.Generic.List[string]]::new()
    foreach ($line in $other) { $lines.Add($line) }
    $shells = @($pwshEntry) + @($groups.Values)
    for ($i = 0; $i -lt $shells.Count; $i++) {
        foreach ($field in $shells[$i].Keys) { $lines.Add("$i.$field=$($shells[$i][$field])") }
    }
    [IO.File]::WriteAllLines($dataFile, $lines.ToArray())
    Write-Output '  added      Terminal view  PowerShell 7, first in the list'
}

Write-Output 'Done. Start Eclipse to pick up the changes.'
