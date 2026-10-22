# Bootstrap

`bootstrap.sh` checks the platform, asks for the sudo password once, then runs each stage in
order. Every stage can be re-run safely: apt skips installed packages and each installer looks for
an existing copy first.

## Layout

| Path | Contents |
| --- | --- |
| `bootstrap.sh` | Entry point and option parsing (`--with`, `--extras-only`, `--apps-only`, `--list`, `--help`) |
| `lib/logging.sh` | `[INFO]`, `[ OK ]`, `[WARN]` and `[ERROR]` output and the error handler |
| `lib/common.sh` | Run modes, `as_root`, apt wrappers, vendor repositories, downloads and command checks |
| `lib/platform.sh` | Release, architecture, environment and virtualisation detection |
| `lib/*.sh` | One file per stage with its package list, installers and final command check |
| `lib/optional.sh` | The registry of optional extras and their installers |
| `stages/` | One small script per stage, run in numeric order |

## Stages

| Order | Stage | What it does |
| --- | --- | --- |
| 00 | Base | Build tools, Python with venv and pipx, Git, archive tools, gpg and the headers that pip, gem and cargo builds commonly need |
| 10 | Language toolchains | Ubuntu packages for C, C++, the JVM languages, .NET, Go, Haskell, Elixir, Ruby, PHP and Lua. Node.js through nvm, Rust through rustup, Swift through swiftly (after the system packages it checks for) and Zig from ziglang.org on 24.04 |
| 20 | Embedded tooling | ARM Cortex-M and AVR toolchains, OpenOCD, HDL tools and serial consoles. PlatformIO and a pinned Arduino CLI release, with the AVR core, in the user's home. Adds the user to `dialout` for serial ports |
| 30 | Cloud and DevOps | Docker and Compose, Ansible, Terraform and kubectl from their vendors' repositories and AWS CLI v2. Adds the user to `docker` |
| 40 | CLI productivity | zsh with zsh-syntax-highlighting, Neovim, tmux, the modern replacements for ls, cat, find and grep, git helpers, speedtest-cli and media converters |
| 45 | Developer tools | PDF and image utilities, psql, starship, uv and ruff, typst, lychee and trivy |
| 50 | Git integration | GitHub CLI from GitHub's repository, safe Git defaults and `~/.ssh` with 700 permissions |
| 60 | Environment | WSL systemd and browser support. Guest integration for QEMU desktop VMs |
| 70 | Apps | Runs after the extras: each installed editor's and app's own apply script from the dotfiles clone, described below |

After the stages, any extras named with `--with` are installed. See
[docs/optional-extras.md](../docs/optional-extras.md).

Last comes stage 70, Apps, so the clone made by the `configs` extra and any app an extra installed
are already there. Each editor and app found on the machine is set up by its own apply script in
the dotfiles clone, the same script `zt` runs: Zed, the JetBrains IDEs, Eclipse, STM32CubeIDE,
Arduino IDE, KiCad, LTspice (under Wine), MATLAB, Processing, Thonny, Vivado, Obsidian and Zotero.
An app counts as installed once it has written its own settings (a workspace for Eclipse and
STM32CubeIDE, a config folder with `options/` for a JetBrains IDE, a settings file or profile for
the rest); Zed counts once `zed` is on `PATH` or its config folder exists; KiCad, Processing and
Vivado check for themselves. Obsidian needs its vault named in `OBSIDIAN_VAULT`. The theme is the
one `zt` last set (`~/.local/state/zacess/theme`), with the light or dark half picked by the
desktop's appearance when `zt` follows the system. Zed's script installs the theme file and sets the
theme in its `settings.json`; the JetBrains script installs the theme plugin and the tracked
settings in every IDE and points new projects at `~/dev/projects`.

Every script refuses to run while its app is open. That app is reported as open and skipped and
the run carries on, so quitting it and running `bootstrap.sh --apps-only` finishes the job.
`--apps-only` never asks for the sudo password. A script that fails is reported with its last line
and never stops the bootstrap. Each app prints one line; the scripts' full output goes to
`~/.local/state/linux-bootstrap/apps.log`. Without a dotfiles clone the stage says so and does
nothing.

## What the bootstrap never does

- It never creates SSH keys, signs in to GitHub or sets the Git identity. `gh auth login` and the
  dotfiles handle those.
- It never edits shell profiles. Installers that offer to (nvm, uv, starship) are told not to, so
  the dotfiles stay the single owner of `PATH` and aliases. Only the opt-in `configs` extra writes
  the profile loaders and changes the login shell to zsh.
- It never removes packages.

## Run modes

| Mode | Set with | Behaviour |
| --- | --- | --- |
| Normal | Nothing | Installs everything for real |
| Simulate | `LINUX_BOOTSTRAP_SIMULATE=1` | Adds vendor repositories for real, resolves every package without installing and skips external installers. CI uses it in clean containers |
| Test | `LINUX_BOOTSTRAP_TEST_MODE=1` | apt-get and sudo are stubs from the test suite. Nothing touches the network or the machine |

## Command checks

Each stage that installs tools ends by checking that its commands are on `PATH`, naming every
missing one before it fails. The commands are declared once per stage as a readonly array next to
its package list (`LANGUAGE_COMMANDS`, `EMBEDDED_COMMANDS`, `CLOUD_COMMANDS`, `CLI_COMMANDS`,
`DEVTOOLS_COMMANDS` and `INTEGRATION_COMMANDS`). The test suite runs every check against stub
commands built from those arrays.

## State

Each completed stage is appended with a timestamp to `~/.local/state/linux-bootstrap/stages.log`.
