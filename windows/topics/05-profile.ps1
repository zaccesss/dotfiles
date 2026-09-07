# =============================================================================
# Profile management
# Edit-Profile opens the loader in VS Code. Reload-Profile re-dots it in the
# current session - all topic files are re-sourced in order.
# =============================================================================

function Edit-Profile   { code $PROFILE }
function Reload-Profile { . $PROFILE }
