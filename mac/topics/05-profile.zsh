# =============================================================================
# Profile management
# Quick shortcuts to edit and reload this profile without restarting the shell.
# edit-profile opens the loader zshrc in VS Code; changes to topic files can
# be reloaded with reload-profile or by opening a new terminal window.
# =============================================================================

alias edit-profile="code ~/.zshrc"
# Hard-clear (including scrollback) before re-sourcing, so the reprinted welcome banner
# lands on a clean screen instead of stacking under the old one.
alias reload-profile="printf '\033[2J\033[3J\033[H'; source ~/.zshrc"
