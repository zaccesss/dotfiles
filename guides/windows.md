# Windows Profile Guide

Setup and command reference for the PowerShell profile on Windows. The profile uses a modular topic system - each area of tools and functions lives in its own numbered file under [windows/topics/](../windows/topics/), loaded in order at shell startup. Function names are intentionally identical to the macOS and Linux profiles so muscle memory carries across all three platforms.

Profile file: `$PROFILE`
Repo copy: [windows/Microsoft.PowerShell_profile.ps1](../windows/Microsoft.PowerShell_profile.ps1)

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
- [Key Windows differences](#key-windows-differences)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Windows 10 or Windows 11
- PowerShell 7+ (recommended - install from the Microsoft Store or `winget install Microsoft.PowerShell`)
- git and VS Code installed
- GitHub CLI (`gh`) for the GitHub CLI commands

```powershell
$PSVersionTable.PSVersion   # check PowerShell version
winget install Git.Git Microsoft.VisualStudioCode GitHub.cli
gh auth login
```

---

## Installation

```powershell
$dir = Split-Path $PROFILE
if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force }
Copy-Item windows\Microsoft.PowerShell_profile.ps1 $PROFILE -Force
```

Restart PowerShell. The welcome banner confirms the profile loaded. Run `cmds` to see all available commands. Use `Edit-Profile` to open the profile in VS Code and `Reload-Profile` to apply changes without restarting.

> [!WARNING]
> If you see a script execution policy error, run this once before proceeding, then re-run the install:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

> [!IMPORTANT]
> The profile is a loader - it dot-sources topic files from the repo directory. Edit the topic files directly and run `Reload-Profile` to pick up changes.

---

## WSL2 notes

If you use WSL2, the Linux bash profile (`linux/bashrc`) applies inside WSL2 - not this PowerShell profile. The two profiles serve different shells:

- This PowerShell profile: native Windows PowerShell
- Linux bash profile: WSL2 terminal (bash inside the Linux subsystem)

Both can run simultaneously. Function names are identical across all three platforms so the same muscle memory applies everywhere. The `wt-here` and `wt-split` functions in [windows/topics/21-tmux.ps1](../windows/topics/21-tmux.ps1) help manage Windows Terminal panes alongside a WSL2 session.

> [!TIP]
> Install Windows Terminal from the Microsoft Store. It supports ANSI colour codes and multiple tabs/panes out of the box. The legacy Windows Console Host (`conhost.exe`) does not support all of these.

---

## How the profile works

`$PROFILE` dot-sources every numbered `.ps1` file in `windows/topics/` in order:

```powershell
Get-ChildItem "$PSScriptRoot\topics\[0-9]*.ps1" | Sort-Object Name | ForEach-Object {
    . $_.FullName
}
```

Files load from `01-path.ps1` to `35-secrets.ps1`. A later-numbered file overrides a function from an earlier one if they share a name. See [windows/topics/README.md](../windows/topics/README.md) for the full listing.

`34-starship.ps1` initialises the Starship prompt. The config lives in [windows/starship.toml](../windows/starship.toml), identical content to the Mac and Linux copies. Symlink it to `~/.config/starship.toml`.

> [!TIP]
> Starship's prompt uses glyphs (branch icon, language icons) that need a Nerd Font to render
> correctly, otherwise you get missing-glyph boxes. Install one (e.g. `winget install
> DEVCOM.JetBrainsMonoNerdFont`) and set it as your terminal's font.

---

## Navigation

Defined in [windows/topics/03-navigation.ps1](../windows/topics/03-navigation.ps1). Identical names to macOS and Linux.

| Command | Destination |
| --- | --- |
| `dev` | `C:\dev` |
| `downloads` | `$HOME\Downloads` |
| `dot` | dotfiles repo directory |

---

## Git

Defined in [windows/topics/04-git.ps1](../windows/topics/04-git.ps1). Identical names to macOS and Linux.

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

Defined in [windows/topics/04-git.ps1](../windows/topics/04-git.ps1). Identical names to macOS and Linux.

| Command | What it does |
| --- | --- |
| `pull-all [dir]` | Pull latest commits in every repo under a directory |
| `repo-status [dir]` | Show branch and clean/dirty state for every repo |

---

## Core functions

Defined in [windows/topics/06-functions.ps1](../windows/topics/06-functions.ps1). Identical names to macOS and Linux.

| Command | What it does |
| --- | --- |
| `cmds` | Print all custom functions grouped by topic, piped through `Out-Host -Paging` (press q to exit) |
| `mkcd <dir>` | Create a directory and `cd` into it |
| `mkf <file>` | Create a file and any missing parent directories |
| `mkr <name>` | Scaffold a new Rust project |
| `mkt <name>` | Scaffold a new TypeScript/Node project |
| `dot` | `cd` to the dotfiles repo |
| `Edit-Profile` | Open `$PROFILE` in VS Code |
| `Reload-Profile` | Re-source the profile without restarting PowerShell |

`cmds` pipes its output through `Out-Host -Paging`, PowerShell's native pager, so real scrolling and a clean q-to-exit work regardless of output length. Colour is preserved because `cmds` builds each line as a plain string with raw ANSI codes rather than `Write-Host -ForegroundColor`, since `Write-Host` output cannot be piped.

---

## Utilities

Defined in [windows/topics/07-utilities.ps1](../windows/topics/07-utilities.ps1) and [windows/topics/08-community.ps1](../windows/topics/08-community.ps1).

| Command | What it does |
| --- | --- |
| `ll` | Long list with hidden files |
| `la` | Long list with hidden files |
| `c` | Clear the terminal |
| `clipcopy` | Set clipboard: `$input \| Set-Clipboard` |
| `paste` | Get clipboard: `Get-Clipboard` |
| `pubip` | Print public IP |
| `localip` | Print LAN IP |
| `weather` | Print weather for current location |
| `temp` | Print temperature only |
| `extract <archive>` | Extract any archive format |
| `dataurl <file>` | Convert a file to a base64 data URL |
| `envup [file]` | Load a `.env` file into the current session |
| `digga <domain>` | DNS lookup with common record types |
| `dns-flush` | Flush Windows DNS cache via `ipconfig /flushdns` |

---

## Development shortcuts

For full descriptions of every command, see [documentation.md](documentation.md).

| Area | Key commands | Topic file |
| --- | --- | --- |
| winget / Choco | `wgins`, `wgup`, `wgls`, `chocoins`, `chocoup` | [16-winget.ps1](../windows/topics/16-winget.ps1) |
| GitHub CLI | `ghpr`, `ghprc`, `ghclone`, `ghissue`, `ghgist`, `ghrun` | [17-gh.ps1](../windows/topics/17-gh.ps1) |
| Node / nvm | `nvminstall`, `nvmuse`, `nvmlts` | [18-nvm.ps1](../windows/topics/18-nvm.ps1) |
| Docker | `dps`, `drun2`, `dcb`, `dcu`, `dcd`, `dlogs`, `dex` | [22-docker.ps1](../windows/topics/22-docker.ps1) |
| Kubernetes | `kc`, `kg`, `ka`, `kd`, `klogs`, `kns`, `kctx` | [23-kubernetes.ps1](../windows/topics/23-kubernetes.ps1) |
| Windows Terminal | `wt-here`, `wt-split` | [21-tmux.ps1](../windows/topics/21-tmux.ps1) |
| Terraform | `tfi`, `tfp`, `tfa`, `tfd`, `tfst` | [25-devops.ps1](../windows/topics/25-devops.ps1) |
| SSH | `keygen`, `sshcp`, `ssha`, `sshtest`, `sshls` | [10-ssh.ps1](../windows/topics/10-ssh.ps1) |
| Database | `myconn`, `pgconn`, `rflush`, `sqls` | [13-database.ps1](../windows/topics/13-database.ps1) |
| Shell tools | `shck` (shellcheck), `psanalyse`, `psanalysefix` | [20-shell-tools.ps1](../windows/topics/20-shell-tools.ps1) |
| Python | `py`, `venv`, `activate`, `pip`, `ptest`, `pfmt`, `plint` | [26-python.ps1](../windows/topics/26-python.ps1) |
| Web / Node | `nb`, `nd`, `nr`, `ns`, `nt`, `npmi` (note: not `ni`) | [27-web.ps1](../windows/topics/27-web.ps1) |
| Ruby | `be`, `binst`, `bupd`, `rs`, `rc`, `rdm`, `rspec` | [28-ruby.ps1](../windows/topics/28-ruby.ps1) |
| PHP | `pa`, `par`, `pam`, `pat`, `cupdate`, `punit`, `pint` | [29-php.ps1](../windows/topics/29-php.ps1) |
| Go | `gor`, `gob`, `got`, `gfmt`, `govet`, `gomod` | [30-go.ps1](../windows/topics/30-go.ps1) |
| Rust | `cr`, `cb`, `cbr`, `ct`, `ccheck`, `cfmt`, `cclippy` | [31-rust.ps1](../windows/topics/31-rust.ps1) |
| Java | `mvnt`, `mvnb`, `mvni`, `mvnc`, `gwb`, `gwt`, `gwr` | [32-java.ps1](../windows/topics/32-java.ps1) |
| C/C++ | `cc2`, `ccrun`, `ccdbg`, `ccsan`, `cppc`, `cfmt2` | [33-c-cpp.ps1](../windows/topics/33-c-cpp.ps1) |

---

## Colours

Defined in [windows/topics/02-colours.ps1](../windows/topics/02-colours.ps1). The welcome banner and `cmds` output use `Write-Host` with `-ForegroundColor` parameters.

`cmds` uses a consistent 3-color scheme: **Magenta** for category headers, **Cyan** for command names and **White** for short descriptions. Parenthetical expansion lines are also White.

To change a colour, edit [windows/topics/02-colours.ps1](../windows/topics/02-colours.ps1) or the welcome block in [windows/topics/05-profile.ps1](../windows/topics/05-profile.ps1) and run `Reload-Profile`.

---

## Extending the profile

Create a new file in `windows/topics/` with the next available number, e.g. `36-mytopic.ps1`. It is dot-sourced automatically. No changes to the profile loader needed.

Before naming a new function, check it is not already taken:

```powershell
Get-Command myfunction -ErrorAction SilentlyContinue
Get-Alias myfunction -ErrorAction SilentlyContinue
```

---

## Key Windows differences

| Area | macOS / Linux | Windows |
| --- | --- | --- |
| shellcheck | `sc` | `shck` - `sc` is reserved for `sc.exe` (Service Control Manager) |
| Clipboard | `pbcopy`/`xclip` | `Set-Clipboard`/`Get-Clipboard` |
| DNS flush | platform-specific | `ipconfig /flushdns` |
| Package manager | Homebrew | winget and Chocolatey |
| tmux | native tmux | tmux via WSL + `wt-here`/`wt-split` for Windows Terminal |
| git wrapper | Shell function | `function git` wraps `git.exe` - non-push commands pass through unchanged |

---

## Troubleshooting

**Profile did not load** - check execution policy:

```powershell
Get-ExecutionPolicy -Scope CurrentUser
# if Restricted, run:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**A function is not recognised** - run `Get-Command myfunction` to check if it loaded. Run `Reload-Profile` and try again.

**`sc` (shellcheck) not working** - use `shck`. `sc` is Windows `sc.exe`.

**`cmds` not paging correctly** - `Out-Host -Paging` needs a real interactive console. Upgrade from the legacy Windows Console Host (`conhost.exe`) to Windows Terminal for full support.
