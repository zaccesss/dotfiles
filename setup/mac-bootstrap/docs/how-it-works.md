# How it works

`bootstrap/bootstrap.sh` checks the Mac, then runs six stages in order. Each stage looks first and
acts only where something is missing, so the same command sets up a new Mac and re-checks an old one.

## The stages

### 1. Xcode command line tools

Homebrew and almost every build need git, clang and the macOS SDK. If they are missing, Apple's own
installer window opens; click **Install**. The bootstrap waits for it to finish (up to 30 minutes).

### 2. Homebrew

Homebrew is installed if missing, under `/opt/homebrew` on Apple Silicon or `/usr/local` on Intel.
The GitHub CLI is installed straight away so the next stage can sign in.

### 3. Dotfiles

- signs in to GitHub with `gh auth login` in the browser, if not already signed in
- clones the dotfiles into `~/dev/github/repos/dotfiles`
- writes `~/.zshrc` as a two-line loader for the profile in that clone's `shell` folder and links
  `~/.config/starship.toml` to its prompt

Loading rather than copying means editing a topic file in the clone changes the next terminal.
An existing `~/.zshrc` is moved into `~/.local/state/mac-bootstrap/backups`, never deleted.

### 3b. Configs

Links each tool config from its folder in the same clone into place: `~/.tmux.conf`,
`~/.config/nvim`, `~/.git-hooks`, VS Code's `settings.json` and `keybindings.json`, Zed's `settings.json`, lazygit's
`config.yml`, `~/.ripgreprc` and `~/.config/fzf/fzf.zsh`. `~/.gitconfig` and `~/.ssh/config` are
copied once if missing, since they hold your own identity. It then installs the tmux plugin manager
and runs the [terminal](../../../terminal/terminal) folder's installer for the High Contrast palette. Anything already there that is
not a link is moved into `~/.local/state/mac-bootstrap/backups` first.

### 4. Brewfile

Everything in the dotfiles' `shell/mac/Brewfile` is installed: command-line tools, apps and fonts. Apps
already installed are left at their version; upgrades stay a deliberate `brew upgrade`. If
`brew bundle check` reports nothing missing, the stage finishes without touching anything.

The Brewfile lives in the [shell](../../../shell) folder, not here, so there is one list of what a Mac should have. After
installing something new by hand, run `bdump` in the shell to add it to the Brewfile.

### 5. Toolchains

Selects Rust's stable toolchain (Homebrew installs rustup without one), then checks that every
everyday tool is on `PATH`, naming any that are missing.

### 6. Settings

Runs the macOS script in the [defaults](../../defaults) folder, which applies the settings captured from
a set-up Mac. See [Settings](settings.md).

### 7. Apps

Runs last, after any extras, so every app the Brewfile installed is already there. Each editor and
app found on the Mac is set up by its own apply script in the dotfiles clone, the same script
`zt` runs, so a new Mac and a theme switch write the same files. The theme is the one `zt` last set
(`~/.local/state/zacess/theme`), with the light or dark half picked by the current appearance when
`zt` follows the system. With no state file each script uses its own default, Zacess Deep Contrast
Dark.

| App | Counts as installed when | Script |
| --- | --- | --- |
| Zed | `Zed.app` is in `/Applications` or `~/.config/zed` exists | `editors/zed/mac/apply.sh`, which installs the theme file and sets the theme in the `settings.json` the configs stage linked |
| JetBrains IDEs | An IDE has a config folder with `options/` under `~/Library/Application Support/JetBrains` | `editors/jetbrains/mac/apply.sh`, one run for every IDE: the theme plugin, the tracked settings, the theme and `~/dev/projects` for new projects |
| Xcode | `Xcode.app` is in `/Applications` | `editors/xcode/apply.sh` |
| Eclipse | `~/eclipse-workspace` has been opened once | `editors/eclipse/apply.sh` |
| STM32CubeIDE | A `~/STM32CubeIDE/workspace_*` has been opened once | `editors/stm32cubeide/mac/apply.sh` |
| Arduino IDE | `~/.arduinoIDE/settings.json` exists | `editors/arduino/mac/apply.sh` |
| KiCad, Processing and Nextpad++ | The script checks itself | Each folder's `mac/apply.sh` |
| LTspice | `LTspice.app` is in `/Applications` | `editors/ltspice/mac/apply.sh` |
| MATLAB | A `MATLAB_R20*.app` is in `/Applications` or `matlab` is on `PATH` | `editors/matlab/mac/apply.sh` |
| Thonny | Thonny has been started once | `editors/thonny/mac/apply.sh` |
| Obsidian | `OBSIDIAN_VAULT` names a vault Obsidian has opened | `apps/obsidian/mac/apply.sh` |
| Zotero | A Zotero profile exists | `apps/zotero/mac/apply.sh` |
| Rectangle | `Rectangle.app` is in `/Applications` | Copies `apps/rectangle/mac/RectangleConfig.json` into Rectangle's support folder, only if no Rectangle config was ever offered there. Rectangle asks before applying it on its next start |

Every script apart from Zed's refuses to run while its app is open (Zed reloads its settings live). That app is reported as open and skipped and the
run carries on, so quitting it and running `bootstrap.sh --apps-only` finishes the job. A script
that fails is reported with its last line and never stops the bootstrap. Each app prints one line;
the scripts' full output goes to `~/.local/state/mac-bootstrap/apps.log`.

## When the password is asked for

Only when a step really needs administrator rights: installing the Xcode tools or Homebrew, plus
Brewfile apps that come as system packages. It is asked once and kept for the rest of the run. A Mac
that is already set up is never asked.

## What it never does

- remove apps, packages or files (a replaced `~/.zshrc` is kept as a backup)
- upgrade apps that are already installed
- create SSH keys or change Git identity, which the dotfiles' [shell](../../../shell) and [ssh](../../../git/ssh) folders own
- change a macOS setting that is not in the captured list (the Apps stage changes only what each app's own apply script writes)

## Where things live

| What | Where |
| --- | --- |
| The bootstrap and its stages | `setup/mac-bootstrap/bootstrap/` |
| Captured settings and the tracked key list | `setup/defaults/mac/` |
| Apps and tools | `shell/mac/Brewfile` |
| Shell profile and prompt | `shell/mac/zshrc`, `shell/mac/topics/` and `shell/mac/starship.toml` |
| VS Code extensions | `editors/vscode/extensions.txt` |
| Progress log | `~/.local/state/mac-bootstrap/stages.log` |
