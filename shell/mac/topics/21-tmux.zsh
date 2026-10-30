# =============================================================================
# tmux - terminal multiplexer
# Essential when working on the 4-node cluster - persistent sessions
# per node mean detaching and reattaching never loses context.
# requires: brew install tmux
# =============================================================================

# ta: attach to an existing session (or create one if it doesn't exist)
ta() {
    local session="${1:-main}"
    tmux attach-session -t "$session" 2>/dev/null || tmux new-session -s "$session"
}

# tn: create a new named session
tn() { tmux new-session -s "${1:?Usage: tn <session-name>}"; }

# tls: list all sessions
alias tls="tmux list-sessions"

# tk: kill a session
tk() { tmux kill-session -t "${1:?Usage: tk <session-name>}"; }

# tka: kill all sessions
alias tka="tmux kill-server"

# tw: create a new window in the current session
alias tw="tmux new-window"

# ts: split the current pane horizontally
alias ts="tmux split-window -v"

# tss: split the current pane vertically
alias tss="tmux split-window -h"

# tconf: reload the tmux config without restarting
alias tconf="tmux source-file ~/.tmux.conf"

# tlog: show the scrollback buffer of the current pane as plain text
alias tlog="tmux capture-pane -p"

# td: detach the current client, leaving the session running in the background
alias td="tmux detach-client"

# tren: rename the current session
tren() { tmux rename-session "${1:?Usage: tren <new-name>}"; }

# tkillother: kill every session except the one attached in this terminal -
# a quick cleanup after a day of spinning up throwaway sessions
tkillother() { tmux kill-session -a; }

# cluster: open a 4-pane window pre-connected to each cluster node.
# adjust the node names to match your ~/.ssh/config entries.
cluster() {
    tmux new-session -d -s cluster -x 220 -y 50
    tmux rename-window -t cluster 'nodes'
    tmux send-keys -t cluster 'ssh node1' Enter
    tmux split-window -t cluster -h
    tmux send-keys -t cluster 'ssh node2' Enter
    tmux split-window -t cluster -v
    tmux send-keys -t cluster 'ssh node3' Enter
    tmux select-pane -t cluster:0.0
    tmux split-window -t cluster -v
    tmux send-keys -t cluster 'ssh node4' Enter
    tmux attach-session -t cluster
}

# ide: a project's workspace in tmux. Neovim takes the top 70 percent, a shell sits bottom left
# and a Zacess scene bottom right follows that shell, calm while commands work and stormy when
# one fails. A folder that is a git repository also gets a git window running lazygit. Running
# it again for the same folder goes back to the open session rather than making another.
#   ide            the current folder
#   ide <folder>   another folder
ide() {
    local dir name editor shell width height
    if ! dir="$(cd "${1:-.}" 2>/dev/null && pwd -P)"; then
        printf 'ide: there is no folder %s\n' "${1:-.}" >&2
        return 1
    fi
    # tmux reads a dot or a colon in a session name as a separator, so both become dashes
    name="$(basename "$dir" | tr -c 'A-Za-z0-9_\n-' '-')"
    if ! tmux has-session -t "=$name" 2>/dev/null; then
        # the layout is split at the size it will be seen at, so the shares come out right
        if [ -n "$TMUX" ]; then
            width="$(tmux display-message -p '#{window_width}')"
            height="$(tmux display-message -p '#{window_height}')"
        else
            width="$(tput cols)"
            height="$(tput lines)"
        fi
        editor="$(tmux new-session -d -P -F '#{pane_id}' -s "$name" -n editor -c "$dir" -x "$width" -y "$height")"
        tmux send-keys -t "$editor" 'nvim .' Enter
        shell="$(tmux split-window -v -l 30% -P -F '#{pane_id}' -t "$editor" -c "$dir")"
        if command -v zacess-scenes >/dev/null 2>&1; then
            tmux split-window -h -l 35% -d -t "$shell" -c "$dir" 'zacess-scenes follow'
        fi
        if command -v lazygit >/dev/null 2>&1 && git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            tmux new-window -d -t "=$name:" -n git -c "$dir"
            tmux send-keys -t "=$name:git" lazygit Enter
        fi
        tmux select-pane -t "$editor"
    fi
    if [ -n "$TMUX" ]; then
        tmux switch-client -t "=$name"
    else
        tmux attach-session -t "=$name"
    fi
}

# ide-pick: the list Ctrl+B then f shows in tmux. Every folder in IDE_ROOTS (folders separated by
# colons, the repos folder by default), filtered as you type. The one picked opens in ide
ide-pick() {
    local pick
    pick="$(printf '%s\n' "${IDE_ROOTS:-$HOME/dev/github/repos}" | tr ':' '\n' | while IFS= read -r root; do
        [ -d "$root" ] && find "$root" -mindepth 1 -maxdepth 1 -type d ! -name '.*'
    done | sort | fzf --prompt 'project> ' --height 100% --reverse)"
    [ -n "$pick" ] && ide "$pick"
}
