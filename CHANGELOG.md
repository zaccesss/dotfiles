# Changelog

All notable changes to this dotfiles repository are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions increment by one patch step (0.0.1) per release.

---

## [Unreleased]

### Added

- Every public config now lives in this one repository, grouped by what it is for. Each folder keeps its own README, guides, accessibility statement and screenshots. Each came from its own repository:

  | Folder | Came from |
  | --- | --- |
  | `setup/mac-bootstrap/` | `zaccesss/mac-bootstrap` |
  | `setup/linux-bootstrap/` | `zaccesss/linux-bootstrap` |
  | `setup/windows-bootstrap/` | `zaccesss/windows-bootstrap` |
  | `setup/defaults/` | `zaccesss/system-defaults` |
  | `terminal/terminal/` | `zaccesss/terminal-config` |
  | `terminal/tmux/` | `zaccesss/tmux-config` |
  | `terminal/cli-tools/` | `zaccesss/cli-tools-config` |
  | `git/gitconfig/` | `zaccesss/git-config` |
  | `git/git-hooks/` | `zaccesss/git-hooks` |
  | `git/ssh/` | `zaccesss/ssh-config` |
  | `editors/vscode/` | `zaccesss/vscode-config` |
  | `editors/zed/` | `zaccesss/zed-config` |
  | `editors/jetbrains/` | `zaccesss/jetbrains-config` |
  | `editors/eclipse/` | `zaccesss/eclipse-config` |
  | `editors/stm32cubeide/` | `zaccesss/stm32cubeide-config` |
  | `editors/xcode/` | `zaccesss/xcode-config` |
  | `editors/neovim/` | `zaccesss/neovim-config` |
  | `apps/raycast/` | `zaccesss/raycast-config` |
  | `apps/rectangle/` | `zaccesss/rectangle-config` |

