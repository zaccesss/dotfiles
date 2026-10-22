# Mac Bootstrap

[![CI](https://github.com/zaccesss/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/zaccesss/dotfiles/actions/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

One command that turns a new Mac into a complete development machine and keeps an existing one in
line. It covers the Xcode command line tools, Homebrew with every app and tool in the Brewfile, the
shell profile and prompt, the developer toolchains and the Mac's own settings.

## Quickstart

> [!WARNING]
> The bootstrap installs apps and changes macOS settings. Read [docs/how-it-works.md](docs/how-it-works.md)
> first so you know what each stage does.

On a brand-new Mac, open Terminal and run:

```bash
xcode-select --install          # click Install, wait for it to finish
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
~/dev/github/repos/dotfiles/setup/mac-bootstrap/bootstrap/bootstrap.sh
```

On a Mac that is already set up, running it again takes a few seconds, changes nothing and does not
ask for a password. It only acts where something is missing.

## What it does

| Stage | What happens |
| --- | --- |
| Xcode tools | Installs the command line tools (git, clang, make, the macOS SDK) if missing |
| Homebrew | Installs Homebrew if missing, plus the GitHub CLI |
| Dotfiles | Signs in to GitHub, clones the dotfiles and points the shell profile and prompt at them |
| Configs | Links the tool configs in the dotfiles (tmux, Neovim, Git hooks, VS Code settings, Zed settings, lazygit, ripgrep and fzf) into place, copies starting Git and SSH configs, then gives Terminal.app and iTerm2 the High Contrast palette |
| Brewfile | Installs everything in the dotfiles' Brewfile without upgrading what is already there |
| Toolchains | Selects Rust's stable toolchain and checks every everyday tool is on `PATH` |
| Settings | Applies the macOS settings captured in the [defaults](../defaults) folder, writing only the ones that differ |
| Apps | Runs the apply script of every editor and app that is installed (Zed, the JetBrains IDEs, Xcode, Eclipse, STM32CubeIDE, Arduino IDE, KiCad, LTspice, MATLAB, Processing, Thonny, Nextpad++, Obsidian and Zotero) with the theme `zt` last set and offers Rectangle its config once. The JetBrains script also points new projects at `~/dev/projects`. An app that is open or not set up is skipped with one line saying so |

Extras, chosen with `--with`:

| Extra | What it installs |
| --- | --- |
| `vscode-extensions` | Any VS Code extension in the [vscode](../../editors/vscode) folder that is missing, at its latest version |
| `linux` | An OrbStack Ubuntu machine set up with linux-bootstrap and its configs extra |

```bash
./bootstrap/bootstrap.sh --with vscode-extensions,linux
./bootstrap/bootstrap.sh --extras-only --with linux     # just the extra
./bootstrap/bootstrap.sh --settings-only                # just the settings
./bootstrap/bootstrap.sh --apps-only                    # just the app settings, after quitting an app that was open
./bootstrap/bootstrap.sh --capture-settings             # record this Mac's settings in the defaults folder
```

## Your own configuration

The dotfiles and configs come from these folders of the dotfiles repository:

| Folder | What it provides |
| --- | --- |
| [shell](../../shell) | zsh profile with aliases and helpers, the starship prompt and the Brewfile |
| [tmux](../../terminal/tmux) | tmux with vi-style copy mode |
| [neovim](../../editors/neovim) | Neovim with LSP, treesitter and Telescope |
| [gitconfig](../../git/gitconfig) | A starting `~/.gitconfig` with SSH commit signing |
| [git-hooks](../../git/git-hooks) | Secret scanning, large file and force push guards |
| [ssh](../../git/ssh) | A starting `~/.ssh/config` |
| [cli-tools](../../terminal/cli-tools) | ripgrep, fzf and lazygit defaults |
| [vscode](../../editors/vscode) | VS Code settings, keybindings and extensions |
| [terminal](../../terminal/terminal) | The High Contrast light and dark palette for Terminal.app and iTerm2 |
| [defaults](../defaults) | macOS settings, captured and applied |

The dotfiles repository is cloned once into `~/dev/github/repos/dotfiles` (change the parent folder with
`BOOTSTRAP_CONFIG_DIR`) and each file is linked into place, so editing a file in the clone applies
straight away. `~/.gitconfig` and `~/.ssh/config` are copied once as a starting point instead,
because they hold your own name, email, keys and hosts. A Mac set up by an earlier release keeps
its old clones in `~/.dotfiles`. Running the bootstrap again re-points every link and the
`~/.zshrc` loader at the new clone, after which `~/.dotfiles` can be deleted. Fork the repository
and point the bootstrap at your own account to make it yours:

```bash
BOOTSTRAP_GITHUB_USER=<your GitHub user> ~/dev/github/repos/dotfiles/setup/mac-bootstrap/bootstrap/bootstrap.sh
```

## Documentation

| Page | What it covers |
| --- | --- |
| [How it works](docs/how-it-works.md) | Each stage in detail, what is never touched and where the lists live |
| [Settings](docs/settings.md) | Where the settings live and how they are captured and applied |
| [New Mac checklist](docs/new-mac.md) | Everything to do on a new Mac, including what the bootstrap cannot do |

## Other platforms

| Platform | Folder |
| --- | --- |
| macOS | [mac-bootstrap](.) |
| Ubuntu, including WSL2 and VMs | [linux-bootstrap](../linux-bootstrap) |
| Windows 11 | [windows-bootstrap](../windows-bootstrap) |

All three use the same folders of this dotfiles repository.

## Development

Run the tests on any Mac with `/bin/bash tests/bootstrap-test.sh`. They use stubs for every command
that would change the Mac and run on the stock bash 3.2 that a new Mac has. Changes follow the
issue, branch, pull request, review and squash-merge workflow in [CONTRIBUTING.md](../../CONTRIBUTING.md).

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
