# Linux Profile Guide

Setup and command reference for the Linux and WSL2 profile. zsh is the default, matching the macOS profile; bash stays as a fallback for a machine without zsh. Each area of tools and aliases lives in its own numbered file, loaded in order at shell startup: the zsh topics under [linux/topics-zsh/](../linux/topics-zsh/) and the parallel bash topics under [linux/topics/](../linux/topics/). The command names are intentionally identical to the macOS profile so muscle memory carries across with no adjustment.

Default profile file: `~/.zshrc`
Repo copy: [linux/zshrc](../linux/zshrc)

Fallback profile file: `~/.bashrc`
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
- zsh 5.8+ for the default profile. The bash fallback needs bash 4+, which is the default on most distros
- git, curl and jq installed
- VS Code with the `code` command available (optional but used by `edit-profile`)
- GitHub CLI (`gh`) for the GitHub CLI commands

```bash
# Ubuntu/Debian
sudo apt install -y git curl jq
```

Install zsh and the syntax-highlighting plugin that colours typed commands:

```bash
# Ubuntu/Debian
sudo apt install -y zsh zsh-syntax-highlighting
# Fedora
sudo dnf install -y zsh zsh-syntax-highlighting
```

Make zsh the login shell (it takes effect at the next login):

```bash
chsh -s "$(command -v zsh)"
```

---

## Installation

zsh (the default):

```bash
cp linux/zshrc ~/.zshrc
source ~/.zshrc
```

bash (the fallback, for a machine without zsh):

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
- `clipcopy`/`clippaste` use `xclip` - install it if you need clipboard access: `sudo apt install xclip`.
- `dns-flush` clears the Linux/WSL2 DNS cache via `systemd-resolve --flush-caches`.
- For GUI apps via WSL2, WSLg is required. Most tool shortcuts here are CLI only.

---

## How the profile works

`~/.zshrc` sources every numbered `.zsh` file in `linux/topics-zsh/` in order (and `~/.bashrc` does the same for the `.sh` files in `linux/topics/`):

```zsh
for f in "$DOTFILES/linux/topics-zsh/"*.zsh; do
    [[ -f "$f" ]] && source "$f"
done
```

Files load from `01-path.zsh` to `38-syntax-highlighting.zsh`. A higher-numbered file overrides an alias from a lower-numbered one if they share a name. See [linux/topics-zsh/README.md](../linux/topics-zsh/README.md) for what differs from the bash topics and [linux/topics/README.md](../linux/topics/README.md) for the full command listing.

Both profiles bail out early in a non-interactive shell, so a login shell running a single command (`ssh host cmd`, `scp`, `rsync`) loads nothing and prints no banner.

`38-syntax-highlighting.zsh` loads zsh-syntax-highlighting last, so typed commands are coloured as you type: a known command, alias, function or builtin green, an unknown command red, quoted strings yellow and options cyan. It is sourced from `/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh` and is silently skipped when the package is not installed. Colour is only a second signal here: an unknown command still fails to run.

`34-starship.zsh` (and `34-starship.sh` under bash) initialises the Starship prompt. The config lives in [linux/starship.toml](../linux/starship.toml), identical content to the Mac and Windows copies. Symlink it to `~/.config/starship.toml`.

