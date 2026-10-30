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
