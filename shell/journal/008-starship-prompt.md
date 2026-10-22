# 009 - Starship prompt

**Date:** June 2026
**Status:** Complete

---

## Why I added it

My prompt before Starship was a plain `%` on macOS and `$` on Linux. Every time I opened a
terminal tab I had no idea which branch I was on, whether there were uncommitted changes, or
what folder I was in without running `pwd`. I was running `gs` constantly just to orient myself.

The other reason is consistency. My whole dotfiles setup is built around the rule that muscle
memory should carry identically across Mac, Linux and Windows. The prompt was the one place
where that broke down - zsh, bash and PowerShell each have their own prompt syntax and there
is no way to write one prompt string that works on all three shells.

Starship solves both problems. The `starship.toml` config covers all three platforms with
identical content, one copy per platform folder. The init line (`eval "$(starship init zsh)"`
etc.) goes in the platform-specific `34-starship` topic file, everything about the actual prompt
appearance lives in that platform's own `starship.toml`. See [009](009-dropping-shared-folder.md)
for why this moved off a single shared file.

---

## Why topic file 34

The other 34 topic files run from `01-path` to `35-secrets`. Starship must be initialised
after all the aliases, functions and environment variables it needs are already loaded, so it
sits near the end of the load order in the glob sort.

---

## Where the config lives

`starship.toml` now lives in each platform's own folder (`mac/starship.toml`,
`linux/starship.toml`, `windows/starship.toml`), identical content on all three, symlinked from
`~/.config/starship.toml` on each device same as before. This originally lived in a single
`shared/` folder with one symlinked file. [009](009-dropping-shared-folder.md) covers why that
changed: every other file in this repo follows the rule that each platform folder is fully
self-contained, `shared/` was the one exception, worth fixing once other files needed splitting
out of it too, not just this one.

---

## Module choices

Starship has modules for dozens of languages and tools. These activate automatically based on
project files it finds in the current directory, entirely independent of which topic files are
installed in this repo:

| Module | What triggers it |
| --- | --- |
| `git_branch`, `git_status` | Any git repository |
| `hostname` | SSH sessions only |
| `kubernetes` | A kubeconfig context is active |
| `jobs` | Built in, no dedicated module trigger needed |
| `python`, `nodejs`, `golang`, `rust`, `dotnet`, `java`, `kotlin`, `scala`, `maven`, `php`, `ruby`, `rlang`, `lua`, `zig`, `swift`, `elixir` | Presence of that language's project files (e.g. `package.json`, `Cargo.toml`, `go.mod`) in the current directory |
| `docker_context` | An active Docker context |
| `helm` | A `Chart.yaml` in the current directory |
| `cmd_duration` | All - shows if any command takes over 2s |
| `battery` | Built in, discharging only |
| `time` | Right edge of line 1, redraws with every prompt |

Cloud modules (AWS, GCloud, Azure) are explicitly disabled because I do not use them and
they add latency to every prompt render by querying config files.

Kotlin and Scala were originally lumped under `java`'s `detect_extensions`, moved to their own
native Starship modules once I realised Starship ships dedicated ones for both, same for R
(`rlang`), Kubernetes, Helm and Maven. Hostname, jobs, battery and time were added later too,
along with a full colour theme, all covered in the CHANGELOG rather than repeated here.

---

## Disabling it

To disable Starship entirely: comment out the single `eval` line in `34-starship.zsh` (or
`.sh` / `.ps1`) and run `reload-profile`. The rest of the profile is unaffected.

To hide a specific module: add `disabled = true` under its section in that platform's
`starship.toml`. The change takes effect on the next shell open on that device.

---

## What the prompt looks like

In a git repo with uncommitted changes inside a Go project:

```
dotfiles  main *  via 🐹 v1.22
>
```

In an ordinary folder with no git, no recognised language:

```
~/documents
>
```

The prompt line and the input line are separate. The `>` is where you type. Directory and
context always appear on the line above it.
