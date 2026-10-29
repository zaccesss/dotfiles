# =============================================================================
# Zacess theme switching
# zt switches every editor, terminal and app with a Zacess theme to one of the eight at once:
# VS Code, Zed, the JetBrains IDEs, Neovim, Eclipse, STM32CubeIDE, KiCad, Vivado, Arduino IDE,
# Notepad++, Thonny, LTspice, Proteus, Zotero, Obsidian, MATLAB, Processing, Microchip Studio,
# Windows Terminal and Alacritty. the work is done by
# windows/scripts/zt.ps1, which zt.cmd also runs from Command Prompt.
#   zt deep-dark            fix one theme everywhere (short name, id or full name)
#   zt auto [dark] [light]  follow the Windows light and dark setting where a tool can
#   zt list / zt current    the themes plus what each tool is on now
#   zt doctor               every installed theme file against the repo copy, exit 1 on drift
#   zt highlight [default]  the system text highlight from the theme or the system's own back
# =============================================================================

function zt { & (Join-Path $env:DOTFILES 'windows\scripts\zt.ps1') @args }
function zacess-theme { zt @args }

# zt --all leaves a change in a synced folder. a new shell compares its id with the last one this
# device handled using .NET calls in this process, so an unchanged folder costs one small file
# read. zt sync starts hidden in the background only when a new change has arrived
& {
    $folder = if ($env:ZACESS_SHARED_DIR) { $env:ZACESS_SHARED_DIR }
              elseif ($env:OneDriveConsumer) { Join-Path $env:OneDriveConsumer '.zacess' }
              elseif ($env:OneDrive) { Join-Path $env:OneDrive '.zacess' }
    if (-not $folder) { return }
    $shared = Join-Path $folder 'zt-all.json'
    if (-not [IO.File]::Exists($shared)) { return }
    $id = [regex]::Match([IO.File]::ReadAllText($shared), '"id"\s*:\s*"([^"]+)"')
    if (-not $id.Success) { return }
    $seen = Join-Path $env:LOCALAPPDATA 'zacess\all-seen'
    if ([IO.File]::Exists($seen) -and [IO.File]::ReadAllText($seen).Trim() -eq $id.Groups[1].Value) { return }
    Start-Process pwsh -WindowStyle Hidden -ArgumentList '-NoProfile', '-File', "`"$(Join-Path $env:DOTFILES 'windows\scripts\zt.ps1')`"", 'sync'
}
