# =============================================================================
# Profile management
# Edit-Profile opens the loader in VS Code. Reload-Profile re-dots it in the
# current session - all topic files are re-sourced in order.
# =============================================================================

function Edit-Profile   { code $PROFILE }

# dot-sourcing from inside a function defines everything in that function's own scope, which is
# thrown away when it returns, so a reload would silently keep the old definitions. this dots the
# profile, then copies the functions, aliases and variables it made up to the global scope.
# automatic variables and read-only or all-scope items are skipped: they are not the profile's own
function Import-ProfileGlobal {
    . $PROFILE
    Get-ChildItem function: | Where-Object { -not $_.ModuleName } | ForEach-Object {
        Set-Item -Path "function:global:$($_.Name)" -Value $_.ScriptBlock
    }
    $fixed = [System.Management.Automation.ScopedItemOptions]'ReadOnly, Constant, AllScope'
    Get-Alias -Scope 0 | Where-Object { -not ($_.Options -band $fixed) } | ForEach-Object {
        Set-Alias -Name $_.Name -Value $_.Definition -Scope Global -Force
    }
    $automatic = 'args', 'input', 'MyInvocation', 'null', 'PSBoundParameters', 'PSCommandPath',
        'PSScriptRoot', 'PSCmdlet', '_', 'PSItem', 'foreach', 'this', 'Matches', 'fixed', 'automatic'
    Get-Variable -Scope 0 | Where-Object {
        -not ($_.Options -band $fixed) -and $_.Name -notin $automatic
    } | ForEach-Object { Set-Variable -Name $_.Name -Value $_.Value -Scope Global -Force }
}

# Hard-clear (including scrollback) before re-dotting, so the reprinted welcome banner
# lands on a clean screen instead of stacking under the old one.
function Reload-Profile { [System.Console]::Clear(); Import-ProfileGlobal }