> [!TIP]
> The prompt does not need a Nerd Font. Its own symbols (the `>` prompt character, jobs and git
> status) are plain ASCII and most language modules use Starship's default emoji. Node.js shows
> the plain text `node` instead of Starship's default Nerd Font glyph. The terminals on my Mac use
> Monaco 12 in iTerm2 and Warp's default font at size 13, neither of them a Nerd Font. Other tools that use icon glyphs need
> one (from your package manager or [nerdfonts.com](https://www.nerdfonts.com)) set as the
> terminal's font.

### Command marks

`37-command-marks.zsh` (and `37-command-marks.sh` under bash) marks where each prompt, command and output starts and ends (OSC 133 shell integration). A terminal that reads the marks can then jump from one command to the next and select a single command's output. zsh uses `precmd` and `preexec` hooks; bash chains onto `PROMPT_COMMAND` without replacing it and uses `PS0`. Both load after Starship, so the end-of-prompt mark follows the prompt Starship builds. The zsh file loads before syntax highlighting, which stays last.

| Terminal | How to move between commands |
| --- | --- |
| Windows Terminal (WSL) | Actions bound in its own `settings.json`: see the [Windows guide](windows.md#command-marks) |
| VS Code's terminal | VS Code uses its own shell integration and the profile leaves it alone: `Ctrl+Up` and `Ctrl+Down` |
| tmux and other terminals that read OSC 133 | Their own prompt-jump keys |

The marks are skipped in a dumb terminal and in a non-interactive shell.

Under WSL, `BROWSER` is set to `explorer.exe` when it is not already set (and `wslview` is not installed), so `gh` and other tools open links in the Windows browser.

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
| `gclean-branches` | Delete every local branch already merged into main in one step |

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
| `welcome` | Print the welcome banner again. `DOTFILES_NO_BANNER=1` hides it when a shell starts |
| `update` | List everything out of date (system packages, global npm packages and uv tools), then upgrade it all after a yes |
| `sysinfo` | Full system summary through fastfetch: OS, CPU, GPU, memory and disk (install with `sudo apt install fastfetch`) |
| `copyout <command>` | Run a command, show its output as normal and copy all of it (output and errors) to the clipboard, then say how many lines were copied. Uses `clip.exe` under WSL, otherwise `wl-copy` (Wayland) or `xclip` (X11), with an install hint when none is available. The command's exit status is kept |
| `logrun <command>` | Run a command with its output shown live and saved to `~/logs/<YYYY-MM-DD_HHMMSS>-<command>.log`, then print the log's path. The command's exit status is kept |
| `games` | A menu of six terminal games: 2048, Snake, Blocks, Meteors, Word and a typing test. Arrows choose, Enter plays, Q or Esc leaves any game |
| `mkf <file>` | Create a file and any missing parent directories |
| `mkr <name>` | Scaffold a new Rust project |
| `mkt <name>` | Scaffold a new TypeScript/Node project |
| `dot` | `cd` to the dotfiles repo |
| `edit-profile` | Open the profile in VS Code (`~/.zshrc` by default; `~/.bashrc` under the bash fallback) |
| `reload-profile` | Hard-clear the terminal then re-source the profile without restarting it |

---

## Utilities

Defined in [linux/topics/07-utilities.sh](../linux/topics/07-utilities.sh) and [linux/topics/08-community.sh](../linux/topics/08-community.sh).

| Command | What it does |
| --- | --- |
| `ll` | Long list with hidden files and human-readable sizes |
| `la` | Long list with hidden files |
| `c` | Clear the terminal |
| `clipcopy` | Pipe to clipboard via `xclip -selection clipboard` |
| `clippaste` | Paste from clipboard via `xclip -selection clipboard -o` |
| `pubip` | Print public IP |
| `localip` | Print LAN IP via `hostname -I` |
| `weather` | Print weather for current location |
| `temp` | Print temperature only |
| `battery` | Print charge percentage and status. Requires `acpi` |
| `please` | Rerun the last command with `sudo` |
| `cheat <command>` | Print an instant command cheatsheet from `cheat.sh` |
| `zipf <file-or-folder>` | Zip a file or folder into a same-named `.zip` |
| `google <query>` | Open the default browser straight to a search for `<query>` |
| `gh-search <query>` | Search GitHub itself (code and repos) |
| `so <query>` | Search Stack Overflow |
| `mdn <query>` | Search MDN Web Docs |
| `npmjs <package>` | Jump to a package's npm page |
| `pypi <package>` | Jump to a package's PyPI page |
| `caniuse <query>` | Check browser support for a web feature |
| `leetcode <slug>` | Jump to a LeetCode problem page |
| `neetcode <slug>` | Jump to a NeetCode problem page |
| `codeforces [path]` | Jump to a Codeforces page, defaults to my own profile |
| `translate <text>` | Quick Google Translate lookup |
| `regex101` | Open regex101.com for quick regex testing |
| `maps <query>` | Search Google Maps |
| `yt <query>` | Search YouTube |
| `wiki <query>` | Search Wikipedia |
| `godocs <package>` | Jump to a Go package's page on pkg.go.dev |
| `crates <package>` | Jump to a Rust package's page on crates.io |
| `dockerhub <query>` | Search Docker Hub for an image |
| `packagist <vendor/package>` | Jump to a PHP/Composer package's page |
| `rubygems <package>` | Jump to a Ruby gem's page |
| `nugetpkg <package>` | Jump to a .NET package's page on NuGet |
| `mvnrepo <query>` | Search Maven Central for a Java/Kotlin package |
| `hexpm <package>` | Jump to an Elixir package's page on Hex.pm |
| `archive <url>` | Open the Wayback Machine's history for a URL |
| `bundlephobia <package>` | Check an npm package's real bundle-size cost |
| `vt <query>` | Search VirusTotal for a hash, IP or domain |
| `shodan <query>` | Search Shodan |
| `cve <id>` | Jump to a CVE's NVD detail page |
| `extract <archive>` | Extract any archive format |
| `dataurl <file>` | Convert a file to a base64 data URL |
| `envup [file]` | Load a `.env` file into the current session |
| `digga <domain>` | DNS lookup with common record types. Prints an install hint when `dig` is missing |
| `dns <domain>` | Quick DNS lookup with all record types. Prints the same hint when `dig` is missing |
| `dns-flush` | Flush Linux DNS cache via `systemd-resolve --flush-caches` |
| `speedtest` | Run a network speed test (prefers the installed `speedtest-cli`, with an install hint otherwise) |

---

## Development shortcuts

For full descriptions of every command, see [documentation.md](documentation.md).

| Area | Key commands | Topic file |
| --- | --- | --- |
| Linuxbrew | `bup`, `bins`, `brm`, `brewclean`, `brewoutd` | [16-brew.sh](../linux/topics/16-brew.sh) |
| GitHub CLI | `ghpr`, `ghprc`, `ghclone`, `ghissue`, `ghgist`, `ghrun` | [17-gh.sh](../linux/topics/17-gh.sh) |
| Node/nvm | `nvminstall`, `nvmuse`, `nvmlts` (nvm lazy-loaded, default Node on `PATH` from the start) | [18-nvm.sh](../linux/topics/18-nvm.sh) |
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

Defined in [linux/topics-zsh/02-colours.zsh](../linux/topics-zsh/02-colours.zsh) for zsh and [linux/topics/02-colours.sh](../linux/topics/02-colours.sh) for bash. Variables are identical to macOS; the welcome banner uses `echo -e` to parse the escape codes, which both bash and zsh honour.

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

Create a new file in `linux/topics/` with the next available number, e.g. `38-mytopic.sh`. It is sourced automatically. No changes to `bashrc` needed.

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
for f in linux/topics-zsh/*.zsh; do zsh -n "$f" && echo "OK: $f"; done   # zsh profile
for f in linux/topics/*.sh;        do bash -n "$f" && echo "OK: $f"; done  # bash fallback
```

**An alias is not working** - run `type myalias` to confirm it loaded. Run `reload-profile` and try again.

**`copy`/`clippaste` not working** - install xclip:

```bash
sudo apt install xclip     # Ubuntu/Debian
sudo dnf install xclip     # Fedora
sudo pacman -S xclip       # Arch
```
