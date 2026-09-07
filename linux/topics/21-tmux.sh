# =============================================================================
# tmux - terminal multiplexer
# Requires: apt install tmux
# =============================================================================

ta() {
    local session="${1:-main}"
    tmux attach-session -t "$session" 2>/dev/null || tmux new-session -s "$session"
}

tn() { tmux new-session -s "${1:?Usage: tn <session-name>}"; }
alias tls="tmux list-sessions"
tk() { tmux kill-session -t "${1:?Usage: tk <session-name>}"; }
alias tka="tmux kill-server"
alias tw="tmux new-window"
alias ts="tmux split-window -v"
alias tss="tmux split-window -h"
alias tconf="tmux source-file ~/.tmux.conf"
alias tlog="tmux capture-pane -p"
alias td="tmux detach-client"
tren() { tmux rename-session "${1:?Usage: tren <new-name>}"; }
tkillother() { tmux kill-session -a; }

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
