# Changelog

All notable changes to this dotfiles repository are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions increment by one patch step (0.0.1) per release.

---

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
