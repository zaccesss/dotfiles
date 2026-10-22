# Contributing

Thanks for taking an interest. These are personal configs, so contributions are narrowly scoped,
but bug fixes, platform corrections and clearer docs are welcome in every folder.

## What belongs here

- Bug fixes for an existing command, script, setting or key binding (wrong flags, broken paths,
  syntax errors, a setting a tool no longer reads)
- Corrections for platform differences, such as a macOS step that also works on Linux
- A bootstrap step that fails on a supported release
- Missing support that fits an existing folder's structure
- Typo, link and comment fixes

## What does not belong here

- New tools or categories that are highly personal or niche
- Opinionated changes to aliases, key bindings or theme colours that work fine as they are
- Reformatting files purely for style

## How to contribute

1. Open an issue first with the [issue forms](https://github.com/zaccesss/dotfiles/issues/new/choose)
   and say which folder it is about.
2. Fork the repository and create a branch named `fix/<short-description>` or
   `feat/<short-description>`.
3. Make the change in the folder it belongs to and keep it to that folder where you can. If a change
   applies to macOS, Linux and Windows, update all three copies.
4. Run the checks for the folders you touched (see below).
5. Open a pull request. The template asks which folders it touches and what you checked.

## Checks before a pull request

CI runs every check below on each pull request, but only for the folders that changed. Running the
same ones locally first saves a round trip.

| Folder | Local check |
| --- | --- |
| shell | `zsh -n shell/mac/topics/<file>.zsh`, `bash -n shell/linux/topics/<file>.sh` and `shellcheck` on the shell files |
| setup/mac-bootstrap | `/bin/bash setup/mac-bootstrap/tests/bootstrap-test.sh` on a Mac |
| setup/linux-bootstrap | `setup/linux-bootstrap/tests/bootstrap-test.sh` on Ubuntu |
| setup/windows-bootstrap | `Invoke-ScriptAnalyzer` and `Invoke-Pester` from that folder, as its README shows |
| setup/defaults | `/bin/bash setup/defaults/tests/mac-defaults-test.sh` on a Mac and the Pester tests on Windows |
| terminal/terminal | `python3 terminal/terminal/scripts/build-themes.py --check` |
| every `editors/` and `apps/` folder with a validator | `python3 <folder>/scripts/validate.py` |
| any Markdown | `npx markdownlint-cli2 "**/*.md"` from the repository root |

Each folder's README and guides say more about how that folder is tested. The full list of CI jobs is
in [.github/ABOUT.md](.github/ABOUT.md).

## Style rules

- **Comments** explain why, not what.
- **No secrets.** Never include tokens, passwords, private keys or personal credentials. See
  [SECURITY.md](SECURITY.md).
- **Folder by folder.** Each tool keeps its own README, guides and screenshots. Do not move files
  between folders without discussing it in the issue first.
- **Screenshots** stay byte for byte as recorded. Add new ones rather than editing existing ones.

## Reporting bugs

Open an issue with the bug report form. It asks which folder, which platform, what you expected and
what happened.

## The shared guide

> [!NOTE]
> I keep one shared contributing guide for all my projects, covering software, hardware, writing and everything in between: [zaccesss/contribute](https://github.com/zaccesss/contribute) or on [my site](https://isaacadjei.me/contribute). This file takes precedence where the two differ.
