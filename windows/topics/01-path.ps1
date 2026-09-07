# =============================================================================
# PATH configuration
# Adds user-managed tool locations to the front of PATH so my scripts take
# priority over system tools.
# =============================================================================

$env:PATH = "$HOME\.local\bin;$env:PATH"
