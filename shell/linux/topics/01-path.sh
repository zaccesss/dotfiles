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
# pyenv lives in PYENV_ROOT, so it is tested there: a PATH search also walks every Windows
# folder under WSL, about 0.2 seconds when pyenv is not installed
[[ -x "$PYENV_ROOT/bin/pyenv" ]] && eval "$("$PYENV_ROOT/bin/pyenv" init -)"

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

# WSL has no browser of its own and Ubuntu 26.04 no wslview, so links from gh and other tools open
# in the Windows browser through Windows' own file handler. a BROWSER set by hand is left alone.
# wslview is looked for only where its package installs it: a PATH search also walks every Windows
# folder under WSL, about 0.17 seconds when it is missing
if [[ -z "${BROWSER:-}" && ! -x /usr/bin/wslview && ! -x /usr/local/bin/wslview ]] \
    && { [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qsi microsoft /proc/version; }; then
    export BROWSER="explorer.exe"
fi
