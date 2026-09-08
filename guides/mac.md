# Mac Profile Guide

Setup and command reference for the zsh profile on macOS. The profile uses a modular topic system - each area of tools and aliases lives in its own numbered file under [mac/topics/](../mac/topics/), loaded in order at shell startup.

Profile file: `~/.zshrc`
Repo copy: [mac/zshrc](../mac/zshrc)

---

## Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [How the profile works](#how-the-profile-works)
- [Navigation](#navigation)
- [Git](#git)
- [Repo management](#repo-management)
- [Core functions](#core-functions)
- [Utilities](#utilities)
- [Development shortcuts](#development-shortcuts)
- [Colours](#colours)
- [Extending the profile](#extending-the-profile)
- [Avoiding alias conflicts](#avoiding-alias-conflicts)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- macOS with zsh (default since macOS Catalina)
- [Homebrew](https://brew.sh) installed at `/opt/homebrew`
- VS Code installed with the `code` command available in the terminal

To confirm zsh is your shell:

```bash
echo $SHELL
# should print /bin/zsh
```

---

## Installation

```bash
cp mac/zshrc ~/.zshrc
source ~/.zshrc
```

The welcome banner confirms the profile loaded.

> [!TIP]
> Run `cmds` to see every available command grouped by topic, piped through `less`, press q to exit.

Use `edit-profile` to open the profile in VS Code and `reload-profile` to apply changes without restarting the terminal.

> [!IMPORTANT]
> The profile is a loader - it sources the topic files from wherever you installed the repo. After installation, edit the topic files in the repo directly (not `~/.zshrc`) and run `reload-profile` to pick up changes.

---

## How the profile works

`~/.zshrc` sources every numbered `.zsh` file in `mac/topics/` in order:

```zsh
for f in "$DOTFILES/mac/topics"/[0-9]*.zsh; do
    [[ -r "$f" ]] && source "$f"
done
```

Files are loaded from `01-path.zsh` to `35-secrets.zsh`. A higher-numbered file overrides an alias from a lower-numbered one if they share a name. See [mac/topics/README.md](../mac/topics/README.md) for the full listing of all topic files.

`34-starship.zsh` initialises the Starship prompt. The config lives in [mac/starship.toml](../mac/starship.toml), identical content to the Linux and Windows copies. Symlink it to `~/.config/starship.toml`.

> [!TIP]
> Starship's prompt uses glyphs (branch icon, language icons) that need a Nerd Font to render
> correctly, otherwise you get missing-glyph boxes. Install one (e.g. `brew install --cask
> font-jetbrains-mono-nerd-font`) and set it as your terminal's font.

To add a new group of aliases, create a new file (e.g. `36-mytopic.zsh`) in `mac/topics/`. It is picked up automatically at the next `reload-profile`. No changes to `zshrc` needed.

---

## Navigation

Defined in [mac/topics/03-navigation.zsh](../mac/topics/03-navigation.zsh).

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

Defined in [mac/topics/04-git.zsh](../mac/topics/04-git.zsh).

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
| `gcb <branch>` | Create and switch to a new branch: `git checkout -b` |
| `gb` | `git branch` - list branches |
| `gbd <branch>` | Delete a local branch |
| `gd` | `git diff` |
| `gundo` | Undo last commit, keep changes staged: `git reset --soft HEAD~1` |
| `gclean` | Remove untracked files and directories: `git clean -fd` |
| `gcp "message"` | Stage all, commit and push in one step |

> [!CAUTION]
> `gclean` runs `git clean -fd` which permanently deletes untracked files and directories. There is no undo. Make sure you do not need any of the untracked files before running it.

---

## Repo management

Defined in [mac/topics/04-git.zsh](../mac/topics/04-git.zsh).

| Command | What it does |
| --- | --- |
| `pull-all [dir]` | Pull the latest commits in every repo under a directory. Defaults to `~/dev/github/repos`. |
| `repo-status [dir]` | Show branch and clean/dirty state for every repo under a directory |

---

## Core functions

Defined in [mac/topics/06-functions.zsh](../mac/topics/06-functions.zsh).

| Command | What it does |
| --- | --- |
| `cmds` | Print all custom aliases and functions grouped by topic, piped through `less` (press q to exit) |
| `mkcd <dir>` | Create a directory and `cd` into it |
| `mkf <file>` | Create a file and any missing parent directories |
| `mkr <name>` | Scaffold a new Rust project with `cargo new` |
| `mkt <name>` | Scaffold a new TypeScript/Node project |
| `dot` | `cd` to the dotfiles repo |
| `edit-profile` | Open `~/.zshrc` in VS Code |
| `reload-profile` | Re-source the profile without restarting the terminal |

`cmds` pipes its output through `less`, the same mechanism `git diff` and `man` use, so real scrolling and a clean `q`-to-exit work regardless of terminal or output length.

---

## Utilities

Defined in [mac/topics/07-utilities.zsh](../mac/topics/07-utilities.zsh) and [mac/topics/08-community.zsh](../mac/topics/08-community.zsh).

| Command | What it does |
| --- | --- |
| `ll` | `ls -lah` - long list with hidden files and human-readable sizes |
| `la` | `ls -la` - long list with hidden files |
| `c` | Clear the terminal |
| `clipcopy` | Pipe to clipboard: `pbcopy` |
| `paste` | Paste from clipboard: `pbpaste` |
| `pubip` | Print public IP via `curl ifconfig.me` |
| `localip` | Print LAN IP via `ipconfig getifaddr en0` |
| `weather` | Print weather for current location via `wttr.in` |
| `temp` | Print temperature only |
| `extract <archive>` | Extract any archive format (zip, tar.gz, tar.bz2, 7z, rar, etc.) |
| `dataurl <file>` | Convert a file to a base64 data URL |
| `envup [file]` | Load a `.env` file and export all variables into the current session |
| `digga <domain>` | Run DNS lookup via `dig` with common record types |
| `dns-flush` | Flush the macOS DNS cache |

---

## Development shortcuts

The profile covers a wide range of tools. Here is a summary grouped by area. For full descriptions of every command, see [documentation.md](documentation.md).

| Area | Key commands | Topic file |
| --- | --- | --- |
| Homebrew | `bup`, `bins`, `brm`, `brewclean`, `brewoutd`, `bbundle`, `bdump` | [16-brew.zsh](../mac/topics/16-brew.zsh) |
| GitHub CLI | `ghpr`, `ghprc`, `ghclone`, `ghissue`, `ghgist`, `ghrun` | [17-gh.zsh](../mac/topics/17-gh.zsh) |
| Node/nvm | `nvminstall`, `nvmuse`, `nvmlts` (lazy-loaded) | [18-nvm.zsh](../mac/topics/18-nvm.zsh) |
| Docker | `dps`, `drun2`, `dcb`, `dcu`, `dcd`, `dlogs`, `dex` | [22-docker.zsh](../mac/topics/22-docker.zsh) |
| Kubernetes | `kc`, `kg`, `ka`, `kd`, `klogs`, `kns`, `kctx` | [23-kubernetes.zsh](../mac/topics/23-kubernetes.zsh) |
| Terraform | `tfi`, `tfp`, `tfa`, `tfd`, `tfst` | [25-devops.zsh](../mac/topics/25-devops.zsh) |
| SSH | `keygen`, `sshcp`, `ssha`, `sshtest`, `sshls` | [10-ssh.zsh](../mac/topics/10-ssh.zsh) |
| Database | `myconn`, `pgconn`, `rflush`, `sqls` | [13-database.zsh](../mac/topics/13-database.zsh) |
| Python | `py`, `venv`, `activate`, `pip`, `ptest`, `pfmt`, `plint` | [26-python.zsh](../mac/topics/26-python.zsh) |
| Web/Node | `nb`, `nd`, `nr`, `ns`, `nt`, `ni` | [27-web.zsh](../mac/topics/27-web.zsh) |
| Ruby | `be`, `binst`, `bupd`, `rs`, `rc`, `rdm`, `rspec` | [28-ruby.zsh](../mac/topics/28-ruby.zsh) |
| PHP | `pa`, `par`, `pam`, `pat`, `cupdate`, `punit`, `pint` | [29-php.zsh](../mac/topics/29-php.zsh) |
| Go | `gor`, `gob`, `got`, `gfmt`, `govet`, `gomod` | [30-go.zsh](../mac/topics/30-go.zsh) |
| Rust | `cr`, `cb`, `cbr`, `ct`, `ccheck`, `cfmt`, `cclippy` | [31-rust.zsh](../mac/topics/31-rust.zsh) |
| Java | `mvnt`, `mvnb`, `mvni`, `mvnc`, `gwb`, `gwt`, `gwr` | [32-java.zsh](../mac/topics/32-java.zsh) |
| C/C++ | `cc2`, `ccrun`, `ccdbg`, `ccsan`, `cppc`, `cfmt2` | [33-c-cpp.zsh](../mac/topics/33-c-cpp.zsh) |

---

## Homebrew packages

[mac/Brewfile](../mac/Brewfile) lists every formula, cask and global npm package installed on this
machine via Homebrew, produced by `brew bundle dump --describe --no-vscode`. VS Code extensions are
excluded, the separate `.vscode` repo's own `extensions.txt` is the source of truth there.

- **New machine**: `bbundle` installs everything listed in `mac/Brewfile`.
- **After installing or removing something with brew**: `bdump` regenerates `mac/Brewfile` from
  what is actually installed.

---

## Colours

The colour variables are defined in [mac/topics/02-colours.zsh](../mac/topics/02-colours.zsh) and used in the welcome banner and in `cmds`.

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

The welcome banner prints at every new shell. It shows the machine name (`$(scutil --get ComputerName)`), the current date and time and a confirmation the profile loaded.

`cmds()` uses a consistent 3-color scheme: **MAGENTA** for category headers, **CYAN** for command names and **WHITE** for short descriptions. Parenthetical expansion lines are also WHITE.

To change a colour, edit the relevant variable in [mac/topics/02-colours.zsh](../mac/topics/02-colours.zsh) and run `reload-profile`.

---

## Extending the profile

To add a new group of aliases:

1. Create a new file in `mac/topics/` with the next available number, e.g. `36-mytopic.zsh`
2. Add aliases and functions to the file
3. Run `reload-profile`
4. Run `cmds` to confirm they appear

No changes to `zshrc` needed. The loader picks up any file matching `[0-9]*.zsh`.

To add a single alias quickly to an existing topic, open the relevant file with `edit-profile` (or `code mac/topics/07-utilities.zsh`) and add the line, then `reload-profile`.

Before naming a new alias, check it is not already taken:

```zsh
which myalias       # prints path if it is a real binary
type myalias        # shows if it is an alias, function or binary
alias | grep alias  # finds any existing aliases
```

---

## Avoiding alias conflicts

Files load in numerical order. A name defined in a higher-numbered file overrides the same name from a lower-numbered file. Before naming a new alias, check it is not already taken in an earlier-numbered file. See [journal/003-alias-conflicts.md](../journal/003-alias-conflicts.md) for the conflicts found so far.

---

## Troubleshooting

**Profile did not load after `source ~/.zshrc`** - check for syntax errors:

```zsh
zsh -n mac/topics/06-functions.zsh
# or check all topic files
for f in mac/topics/*.zsh; do zsh -n "$f" && echo "OK: $f"; done
```

**An alias is not working** - run `type myalias` to confirm it loaded. If nothing is returned, the profile may not have been reloaded. Run `reload-profile` and try again.

**Colours not showing** - check the terminal supports ANSI codes. In Terminal.app, enable "Use bright colors for bold text" under Profiles > Text. If the `RESET` variable is missing from `02-colours.zsh`, colours will bleed into subsequent output.
