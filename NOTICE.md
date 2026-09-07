# NOTICE - read this before deploying

This repository contains shell configuration files for three separate operating systems.
Each platform lives in its own folder. Only deploy the folder that matches your machine, do
not mix files across platforms.

| Folder | Platform |
| --- | --- |
| `mac/` | macOS only (zsh, Homebrew, macOS-specific paths and tools) |
| `linux/` | Linux only (bash, apt/pacman, Linux-specific paths and tools) |
| `windows/` | Windows only (PowerShell, winget/choco, Windows-specific paths) |

Each platform's own folder holds its own `starship.toml`, the Starship prompt config, identical
content on all three but not a single shared file. Symlink your platform's copy to
`~/.config/starship.toml` (see the Starship section in `guides/new-device.md`). The `scripts/`
folder contains utility scripts that run from any platform.

## What you must change before using these dotfiles

1. **Your name in the welcome banner.** The `cls()`/`refresh()` function in
   `06-functions.{zsh,sh,ps1}` greets "Isaac". Change this to your own name before sourcing
   any of these files.
2. **The `DOTFILES` path variable.** The loader at the top of each platform's main profile
   sets `export DOTFILES="$HOME/dev/github/repos/dotfiles"`. Change this to wherever you have
   cloned this repository.
3. **Cluster node aliases in `10-ssh`.** The aliases `node1`/`node2`/`node3`/`node4` in
   `10-ssh.{zsh,sh,ps1}` point to my four-node home lab. Replace those hostnames and
   usernames with your own servers. Remove the block entirely if you have no cluster.
4. **Git identity in `04-git`.** The global git name and email stubs reference my details.
   Set your own with `git config --global user.name "Your Name"` and
   `git config --global user.email "you@example.com"`.
5. **Editor paths in `19-editors`.** The JetBrains Toolbox paths and IDE launcher functions
   assume Toolbox is installed at `~/Library/Application Support/JetBrains/Toolbox` (macOS)
   or `~/.local/share/JetBrains/Toolbox` (Linux). Adjust if you installed elsewhere.
6. **Starship prompt in `34-starship`.** The `34-starship` topic file is already written for
   all three platforms. After cloning, symlink your platform's own `starship.toml` to
   `~/.config/starship.toml` and install Starship for your platform. See
   `guides/new-device.md` for the exact commands per platform.

## API tokens and secrets, never commit these

> [!CAUTION]
> Do not paste real tokens into any of these topic files.

None of the topic files in this repo require an API token or secret to work. If you add one
that does (a custom function calling an authenticated API, for example), keep the token in
your OS keychain or a secrets file (`chmod 600`) sourced from your profile, listed in
`.gitignore` and never committed. See `35-secrets` for age/sops helpers if you want to
commit an encrypted secret safely.

## Platform-specific tools mentioned in these files

Some tools appear only on one platform because they have no equivalent elsewhere.

**Windows only:** WinSCP CLI shortcuts (`15-rsync.ps1`); Windows Terminal pane helpers
(`21-tmux.ps1`).

**macOS only:** `open -a` launcher shortcuts (`19-editors.zsh`); Homebrew package
management (`16-brew.zsh`).

**Linux only:** `xdg-open` equivalents (`19-editors.sh`).

**All platforms:** each platform's own `starship.toml` covers all 35 topic files, identical
content on all three. One symlink per device is all that is needed.

> [!NOTE]
> If a command listed in `cmds()` does not exist on your platform, it will simply not be
> defined, the loader will source the file without error.

## Licence

See [LICENSE](LICENSE) in the root of this repository.
