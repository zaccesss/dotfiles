# =============================================================================
# dotfiles - Windows PowerShell profile
# github.com/zaccesss/dotfiles - MIT licence
#
# topic loader - all functions and aliases live in windows/topics/*.ps1.
# deploy on a new machine by copying this file to $PROFILE:
#   Copy-Item windows\Microsoft.PowerShell_profile.ps1 $PROFILE -Force
# All topic files are dot-sourced in numbered order from the DOTFILES path.
# =============================================================================

$env:DOTFILES = if ($env:DOTFILES) { $env:DOTFILES } else { "$HOME\dev\github\repos\dotfiles" }

Get-ChildItem "$env:DOTFILES\windows\topics\*.ps1" | Sort-Object Name | ForEach-Object {
    . $_.FullName
}

# =============================================================================
# Welcome banner - printed after all topics load so welcome is defined
# =============================================================================

welcome
