# =============================================================================
# PATH configuration
# Extends the system PATH with user-managed tool locations. ~/.local/bin is
# first so user-installed tools take priority over system tools.
# =============================================================================

# User-installed scripts and binaries
export PATH="$HOME/.local/bin:$PATH"

# pyenv - manages multiple Python versions
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
[[ -x "$(command -v pyenv)" ]] && eval "$(pyenv init -)"

# Go - adjust if installed to a different location
[[ -d "/usr/local/go/bin" ]] && export PATH="/usr/local/go/bin:$PATH"

# Cargo (Rust)
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# swiftly (Swift toolchains), in its default location under ~/.local/share/swiftly
[[ -f "$HOME/.local/share/swiftly/env.sh" ]] && source "$HOME/.local/share/swiftly/env.sh"

# Flutter SDK, when cloned into ~/dev/tools/flutter
[[ -d "$HOME/dev/tools/flutter/bin" ]] && export PATH="$HOME/dev/tools/flutter/bin:$PATH"

# .NET global tools (dotnet tool install -g)
[[ -d "$HOME/.dotnet/tools" ]] && export PATH="$HOME/.dotnet/tools:$PATH"

# WSL on Ubuntu 26.04 has no wslview, so links open through Windows' own file handler instead
if grep -qsi microsoft /proc/version && ! command -v wslview >/dev/null 2>&1; then
    export BROWSER="explorer.exe"
fi
