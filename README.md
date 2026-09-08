# dotfiles

> Shell profiles, aliases and developer environment configuration for macOS, Windows and Linux.

[![Markdown Lint](https://github.com/zaccesss/dotfiles/actions/workflows/markdownlint.yml/badge.svg)](https://github.com/zaccesss/dotfiles/actions/workflows/markdownlint.yml)
[![Shell Check](https://github.com/zaccesss/dotfiles/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/zaccesss/dotfiles/actions/workflows/shellcheck.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## About

I lost sight in my right eye at age two due to retinoblastoma and have worked with monocular vision my entire life. One of the practical consequences is that a monochrome wall of terminal text is genuinely harder for me to navigate. Distinct, high-contrast colours in a terminal are not an aesthetic preference - they take over the depth-cue job that binocular vision normally does. Cyan headers, green status lines, yellow timestamps - each section is a different colour so I can scan instantly without reading line by line. That is the first reason these dotfiles look the way they do. The hope is that others with similar needs find it useful too.

The second reason is that I work and build across multiple devices - a MacBook Air, a Lenovo laptop on Linux/WSL2 and a Windows gaming PC. Typing long commands that break the moment you leave out a letter, a hyphen or the wrong word was getting in the way. A mistyped `git commit --amend --no-edit` or a forgotten flag in a Docker command meant stopping to look it up or retype it. Small friction that adds up across a day.

These dotfiles solve that by replacing the commands I run most often with short, memorable aliases that are identical on every machine. `gs` instead of `git status`. `dcu` instead of `docker-compose up -d`. The goal is the same muscle memory on macOS, Linux and Windows, no mental context switch between environments.

The profile is split into numbered topic files - one per area of concern - so everything stays organised and easy to find. Adding a new tool means creating one new file, not inserting into a monolithic profile. Run `cmds` at any time for the full command reference, press q to exit.

---

## Quick setup

> [!WARNING]
> These are personal dotfiles configured for a specific set of machines, tools and workflows. Before cloning, read [NOTICE](NOTICE.md) for the full personalisation checklist. Then read the [platform guide](#documentation) for your OS. Remove any topic files you do not need, update paths and usernames to match your own machine and only then source the profile. Running it unchanged on your own machine will not work correctly.

**1. Read first**

> [!IMPORTANT]
> - [NOTICE](NOTICE.md) - personalisation checklist, what to change before use
> - [guides/new-device.md](guides/new-device.md) - prerequisites, Homebrew, language runtimes, token setup

**2. Clone the repo**

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

**3. Adapt to your machine**

> [!CAUTION]
> Go through each topic file in your platform's `topics/` folder. Remove files for tools you do not use. Update any hardcoded paths, usernames or tokens to match your setup.

**4. Copy the profile for your platform**

macOS:

```bash
cp mac/zshrc ~/.zshrc && source ~/.zshrc
```

Linux and WSL2:

```bash
cp linux/bashrc ~/.bashrc && source ~/.bashrc
```

Windows:

```powershell
Copy-Item windows\Microsoft.PowerShell_profile.ps1 $PROFILE -Force
```

---

## Structure

```
dotfiles/
- mac/                         zsh profile for macOS
  - zshrc                      loader: sources all topic files in order
  - starship.toml              Starship prompt config for macOS
  - Brewfile                   every Homebrew formula, cask and npm global on this machine
  - topics/                    numbered .zsh topic files, one per area
- linux/                       bash profile for Linux and WSL2
  - bashrc                     loader
  - starship.toml              Starship prompt config for Linux and WSL2
  - topics/                    numbered .sh topic files
- windows/                     PowerShell profile for Windows
  - Microsoft.PowerShell_profile.ps1   loader
  - starship.toml              Starship prompt config for Windows
  - topics/                    numbered .ps1 topic files
- guides/                      platform setup walkthroughs and command reference
  - documentation.md           full technical reference for every command
- journal/                     engineering journal: decisions, refactors, architecture notes
```

---

## Documentation

| Resource | What it covers |
| --- | --- |
| [guides/documentation.md](guides/documentation.md) | Full technical reference: architecture, loader mechanics and every command described |
| [guides/mac.md](guides/mac.md) | macOS installation, modular profile walkthrough and command reference |
| [guides/linux.md](guides/linux.md) | Linux and WSL2 installation, platform differences and command reference |
| [guides/windows.md](guides/windows.md) | Windows installation, PowerShell specifics and command reference |
| [guides/new-device.md](guides/new-device.md) | Step-by-step setup guide for a brand new machine on any platform |
| [mac/topics/README.md](mac/topics/README.md) | All macOS topic files listed with descriptions and key commands |
| [linux/topics/README.md](linux/topics/README.md) | All Linux topic files listed with descriptions and key commands |
| [windows/topics/README.md](windows/topics/README.md) | All Windows topic files listed with descriptions and key commands |
| [mac/starship.toml](mac/starship.toml), [linux/starship.toml](linux/starship.toml), [windows/starship.toml](windows/starship.toml) | Starship prompt config, identical content per platform, covering git and the 35 topic files, plus Starship's own module-based language detection |
| [mac/Brewfile](mac/Brewfile) | Every Homebrew formula, cask and global npm package on this machine, `bbundle`/`bdump` install and regenerate it |
| [journal/008-starship-prompt.md](journal/008-starship-prompt.md) | Why Starship was added, module choices and how to disable it |

---

## Disclaimer

> [!CAUTION]
> These dotfiles are configured for my own machines. Paths, usernames and tokens are specific to my setup. Review scripts before running them on your own machine and make sure token files are never committed.
