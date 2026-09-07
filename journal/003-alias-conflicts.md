# 002 - Alias conflicts: what clashed and why

**Date:** June 2026
**Status:** Complete

---

## Why this came up

When you put several hundred aliases and functions into a single ordered load chain, sooner or later two files try to use the same short name for different things. Most of the time the higher-numbered file silently wins and you never notice. But there are cases where the conflict causes a visible error, a confusing behaviour or a clash with a built-in OS command. This entry documents every conflict that came up during the refactor, what caused it and what I settled on.

---

## 1. `sc` - shellcheck vs sc.exe (Windows only)

**Conflict:** `windows/topics/19-shell-tools.ps1` originally defined `function sc` as a shortcut for `shellcheck`. On Windows, `sc.exe` is the Service Control Manager - a system binary used to start, stop and query Windows services. Naming a function `sc` in PowerShell shadows `sc.exe`.

This is a problem because:
- `sc` is used by other tools and scripts to interact with Windows services.
- PowerShell itself uses `sc` internally in some service management flows.
- A user running `sc query W32Time` to check a service status would instead invoke `shellcheck` with no arguments and get a shellcheck usage error.

The macOS and Linux `sc` alias is not defined in either profile (there is no equivalent reserved name on those platforms), so there is no conflict there.

**Resolution:** Renamed to `shck` on Windows. The comment makes the reason explicit:

```powershell
# shck: run shellcheck on a .sh file or find all .sh files in the current dir
# sc is reserved for sc.exe (Windows Service Control Manager)
function shck { ... }
```

**Documented in `guides/windows.md`** under the "Key Windows differences" table.

---

## 2. `bclean` / `boutd` - brew cleanup vs bundle clean/outdated

**Conflict:** `16-brew.zsh` originally had:

```zsh
alias bclean="brew cleanup"
alias boutd="brew outdated"
```

`28-ruby.zsh` has:

```zsh
alias bclean="bundle clean --force"
alias boutd="bundle outdated"
```

Because `28-ruby.zsh` loads after `16-brew.zsh`, the Bundler aliases silently overwrote the Homebrew ones. Running `bclean` on a machine with Ruby installed would run `bundle clean --force` instead of `brew cleanup`, which would fail with "Could not locate Gemfile" in any directory that is not a Ruby project.

This was a silent bug, no error at startup, just wrong behaviour at runtime.

**Resolution:** Renamed the Homebrew versions to `brewclean` and `brewoutd`. The `b` prefix is kept for Bundler commands since that convention is already established in `28-ruby.zsh` (`be`, `binst`, `bupd`, `bcheck`, `bclean`). Homebrew gets the full word prefix to make the intent clearer.

**Both mac and Linux affected.** Windows uses `winget`/Chocolatey instead of Homebrew, so `16-winget.ps1` was not affected.

---

## 3. `ni` - npm install vs New-Item (Windows only)

**Conflict:** `windows/topics/27-web.ps1` cannot use `alias ni="npm install"` (as the mac/linux equivalents do) because `ni` is a built-in alias for PowerShell's `New-Item` cmdlet. Running `ni` with no matching function defined calls `New-Item`, which creates files and directories.

This is not a runtime bug in the same way as the others - defining a function named `ni` in PowerShell would simply override the `New-Item` alias. But overriding a core PowerShell cmdlet alias is a bad idea because other scripts and tools may rely on `ni` meaning `New-Item`.

**Resolution:** On Windows only, `npm install` is aliased to `npmi`. The mac/linux profiles keep `ni` as expected.

**Documented in `guides/windows.md`** under both the Development shortcuts table and the "Key Windows differences" table.

---

## 4. PowerShell `echo` in pipe (Windows only)

**Conflict:** `windows/topics/11-security.ps1` originally contained:

```powershell
echo "" | openssl s_client -connect "${h}:${p}" -servername $h 2>$null ...
```

`echo` in PowerShell is an alias for `Write-Object`, which wraps the empty string in a PowerShell object before piping it to `openssl`. Native commands like `openssl` expect raw bytes on stdin, not a PowerShell object. The correct idiomatic approach for piping an empty string to a native command is to use an empty string literal directly:

```powershell
"" | openssl s_client -connect "${h}:${p}" -servername $h 2>$null ...
```

This sends the string value to stdin as the native command expects.

**Resolution:** Replaced `echo ""` with `""` in `ssl-check`.

---

## General principle going forward

Before naming a new alias or function, check both the shell's built-ins and any higher-numbered topic files that might claim the same name later. On Windows also check Windows system binary names (`sc.exe`, `ni`, `curl.exe`, `sort.exe`, etc.) because PowerShell surfaces them as commands in the same namespace.

The quick check on each platform:

```zsh
# zsh
which myname
type myname
alias | grep myname
```

```bash
# bash
type myname
alias | grep myname
```

```powershell
# PowerShell
Get-Command myname -ErrorAction SilentlyContinue
Get-Alias myname -ErrorAction SilentlyContinue
```
