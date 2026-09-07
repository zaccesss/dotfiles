# =============================================================================
# PATH configuration
# Extends the system PATH with user-managed tool locations. ~/.local/bin is
# first so my user-installed tools take priority over system tools.
# =============================================================================

# User-installed scripts and binaries
export PATH="$HOME/.local/bin:$PATH"

# Pyenv - manages multiple Python versions
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
[[ -x "$(command -v pyenv)" ]] && eval "$(pyenv init -)"

# Go - adjust if installed to a different location
[[ -d "/usr/local/go/bin" ]] && export PATH="/usr/local/go/bin:$PATH"

# Cargo (Rust)
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
