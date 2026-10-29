# =============================================================================
# Zacess Scenes
# calm animated scenes in the terminal in the Zacess theme zt last set, plus a build watcher.
# apps/zacess-scenes/setup.sh installs the program and bacon and links scenes.toml.
#   zs                    a random calm scene
#   zs <scene>            one scene by name (zs list shows them all)
#   zs list               every scene and sound set
#   zs sounds [set] [event]  one sound set; with no set, every set's pass tone in turn
#   zs config             open scenes.toml in $EDITOR
#   zs new <name>         start a Lua scene of your own
#   zs snap <scene>       an SVG still of a scene
#   zs themes             the themes and which one is active
#   zw / zwc / zwt / zwa  watch a Rust build: check, clippy, test, check-all
# =============================================================================

zs() {
    if ! command -v zacess-scenes >/dev/null 2>&1; then
        print -u2 "zacess-scenes is not installed: bash \"\$DOTFILES/../apps/zacess-scenes/setup.sh\""
        return 1
    fi
    case "${1:-}" in
        "")
            # the original and pass scenes are the calm ones; fail scenes are left for failures
            local -a calm
            local name
            while IFS= read -r name; do
                calm+=("$name")
            done < <(zacess-scenes list | awk '$2 == "pass" || $2 == "general" {print $1}')
            if (( ${#calm} )); then
                zacess-scenes "${calm[RANDOM % ${#calm} + 1]}"
            else
                zacess-scenes sea
            fi
            ;;
        sounds)
            shift
            if (( $# )); then
                zacess-scenes sounds play "$@"
            else
                local set
                for set in $(zacess-scenes list | awk '/^Sound sets/ {on = 1; next} on && NF {print $1}' | grep -v '^Events:'); do
                    print "$set"
                    zacess-scenes sounds play "$set"
                    sleep 1.5
                done
            fi
            ;;
        config) "${EDITOR:-nvim}" "$(zacess-scenes config path)" ;;
        new) shift; zacess-scenes scene new "$@" ;;
        snap) shift; zacess-scenes snapshot "$@" ;;
        themes) zacess-scenes --list-themes ;;
        *) zacess-scenes "$@" ;;
    esac
}

# the full name, as with zt and zacess-theme
zacess-scene() {
    zs "$@"
}

zw() { zacess-scenes watch "$@"; }
zwc() { zacess-scenes watch clippy "$@"; }
zwt() { zacess-scenes watch test "$@"; }
zwa() { zacess-scenes watch check-all "$@"; }
