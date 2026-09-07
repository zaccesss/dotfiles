# Linux Profile Guide

Setup and command reference for the bash profile on Linux and WSL2. The profile uses a modular topic system - each area of tools and aliases lives in its own numbered file under [linux/topics/](../linux/topics/), loaded in order at shell startup. The command names are intentionally identical to the macOS profile so muscle memory carries across with no adjustment.

Profile file: `~/.bashrc`
Repo copy: [linux/bashrc](../linux/bashrc)

> [!NOTE]
> This profile and guide are ready to use and will be put into practice when I set up my Lenovo or configure WSL2. The alias layout mirrors the Mac profile so switching between machines requires no relearning.

---

## Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [WSL2 notes](#wsl2-notes)
- [How the profile works](#how-the-profile-works)
- [Navigation](#navigation)
- [Git](#git)
- [Repo management](#repo-management)
- [Core functions](#core-functions)
- [Utilities](#utilities)
- [Development shortcuts](#development-shortcuts)
- [Colours](#colours)
- [Extending the profile](#extending-the-profile)
- [Platform differences from macOS](#platform-differences-from-macos)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Any modern Linux distro (Ubuntu, Fedora, Arch and derivatives all work) or WSL2 on Windows
- bash 4+ (default on most distros)
- git, curl and jq installed
- VS Code with the `code` command available (optional but used by `edit-profile`)
- GitHub CLI (`gh`) for the GitHub CLI commands

```bash
# Ubuntu/Debian
sudo apt install -y git curl jq
```

---

## Installation

```bash
cp linux/bashrc ~/.bashrc
source ~/.bashrc
```

The welcome banner confirms the profile loaded. Run `cmds` to see all available commands. Use `edit-profile` to open the profile in VS Code and `reload-profile` to apply changes without restarting the terminal.

> [!IMPORTANT]
> The profile is a loader - it sources topic files from the repo directory. After installation, edit the topic files in the repo directly and run `reload-profile` to pick up changes.

---

## WSL2 notes

This profile works inside WSL2 on Windows without modification.

- The `~/dev` paths map to the Linux home inside WSL2, not `C:\dev`. This is intentional - each environment keeps its own repos folder.
- `clipcopy`/`paste` use `xclip` - install it if you need clipboard access: `sudo apt install xclip`.
- `dns-flush` clears the Linux/WSL2 DNS cache via `systemd-resolve --flush-caches`.
- For GUI apps via WSL2, WSLg is required. Most tool shortcuts here are CLI only.

---

## How the profile works

`~/.bashrc` sources every numbered `.sh` file in `linux/topics/` in order:

```bash
for f in "$DOTFILES/linux/topics"/[0-9]*.sh; do
    [[ -r "$f" ]] && source "$f"
done
```

Files load from `01-path.sh` to `35-secrets.sh`. A higher-numbered file overrides an alias from a lower-numbered one if they share a name. See [linux/topics/README.md](../linux/topics/README.md) for the full listing.

`34-starship.sh` initialises the Starship prompt. The config lives in [linux/starship.toml](../linux/starship.toml), identical content to the Mac and Windows copies. Symlink it to `~/.config/starship.toml`.

> [!TIP]
> Starship's prompt uses glyphs (branch icon, language icons) that need a Nerd Font to render
> correctly, otherwise you get missing-glyph boxes. Install one (e.g. via your package manager or
> [nerdfonts.com](https://www.nerdfonts.com)) and set it as your terminal's font.

> [!TIP]
> The welcome banner in `bashrc` uses colour emoji, a separate thing from the Nerd Font above.
> macOS and Windows both ship a colour emoji font system-wide, so it always works there. Linux
> has no such guarantee, most desktop distros ship one already, but if the banner shows boxes or
> question marks instead of emoji, install one, for example on Debian/Ubuntu:
> `sudo apt install fonts-noto-color-emoji`.

---

## Navigation

Defined in [linux/topics/03-navigation.sh](../linux/topics/03-navigation.sh). Identical to macOS.

| Command | Destination |
| --- | --- |
| `dev` | `~/dev` |
| `downloads` | `~/Downloads` |
| `dot` | dotfiles repo directory |
| `..` | Up one directory |
| `...` | Up two directories |
| `....` | Up three directories |

---

## Git

Defined in [linux/topics/04-git.sh](../linux/topics/04-git.sh). Identical to macOS.

| Command | What it does |
| --- | --- |
| `gs` | `git status` |
| `ga <file>` | `git add <file>` |
| `gaa` | `git add --all` |
| `gcmt "message"` | `git commit -m "message"` |
| `gpsh` | `git push` |
| `gpul` | `git pull` |
| `glog` | `git log --oneline --graph --decorate --all` |
| `gco <branch>` | `git checkout <branch>` |
| `gcb <branch>` | Create and switch to a new branch |
| `gb` | `git branch` |
| `gbd <branch>` | Delete a local branch |
| `gd` | `git diff` |
| `gundo` | Undo last commit, keep changes staged |
| `gclean` | Remove untracked files: `git clean -fd` |
| `gcp "message"` | Stage all, commit and push in one step |

---

## Repo management

Defined in [linux/topics/04-git.sh](../linux/topics/04-git.sh). Identical to macOS.

| Command | What it does |
| --- | --- |
| `pull-all [dir]` | Pull latest commits in every repo under a directory |
| `repo-status [dir]` | Show branch and clean/dirty state for every repo |

---

## Core functions

Defined in [linux/topics/06-functions.sh](../linux/topics/06-functions.sh). Identical to macOS.

| Command | What it does |
| --- | --- |
| `cmds` | Print all custom aliases and functions grouped by topic, piped through `less` (press q to exit) |
| `mkcd <dir>` | Create a directory and `cd` into it |
| `mkf <file>` | Create a file and any missing parent directories |
| `mkr <name>` | Scaffold a new Rust project |
| `mkt <name>` | Scaffold a new TypeScript/Node project |
| `dot` | `cd` to the dotfiles repo |
| `edit-profile` | Open `~/.bashrc` in VS Code |
| `reload-profile` | Re-source the profile without restarting the terminal |

---

## Utilities

Defined in [linux/topics/07-utilities.sh](../linux/topics/07-utilities.sh) and [linux/topics/08-community.sh](../linux/topics/08-community.sh).

| Command | What it does |
| --- | --- |
| `ll` | Long list with hidden files and human-readable sizes |
| `la` | Long list with hidden files |
| `c` | Clear the terminal |
| `clipcopy` | Pipe to clipboard via `xclip -selection clipboard` |
| `paste` | Paste from clipboard via `xclip -selection clipboard -o` |
| `pubip` | Print public IP |
| `localip` | Print LAN IP via `hostname -I` |
| `weather` | Print weather for current location |
| `temp` | Print temperature only |
| `extract <archive>` | Extract any archive format |
| `dataurl <file>` | Convert a file to a base64 data URL |
| `envup [file]` | Load a `.env` file into the current session |
| `digga <domain>` | DNS lookup with common record types |
| `dns-flush` | Flush Linux DNS cache via `systemd-resolve --flush-caches` |

---

## Development shortcuts

For full descriptions of every command, see [documentation.md](documentation.md).

| Area | Key commands | Topic file |
| --- | --- | --- |
| Linuxbrew | `bup`, `bins`, `brm`, `brewclean`, `brewoutd` | [16-brew.sh](../linux/topics/16-brew.sh) |
| GitHub CLI | `ghpr`, `ghprc`, `ghclone`, `ghissue`, `ghgist`, `ghrun` | [17-gh.sh](../linux/topics/17-gh.sh) |
| Node/nvm | `nvminstall`, `nvmuse`, `nvmlts` (lazy-loaded) | [18-nvm.sh](../linux/topics/18-nvm.sh) |
| Docker | `dps`, `drun2`, `dcb`, `dcu`, `dcd`, `dlogs`, `dex` | [22-docker.sh](../linux/topics/22-docker.sh) |
| Kubernetes | `kc`, `kg`, `ka`, `kd`, `klogs`, `kns`, `kctx` | [23-kubernetes.sh](../linux/topics/23-kubernetes.sh) |
| Terraform | `tfi`, `tfp`, `tfa`, `tfd`, `tfst` | [25-devops.sh](../linux/topics/25-devops.sh) |
| SSH | `keygen`, `sshcp`, `ssha`, `sshtest`, `sshls` | [10-ssh.sh](../linux/topics/10-ssh.sh) |
| Database | `myconn`, `pgconn`, `rflush`, `sqls` | [13-database.sh](../linux/topics/13-database.sh) |
| Python | `py`, `venv`, `activate`, `pip`, `ptest`, `pfmt`, `plint` | [26-python.sh](../linux/topics/26-python.sh) |
| Web/Node | `nb`, `nd`, `nr`, `ns`, `nt`, `ni` | [27-web.sh](../linux/topics/27-web.sh) |
| Ruby | `be`, `binst`, `bupd`, `rs`, `rc`, `rdm`, `rspec` | [28-ruby.sh](../linux/topics/28-ruby.sh) |
| PHP | `pa`, `par`, `pam`, `pat`, `cupdate`, `punit`, `pint` | [29-php.sh](../linux/topics/29-php.sh) |
| Go | `gor`, `gob`, `got`, `gfmt`, `govet`, `gomod` | [30-go.sh](../linux/topics/30-go.sh) |
| Rust | `cr`, `cb`, `cbr`, `ct`, `ccheck`, `cfmt`, `cclippy` | [31-rust.sh](../linux/topics/31-rust.sh) |
| Java | `mvnt`, `mvnb`, `mvni`, `mvnc`, `gwb`, `gwt`, `gwr` | [32-java.sh](../linux/topics/32-java.sh) |
| C/C++ | `cc2`, `ccrun`, `ccdbg`, `ccsan`, `cppc`, `cfmt2` | [33-c-cpp.sh](../linux/topics/33-c-cpp.sh) |

---

## Colours

Defined in [linux/topics/02-colours.sh](../linux/topics/02-colours.sh). Variables are identical to macOS but the welcome banner uses `echo -e` to parse escape codes in bash.

| Variable | Code | Effect |
| --- | --- | --- |
| `BOLD` | `\033[1m` | Bold text |
| `DIM` | `\033[2m` | Dimmed text |
| `RED` | `\033[0;31m` | Red |
| `GREEN` | `\033[0;32m` | Green |
| `YELLOW` | `\033[1;33m` | Yellow (bold) |
| `BLUE` | `\033[0;34m` | Blue |
| `CYAN` | `\033[0;36m` | Cyan |
| `WHITE` | `\033[0;37m` | White |
| `RESET` | `\033[0m` | Clears all formatting |

`cmds()` uses a consistent 3-color scheme: **MAGENTA** for category headers, **CYAN** for command names and **WHITE** for short descriptions. Parenthetical expansion lines are also WHITE.

To change a colour, edit [linux/topics/02-colours.sh](../linux/topics/02-colours.sh) and run `reload-profile`.

---

## Extending the profile

Create a new file in `linux/topics/` with the next available number, e.g. `36-mytopic.sh`. It is sourced automatically. No changes to `bashrc` needed.

Before naming a new alias, check it is not already taken:

```bash
which myalias
type myalias
alias | grep myalias
```

---

## Platform differences from macOS

| Area | macOS | Linux |
| --- | --- | --- |
| Clipboard | `pbcopy`/`pbpaste` | `xclip -selection clipboard` |
| DNS flush | `sudo dscacheutil -flushcache` | `systemd-resolve --flush-caches` |
| IP address | `ipconfig getifaddr en0` | `hostname -I` |
| Brew casks | `binsc` available | No cask support on Linuxbrew |

---

## Troubleshooting

**Profile did not load** - check for syntax errors:

```bash
for f in linux/topics/*.sh; do bash -n "$f" && echo "OK: $f"; done
```

**An alias is not working** - run `type myalias` to confirm it loaded. Run `reload-profile` and try again.

**`copy`/`paste` not working** - install xclip:

```bash
sudo apt install xclip     # Ubuntu/Debian
sudo dnf install xclip     # Fedora
sudo pacman -S xclip       # Arch
```
