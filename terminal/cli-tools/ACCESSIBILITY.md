# Accessibility

ripgrep, fzf, lazygit and zoxide make a keyboard-first command line with less to type and less to remember. One high-contrast colour scheme covers the tools that draw their own interface.

> [!NOTE]
> Some of these settings are preferences rather than requirements. Change them freely in your own copy. If a change would help other people too, open an issue or a pull request so I can consider it for everyone.

## Vision

| Element | Colours |
| --- | --- |
| fzf text | The terminal's own text on its own background |
| fzf selected line | Bold and reversed |
| fzf matches and pointer | The terminal's yellow, bold |
| lazygit borders and options | The terminal's yellow for the active panel, its own text for the rest |
| lazygit selected line | Reversed |
| Diffs in lazygit | The terminal's green for added lines and red for removed ones, with the exact change bold and reversed |

Every colour is a terminal colour name rather than a fixed value, so fzf, lazygit and their diffs follow the terminal's palette in both light and dark mode. Their contrast is the terminal's own; the High Contrast palette in [terminal](../terminal) keeps every colour at 7:1 or more in light mode. Selection is shown by reversing the line, never by colour alone. Diffs stay on one screen with paging off.

## Typing and memory

- fzf finds a file from any fragment of its name, so exact paths never need typing.
- zoxide jumps to a directory from part of its name, learning from the folders actually visited.
- ripgrep uses smart case: a lowercase search matches any case, while a capital letter makes it exact.
- lazygit moves with `h`, `j`, `k` and `l`, the same keys as [neovim](../../editors/neovim) and [tmux](../tmux).

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.

## The shared statement

> [!NOTE]
> I keep one shared accessibility statement for all my projects: [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on [my site](https://isaacadjei.me/accessibility). This file takes precedence where the two differ.
