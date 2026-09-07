# 009 - Dropping the shared/ folder

**Date:** August 2026
**Status:** Complete

---

## Why

The `shared/` folder held four files: `starship.toml` (a real runtime config, symlinked from
each device), `shell-profile-guide.md` and `python-venv-guide.md` (reference docs) and its own
`README.md`. Every other structural decision in this repo (see
[001](001-modular-refactor.md)) treats each platform folder as fully self-contained, no shared
folder needing a second copy step at install time, even OS-agnostic content gets duplicated into
every platform folder so a single `cp <platform>/* ~/.dest/` install stays a one-step operation.
`shared/` was the one place that broke that rule.

## What changed

- **`starship.toml`** now lives at `mac/starship.toml`, `linux/starship.toml` and
  `windows/starship.toml`, identical content on all three, kept in step by hand (or by editing
  one and copying it to the others) rather than a symlink to one shared file. [008](008-starship-prompt.md)'s
  original reasoning for the symlink approach (a copy drifts, a symlink always reads from the
  repo) was correct at the time, this trades that convenience for consistency with how every
  other file in this repo works, worth it once the pattern needed to hold for more than one file.
- **`shell-profile-guide.md`** turned out to be fully redundant with `guides/mac.md`,
  `guides/linux.md` and `guides/windows.md`, which already cover the same alias/function/colour
  reference per platform and were more current (the recent alias-collision-fix renames, see the
  same PR this journal entry ships in, were already reflected there, not in the shared copy).
  Deleted outright rather than distributed three ways, since copying it would have just recreated
  the same duplication in three places instead of one.
- **`python-venv-guide.md`** genuinely needed splitting: its content already mixed
  Windows/macOS/Linux commands awkwardly in one document (its own escaped-markdown bug from a
  past copy-paste, `\#`, `\*\*`, `\-` rendering literally instead of as real markdown, found and
  fixed in the process). Now a real "Python virtual environments" section in each of
  `guides/mac.md`, `guides/linux.md` and `guides/windows.md`, showing only that platform's own
  commands.
- Every cross-reference to `shared/` across `README.md`, `documentation.md`, `NOTICE.md` and
  `guides/new-device.md` updated to point at the real per-platform paths. `guides/new-device.md`
  also had an entire "Starship prompt (all platforms)" section that fully duplicated the Starship
  setup steps already present in each platform's own numbered walkthrough, deleted rather than
  updated twice.

## What this does not change

The `34-starship` init pattern, module choices and how to disable Starship are unchanged, see
[008](008-starship-prompt.md) for that. Only where the config file physically lives changed.
