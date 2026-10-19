# =============================================================================
# File sync and transfer - rsync, rclone and scp
# =============================================================================

rcopy() {
    rsync -avh --progress "${1:?Usage: rcopy <src> <dest>}" "${2:?}"
}

rmirror() {
    rsync -avh --delete --progress "${1:?Usage: rmirror <src> <dest>}" "${2:?}"
}

rbackup() {
    rsync -avh --update --progress "${1:?}" "${2:?}"
}

rdry() {
    rsync -avhn --delete "${1:?Usage: rdry <src> <dest>}" "${2:?}"
}

alias rls="rclone ls"
alias rclonecopy="rclone copy --progress"
alias rclonesync="rclone sync --progress"
alias rcloneremotes="rclone listremotes"
alias rclonemove="rclone move --progress"
alias rclonesize="rclone size"

scpget() { scp "${1:?}" "${2:-.}"; }
scpput() { scp "${1:?}" "${2:?}"; }
scpgetdir() { scp -r "${1:?}" "${2:-.}"; }
scpputdir() { scp -r "${1:?}" "${2:?}"; }
