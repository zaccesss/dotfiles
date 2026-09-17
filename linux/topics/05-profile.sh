# =============================================================================
# Profile management
# Quick shortcuts to edit and reload the bash profile.
# =============================================================================

alias edit-profile="code ~/.bashrc"
# Hard-clear (including scrollback) before re-sourcing, so the reprinted welcome banner
# lands on a clean screen instead of stacking under the old one.
alias reload-profile="printf '\033[2J\033[3J\033[H'; source ~/.bashrc"
