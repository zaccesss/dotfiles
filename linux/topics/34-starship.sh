# OrbStack opens its shell over a loopback SSH connection, so starship would treat every local
# session as remote and add the user and host to the prompt. Clearing the loopback-only variables
# keeps the prompt identical to the Mac's; a real SSH session from another machine keeps them
if [[ -d /opt/orbstack-guest ]]; then
    case "${SSH_CONNECTION%% *}" in
        ::1 | 127.0.0.1) unset SSH_CONNECTION SSH_CLIENT SSH_TTY ;;
    esac
fi

# initialise Starship prompt
eval "$(starship init bash)"
