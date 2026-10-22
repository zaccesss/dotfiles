# git

Git identity, signing and safety checks, plus the SSH client config they depend on. The gitconfig
and SSH config are starting points to copy and edit, since they hold a person's own name, email,
keys and hosts. The hooks are linked so a change here applies straight away.

| Folder | What it is | Platforms |
| --- | --- | --- |
| [gitconfig](gitconfig) | SSH commit and tag signing, per-platform credential helpers, GitHub CLI auth and global hook wiring | macOS, Linux and Windows |
| [git-hooks](git-hooks) | Secret scanning, a large file and force push guard and a commit subject length check, with an extension point for your own rules | macOS, Linux and Windows |
| [ssh](ssh) | Per-host key selection, agent settings and an allowed signers example for verifying signed commits | macOS, Linux and Windows |
