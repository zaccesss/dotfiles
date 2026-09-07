# =============================================================================
# SSH helpers
# I manage a small home lab plus various remote servers. These
# shortcuts save me typing the same ssh flags and key paths repeatedly.
# Edit the node aliases below to match your own ~/.ssh/config host names.
# =============================================================================

# keygen: generate a modern Ed25519 key with a descriptive comment.
# I use this on every new machine before adding the key to GitHub and servers.
keygen() {
    local name="${1:-id_ed25519}"
    ssh-keygen -t ed25519 -C "$(git config user.email 2>/dev/null || echo "$USER@$(hostname)")" -f "$HOME/.ssh/$name"
}

# sshcp: copy a public key to a remote host using ssh-copy-id.
# Usage: sshcp user@host  or  sshcp user@host ~/.ssh/id_ed25519.pub
sshcp() {
    local target="$1"
    local key="${2:-$HOME/.ssh/id_ed25519.pub}"
    ssh-copy-id -i "$key" "$target"
}

# ssha: add a key to the running ssh-agent (starts agent if not running).
ssha() {
    local key="${1:-$HOME/.ssh/id_ed25519}"
    eval "$(ssh-agent -s)" 2>/dev/null
    ssh-add "$key"
}

# sshls: list all keys currently loaded in the agent
alias sshls="ssh-add -l"

# sshconf: open the SSH config file in VS Code for quick edits
alias sshconf='code $HOME/.ssh/config'

# sshtest: test a connection with verbose output - useful for diagnosing timeouts
sshtest() {
    ssh -v -o ConnectTimeout=5 "$1" exit 2>&1 | grep -E "Connecting|debug1|Permission|connect|success"
}

# sshfp: show the fingerprint of a key file
sshfp() {
    ssh-keygen -lf "${1:-$HOME/.ssh/id_ed25519.pub}"
}

# sshrm: remove a host's entry from known_hosts - I use this after a VM/node gets
# reimaged and ssh refuses to connect with a "REMOTE HOST IDENTIFICATION HAS CHANGED" warning
sshrm() {
    ssh-keygen -R "${1:?Usage: sshrm <host>}"
}

# Cluster node shortcuts - update these to match your ~/.ssh/config host entries
alias node1="ssh node1"
alias node2="ssh node2"
alias node3="ssh node3"
alias node4="ssh node4"

# scp shortcuts
# scpto: copy a local file to a remote host
scpto() { scp "$1" "$2"; }
# scpfrom: copy from a remote host to the current directory
scpfrom() { scp "$1" .; }
