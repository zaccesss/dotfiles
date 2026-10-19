# Changelog

All notable changes to this dotfiles repository are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions increment by one patch step (0.0.1) per release.

---

## [Unreleased]

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

### Fixed

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

### Added

- `termtheme` on macOS, Linux and Windows switches the terminal's High Contrast colours: `dark` or `light` pins one, `auto` follows the system's light and dark setting and no argument shows the current mode. It drives Terminal.app (with the login helper for `auto`), Ptyxis and Windows Terminal. Inside OrbStack or WSL it points to the host's terminal instead.
- `docker-clean` on macOS, Linux and Windows: shows Docker's disk use, asks, removes every unused container, image, volume and the build cache, then shows the space again.
- `orbls` and `orbsh` for OrbStack on macOS.
- `typw` to rebuild a Typst document on save, `linkcheck` to check every link under a folder with lychee and `trivyscan` to scan a folder for vulnerable dependencies, leaked secrets and misconfigurations.
- Linux `PATH` entries for swiftly's Swift toolchains, the Flutter SDK and .NET global tools. On WSL without wslview, links open through Windows with `BROWSER=explorer.exe`.

### Changed

- The font advice in the platform guides and `ACCESSIBILITY.md` now matches the real setup: the prompt needs no Nerd Font, only the Node.js module shows a Nerd Font glyph and the Mac's terminals run Monaco 12 in iTerm2 and Warp's default font at size 13.
- `ACCESSIBILITY.md`: a note that the settings are preferences and a link to the shared accessibility statement.

### Added

- `ACCESSIBILITY.md`: how the colours, the prompt and the aliases support people with low or monocular vision, colour vision differences and typing fatigue, plus the known gaps.

### Changed

- Tidied code comments and the contributor guide.

### Fixed

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
