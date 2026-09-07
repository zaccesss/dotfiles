# linux/

bash profile for Linux and WSL2. The entry point is `bashrc`, which acts as a loader - it sources every numbered `.sh` file in `topics/` in order. All aliases, functions and configuration live in those topic files, not in `bashrc` itself.

Works on any modern Linux distro and inside WSL2 on Windows without modification.

## Files

| File | Purpose |
| --- | --- |
| `bashrc` | Loader: sets up colours and sources all files in `topics/` in numerical order |

## Subfolders

| Folder | Contents |
| --- | --- |
| [`topics/`](topics/) | 35 numbered `.sh` files, one topic per file |

## Installation

```bash
cp linux/bashrc ~/.bashrc
source ~/.bashrc
```

After that, use `edit-profile` to open the profile in VS Code and `reload-profile` to apply changes without restarting the terminal. See [guides/linux.md](../guides/linux.md) for the full setup walkthrough, WSL2 notes and command reference.
