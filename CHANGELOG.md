# Changelog

All notable changes to this dotfiles repository are recorded here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions increment by one patch step (0.0.1) per release.

---

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
