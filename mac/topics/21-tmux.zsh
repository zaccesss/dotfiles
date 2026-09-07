# =============================================================================
# tmux - terminal multiplexer
# Essential when working on the 4-node cluster - I keep persistent sessions
# per node so I can detach and reattach without losing context.
# Requires: brew install tmux
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
# Adjust the node names to match your ~/.ssh/config entries.
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
