# =============================================================================
# dotfiles - Windows PowerShell profile
# github.com/zaccesss/dotfiles - MIT licence
#
# topic loader - all functions and aliases live in windows/topics/*.ps1.
# deploy on a new machine by copying this file to $PROFILE:
#   Copy-Item windows\Microsoft.PowerShell_profile.ps1 $PROFILE -Force
# All topic files are dot-sourced in numbered order from the DOTFILES path.
# =============================================================================

# the topic files use PowerShell 7 syntax that Windows PowerShell 5.1 cannot parse, so 5.1 stops
# here with one hint instead of a screen of parse errors. this block must stay 5.1-compatible
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "dotfiles need PowerShell 7: run pwsh" -ForegroundColor DarkGray
    return
}

$env:DOTFILES = if ($env:DOTFILES) { $env:DOTFILES } else { "$HOME\dev\github\repos\dotfiles" }

Get-ChildItem "$env:DOTFILES\windows\topics\*.ps1" | Sort-Object Name | ForEach-Object {
    . $_.FullName
}

# =============================================================================
# Welcome banner - printed after all topics load so welcome is defined
# =============================================================================

welcome
