# Linux Bootstrap

[![CI](https://github.com/zaccesss/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/zaccesss/dotfiles/actions/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

One command that turns a fresh Ubuntu install into a complete development machine with language
toolchains, embedded and electronics tools, cloud and DevOps tools, everyday terminal tools and
Git, set up the same way on every machine.

## Supported platforms

| Architecture | Ubuntu 24.04 LTS | Ubuntu 26.04 LTS |
| --- | --- | --- |
| ARM64 (Apple Silicon VMs, ARM laptops and servers) | Supported | Supported |
| x86_64 (PCs, laptops, WSL2 on Windows) | Supported | Supported |

The bootstrap also detects where it runs (a desktop, WSL2 on Windows, a server or a container) and
adjusts to it. WSL gets systemd switched on, a desktop VM gets guest integration and desktop-only
apps are skipped where there is no desktop. See [docs/platforms.md](docs/platforms.md) for details.

## Quickstart

> [!WARNING]
> The bootstrap installs system packages and changes user-level configuration. Read
> [bootstrap/README.md](bootstrap/README.md) first so you know what each stage does before running
> it on a machine you care about.

```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
cd ~/dev/github/repos/dotfiles/setup/linux-bootstrap
./bootstrap/bootstrap.sh
```

Optional extras are added with `--with` and listed with `--list`:

```bash
./bootstrap/bootstrap.sh --with kicad,android,flutter
./bootstrap/bootstrap.sh --extras-only --with gcloud    # add an extra later without the default stages
./bootstrap/bootstrap.sh --list
```

Every stage is safe to re-run. Running the bootstrap again later also updates the tools it
installed through version managers. Progress is recorded under `~/.local/state/linux-bootstrap`.

## What gets installed

| Stage | Highlights |
| --- | --- |
| Base | Build tools, Python with venv and pipx, Git, archive tools and common build headers |
| Language toolchains | C and C++ (gcc, clang, gdb, lldb, valgrind), Java 25, Kotlin, Scala, Go, Rust, .NET 10, Node.js, Swift, Zig, Haskell, Elixir, Ruby, PHP, Lua and Clojure |
| Embedded tooling | ARM Cortex-M and AVR toolchains, OpenOCD, GHDL, GTKWave, Yosys, PlatformIO, Arduino CLI and serial consoles |
| Cloud and DevOps | Docker with Compose, Terraform, kubectl, Ansible and AWS CLI v2 |
| CLI productivity | zsh with zsh-syntax-highlighting, Neovim, tmux, ripgrep, fd, fzf, bat, eza, zoxide, delta, lazygit, btop and speedtest-cli |
| Developer tools | starship, uv with Python 3.15 as the user's default `python` and `python3` (the system Python stays as it is), ruff, typst, trivy, lychee, psql, git-filter-repo and PDF and image utilities |
| Git integration | GitHub CLI, safe Git defaults and the `~/.ssh` folder, with no credentials created |
| Environment | systemd and browser support on WSL. Guest integration on QEMU desktop VMs |
| Apps | Each installed editor's and app's own apply script from the dotfiles clone, with the theme `zt` last set. Re-run on its own with `--apps-only` |

Optional extras include `configs`, which links a shell profile and tool configs from the dotfiles
repository (see [Your own configuration](#your-own-configuration)), plus Warp, Blender, KiCad, STM32 tools, Android tools, Google Cloud, Azure,
Flutter, ArduPilot SITL, PowerShell, the Vercel CLI, more languages, game libraries, Chinese input
and Mac-style keys for a VM on a Mac. See [docs/optional-extras.md](docs/optional-extras.md).

## Your own configuration

The bootstrap installs tools only. The `configs` extra then brings in configuration from these
folders of the dotfiles repository, each written to be forked and adapted:

| Folder | What it provides |
| --- | --- |
| [shell](../../shell) | zsh profile (with a bash fallback) with aliases, helpers and typed-command colours, starship prompt |
| [tmux](../../terminal/tmux) | tmux with vi-style copy mode |
| [neovim](../../editors/neovim) | Neovim with LSP, treesitter and Telescope |
| [gitconfig](../../git/gitconfig) | A starting `~/.gitconfig` with SSH commit signing |
| [git-hooks](../../git/git-hooks) | Secret scanning, large file and force push guards |
| [ssh](../../git/ssh) | A starting `~/.ssh/config` |
| [cli-tools](../../terminal/cli-tools) | ripgrep, fzf and lazygit defaults |
| [vscode](../../editors/vscode) | VS Code settings and keybindings (desktops) |
| [terminal](../../terminal/terminal) | The eight Zacess palettes for the Ptyxis terminal (desktops) |
| [defaults](../defaults) | GNOME desktop preferences (desktops) |

```bash
./bootstrap/bootstrap.sh --extras-only --with configs
BOOTSTRAP_GITHUB_USER=<your GitHub user> ./bootstrap/bootstrap.sh --extras-only --with configs   # use your fork
```

The dotfiles repository is cloned once into `~/dev/github/repos/dotfiles` (change the parent folder with
`BOOTSTRAP_CONFIG_DIR`) and each file is linked into place, so editing a file in the clone applies
straight away. `~/.zshrc` and `~/.bashrc` become small
loaders for the dotfiles' zsh and bash profiles. zsh becomes the login shell when it is not
already. `~/.gitconfig` and `~/.ssh/config` are copied once as a starting point instead, because
they hold your own name, email, keys and hosts. A machine set up by an earlier release keeps its
old clones in `~/.dotfiles`. Running the extra again re-points every link and loader at the new
clone, after which `~/.dotfiles` can be deleted.

## Setting up a machine

Not sure which way to run Linux? Start with [Ways to run Linux](docs/ways-to-run-linux.md).

| Machine | Guide |
| --- | --- |
| Windows PC with Linux alongside | [WSL2](docs/wsl2.md) |
| Laptop with Ubuntu next to Windows | [Dual boot](docs/dual-boot.md) |
| Mac | [Linux on a Mac](docs/linux-on-mac.md) |

## Folder structure

| Path | Purpose |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | How a run reads and what a desktop gets |
| `bootstrap/` | The bootstrap itself, see [bootstrap/README.md](bootstrap/README.md) for what each stage does |
| `docs/` | Platform notes, optional extras and machine setup guides |
| `tests/` | Offline tests, see [tests/README.md](tests/README.md) |
| [`../../.github/`](../../.github/ABOUT.md) | CI for the whole repository, including the job that resolves every package on every supported platform |

## Other platforms

| Platform | Folder |
| --- | --- |
| macOS | [mac-bootstrap](../mac-bootstrap) |
| Ubuntu, including WSL2 and VMs | [linux-bootstrap](.) |
| Windows 11 | [windows-bootstrap](../windows-bootstrap) |

All three use the same folders of this dotfiles repository.

## Development

Changes follow the dotfiles repository's issue, branch, pull request, review and squash-merge workflow.
See [CONTRIBUTING.md](../../CONTRIBUTING.md) before making changes. Run the tests on any Ubuntu machine
with `./tests/bootstrap-test.sh`.

> [!IMPORTANT]
> Do not commit passwords, API keys, private keys, tokens or other secrets. See
> [SECURITY.md](../../SECURITY.md) for the security reporting process.

## Licence

Apache License, Version 2.0. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).

## Contact and Support

Open an [issue](https://github.com/zaccesss/dotfiles/issues) in the dotfiles repository for
questions or bugs. See [SUPPORT.md](../../SUPPORT.md) for the full breakdown of where to go.

> [!TIP]
> Reach me directly at [contact@isaacadjei.me](mailto:contact@isaacadjei.me) or through the
> [website contact page](https://isaacadjei.me/contact).
