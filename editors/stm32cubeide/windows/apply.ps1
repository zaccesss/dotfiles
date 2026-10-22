# merges the tracked STM32CubeIDE preferences into one workspace's instance scope.
# usage: .\apply.ps1 [-Workspace <path>] [-Theme <theme> | -NoTheme]
#   (the workspace defaults to the newest %USERPROFILE%\STM32CubeIDE\workspace_<version>
#   that STM32CubeIDE has opened)
#
# -Theme merges one of the eight Zacess themes from ..\shared\theme (editor, C
# syntax and Terminal colours, plus the tab outlines for the two Deep Contrast
# themes) and sets the matching Light or Dark workbench theme. It takes a short
# name (deep-dark, deep-light, hc-dark, hc-light, dark, light, cream, yellow),
# an id (deep-contrast-dark) or the full name. the default is deep-dark.
#
# the values live in ..\shared\prefs, the same files mac/apply.sh and
# linux/apply.sh read, plus an optional prefs\ folder next to this script for
# keys that only hold on windows (the font strings). nothing is backed up: the
# repo holds every value it writes. every key it does not track is left as it
# was.
param(
    [string]$Workspace,
    [string]$Theme = 'deep-dark',
    [switch]$NoTheme
)

$ErrorActionPreference = 'Stop'

$shared = Join-Path $PSScriptRoot '..\shared\prefs'
$overlay = Join-Path $PSScriptRoot 'prefs'
$themes = Join-Path $PSScriptRoot '..\shared\theme'

# STM32CubeIDE names its default workspace after its own version, so the newest
# one it has opened is the one in use
if (-not $Workspace) {
    $newest = Get-ChildItem -Path (Join-Path $env:USERPROFILE 'STM32CubeIDE') -Directory -Filter 'workspace_*' -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName '.metadata') -PathType Container } |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $newest) {
        [Console]::Error.WriteLine("No STM32CubeIDE workspace under $(Join-Path $env:USERPROFILE 'STM32CubeIDE').")
        [Console]::Error.WriteLine('Start STM32CubeIDE once, quit it, then run this again or pass -Workspace.')
        exit 1
    }
    $Workspace = $newest.FullName
}

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

# STM32CubeIDE holds these files in memory and writes them back on exit, so a
# merge made while it runs is silently lost
if (Get-Process -Name 'stm32cubeide' -ErrorAction SilentlyContinue) {
    [Console]::Error.WriteLine('STM32CubeIDE is running. Quit it first, then run this again.')
    exit 1
}

# a mistyped path would otherwise create a stray workspace, so the workspace
# must already have been opened by STM32CubeIDE once
if (-not (Test-Path (Join-Path $Workspace '.metadata') -PathType Container)) {
    [Console]::Error.WriteLine("No STM32CubeIDE workspace at $Workspace (no .metadata folder).")
    [Console]::Error.WriteLine('Start STM32CubeIDE once with that workspace, quit it, then run this again.')
    exit 1
}

New-Item -ItemType Directory -Force $settings | Out-Null
Write-Output "Workspace: $Workspace"

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

$fragments = @(Get-ChildItem -Path $shared -Filter '*.prefs' -File)
if (Test-Path $overlay) {
    $fragments += @(Get-ChildItem -Path $overlay -Filter '*.prefs' -File)
}
foreach ($fragment in $fragments) {
    Merge-PrefFile $fragment.FullName (Join-Path $settings $fragment.Name)
}

# an .epf file is what File > Import > Preferences reads: one
# /instance/<plugin>/<key>=<value> line per preference. each line goes into
# that plugin's fragment, then merges like the tracked prefs above
if ($picked) {
    $name, $mode = $picked
    $split = Join-Path ([IO.Path]::GetTempPath()) ("stm32cubeide-theme-" + [guid]::NewGuid())
    New-Item -ItemType Directory -Force $split | Out-Null
    try {
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
    } finally {
        Remove-Item -Recurse -Force $split
    }
    Write-Output "Theme: $name with the $mode workbench theme"
}

Write-Output 'Done. Start STM32CubeIDE to pick up the changes.'
