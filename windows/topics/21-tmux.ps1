# =============================================================================
# tmux / Windows Terminal shortcuts
# tmux is available on Windows via WSL. Windows Terminal itself handles
# tabs and panes natively. These shortcuts cover both approaches.
# =============================================================================

# wt: open a new Windows Terminal tab in the current directory
function wt-here { wt -d (Get-Location).Path }

# wt-split: open a split pane in Windows Terminal
function wt-split { wt sp -d (Get-Location).Path }

# tmux via WSL (if WSL is installed)
function ta {
    param([string]$Session = "main")
    wsl tmux attach-session -t $Session 2>$null
    if ($LASTEXITCODE -ne 0) { wsl tmux new-session -s $Session }
}

function tn    { param([string]$Session) wsl tmux new-session -s $Session }
function tls   { wsl tmux list-sessions }
function tk    { param([string]$Session) wsl tmux kill-session -t $Session }
function tka   { wsl tmux kill-server }
function tw    { wsl tmux new-window }
function ts    { wsl tmux split-window -v }
function tss   { wsl tmux split-window -h }
function tconf { wsl tmux source-file '~/.tmux.conf' }
function tlog  { wsl tmux capture-pane -p }
function td    { wsl tmux detach-client }
function tren  { param([string]$Name) wsl tmux rename-session $Name }
function tkillother { wsl tmux kill-session -a }

# cluster: open 4 Windows Terminal panes connected to cluster nodes
function cluster {
    wt `
        --window 0 new-tab --title "node1" -- ssh node1 `; `
        split-pane --title "node2" -- ssh node2 `; `
        split-pane --title "node3" -- ssh node3 `; `
        split-pane --title "node4" -- ssh node4
}
