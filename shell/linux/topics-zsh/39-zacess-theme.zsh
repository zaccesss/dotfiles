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
    local shared state="${XDG_STATE_HOME:-$HOME/.local/state}/zacess/all-seen" text seen=""
    # the OneDrive client syncs the folder into ~/OneDrive, the place zt.py looks too
    if [[ -n ${ZACESS_SHARED_DIR:-} ]]; then
        shared="$ZACESS_SHARED_DIR/zt-all.json"
    else
        shared="$HOME/OneDrive/.zacess/zt-all.json"
    fi
    [[ -n $shared && -r $shared ]] || return 0
    text=$(<"$shared")
    local pattern='"id": *"([^"]+)"'
    [[ $text =~ $pattern ]] || return 0
    [[ -r $state ]] && seen=$(<"$state")
    # zsh sets match from the =~ test above
    # shellcheck disable=SC2154
    [[ ${match[1]} == "$seen" ]] && return 0
    (python3 "$DOTFILES/scripts/zt.py" sync >/dev/null 2>&1 &)
}
_zt_check_all
unset -f _zt_check_all
