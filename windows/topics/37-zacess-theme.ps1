# =============================================================================
# Zacess theme switching
# zt switches VS Code, Zed, the JetBrains IDEs, Neovim, Eclipse, Windows Terminal
# and Alacritty to one of the eight Zacess themes at once. the work is done by
# windows/scripts/zt.ps1, which zt.cmd also runs from Command Prompt.
#   zt deep-dark            fix one theme everywhere (short name, id or full name)
#   zt auto [dark] [light]  follow the Windows light and dark setting where a tool can
#   zt list / zt current    the themes plus what each tool is on now
# =============================================================================

function zt { & (Join-Path $env:DOTFILES 'windows\scripts\zt.ps1') @args }
function zacess-theme { zt @args }
