# Changelog

All notable changes to this dotfiles repository are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions increment by one patch step (0.0.1) per release.

---

## [Unreleased]

### Changed

- The font advice in the platform guides and `ACCESSIBILITY.md` now matches the real setup: the prompt needs no Nerd Font, only the Node.js module shows a Nerd Font glyph and the Mac's terminals run Monaco 12 in iTerm2 and Warp's default font at size 13.
- `ACCESSIBILITY.md`: a note that the settings are preferences and a link to the shared accessibility statement.

### Added

- `ACCESSIBILITY.md`: how the colours, the prompt and the aliases support people with low or monocular vision, colour vision differences and typing fatigue, plus the known gaps.

### Changed

- Tidied code comments and the contributor guide.

### Fixed

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
