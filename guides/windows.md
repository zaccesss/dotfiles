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
- PowerShell 7+ (required - install from the Microsoft Store or `winget install Microsoft.PowerShell`). The topic files use PowerShell 7 syntax, so if the loader is run from the built-in Windows PowerShell 5.1 it loads nothing and prints one dim line: `dotfiles need PowerShell 7: run pwsh`. 5.1 reads its own profile under `Documents\WindowsPowerShell`, which the setup never writes, so it normally loads nothing at all.
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

A one-line pointer profile works too and follows every `git pull` with nothing to copy. `dot` leaves a pointer like this in place:

```powershell
Set-Content $PROFILE ". `"$HOME\dev\github\repos\dotfiles\windows\Microsoft.PowerShell_profile.ps1`""
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

`$PROFILE` points at the repo's loader, which dot-sources every `.ps1` file in `windows/topics/` in name order from the `DOTFILES` path (`~\dev\github\repos\dotfiles` unless `DOTFILES` is already set):

```powershell
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "dotfiles need PowerShell 7: run pwsh" -ForegroundColor DarkGray
    return
}

$env:DOTFILES = if ($env:DOTFILES) { $env:DOTFILES } else { "$HOME\dev\github\repos\dotfiles" }

Get-ChildItem "$env:DOTFILES\windows\topics\*.ps1" | Sort-Object Name | ForEach-Object {
    . $_.FullName
}
```

Files load from `01-path.ps1` to `36-command-marks.ps1`. A later-numbered file overrides a function from an earlier one if they share a name. `Reload-Profile` and `dot` run the same loader and then copy the functions, aliases and variables it defines into the global scope, so a change made in a topic file is live in the current session straight after the reload. See [windows/topics/README.md](../windows/topics/README.md) for the full listing.

`01-path.ps1` adds `C:\Program Files\LibreOffice\program` to the end of `PATH` when it exists, so `soffice` works for headless document conversion. It goes last because that folder also holds LibreOffice's own `python.exe`. The welcome banner reads the Windows edition from the registry only on Windows, so loading the profile in `pwsh` on macOS or Linux prints no errors.

`34-starship.ps1` initialises the Starship prompt. The config lives in [windows/starship.toml](../windows/starship.toml), identical content to the Mac and Linux copies. Symlink it to `~/.config/starship.toml`.

> [!TIP]
> The prompt does not need a Nerd Font. Its own symbols (the `>` prompt character, jobs and git
> status) are plain ASCII and most language modules use Starship's default emoji. Node.js shows
> the plain text `node` instead of Starship's default Nerd Font glyph. The terminals on my Mac use
> Monaco 12 in iTerm2 and Warp's default font at size 13, neither of them a Nerd Font. Other tools that use icon glyphs need
> one (for example `winget install DEVCOM.JetBrainsMonoNerdFont`) set as the terminal's font.

### Command marks

`36-command-marks.ps1` marks where each prompt, command and output starts and ends (OSC 133 shell integration). It loads after Starship and wraps the prompt Starship defines: the start and end of the prompt, then the exit status of the command that just finished (its own exit code when it was a native command that failed, otherwise 0 or 1 from `$?`). A PSReadLine handler on Enter marks where the output starts. The marks are skipped in a dumb terminal, a non-interactive session and VS Code, which has its own shell integration (`Ctrl+Up` and `Ctrl+Down` there).

Windows Terminal reads the marks through its `scrollToMark`, `selectCommand` and `selectOutput` actions. They are set up in the Windows Terminal settings (`settings.json`), which are not part of these dotfiles. For example, in its `actions` list:

```json
"actions": [
    { "keys": "ctrl+up", "command": { "action": "scrollToMark", "direction": "previous" } },
    { "keys": "ctrl+down", "command": { "action": "scrollToMark", "direction": "next" } },
    { "keys": "ctrl+shift+up", "command": { "action": "selectCommand", "direction": "prev" } },
    { "keys": "ctrl+shift+down", "command": { "action": "selectCommand", "direction": "next" } },
    { "keys": "ctrl+shift+alt+up", "command": { "action": "selectOutput", "direction": "prev" } },
    { "keys": "ctrl+shift+alt+down", "command": { "action": "selectOutput", "direction": "next" } }
]
```

