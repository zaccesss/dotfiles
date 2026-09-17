# =============================================================================
# Profile management
# Edit-Profile opens the loader in VS Code. Reload-Profile re-dots it in the
# current session - all topic files are re-sourced in order.
# =============================================================================

function Edit-Profile   { code $PROFILE }
# Hard-clear (including scrollback) before re-dotting, so the reprinted welcome banner
# lands on a clean screen instead of stacking under the old one.
function Reload-Profile { [System.Console]::Clear(); . $PROFILE }
