# Accessibility

The config favours a readable screen and short, consistent key sequences. Every binding is listed in [guides/reference.md](guides/reference.md).

> [!NOTE]
> Some of these settings are preferences rather than requirements. Change them freely in your own copy. If a change would help other people too, open an issue or a pull request so I can consider it for everyone.

## Vision

- The colour scheme is `high-contrast` (`colors/high-contrast.lua`). Every colour in it is one of the terminal's own 16, so Neovim shows exactly the terminal's palette and follows it between light and dark mode.
- Meaning never rests on colour alone. Selection, search matches, the status line mode block and menus use reverse video. Keywords and errors are bold. Diagnostics are underlined in the text.
- Absolute and relative line numbers are both shown, so a motion such as `5j` needs no counting by eye.
- The sign column is always reserved, so diagnostics never push the text sideways.
- The current line is marked across the text and its line number (`cursorline`), so the cursor is never the only sign of where the edit is.
- Git changes carry a sign shape as well as a colour: `+` added, `~` changed, `_` deleted (`‾` at the top of the file, `~_` for a change next to a deletion) and `┆` untracked, with the line number coloured too. gitsigns' own signs draw the same bar for an addition and a change.
- Eight lines of context stay visible above and below the cursor. Half-page jumps keep the cursor centred.

> [!IMPORTANT]
> The colour scheme is only as clear as the terminal's own palette, since it draws with the terminal's 16 colours (`termguicolors` is off). The High Contrast profile in [terminal](../../terminal/terminal) is designed for it. Any palette whose colours read well on its background works too.

## Keyboard and motor

- The leader key is Space, the largest key on the keyboard.
- `j k` leaves insert mode without reaching for Esc.
- `Ctrl+H`, `Ctrl+J`, `Ctrl+K` and `Ctrl+L` move between windows, the same letters [tmux](../../terminal/tmux) uses for panes.
- The mouse works in every mode.
- Search uses smart case: lowercase matches any case, a capital letter makes it exact.
- The system clipboard is shared with every other app.

## Adjusting it

- Multi-key bindings wait 300 ms for the next key. Raise `timeoutlen` in `lua/config/options.lua` if sequences feel rushed.
- Long lines do not wrap. Set `opt.wrap = true` for larger fonts on a narrow screen.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.

## The shared statement

> [!NOTE]
> I keep one shared accessibility statement for all my projects: [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on [my site](https://isaacadjei.me/accessibility). This file takes precedence where the two differ.