With these, `Ctrl+Up` and `Ctrl+Down` jump to the previous or next command, `Ctrl+Shift+Up` and `Ctrl+Shift+Down` select a whole command and `Ctrl+Shift+Alt+Up` and `Ctrl+Shift+Alt+Down` select just its output. Setting `"showMarksOnScrollbar": true` under `profiles.defaults` also shows each command as a tick on the scrollbar (Windows Terminal 1.21 or later).

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
| `gclean-branches` | Delete every local branch already merged into main in one step |

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
| `cmds` | Print all custom functions grouped by topic, paged through `less -RF` (press q to exit) |
| `mkcd <dir>` | Create a directory and `cd` into it |
| `welcome` | Print the welcome banner again. `DOTFILES_NO_BANNER=1` hides it when a shell starts |
| `update` | List everything out of date (system packages, global npm packages and uv tools), then upgrade it all after a yes |
| `sysinfo` | Full system summary through fastfetch: OS, CPU, GPU, memory and disk (install with `winget install --id Fastfetch-cli.Fastfetch --exact`) |
| `copyout <command>` | Run a command, show its output as normal and copy all of it (output and errors) to the clipboard with `Set-Clipboard`, then say how many lines were copied. `$LASTEXITCODE` is kept |
| `logrun <command>` | Run a command with its output shown live and saved to `~\logs\<YYYY-MM-DD_HHMMSS>-<command>.log` through `Tee-Object`, then print the log's path. `$LASTEXITCODE` is kept |
| `games` | A menu of six terminal games: 2048, Snake, Blocks, Meteors, Word and a typing test. Arrows choose, Enter plays, Q or Esc leaves any game |
| `mkf <file>` | Create a file and any missing parent directories |
| `mkr <name>` | Scaffold a new Rust project |
| `mkt <name>` | Scaffold a new TypeScript/Node project |
| `dot` | `cd` to the dotfiles repo |
| `Edit-Profile` | Open `$PROFILE` in VS Code |
| `Reload-Profile` | Hard-clear the terminal then re-source the profile without restarting PowerShell |

`cmds` pages its output through `less -RF`, the same pager the Mac and Linux profiles use, so real scrolling and a clean q-to-exit work regardless of output length. It uses `less` when it is on `PATH`, else the copy Git for Windows ships at `%ProgramFiles%\Git\usr\bin\less.exe`. It sets `LESSCHARSET=utf-8` so the banner's box-drawing characters survive. `-R` keeps the ANSI colours while `-F` quits straight away when the output fits one screen. When `less` is not found it falls back to plain output with no pager. Colour is preserved because `cmds` builds each line as a plain string with raw ANSI codes rather than `Write-Host -ForegroundColor`, since `Write-Host` output cannot be piped.

---

## Utilities

Defined in [windows/topics/07-utilities.ps1](../windows/topics/07-utilities.ps1) and [windows/topics/08-community.ps1](../windows/topics/08-community.ps1).

| Command | What it does |
| --- | --- |
| `ll` | Long list with hidden files |
| `la` | Long list with hidden files |
| `c` | Clear the terminal |
| `clipcopy` | Set clipboard: `$input \| Set-Clipboard` |
| `clippaste` | Get clipboard: `Get-Clipboard` |
| `pubip` | Print public IP |
| `localip` | Print LAN IP |
| `speedtest` | Run a network speed test through `speedtest-cli` or Ookla's `speedtest`, with an install hint when neither is installed |
| `weather` | Print weather for current location |
| `temp` | Print temperature only |
| `battery` | Print charge percentage and status |
| `please` | Rerun the last command elevated in a new PowerShell window |
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

Defined in [windows/topics/02-colours.ps1](../windows/topics/02-colours.ps1). The welcome banner and `cmds` output use ANSI escape codes. The banner asks for the normal colours, the same ones the Mac and Linux banners use, because `Write-Host -ForegroundColor Cyan` and `Green` pick the bright variants, which the High Contrast palette makes paler.

`cmds` uses a consistent 3-color scheme: **Magenta** for category headers, **Cyan** for command names and **White** for short descriptions. Parenthetical expansion lines are also White.

PSReadLine colours typed commands as you type, sharing the one scheme used on macOS and Linux: commands green, parameters cyan, strings yellow and errors red. PSReadLine cannot tell a known command from an unknown one, so it does not colour an unknown command red the way zsh-syntax-highlighting does on the other platforms; a bad command still fails to run.

To change a colour, edit [windows/topics/02-colours.ps1](../windows/topics/02-colours.ps1) or the `welcome` function in [windows/topics/06-functions.ps1](../windows/topics/06-functions.ps1) and run `Reload-Profile`.

---

## Extending the profile

Create a new file in `windows/topics/` with the next available number, e.g. `37-mytopic.ps1`. It is dot-sourced automatically. No changes to the profile loader needed.

Before naming a new function, check it is not already taken:

```powershell
Get-Command myfunction -ErrorAction SilentlyContinue
Get-Alias myfunction -ErrorAction SilentlyContinue
```

---

## Command Prompt

Command Prompt gets the same banner, a coloured prompt and the PowerShell aliases and short functions as doskey macros. No add-on is installed. The bootstrap points the `AutoRun` value under `HKCU\Software\Microsoft\Command Processor` at [`windows/cmd/autorun.cmd`](../windows/cmd/autorun.cmd), keeping any earlier value. It also puts `windows\scripts` on the user `PATH` so `zt` works there too. The prompt and banner use the terminal's 16 colour slots, so they follow any terminal theme. Interactive windows only: a `cmd /c` or `cmd /k` started by a script skips all of it. Details, the uninstall step and the functions that stay PowerShell-only are in [`windows/cmd/README.md`](../windows/cmd/README.md).

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

**`cmds` not paging correctly** - `cmds` pages through `less`. Install Git for Windows (which ships `less`) or put another `less` on `PATH`. Without one, `cmds` prints its output in full with no pager, which still works.
