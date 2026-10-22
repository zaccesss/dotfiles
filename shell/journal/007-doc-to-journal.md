# 007 - Renaming doc/ to journal/ and separating documentation from decisions

**Date:** June 2026
**Status:** Complete

---

## The original structure

The repo originally had a `doc/` folder. The name was vague - it could mean API docs, architecture docs, guides or anything else. During the refactor the actual intended content became clearer: the folder is for engineering journal entries, not general documentation.

The distinction matters:

- **Documentation** answers "how do I use this?" - it describes commands, installation steps, parameters. This lives in `guides/documentation.md` (full technical reference) and the rest of `guides/` (platform-specific walkthroughs).
- **Journal** answers "why does this exist the way it does?" - it records decisions, failed attempts, trade-offs and the reasoning behind choices that are not obvious from the code or the git log. The `journal/` folder is for this.

The folder was renamed from `doc/` to `journal/` to make the distinction explicit.

---

## The rename process and the git mv problem

The standard way to rename a folder in a git repo is `git mv doc/ journal/`. This failed with:

```
fatal: source directory is empty
```

The reason: `doc/README.md` was an untracked file (it had been written in this session but never committed). From git's perspective, `doc/` contained no tracked files - an empty tracked directory. `git mv` on an empty tracked directory fails because there is nothing to move in the index.

The fix was to do the rename manually:

```bash
mkdir journal
mv doc/README.md journal/README.md
rmdir doc
```

This bypasses the git index and just moves the files on disk. The untracked `journal/README.md` is then ready to be staged as a new file when committing.

---

## The separation in practice

After the rename, the content breakdown is:

| Location | Content | Audience |
| --- | --- | --- |
| `guides/documentation.md` | Full command reference, architecture, every alias described | Anyone setting up or using the dotfiles |
| `guides/mac.md` | macOS install walkthrough, command tables | New macOS setup |
| `guides/linux.md` | Linux/WSL2 install walkthrough | New Linux setup |
| `guides/windows.md` | Windows install, PowerShell specifics | New Windows setup |
| `guides/new-device.md` | Public step-by-step guide with generic placeholders | Anyone cloning these dotfiles |
| `journal/` | Engineering decisions, conflict resolutions, refactor rationale | Myself, future reference |

The `journal/` entries are written after the fact, not as planning documents. They record what was done and why - the kind of context that is usually lost to git commit messages or never written down at all.

---

## Why the journal entries are in the repo

I considered keeping the journal in a private location (e.g. `will-do/` which is gitignored) but decided against it. The entries are useful to anyone who forks or adapts these dotfiles, not just to me. Understanding why `bclean` means `brew cleanup` and not `bundle clean` or why nvm is lazy-loaded, saves the next person from rediscovering the same issues. Making the journal public is consistent with the goal of these dotfiles being a usable reference, not just a personal configuration dump.

The one folder that does stay private and gitignored is `will-do/`. That is for personal task notes, private setup prompts and device-specific configuration that should never be public. The journal is the technical history; `will-do/` is the personal planning space.
