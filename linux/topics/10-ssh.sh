# =============================================================================
# SSH helpers
# Shortcuts for a small home lab plus various remote servers. They
# save typing the same ssh flags and key paths repeatedly.
# edit the node aliases below to match your own ~/.ssh/config host names.
# =============================================================================

# one ssh-agent shared by every shell on a fixed socket, so a key added once (with ssha, ssh-add or
# AddKeysToAgent in ~/.ssh/config) is not asked for again in the next terminal. WSL and a plain
# server start no agent of their own. an agent that already answers, such as one forwarded over SSH
# or a desktop keyring, is used as it is. keys are never added here, since adding one may need the
# passphrase
_ssh_agent_ensure() {
    local sock="$HOME/.ssh/agent.sock" rc
    # ssh-add -l exits 0 with keys loaded, 1 with none and 2 when no agent answers
    if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
        ssh-add -l >/dev/null 2>&1; rc=$?
        [[ $rc -ne 2 ]] && return 0
    fi
    command -v ssh-agent >/dev/null 2>&1 || return 0
    export SSH_AUTH_SOCK="$sock"
    ssh-add -l >/dev/null 2>&1; rc=$?
    [[ $rc -ne 2 ]] && return 0
    [[ -d "$HOME/.ssh" ]] || mkdir -m 700 "$HOME/.ssh"
    # a socket left by an agent that has gone (after a WSL shutdown, say) blocks ssh-agent -a
    [[ -S "$sock" ]] && rm -f "$sock"
    ssh-agent -a "$sock" >/dev/null 2>&1
}
_ssh_agent_ensure

# keygen: generate a modern Ed25519 key with a comment matching the git email.
# run this on every new machine before adding the key to GitHub and servers.
keygen() {
    local name="${1:-id_ed25519}"
    ssh-keygen -t ed25519 -C "$(git config user.email 2>/dev/null || echo "$USER@$(hostname)")" -f "$HOME/.ssh/$name"
}

# sshcp: copy a public key to a remote host in one command.
sshcp() {
    local target="$1"
    local key="${2:-$HOME/.ssh/id_ed25519.pub}"
    ssh-copy-id -i "$key" "$target"
}

# ssha: add a key to the shared agent so the passphrase is not asked for again in any terminal.
ssha() {
    local key="${1:-$HOME/.ssh/id_ed25519}"
    _ssh_agent_ensure
    ssh-add "$key"
}

alias sshls="ssh-add -l"
alias sshconf='code $HOME/.ssh/config'

# sshtest: test a connection verbosely - useful when diagnosing timeouts or key issues.
sshtest() {
    ssh -v -o ConnectTimeout=5 "$1" exit 2>&1 | grep -E "Connecting|debug1|Permission|connect|success"
}

sshfp() {
    ssh-keygen -lf "${1:-$HOME/.ssh/id_ed25519.pub}"
}

# sshrm: remove a host's entry from known_hosts - needed after a VM/node gets
# reimaged and ssh refuses to connect with a "REMOTE HOST IDENTIFICATION HAS CHANGED" warning
sshrm() {
    ssh-keygen -R "${1:?Usage: sshrm <host>}"
}

alias node1="ssh node1"
alias node2="ssh node2"
alias node3="ssh node3"
alias node4="ssh node4"

scpto() { scp "$1" "$2"; }
scpfrom() { scp "$1" .; }
