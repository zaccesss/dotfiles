# =============================================================================
# Zacess theme switching
# zt switches every editor, terminal and app with a Zacess theme to one of the eight at once:
# VS Code, Zed, the JetBrains IDEs, Neovim, Eclipse, STM32CubeIDE, KiCad, Processing, Nextpad++,
# Arduino IDE, Thonny, MATLAB, LTspice, Zotero, Obsidian, Terminal.app, iTerm2, Kitty, Alacritty
# and Ghostty.
# the work is done by scripts/zt.py; run zt with no argument for its help.
#   zt deep-dark          fix one theme everywhere (short name, id or full name)
#   zt auto [dark] [light]  follow macOS light and dark where a tool can
#   zt list / zt current  the themes plus what each tool is on now
# =============================================================================

zt() {
    python3 "$DOTFILES/scripts/zt.py" "$@"
}

# the full name, a function rather than an alias so it also works in scripts
zacess-theme() {
    zt "$@"
}
