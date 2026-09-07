# 005 - Cross-platform naming: why the same name everywhere

**Date:** June 2026
**Status:** Complete

---

## The goal

I work on a MacBook Air (macOS, zsh), a Lenovo laptop (Ubuntu/Linux, bash) and a Windows gaming PC (Windows 11, PowerShell 7). The primary irritation that started these dotfiles was mistyping commands or forgetting the exact flags. The secondary irritation - which the modular refactor also addresses - is that switching between machines required a mental context switch: "am I on Mac so it is `pbcopy` or Linux so it is `xclip`?"

The goal of the naming convention is zero mental context switch. If `gs` means `git status` on Mac, it means `git status` on Linux and on Windows. If `dcu` means `docker-compose up -d` on Mac, it means the same thing everywhere. Muscle memory from one machine transfers directly to another.

---

## How it is achieved

Every alias and function is defined three times: once in `mac/topics/`, once in `linux/topics/`, once in `windows/topics/`. The implementation may differ (bash functions vs PowerShell functions, `pbcopy` vs `xclip` vs `Set-Clipboard`) but the name is always the same.

Where the underlying tool has a platform difference, the alias hides it:

| What you type | macOS | Linux | Windows |
| --- | --- | --- | --- |
| `copy` | `pbcopy` | `xclip -selection clipboard` | `Set-Clipboard` |
| `paste` | `pbpaste` | `xclip -selection clipboard -o` | `Get-Clipboard` |
| `dns-flush` | `sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder` | `systemd-resolve --flush-caches` | `ipconfig /flushdns` |
| `localip` | `ipconfig getifaddr en0` | `hostname -I` | `(Get-NetIPAddress -AddressFamily IPv4).IPAddress` |

The name is consistent. The body is platform-specific.

---

## The exceptions

There are four cases where I deliberately chose a different name on Windows, because the same name was already taken by something the OS depends on.

**`ni` vs `npmi`**

On macOS and Linux, `ni` is an alias for `npm install`. On Windows, `ni` is a built-in PowerShell alias for `New-Item`. If I defined `function ni` in PowerShell, it would shadow the cmdlet. Worse, scripts and tools that rely on `ni` being `New-Item` would silently break. So on Windows, `npm install` is `npmi`. This is the only npm alias that differs.

**`sc` vs `shck`**

On macOS and Linux, `sc` could be a shellcheck shortcut. On Windows, `sc.exe` is the Service Control Manager - a fundamental Windows system tool. I do not define `sc` on macOS or Linux (there is no equivalent system binary to clash with), but I was defining `function sc` in the original Windows topic file. This was renamed to `shck` (shellcheck) to avoid shadowing `sc.exe`.

**`tmux` vs `wt-here` / `wt-split`**

On macOS and Linux, `21-tmux.zsh/sh` provides full tmux integration: `tls`, `ts`, `tss`, `tw`, `tka`, `tconf`, `tlog`. tmux is a native terminal multiplexer and runs well on both.

On Windows, tmux is not a native application. It can run inside WSL2, but that is a separate environment. The Windows equivalent for managing terminal panes is Windows Terminal. So `21-tmux.ps1` on Windows provides `wt-here` (open Windows Terminal in the current directory) and `wt-split` (split the current pane), rather than tmux shortcuts. The function names are different here because the underlying metaphors are different - tmux sessions are not the same as Windows Terminal panes.

---

## The benefit in practice

The practical benefit shows up in the git and Docker sections most often, because those are the tools I use on all three platforms every day. `gs`, `ga`, `gc`, `gp`, `gl` work identically everywhere. `dps`, `dcu`, `dcd`, `dex` work identically everywhere. I never have to remember whether I am on a platform that uses `git status` or one that has an alias for it - it is always `gs`, everywhere.

The documentation reflects this too. The guides for mac, linux and windows show the same alias tables in the git and core sections, with platform-specific notes only where the implementation genuinely differs.
