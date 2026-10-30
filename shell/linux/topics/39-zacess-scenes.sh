# =============================================================================
# Zacess Scenes
# calm animated scenes in the terminal in the Zacess theme zt last set, plus a build watcher.
# apps/zacess-scenes/setup.sh installs the program and bacon and links scenes.toml.
#   zs                    a random calm scene, then another every five minutes
#   zs <scene>            one scene by name (zs list shows them all)
#   zs list               every scene and sound set
#   zs sounds [set] [event]  one sound set; with no set, every set's pass tone in turn
#   zs config             open scenes.toml in $EDITOR
#   zs new <name>         start a Lua scene of your own
#   zs snap <scene>       an SVG still of a scene
#   zs themes             the themes and which one is active
#   zsf                   follow the shells in this tmux session: calm while commands work
#   zw                    watch the project here, in any language, rerun on each save
#   zwc / zwt / zwa       watch a Rust build with bacon: clippy, test, check-all
# =============================================================================

zs() {
    if ! command -v zacess-scenes >/dev/null 2>&1; then
        echo "zacess-scenes is not installed: bash \"\$DOTFILES/../apps/zacess-scenes/setup.sh\"" >&2
        return 1
    fi
    case "${1:-}" in
        "")
            # the original and pass scenes are the calm ones; fail scenes are left for failures
            local -a calm
            mapfile -t calm < <(zacess-scenes list | awk '$2 == "pass" || $2 == "general" {print $1}')
            if ((${#calm[@]})); then
                zacess-scenes "${calm[RANDOM % ${#calm[@]}]}" --shuffle
            else
                zacess-scenes sea
            fi
            ;;
        sounds)
            shift
            if (($#)); then
                zacess-scenes sounds play "$@"
            else
                local set
                for set in $(zacess-scenes list | awk '/^Sound sets/ {on = 1; next} on && NF {print $1}' | grep -v '^Events:'); do
                    echo "$set"
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

zsf() { zacess-scenes follow "$@"; }
zw() { zacess-scenes watch "$@"; }
zwc() { zacess-scenes watch clippy "$@"; }
zwt() { zacess-scenes watch test "$@"; }
zwa() { zacess-scenes watch check-all "$@"; }

# a scene running zacess-scenes follow shows how each command in this shell ended. The hook writes
# one line per finished command; an older zacess-scenes without follow mode prints nothing here
_zacess_follow_init="$(zacess-scenes follow init bash 2>/dev/null)" && eval "$_zacess_follow_init"
unset _zacess_follow_init