- A README for each group (`setup`, `shell`, `terminal`, `git`, `editors` and `apps`) and a master README at the root that links them all.
- One CI workflow for the whole repository that runs each folder's checks only when that folder changes, including the macOS, Windows and Ubuntu test jobs. `.github/ABOUT.md` lists every job, form and template.
- Issue forms with a "Which tool?" dropdown and a pull request template with a checklist of every folder.
- Windows screenshots of the PowerShell banner, `cmds`, `gs` and `glog` and the Command Prompt prompt in Zacess Deep Contrast Dark and Light, in the shell README.
- The Zacess themes for eleven more editors, each in its own folder under `editors/` with apply scripts, a validator and its own CI job: `arduino` (Arduino IDE 2), `microchip-studio` (Microchip Studio 7), `kicad`, `vivado`, `processing`, `notepad-plus-plus`, `nextpad-plus-plus`, `thonny`, `matlab`, `ltspice` and `proteus`.
- `apps/obsidian` and `apps/zotero`: the Zacess theme in an Obsidian vault named by the caller or `OBSIDIAN_VAULT` and Zotero's mode and reader theme matched to the Zacess theme.
- `zt` switches STM32CubeIDE and every new editor and app above by running each folder's own apply script while that app is closed. `zt current` reads each one back.
- Temporary forwarding files at the shell profile's old paths (`mac/`, `linux/` and `windows/` at the root) keep a machine working if it pulls before its bootstrap re-runs. Each forwards to `shell/` and prints one line saying to run the bootstrap.
- The three bootstraps end with an Apps stage that runs the apply script of every installed editor and app, printing one line per app. An app that is open, not installed or not started once is skipped and the run carries on. On macOS and Linux the stage uses the theme `zt` last set and `--apps-only` runs it again on its own; on Windows it is the `apps` stage. On macOS Rectangle is offered its config once. Obsidian is applied when `OBSIDIAN_VAULT` names its vault.
- `editors/zed` and `editors/jetbrains` have apply scripts like every other editor folder, each with a validator in CI. Zed's installs the Zacess theme file (the 0.4.0 release, kept in `shared/themes` while the extension store still serves 0.2.1 and removed once the installed extension catches up) and sets the theme in `settings.json`, reusing `zt`'s own theme block and JSON-with-comments editing. JetBrains' installs the Zacess Themes plugin into every IDE with the IDE's own `installPlugins` command (or the pinned release when no launcher is found), copies in the colour schemes, file template, keymap and fonts, sets the theme through `zt`'s own function and points new projects at `~/dev/projects`. The Mac bootstrap's configs stage links Zed's `settings.json`.
- One projects folder for every editor: MATLAB starts in `~/dev/projects/matlab`, Thonny in `~/dev/projects/python`, the Arduino IDE sketchbook is `~/dev/projects/arduino`, the Processing sketchbook is `~/dev/projects/processing`, Microchip Studio puts new projects in `~\dev\projects\avr` and every JetBrains IDE offers `~/dev/projects` for a new project. Each folder is made when it is missing. Moving an existing sketchbook is a step of its own, in the Arduino and Processing READMEs.
- Thonny runs code in its own virtual environment, `~/.venvs/thonny`, made once from Python 3.15 on every OS (Homebrew's `python@3.15` on macOS, the Python install manager on Windows, `uv` or `python3.15` on Linux), so packages from **Tools > Manage packages** stay out of the system Python. The apply script makes it Thonny's interpreter and keeps earlier choices in Thonny's recent list.
- MATLAB's dark theme gets the Zacess syntax, editor and Command Window colours from code. Each theme also has a colour scheme in `editors/matlab/shared/schemes`, applied with `import_scheme` from MathWorks' Color Theme Extensions add-on, which the apply scripts download at a pinned commit and check against its digests. The add-on's template is kept unchanged with its BSD 3-Clause licence, credited in `NOTICE.md`.
- `zt` on Windows switches Microchip Studio too: its apply script's new `-Close` starts Studio, imports the theme and closes it so the colours are saved. `zt current` reads back its dark or light environment theme.
- CI lints `shell/scripts` with ruff, gives the forwarding zshrc files zsh's own syntax check and parses the forwarding PowerShell files. The shell checks also run when `editors/` or `apps/` change, since `zt` calls their apply scripts.
- The Mac Brewfile installs Nextpad++ from its Homebrew cask.
- The `zacess-theme` shell topics name every tool `zt` switches, the shell guide has a `zt` entry and `CONTRIBUTING.md` lists the validators every `editors/` and `apps/` folder is checked with.

### Changed

- The Mac moves to Python 3.15: the Brewfile installs `python@3.15` and the PATH shim points `python` and `pip` at it, so they match `python3`.
- The shell profile, its scripts, guides, journal and screenshots move into `shell/`. `DOTFILES` now points at that folder, so the default is `~/dev/github/repos/dotfiles/shell`. `dot` now asks git whether that folder is inside a clone.
- The three bootstraps clone only this repository and link every config from its folder, instead of cloning a repository per tool. The clone goes to `~/dev/github/repos/dotfiles` (`%USERPROFILE%\dev\github\repos\dotfiles` on Windows), the folder the shell profile already expects, instead of `~/.dotfiles`. `BOOTSTRAP_CONFIG_DIR` still changes the parent folder and every README and guide uses the new path.
- A machine set up by an earlier release is re-pointed when its bootstrap runs again. On Windows that covers the Neovim and Git hooks junctions into an old clone in `~\.dotfiles` (only the clones earlier releases made), the old `zt` folder on the user `PATH`, the old Command Prompt `AutoRun` call and a Windows PowerShell 5.1 profile pointing at the old loader, with tests. `~/.dotfiles` can then be deleted.
- The Processing apply scripts set the sketchbook themselves instead of reading it from `preferences.txt`. The Zotero Windows script's `-Profile` is now `-ProfileDir`, so it no longer shadows PowerShell's own `$PROFILE`.
- `zt` reads the Eclipse themes from `editors/eclipse/theme` in the same clone unless `ZT_ECLIPSE_THEMES` says otherwise.
- The PowerShell profile and the Command Prompt start-up treat a `DOTFILES` that names the clone's root as unset, so a window opened before the move still loads the profile. An elevated PowerShell window moves from System32 to the home folder.
- The Windows bootstrap moves a Windows PowerShell 5.1 profile that points at the old loader to the new one, with a test.
- Python bytecode (`__pycache__` and `*.pyc`) is ignored.
- The root community files (contributing guide, security policy, support, accessibility statement and notice) now cover every folder. The bootstraps stay under the Apache License 2.0 with their own `LICENSE` and `NOTICE.md`; everything else is MIT.

### Fixed

- On macOS, `zt`, `termtheme` and every Mac apply script see an app as open when they run inside its own terminal. macOS `pgrep` leaves out its own ancestors unless given `-a`, so `zt` run from Terminal.app wrote the defaults without switching the open tabs and an apply script run from an IDE's terminal changed settings the IDE then wrote over.
- `zt` on Linux sees a JetBrains IDE installed from a tarball as open, by the paths selector its Java process carries.
- The Linux Thonny script finds a Thonny installed with apt or dnf when `uv`'s Python comes first on `PATH`.
- The Command Prompt start-up only accepts a `DOTFILES` that holds the shell folder's macros, so a window opened before the move no longer loads the root's stand-in.
- Ruff findings in `shell/scripts/games.py`, the Microchip Studio scripts and the Proteus build script.

## [1.0.10] - 2026-10-22

### Added

- The screenshots and clips are recorded again in Zacess Deep Contrast Dark and Light, using the real config in a throwaway demo project.
- `zt` (and `zacess-theme`) on macOS, Linux and Windows switches every installed editor and terminal to one of the eight Zacess themes at once: VS Code, Zed, the JetBrains IDEs, Neovim, Eclipse, Terminal.app, iTerm2, Kitty, Alacritty, Ghostty and Windows Terminal. `zt <theme>` fixes one theme and stops following the system, `zt auto [dark] [light]` follows the system light and dark appearance where a tool can, `zt list` lists the themes and `zt current` reads each tool's setting back. `scripts/zt.py` does the work on macOS and Linux and `windows/scripts/zt.ps1` on Windows, with `zt.cmd` and `zacess-theme.cmd` for Command Prompt.
- Command Prompt setup in `windows/cmd/`: `autorun.cmd` runs from the `AutoRun` value for interactive windows only, sets a prompt and prints the banner in the terminal's 16 colour slots and loads doskey macros made from the PowerShell aliases and short functions by `scripts/build-cmd-macros.py`. `windows/cmd/README.md` lists the functions that stay PowerShell-only and why. `.gitattributes` keeps `.cmd` and `.doskey` files on Windows line endings.

### Changed

- `termtheme` uses the Zacess Deep Contrast Dark and Light profiles and schemes in Terminal.app and Windows Terminal in place of the High Contrast ones.

### Fixed

- `ls` draws other-writable folders like any other folder. On macOS the last two `LSCOLORS` pairs are now bold cyan instead of black or blue on a yellow or green background. On Linux `LS_COLORS` gets `ow` and `tw` set to the machine's own `di` colour. Both were unreadable in every theme.
- `zt` keeps a JSON object that is already spread over several lines (such as Zed's theme setting) in its existing layout and trailing comma, so a settings file only changes where a value really changed.
- `zt` on Linux only treats a running JetBrains IDE launcher as an open IDE, so the Toolbox app running in the background no longer makes it skip the JetBrains theme.

## [1.0.9] - 2026-10-19

### Added

- `copyout <command>`: runs a command, shows its output as normal and copies all of it (output and errors) to the clipboard, then says how many lines were copied. It uses `pbcopy` on macOS, `clip.exe` under WSL, `wl-copy` or `xclip` on other Linux and `Set-Clipboard` on Windows. The command's exit status is kept.
- `logrun <command>`: runs a command with its output shown live and saved to `~/logs/<YYYY-MM-DD_HHMMSS>-<command>.log`, then prints the log's path. The command's exit status is kept.
- Command marks (OSC 133 shell integration) on every platform. Each prompt, command and output is marked, with the exit status of every command that ran, so Windows Terminal, tmux and other terminals that read the marks can jump between commands and select one command's output. Terminal.app keeps its own built-in marks. VS Code uses its own shell integration, so the profile's marks are skipped there. The Windows guide shows the Windows Terminal actions, which live in its own settings.
- zsh is now the default shell on Linux, matching the macOS profile. `linux/zshrc` loads the new `linux/topics-zsh/` port of every topic, keeping the Linux specifics (apt or dnf, `/etc/os-release`, `xdg-open`, Linux paths). `linux/bashrc` stays as the fallback for a machine without zsh. The welcome banner on Linux zsh reads `Shell     zsh <version>` with the same layout and colours as the Mac.
- Typed-command colours on macOS and Linux through zsh-syntax-highlighting, sourced last and silently skipped when the package is absent: known commands, aliases, functions and builtins green, an unknown command red, quoted strings yellow and options cyan, in the normal (not bright) ANSI colours a high contrast palette reads best. `zsh-syntax-highlighting` is now in the Mac Brewfile.
- Windows `paste` (Get-Clipboard) plus `sha256` and `sha512`, which print the lowercase hash then the path, the same as the Mac's.
- Linux `speedtest` and the Swift `sf2` alias (`swift format`).
- `speedtest` runs the installed `speedtest-cli` on macOS and Linux instead of downloading a script on each run. It also hides the tool's Python deprecation notice. The Brewfile installs it on the Mac.
- `games`: a menu of six terminal games (2048, Snake, Blocks, Meteors, Word and a typing test) on every platform, in `scripts/games.py`. Arrows or W and S choose, Enter plays and Q or Esc leaves any game. Best scores are kept per machine.
- `update`: lists everything out of date on the machine (Homebrew, winget, apt or dnf, global npm packages and uv or pipx tools), then upgrades it all only after a yes.
- `sysinfo`: a full system summary through fastfetch on demand, kept out of the banner so new tabs stay fast.
- `DOTFILES_NO_BANNER=1` hides the welcome banner.
- Screenshots and short animations of the config in action, dark and light, in the README's In action section.
- `termtheme` on macOS, Linux and Windows switches the terminal's High Contrast colours: `dark` or `light` pins one, `auto` follows the system's light and dark setting and no argument shows the current mode. It drives Terminal.app (with the login helper for `auto`), Ptyxis and Windows Terminal. Inside OrbStack or WSL it points to the host's terminal instead.
- `docker-clean` on macOS, Linux and Windows: shows Docker's disk use, asks, removes every unused container, image, volume and the build cache, then shows the space again.
- `orbls` and `orbsh` for OrbStack on macOS.
- `typw` to rebuild a Typst document on save, `linkcheck` to check every link under a folder with lychee and `trivyscan` to scan a folder for vulnerable dependencies, leaked secrets and misconfigurations.
- Linux `PATH` entries for swiftly's Swift toolchains, the Flutter SDK and .NET global tools. On WSL without wslview, links open through Windows with `BROWSER=explorer.exe`.
- `ACCESSIBILITY.md`: how the colours, the prompt and the aliases support people with low or monocular vision, colour vision differences and typing fatigue, plus the known gaps.

### Changed

- Under WSL, `BROWSER` is only set to `explorer.exe` when it is not already set. WSL is now recognised by `WSL_DISTRO_NAME` as well as `/proc/version`.
- The zsh syntax highlighting topic is now `37-syntax-highlighting.zsh` on macOS and `38-syntax-highlighting.zsh` on Linux, so it still loads last after the new command marks topic.
- The welcome banner shows in every terminal: editor terminals in VS Code and editors built on it show it too.
- The games share one colour scheme: titles bold cyan, good things green, the next or current thing yellow and danger or mistakes red, with borders and empty cells in the plain text colour. In the typing test, correct letters turn green and the next letter to type is yellow and underlined.
- The welcome banner is plain text with labels and no emoji: a bold cyan heading, then Machine (with the OS), Shell (with its version) and Session (date and time) between line-drawing borders. It lives in one `welcome` function per platform that the profile and `cls` or `refresh` both call.
- The Windows banner uses the normal green and cyan, matching the Mac and Linux, instead of the paler bright variants that `Write-Host` picks.
- The welcome banner's dashed top and bottom lines use the terminal's own text colour instead of bold cyan, so they no longer blend into the cyan welcome line and stay full contrast in light and dark mode.
- `ACCESSIBILITY.md` describes the High Contrast palette in light and dark mode, the four-colour banner and fzf's colours.
- The welcome banner's machine line is magenta on every platform, so each of its 4 lines has its own colour: cyan, green, magenta and yellow.
- macOS and Linux set `RIPGREP_CONFIG_PATH` when `~/.ripgreprc` exists, so ripgrep picks up its defaults file.
- Windows `cmds` pages through `less -RF` (from Git for Windows) when `less` is available, with `LESSCHARSET=utf-8` so the banner's box characters survive. It falls back to plain output otherwise.
- `linux/bashrc` returns early in a non-interactive shell, so a login shell running a single command (`ssh host cmd`, `scp` or `rsync`) no longer loads the profile or prints the banner. `linux/zshrc` only runs for interactive shells.
- The font advice in the platform guides and `ACCESSIBILITY.md` now matches the real setup: the prompt needs no Nerd Font, only the Node.js module shows a Nerd Font glyph and the Mac's terminals run Monaco 12 in iTerm2 and Warp's default font at size 13.
- `ACCESSIBILITY.md`: a note that the settings are preferences and a link to the shared accessibility statement.
- Tidied code comments and the contributor guide.

### Fixed

- Linux zsh and bash no longer print `nvm not found` before every `node`, `npm` or `npx` call on a machine without nvm, where Node comes from apt, dnf or another manager. With no `$NVM_DIR/nvm.sh`, no `node`, `npm` or `npx` wrappers are defined and only `nvm` and its helpers remain to print the install hint, matching macOS.
- macOS no longer prints `nvm not found` (or `command not found: _nvm_load`) before every `node`, `npm` or `npx` call on a Mac where Node comes from Homebrew. With no `$NVM_DIR/nvm.sh`, no `node`, `npm` or `npx` wrappers are defined and only `nvm` and its helpers remain to print the install hint. Where nvm is installed, its default Node is put on `PATH` at shell start the same way as on Linux, the wrappers are only defined when no default resolves and `nvmls`, `nvmuse` and the other helpers no longer disappear after the first nvm call.
- Linux zsh and bash put nvm's default Node on `PATH` at shell start without loading nvm, reading `$NVM_DIR/alias/default` the way nvm does (aliases such as `lts/*` and partial versions such as `26` resolve to the highest installed match). `node`, `npm` and `npx` are now real binaries, so a process started through `sh` no longer fails with `node: not found`. The lazy wrappers for them are only defined when no default resolves. `nvmls`, `nvmuse` and the other helpers no longer disappear after the first nvm call and a missing `bash_completion` no longer makes the first `nvm` call fail.
- Opening Windows PowerShell 5.1 with the profile no longer prints a screen of parse errors. The topic files use PowerShell 7 syntax (the backtick-e escape and `&&`), so the loader now stops before loading any topic when the major version is below 7 and prints one dim line: `dotfiles need PowerShell 7: run pwsh`.
- Windows `Reload-Profile` and `dot` keep what the reload defines. Dot-sourcing the profile inside a function only reached that function's own scope, so new or changed functions, aliases and variables were lost as soon as it returned. Both now run the loader through `Import-ProfileGlobal`, which copies them into the global scope.
- The PowerShell loader snippet in the Windows and documentation guides matches the real loader: it reads the topic files from the `DOTFILES` path, not `$PSScriptRoot`.
- Windows `dot` leaves a `$PROFILE` that is a one-line pointer to the repo's loader in place instead of overwriting it with a full copy, matching how macOS and Linux treat a linked profile. The Windows guide shows the pointer form.
- Loading the Windows profile in `pwsh` on macOS or Linux no longer prints registry errors from the welcome banner.
- Windows adds LibreOffice's `program` folder to the end of `PATH` when it is installed, so `soffice` is found.
- Linux zsh and bash share one `ssh-agent` on `~/.ssh/agent.sock` instead of `ssha` starting a new agent each time. It starts only when no agent answers there and is skipped when `SSH_AUTH_SOCK` already reaches a live agent. A key added once stays loaded for every terminal. Keys are never added automatically.
- The topic file counts in the guides and READMEs match the real files. The SSH and `dot` rows in the command reference describe what the commands really do.
- Starship waits up to 500 ms to scan a folder instead of 100 ms, so the home folder no longer prints a scan timeout warning above the prompt.
- Windows gains the `speedtest` command its `cmds` help already listed, through `speedtest-cli` or Ookla's `speedtest`. It prints an install hint when neither is present.
- `dot` on macOS and Linux no longer copies the profile onto itself when `~/.zshrc` or `~/.bashrc` is already a link to the repo copy.
- fzf on Linux and Windows uses terminal colour names, so it follows the terminal's light or dark palette. Its file list uses `rg` when ripgrep is installed.
- Inside an OrbStack machine, the Linux prompt no longer shows the user and machine name on every line, since OrbStack's shell arrives over a loopback SSH connection. A real SSH session still shows both.
- Starship waits up to 100 ms to scan a folder, so a large folder such as the home folder no longer prints a timeout warning above the prompt.
- `rg` runs ripgrep again on every platform. The Rails generator moved to `rgen`, the clipboard paste to `clippaste`, Elixir to `elx` and the R docs builder to `rdocs`, so none of them hide a real command. `rg2` stays as an extra name for ripgrep.
- On Linux, `ping4` keeps its real meaning (IPv4 only) while still sending four pings.
- The Linux prompt no longer tags every line with the container type inside WSL and other containers.
- The `cmds` reference lists the real Rails aliases (`rdm`, `rgen`, `rdreset`) on macOS, Linux and Windows, in place of names that no longer existed.
- Leaving the Windows `cmds` pager with Q no longer prints an error.
- Linux `digga` and `dns` give a friendly install hint when `dig` is missing, matching `sysinfo`'s fastfetch hint.
- `bdump` no longer passes `--describe`, which `brew bundle dump` has dropped since descriptions are now its default.
- The Starship Node.js module now uses the plain-text symbol `"node "` in every platform's `starship.toml`, so the whole prompt reads correctly without a Nerd Font. The font tips match.
- The README and `guides/new-device.md` now clone to `~/dev/github/repos/dotfiles`, the path every loader defaults to, with a note on setting `DOTFILES` for any other location.
- `mac/Brewfile` now installs `php@8.4`, `composer` and `avr-gcc@14` from the `osx-cross/avr` tap, with a `guides/mac.md` note on putting the keg-only PHP 8.4 on `PATH`.
- Linux JetBrains launchers now support manual IDE installations under `~/dev/tools/jetbrains` while retaining JetBrains Toolbox shell-script support

## [1.0.8] - 2026-09-18

### Added

- `zipf` in `07-utilities`, across mac, linux and windows, zipping a file or folder into a same-named `.zip`. The counterpart to `extract` in `08-community`, which already unpacks a zip among other archive formats but had no equivalent for creating one
- `zipf` documented in `guides/documentation.md`, the three platform guides and `cmds`

---

## [1.0.7] - 2026-09-17

### Added

- A red team and blue team section in `12-security`, authorised testing only: `revshell`, `listener`, `hydra-ssh`, `fuzz`, `subenum` and `msfq` for red team; `authfails`, `conns`, `fwstatus`, `sigcheck` and `lastlogins` for blue team
- Sixteen more quick-launcher functions: `vt`, `shodan`, `cve`, `maps`, `yt`, `wiki`, `godocs`, `crates`, `dockerhub`, `packagist`, `rubygems`, `nugetpkg`, `mvnrepo`, `hexpm`, `archive` and `bundlephobia`, matching every language ecosystem I already have tooling for
- All of the above documented in `guides/documentation.md`, the three platform guides and the `cmds` cheat-sheet

## [1.0.6] - 2026-09-17

### Added

- `battery`, `flushdns` and `please`, three genuine gaps found while auditing the existing alias set
- `kn` and `kgpw`, switching the current namespace and watching pods live, since `kuse` only switched context and `kgp` only listed pods once
- `dip`, printing a container's IP address in one step
- Eleven quick-launcher functions sharing one internal helper: `gh-search`, `so`, `mdn`, `npmjs`, `pypi`, `caniuse`, `leetcode`, `neetcode`, `codeforces`, `translate`, `regex101`
- All of the above documented in `guides/documentation.md`, the three platform guides and the `cmds` cheat-sheet

## [1.0.5] - 2026-09-17

### Changed

- `reload-profile` now hard-clears the terminal, including scrollback, before re-sourcing the profile, so the reprinted welcome banner lands on a clean screen instead of stacking under the old one

## [1.0.4] - 2026-09-17

### Added

- `gclean-branches`, deleting every local branch already merged into main in one step, a gap found while writing git-practice-lab's daily-workflow module since `gdone` only takes one branch at a time
- `google`, opening the default browser straight to a Google search for the given query, on every platform

## [1.0.3] - 2026-09-17

### Added

- `.github/ISSUE_TEMPLATE/config.yml` disabling the blank issue option, pointing to the security policy and my contact channels instead

## [1.0.2] - 2026-09-15

### Changed

- Issue templates converted from markdown frontmatter to YAML issue forms

## [1.0.1] - 2026-09-08

### Added

- `mac/Brewfile`, every Homebrew formula, cask and global npm package on this machine, produced by
  `brew bundle dump --describe --no-vscode` (VS Code extensions excluded, the separate `.vscode`
  repo's own `extensions.txt` is the source of truth for those)
- `bbundle`/`bdump` aliases in `16-brew.zsh` to install from and regenerate `mac/Brewfile`

---

## [1.0.0] - 2026-08-19

### Added

- Initial public release: cross-platform aliases and functions for macOS, Linux and Windows, a
  shared Starship prompt theme, install and setup guides and the topic-file structure that
  keeps each platform folder self-contained.
