# linux/topics-zsh/

38 numbered `.zsh` files loaded in order by `../zshrc`. This is the zsh port of [`linux/topics/`](../topics/) and is the default Linux profile, matching the macOS profile. Each file covers the same topic area as its `.sh` counterpart, so the command reference in [`linux/topics/README.md`](../topics/README.md) applies here too - only the shell dialect differs.

The parallel `.sh` files under [`topics/`](../topics/) stay as the bash fallback for a machine without zsh.

## What differs from the bash topics

The bulk of the files are shared verbatim. These carry zsh-specific changes:

| File | zsh change |
| --- | --- |
| `02-colours.zsh` | zsh `PROMPT` with `%F{...}` colour escapes instead of a bash `PS1` |
| `05-profile.zsh` | `edit-profile` and `reload-profile` target `~/.zshrc` |
| `06-functions.zsh` | `welcome` shows `zsh <version>`; `listcmds` uses `print -l ${(k)functions}` and `${(s/:/)PATH}`; `dot` applies `~/.zshrc` |
| `07-utilities.zsh` | `update` uses the zsh `read "var?prompt"` form; `copyout` and `logrun` read zsh's `pipestatus` |
| `08-community.zsh` | adds the global pipe aliases `G H T L N` (`alias -g`, zsh only) |
| `09-cli-tools.zsh` | `zoxide init zsh` |
| `34-starship.zsh` | `starship init zsh` |
| `37-command-marks.zsh` | `precmd` and `preexec` hooks with the end-of-prompt mark on `PROMPT`, where bash uses `PROMPT_COMMAND` and `PS0` |
| `38-syntax-highlighting.zsh` | loads zsh-syntax-highlighting last (new file, no bash equivalent) |

## Adding a topic

Create a new file with the next available number, e.g. `39-mytopic.zsh`. It is sourced automatically. There is no need to edit `zshrc`.

## Platform differences from macOS

The same as the bash topics: `clipcopy`/`clippaste` use `xclip`, `dns-flush` uses `systemd-resolve`, `36-swift.zsh` has no Xcode or Simulator and `16-brew.zsh` covers Linuxbrew with no cask support.
