# =============================================================================
# Zacess theme switching
# zt switches every editor, terminal and app with a Zacess theme to one of the eight at once:
# VS Code, Zed, the JetBrains IDEs, Neovim, Eclipse, STM32CubeIDE, KiCad, Processing, Vivado,
# Arduino IDE, Thonny, MATLAB, LTspice (under Wine), Zotero, Obsidian, Kitty, Alacritty and
# Ghostty.
# the work is done by scripts/zt.py; run zt with no argument for its help.
#   zt deep-dark          fix one theme everywhere (short name, id or full name)
#   zt auto [dark] [light]  follow the desktop light and dark where a tool can
#   zt list / zt current  the themes plus what each tool is on now
#   zt doctor             every installed theme file against the repo copy, exit 1 on drift
#   zt highlight [default]  the system text highlight from the theme or the system's own back
# =============================================================================

zt() {
    python3 "$DOTFILES/scripts/zt.py" "$@"
}

# the full name, a function rather than an alias so it also works in scripts
zacess-theme() {
    zt "$@"
}

# zt --all leaves a change in a synced folder. a new shell compares its id with the last one this
# device handled using only shell builtins, so an unchanged folder costs nothing. zt sync starts in
# the background only when a new change has arrived
_zt_check_all() {
    local shared="${ZACESS_SHARED_DIR:+$ZACESS_SHARED_DIR/zt-all.json}"
    local state="${XDG_STATE_HOME:-$HOME/.local/state}/zacess/all-seen" text="" seen=""
    [[ -n $shared && -r $shared ]] || return 0
    IFS= read -r -d '' text < "$shared"
    [[ $text =~ \"id\":\ *\"([^\"]+)\" ]] || return 0
    [[ -r $state ]] && IFS= read -r seen < "$state"
    [[ ${BASH_REMATCH[1]} == "$seen" ]] && return 0
    (python3 "$DOTFILES/scripts/zt.py" sync >/dev/null 2>&1 &)
}
_zt_check_all
unset -f _zt_check_all
