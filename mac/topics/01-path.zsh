# =============================================================================
# PATH configuration
# These entries extend the system PATH so every tool I rely on is available
# without typing its full path. Order matters - entries added first take
# priority, so my user scripts in ~/.local/bin override everything else.
# =============================================================================

# Homebrew - must come before system tools so brew-managed binaries win
export PATH="/opt/homebrew/bin:$PATH"

# OpenJDK installed via Homebrew (macOS ships a stale Java)
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Python 3.14 shims so 'python' and 'pip' resolve to the brew-managed version
export PATH="/opt/homebrew/opt/python@3.14/libexec/bin:$PATH"

# User-installed scripts and binaries
export PATH="$HOME/.local/bin:$PATH"
