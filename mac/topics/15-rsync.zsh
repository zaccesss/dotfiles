# =============================================================================
# File sync and transfer
# rsync shortcuts for backups, deployments and copying between machines.
# rclone shortcuts cover cloud storage (Google Drive, S3, Dropbox etc).
# =============================================================================

# rcopy: copy a directory preserving all attributes with a progress bar.
# I use this for large transfers where I want to see what's happening.
rcopy() {
    rsync -avh --progress "${1:?Usage: rcopy <src> <dest>}" "${2:?}"
}

# rmirror: mirror src to dest - deletes files in dest that are not in src.
# Useful for keeping a backup drive in sync. Be careful: dest files are deleted.
rmirror() {
    rsync -avh --delete --progress "${1:?Usage: rmirror <src> <dest>}" "${2:?}"
}

# rbackup: copy src to dest, skipping files that are identical.
# I use this for incremental backups to an external drive or NAS.
rbackup() {
    rsync -avh --update --progress "${1:?}" "${2:?}"
}

# rdry: dry-run of rmirror - shows what would change without doing anything.
rdry() {
    rsync -avhn --delete "${1:?Usage: rdry <src> <dest>}" "${2:?}"
}

# rclone shortcuts (requires: brew install rclone + rclone config)
# rls: list files in a configured rclone remote
alias rls="rclone ls"
# rclonecopy: copy local to remote (or remote to local)
alias rclonecopy="rclone copy --progress"
# rclonesync: bidirectional sync with a remote
alias rclonesync="rclone sync --progress"
# rclonels: list configured remotes
alias rcloneremotes="rclone listremotes"
# rclonemove: move local to remote (or remote to local) - unlike rclonecopy, deletes the source
alias rclonemove="rclone move --progress"
# rclonesize: show the total size and file count of a remote path
alias rclonesize="rclone size"

# scp shortcuts (for when rsync is unavailable on the remote)
# scpget: download a file from a remote host
scpget() { scp "${1:?Usage: scpget user@host:/path/file}" "${2:-.}"; }
# scpput: upload a file to a remote host
scpput() { scp "${1:?}" "${2:?}"; }
# scpgetdir: download a directory from a remote host recursively
scpgetdir() { scp -r "${1:?Usage: scpgetdir user@host:/path/dir}" "${2:-.}"; }
# scpputdir: upload a directory to a remote host recursively
scpputdir() { scp -r "${1:?}" "${2:?}"; }
