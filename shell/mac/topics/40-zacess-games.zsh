# =============================================================================
# Zacess Games
# fourteen small original terminal games in the Zacess theme zt last set.
# apps/zacess-games/setup.sh installs the newest release binary.
#   zg                    the menu
#   zg <game>             one game: stackline, merge-gates, termle, signal, trace, drift,
#                         rooms, relay, through-ball, slipstream, array-guard, heatsink,
#                         touch-typing or learn-to-code
#   zg list               every game with its best score
#   zg sounds [game]      plays every effect, then each game's music
#   zg snap [game]        SVG stills of the games
#   zg --help             every option, such as --reduced-motion, --volume and --music-volume
# + and - set the effects, [ and ] the music and 0 mutes; effects start at 35 and music at 20.
# docs/controls.md in the zacesshq/games repository lists every key
# =============================================================================

zg() {
    if ! command -v zacess-games >/dev/null 2>&1; then
        print -u2 "zacess-games is not installed: bash \"\$DOTFILES/../apps/zacess-games/setup.sh\""
        return 1
    fi
    zacess-games "$@"
}

# the full name, as with zt and zs
zacess-game() {
    zg "$@"
}

# Tab completes the game names and subcommands: through compsys when compinit has run,
# otherwise through the older compctl, which needs nothing loaded first
_zacess_games_words=(stackline merge-gates termle signal trace drift rooms relay through-ball slipstream array-guard heatsink touch-typing learn-to-code list sounds snap menu --help)
_zg() {
    compadd -- "${_zacess_games_words[@]}"
}
if command -v compdef >/dev/null 2>&1; then
    compdef _zg zg zacess-game zacess-games
else
    compctl -k _zacess_games_words zg zacess-game zacess-games
fi
