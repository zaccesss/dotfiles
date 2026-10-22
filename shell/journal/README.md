# journal/

Engineering journal for this dotfiles repo. Each entry covers a significant decision, refactor or architectural change - the reasoning behind it, what was tried and what I settled on. These are written after the fact as a record, not as planning documents.

## Entries

| File | Topic |
| --- | --- |
| [`001-modular-refactor.md`](001-modular-refactor.md) | Why the profile was split from one big file into numbered topic files, how the loader works and why the order matters |
| [`002-colours-and-accessibility.md`](002-colours-and-accessibility.md) | Why the colour scheme is deliberate: monocular vision, high-contrast ANSI choices, why `cmds()` pipes through a pager and how the choices help others too |
| [`003-alias-conflicts.md`](003-alias-conflicts.md) | Every naming conflict found during the refactor: `sc` (shellcheck vs sc.exe), `bclean`/`boutd` (brew vs bundle), `ni` (npm install vs New-Item), `echo ""` in PowerShell pipes |
| [`004-nvm-lazy-load.md`](004-nvm-lazy-load.md) | Why nvm is initialised lazily on first call rather than at shell startup and how the stub function pattern works |
| [`005-cross-platform-naming.md`](005-cross-platform-naming.md) | The philosophy of identical command names across macOS, Linux and Windows and the deliberate exceptions where OS reservations forced a different name |
| [`006-windows-static-analysis.md`](006-windows-static-analysis.md) | How the Windows PowerShell topic files were verified for correctness without `pwsh` installed - the static analysis approach and its limits |
| [`007-doc-to-journal.md`](007-doc-to-journal.md) | Why the folder was renamed from `doc/` to `journal/`, the separation between documentation and decision records and the `git mv` failure on untracked files |
| [`008-starship-prompt.md`](008-starship-prompt.md) | Why Starship was added, module choices, the shared/ approach and how to disable it |
| [`009-dropping-shared-folder.md`](009-dropping-shared-folder.md) | Why the shared/ folder was removed: starship.toml split into per-platform copies, shell-profile-guide.md deleted as redundant, python-venv-guide.md split into real per-platform guide sections |

## Purpose

The journal exists because shell profile decisions are easy to forget. Why is nvm lazy-loaded? Why is npm install `npmi` and not `ni` on Windows? Why are there numbered topic files rather than one big profile? The entries here answer those questions so I do not have to reverse-engineer the reasoning from the git log.
