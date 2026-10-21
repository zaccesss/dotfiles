# =============================================================================
# Zacess theme switching
# zt switches VS Code, Zed, the JetBrains IDEs, Neovim, Eclipse, Kitty,
# Alacritty and Ghostty to one of the eight Zacess themes at once.
# the work is done by scripts/zt.py; run zt with no argument for its help.
#   zt deep-dark          fix one theme everywhere (short name, id or full name)
#   zt auto [dark] [light]  follow the desktop light and dark where a tool can
#   zt list / zt current  the themes plus what each tool is on now
# =============================================================================

zt() {
    python3 "$DOTFILES/scripts/zt.py" "$@"
}

# the full name, a function rather than an alias so it also works in scripts
zacess-theme() {
    zt "$@"
}
