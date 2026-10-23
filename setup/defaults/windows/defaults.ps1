#Requires -Version 5.1
<#
.SYNOPSIS
    Windows preferences, captured from a PC as they really are and replayed on the next one.

.DESCRIPTION
    tracked.txt names the registry values to carry over and defaults.tsv holds the values a real PC
    has. Applying writes only values that differ, then restarts Explorer only when one of its own
    settings changed. Every value is under HKEY_CURRENT_USER, so no administrator rights are needed.
    The same model as mac/defaults.sh, so all three platforms work the same way.

.PARAMETER Capture
    Record this PC's values for every tracked registry value into defaults.tsv.

.PARAMETER Plan
    Show what applying would change without writing anything.

.EXAMPLE
    .\windows\defaults.ps1 -Capture
.EXAMPLE
    .\windows\defaults.ps1 -Plan
#>
[CmdletBinding()]
param(
    [switch]$Capture,
    [switch]$Plan,
    [string]$TrackedFile = (Join-Path $PSScriptRoot 'tracked.txt'),
    [string]$ValuesFile = (Join-Path $PSScriptRoot 'defaults.tsv')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# the functions below read these script-scope copies, which also keeps them in one place
$script:PlanMode = [bool]$Plan
$script:Tracked = $TrackedFile
$script:Values = $ValuesFile

function Write-Info([string]$Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Ok([string]$Message) { Write-Host "[ OK ] $Message" -ForegroundColor Green }
function Write-Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }

# each tracked line is "<key path> <value name>"; the key path itself may contain spaces, so the
# value name is everything after the last space
function Get-TrackedValue {
    Get-Content $script:Tracked | Where-Object { $_ -and $_ -notmatch '^\s*#' } | ForEach-Object {
        $line = $_.Trim()
        $split = $line.LastIndexOf(' ')
        [pscustomobject]@{ Path = $line.Substring(0, $split); Name = $line.Substring($split + 1) }
    }
}

# registry kinds a value can be written back as. Binary and multi-string values are left out on
# purpose: none of the tracked values use them and replaying them would need per-value care
$script:SupportedKinds = @('DWord', 'QWord', 'String', 'ExpandString')

# a home path is stored with %USERPROFILE% so the file works for any user name
function ConvertTo-Portable([string]$Value) {
    if ($Value.StartsWith($HOME, [StringComparison]::OrdinalIgnoreCase)) {
        return '%USERPROFILE%' + $Value.Substring($HOME.Length)
    }
    return $Value
}

function ConvertFrom-Portable([string]$Value) {
    return $Value -replace '^%USERPROFILE%', [regex]::Escape($HOME).Replace('\\', '\')
}

function Invoke-Capture {
    $rows = [System.Collections.Generic.List[string]]::new()
    # a plain header row and no comments, so GitHub shows the file as a searchable table
    $rows.Add("path`tname`ttype`tvalue")

    foreach ($tracked in Get-TrackedValue) {
        if (-not (Test-Path $tracked.Path)) { continue }
        $key = Get-Item $tracked.Path
        if ($key.GetValueNames() -notcontains $tracked.Name) { continue }

        # DoNotExpandEnvironmentNames keeps %USERPROFILE% in expandable strings as written
        $kind = $key.GetValueKind($tracked.Name).ToString()
        if ($script:SupportedKinds -notcontains $kind) { continue }
        $raw = $key.GetValue($tracked.Name, $null, 'DoNotExpandEnvironmentNames')
        $rows.Add("$($tracked.Path)`t$($tracked.Name)`t$kind`t$(ConvertTo-Portable ([string]$raw))")
    }

    Set-Content -Path $script:Values -Value $rows -Encoding utf8
    Write-Ok "Captured $($rows.Count - 1) settings into $script:Values"
}

function Invoke-Apply {
    if (-not (Test-Path $script:Values)) {
        Write-Warn "No captured settings at $script:Values; run with -Capture on a set-up PC first"
        return
    }

    $restartExplorer = $false
    $signInNeeded = $false
    $colourSetChanged = $false
    $rows = Import-Csv -Path $script:Values -Delimiter "`t"
    foreach ($row in $rows) {
        # both string kinds carry home paths in portable form, so both turn back into this user's home
        $value = if ($row.type -in 'String', 'ExpandString') { ConvertFrom-Portable $row.value } else { $row.value }

        $current = $null
        if (Test-Path $row.path) {
            $key = Get-Item $row.path
            if ($key.GetValueNames() -contains $row.name) {
                $current = [string]$key.GetValue($row.name, $null, 'DoNotExpandEnvironmentNames')
            }
        }
        if ($current -eq $row.value -or $current -eq $value) { continue }
        # an expandable path may be stored as %USERPROFILE%\... or spelt out in full; both name the same folder
        if ($null -ne $current -and $row.type -eq 'ExpandString' -and
            [Environment]::ExpandEnvironmentVariables($current) -eq [Environment]::ExpandEnvironmentVariables($value)) { continue }

        if ($script:PlanMode) {
            Write-Info "Would set $($row.path) $($row.name) to $($row.value)"
            continue
        }

        if (-not (Test-Path $row.path)) { New-Item -Path $row.path -Force | Out-Null }
        $typed = switch ($row.type) {
            'DWord' { [int]$value }
            'QWord' { [long]$value }
            default { $value }
        }
        New-ItemProperty -Path $row.path -Name $row.name -Value $typed -PropertyType $row.type -Force | Out-Null
        Write-Info "Set $($row.path) $($row.name) to $($row.value)"

        if ($row.path -like '*\Explorer*' -or $row.path -like '*\Search') { $restartExplorer = $true }
        if ($row.path -like '*\Themes\Personalize') { $colourSetChanged = $true }
        if ($row.path -like '*Accessibility*' -or $row.path -like '*Cursors*' -or $row.path -like '*Keyboard*' -or $row.path -like '*Mouse*') { $signInNeeded = $true }
    }

    # restarting only when an Explorer setting changed means a PC that already matches never
    # loses its open Explorer windows
    if ($restartExplorer) {
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Write-Info 'Restarted Explorer to apply taskbar and Explorer settings'
    }
    if ($signInNeeded) {
        Write-Warn 'Some input and accessibility settings take effect after signing out and back in'
    }
    # the taskbar only redraws its text in the new light or dark colours once Windows is told the
    # colour set changed; without this it keeps the old colours until the next sign-in
    if ($colourSetChanged) {
        Add-Type -Namespace Zacess -Name ColourSet -MemberDefinition @'
[DllImport("user32.dll", CharSet = CharSet.Unicode)]
public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint msg, UIntPtr wParam, string lParam, uint flags, uint timeout, out UIntPtr result);
'@
        $result = [UIntPtr]::Zero
        [void][Zacess.ColourSet]::SendMessageTimeout([IntPtr]0xffff, 0x1A, [UIntPtr]::Zero, 'ImmersiveColorSet', 2, 5000, [ref]$result)
        Write-Info 'Told Windows the light or dark setting changed, so the taskbar redraws'
    }

    # the display and sleep timeouts belong to the power plan, not the registry, so they are set
    # with powercfg on the active plan: display off at 15 minutes on battery and 30 on mains, sleep
    # at 20 on battery and never on mains
    foreach ($setting in @(
            @{ Name = 'monitor-timeout-dc'; Minutes = 15 }, @{ Name = 'monitor-timeout-ac'; Minutes = 30 },
            @{ Name = 'standby-timeout-dc'; Minutes = 20 }, @{ Name = 'standby-timeout-ac'; Minutes = 0 })) {
        powercfg /change $setting.Name $setting.Minutes
        if ($LASTEXITCODE -ne 0) { Write-Warn "powercfg could not set $($setting.Name)" }
    }
    Write-Info 'Set the display and sleep timeouts on the active power plan'

    Write-Ok 'Windows settings match the captured ones'
}

if ($Capture) { Invoke-Capture } else { Invoke-Apply }
