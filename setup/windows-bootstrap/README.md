# Windows Bootstrap

[![CI](https://github.com/zaccesss/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/zaccesss/dotfiles/actions/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

One PowerShell command that sets up a Windows 11 PC for development and keeps it in line. It covers
every app and tool in the winget package list, the PowerShell profile and prompt from the dotfiles,
Git configuration and hooks, VS Code extensions and WSL2 Ubuntu ready for linux-bootstrap.

> [!IMPORTANT]
> Tested on a Windows runner in CI and in plan mode. It has also run end to end on real PCs. Run it
> with `-Plan` first and report anything that goes wrong.

## Quickstart

In **Windows Terminal**, as your normal user (not administrator):

```powershell
winget install --id Git.Git --exact
git clone https://github.com/zaccesss/dotfiles.git "$HOME\dev\github\repos\dotfiles"
cd "$HOME\dev\github\repos\dotfiles\setup\windows-bootstrap"
.\bootstrap\bootstrap.ps1 -Plan     # see what would happen
.\bootstrap\bootstrap.ps1           # do it
```

If PowerShell refuses to run the script, allow local scripts for your user once:
`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

## What it does

| Stage | What happens |
| --- | --- |
| winget | Installs anything missing from `packages/winget.json` without upgrading what is already there |
| dotfiles | Signs in to GitHub, clones the dotfiles, points the PowerShell 7 profile and starship at them, puts `zt` on the `PATH` and makes Command Prompt run the dotfiles' start-up |
| git | Copies a starting `.gitconfig` and SSH config if missing and links the Git hooks |
| configs | Points Neovim, VS Code settings, lazygit and ripgrep at their folders in the dotfiles, installs Geist Mono Nerd Font for the user and for all users, then gives Windows Terminal the eight Zacess schemes with Zacess Deep Contrast Dark as the default and Geist Mono as its font |
| vscode | Installs missing VS Code extensions from the [vscode](../../editors/vscode) folder at their latest version |
| settings | Applies the Windows settings captured in the [defaults](../defaults) folder, writing only what differs, then hides the dot folders in the home folder in File Explorer. Dot files stay shown, because Node and Electron apps cannot save over a hidden file on Windows |
| wsl | Installs WSL2 with Ubuntu 26.04 (or 24.04) and explains the linux-bootstrap step |
| apps | Runs the apply script of every installed editor and app in the dotfiles (Zed, the JetBrains IDEs, Eclipse, STM32CubeIDE, Arduino IDE, Microchip Studio, KiCad, LTspice, MATLAB, Notepad++, Processing, Proteus, Thonny, Vivado, Obsidian and Zotero). The JetBrains script installs the theme plugin and the tracked settings in every IDE and points new projects at `~\dev\projects`. An app that is open is skipped with a note, since it would write its own settings back on exit, so running the bootstrap again after closing it finishes the job. Obsidian needs its vault named in `OBSIDIAN_VAULT`. One line per app |

Leave stages out with `-Skip`, for example `-Skip wsl,vscode`. The list also works as one quoted
string, as in `pwsh -File .\bootstrap\bootstrap.ps1 -Skip 'wsl,vscode'`.

Leave apps out of the winget stage with `-SkipPackage`, for example
`-SkipPackage OBSProject.OBSStudio`. Apps one PC never wants go in
`packages\skip\<computer name>.txt` with one winget id per line. That PC then leaves them out on
every run.

> [!TIP]
> The configs stage turns on Developer Mode first, which asks for administrator rights once. It
> lets the stage link VS Code and lazygit settings instead of copying them, so later edits in the
> dotfiles apply straight away. Declining the prompt only means the files are copied.

## Your own configuration

The dotfiles and configs come from these folders of the dotfiles repository:

| Folder | What it provides |
| --- | --- |
| [shell](../../shell) | The PowerShell 7 profile with aliases and helpers and the starship prompt |
| [gitconfig](../../git/gitconfig) | A starting `.gitconfig` with SSH commit signing |
| [git-hooks](../../git/git-hooks) | Secret scanning, large file and force push guards |
| [ssh](../../git/ssh) | A starting `.ssh\config` |
| [neovim](../../editors/neovim) | Neovim with LSP, treesitter and Telescope |
| [cli-tools](../../terminal/cli-tools) | ripgrep, fzf and lazygit defaults |
| [vscode](../../editors/vscode) | VS Code settings, keybindings and extensions |
| [terminal](../../terminal/terminal) | The eight Zacess schemes for Windows Terminal |
| [defaults](../defaults) | Windows settings, captured and applied |

The dotfiles repository is cloned once into `%USERPROFILE%\dev\github\repos\dotfiles` (change the parent
folder with `BOOTSTRAP_CONFIG_DIR`). `.gitconfig` and `.ssh\config` are copied once as a starting
point, because they hold your own name, email, keys and hosts. A PC set up by an earlier release
keeps its old clones in `%USERPROFILE%\.dotfiles`. Running the bootstrap again re-points every
link, profile pointer, `PATH` entry and the Command Prompt start-up at the new clone, after which
that folder can be deleted. Fork the repository and point the bootstrap at your own account to
make it yours:

```powershell
$env:BOOTSTRAP_GITHUB_USER = '<your GitHub user>'; .\bootstrap\bootstrap.ps1
```

## Documentation

| Page | What it covers |
| --- | --- |
| [How it works](docs/how-it-works.md) | Each stage in detail, what is never touched and where the lists live |
| [New PC checklist](docs/new-pc.md) | Everything to do on a new PC, including WSL2 and dual booting |
| [Accessibility](ACCESSIBILITY.md) | How a run reads and the settings it carries over |

## Other platforms

| Platform | Folder |
| --- | --- |
| macOS | [mac-bootstrap](../mac-bootstrap) |
| Ubuntu, including WSL2 and VMs | [linux-bootstrap](../linux-bootstrap) |
| Windows 11 | [windows-bootstrap](.) |

All three use the same folders of this dotfiles repository.

## Development

The Pester tests and the analyzer run on any machine with PowerShell 7:

```powershell
Invoke-ScriptAnalyzer -Path ./bootstrap -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
Invoke-Pester ./tests
```

CI runs both on a Windows runner, plans a full run and checks every package still exists in the
winget catalogue. Changes follow the workflow in [CONTRIBUTING.md](../../CONTRIBUTING.md).

> [!IMPORTANT]
> Do not commit passwords, API keys, private keys or tokens. See [SECURITY.md](../../SECURITY.md).

## Licence

Apache License, Version 2.0. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).

## Contact and Support

Open an [issue](https://github.com/zaccesss/dotfiles/issues) for questions or bugs. See
[SUPPORT.md](../../SUPPORT.md) for where to go.

> [!TIP]
> Reach me directly at [contact@isaacadjei.me](mailto:contact@isaacadjei.me) or through the
> [website contact page](https://isaacadjei.me/contact).
