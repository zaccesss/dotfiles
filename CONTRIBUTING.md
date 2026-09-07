# Contributing

Thanks for taking an interest. These are personal dotfiles so contributions
are narrowly scoped, but improvements, bug reports and platform corrections are
welcome.

## What belongs here

- Bug fixes for existing commands (wrong flags, broken paths, syntax errors)
- Corrections for platform differences (e.g. a macOS command that also works on Linux)
- Missing tool support that fits the existing category structure
- Typo and comment fixes

## What does not belong here

- New tool categories that are highly personal or niche
- Opiniated changes to aliases that work fine as-is
- Reformatting files purely for style

## How to contribute

1. Fork the repository and create a branch named `fix/<short-description>` or
   `feat/<short-description>`.
2. Make your changes. Follow the style rules below.
3. Run a syntax check before opening a pull request:
   - macOS/Linux zsh files: `zsh -n mac/topics/<file>.zsh`
   - Linux bash files: `bash -n linux/topics/<file>.sh`
   - PowerShell files: `pwsh -NoProfile -Command "& { . './windows/topics/<file>.ps1' }"`
4. Open a pull request with a clear title and a one-paragraph description of
   what changed and why.

## Style rules

- **Comments**: first-person, WHY not WHAT. One line maximum per function.
  Bad: `# this function lists packages`
  Good: `# bls: I use this daily to audit what Homebrew has installed.`
- **UK English** in prose comments and documentation.
- **No secrets** - never include tokens, passwords or personal credentials.
  See [NOTICE](NOTICE.md) for the token policy.
- **Three platforms**: if a change applies to all three platforms, update all
  three files (mac, linux, windows). If it is platform-specific, update only
  the relevant file and add a comment explaining why.
- **Numbering**: do not renumber existing files. If a new file is needed,
  discuss the placement in the pull request before creating it.

## Reporting bugs

Open an issue with:
- Which platform (macOS / Linux / Windows)
- Which topic file and function name
- What you expected vs what happened
- Any relevant error output

## The shared guide

> [!NOTE]
> I keep one shared contributing guide for all my projects, covering software, hardware, writing and everything in between: [zaccesss/contribute](https://github.com/zaccesss/contribute) or on [my site](https://isaacadjei.me/contribute). This file takes precedence where the two differ.
