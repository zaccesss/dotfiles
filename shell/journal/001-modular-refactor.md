# 001 - The modular refactor: one file to 35 topic files

**Date:** June 2026
**Status:** Complete

---

## What happened

The original `mac/zshrc` was a single file of about 275 lines. It held everything: PATH exports, navigation shortcuts, git aliases, all the language tooling, the welcome banner, utility functions. The same shape existed in `linux/bashrc` and `windows/Microsoft.PowerShell_profile.ps1`, each one monolithic.

This worked fine for a while, but over time a few things started to irritate me:

- Finding a specific section meant scrolling or grepping through one long file.
- Adding a new language or tool meant deciding where to slot it in and that decision was arbitrary. Nothing enforced an order.
- Disabling a section (e.g. I want the Ruby aliases on macOS but not on a server) meant commenting out a block mid-file, which was messy.
- The three platform files were structurally different from each other, making it hard to compare them or keep them in sync.
- The git diff for any change was hard to read because the file had no logical sections.

The fix was to split each profile into numbered topic files, one per area of concern and reduce the actual `zshrc`/`bashrc`/`ps1` loader to a loop that sources them all in order.

---

## The structure

Each platform now has a `topics/` subfolder. Files are numbered `01` through `35`, one per area:

```
01-path           PATH and environment variables
02-colours        ANSI colour variables used by the welcome banner and cmds()
03-navigation     cd shortcuts for common directories
04-git            git aliases (gs, ga, gaa, gc, gp, etc.)
05-profile        profile management: edit-profile, reload-profile
06-functions      core shell functions: cmds(), mkcd(), mkf()
07-utilities      everyday tools: ll, la, copy, paste, pubip, weather, etc.
08-community      community shortcuts from various dotfiles projects
09-cli-tools      general-purpose CLI tool shortcuts
10-ssh            SSH key management and connection shortcuts
11-network        IP, DNS, ping, port scanning shortcuts
12-security       OpenSSL, GPG, checksums
13-database       PostgreSQL, MySQL, MongoDB, Redis, SQLite
14-json           jq helpers
15-rsync          rclone shortcuts
16-brew           Homebrew (mac) / Linuxbrew (linux) / winget + Chocolatey (windows)
17-gh             GitHub CLI shortcuts
18-nvm            Node version manager (lazy-loaded)
19-editors        VS Code, Neovim
20-shell-tools    shellcheck, shfmt, PSScriptAnalyzer
21-tmux           tmux (mac/linux) / Windows Terminal pane management (windows)
22-docker         Docker and Docker Compose
23-kubernetes     kubectl shortcuts
24-cloud          AWS CLI, Azure CLI, GCP CLI
25-devops         Terraform, Helm, Vagrant, Ansible
26-python         Python, pip, virtualenv
27-web            Node.js, npm, TypeScript
28-ruby           Ruby, rbenv, Bundler
29-php            Composer
30-go             Go toolchain
31-rust           Cargo
32-java           JVM: Maven, Gradle wrapper
33-c-cpp          GCC, Clang, LLDB
34-starship       Starship prompt init
35-secrets        age and sops encryption
```

The loader in each platform's root file is five lines:

```zsh
# mac/zshrc
DOTFILES="${DOTFILES:-$HOME/dev/github/repos/dotfiles}"
for _f in "$DOTFILES/mac/topics/"*.zsh; do
    [[ -f "$_f" ]] && source "$_f"
done
unset _f
```

The Windows version uses `Get-ChildItem` and a `ForEach-Object` pipe instead.

---

## Why the numbering matters

The numbering guarantees load order and load order matters for two reasons.

First, some files depend on variables defined in earlier files. `02-colours.zsh` defines `$BOLD`, `$CYAN`, `$RESET` and so on. The welcome banner in `zshrc` uses those variables, as does `cmds()` in `06-functions.zsh`. If colours loaded after functions the banner would print raw escape codes instead of actual colours.

Second, when two files define the same name, the later-numbered file wins. This is deliberate - if I want to override a shortcut from `16-brew.zsh`, I put the override in a higher-numbered file. It is also a source of bugs if not watched carefully. See `003-alias-conflicts.md` for the specific conflicts that came up during this refactor.

---

## What the refactor touched

- `mac/zshrc` reduced from 275 lines to 30 lines (loader + welcome banner).
- `linux/bashrc` reduced similarly.
- `windows/Microsoft.PowerShell_profile.ps1` reduced to a `Get-ChildItem` loop.
- All aliases, functions and exports moved into their respective topic files.
- Each topic file has a comment block at the top saying why it exists and what tools it requires.
- PATH exports moved into `01-path` so they're always first.
- Colour variables in `02-colours` so everything that follows can use them.

---

## What this does not solve

The loader uses a glob (`*.zsh`, `*.sh`, `*.ps1`) which means all files in `topics/` load on every shell start, even if the tool is not installed. A file like `23-kubernetes.zsh` loads even on machines with no `kubectl` installed. This is intentional: the aliases fail silently if the binary is not present and the startup cost is just the file read, not the tool initialisation. The one exception is nvm, which is lazy-loaded specifically because `source nvm.sh` adds about 200ms even if you never run a node command. See `004-nvm-lazy-load.md`.
