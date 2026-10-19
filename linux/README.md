# linux/

Profile for Linux and WSL2. zsh is the default, matching the macOS profile; bash stays as a fallback for a machine without zsh. Each entry point is a loader: `zshrc` sources every numbered `.zsh` file in `topics-zsh/` in order and `bashrc` does the same for the `.sh` files in `topics/`. All aliases, functions and configuration live in those topic files, not in the loaders themselves.

Works on any modern Linux distro and inside WSL2 on Windows without modification.

## Files

| File | Purpose |
| --- | --- |
| `zshrc` | zsh loader (the default): sources all files in `topics-zsh/` in numerical order |
| `bashrc` | bash loader (the fallback): sources all files in `topics/` in numerical order |
| `starship.toml` | Starship prompt config, identical content to the Mac and Windows copies |

Both loaders return straight away in a non-interactive shell, so a single remote command (`ssh host cmd`, `scp`, `rsync`) loads nothing and prints no banner.

## Subfolders

| Folder | Contents |
| --- | --- |
| [`topics-zsh/`](topics-zsh/) | 37 numbered `.zsh` files for the zsh profile, one topic per file |
| [`topics/`](topics/) | 36 numbered `.sh` files for the bash fallback, one topic per file |

## Installation

Install zsh and the plugin that colours typed commands, then copy the profile:

```bash
sudo apt install -y zsh zsh-syntax-highlighting   # Fedora: sudo dnf install -y zsh zsh-syntax-highlighting
cp linux/zshrc ~/.zshrc
chsh -s "$(command -v zsh)"
```

The bash fallback, for a machine without zsh:

```bash
cp linux/bashrc ~/.bashrc
source ~/.bashrc
```

After that, use `edit-profile` to open the profile in VS Code and `reload-profile` to apply changes without restarting the terminal. See [guides/linux.md](../guides/linux.md) for the full setup walkthrough, WSL2 notes and command reference.
