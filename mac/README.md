# mac/

macOS shell profile using zsh. The entry point is `zshrc`, which acts as a loader - it sources every numbered `.zsh` file in `topics/` in order. All aliases, functions and configuration live in those topic files, not in `zshrc` itself.

## Files

| File | Purpose |
| --- | --- |
| `zshrc` | Loader: sets up colours and sources all files in `topics/` in numerical order |

## Subfolders

| Folder | Contents |
| --- | --- |
| [`topics/`](topics/) | 35 numbered `.zsh` files, one topic per file |

## Installation

```bash
cp mac/zshrc ~/.zshrc
source ~/.zshrc
```

After that, use `edit-profile` to open the profile in VS Code and `reload-profile` to apply changes without restarting the terminal. See [guides/mac.md](../guides/mac.md) for the full setup walkthrough and command reference.
