# Accessibility

The config favours a readable screen and short, consistent key sequences. Every binding is listed in [guides/reference.md](guides/reference.md).

> [!NOTE]
> Some of these settings are preferences rather than requirements. Change them freely in your own copy. If a change would help other people too, open an issue or a pull request so I can consider it for everyone.

## Vision

- The colour scheme is `zacess-deep-contrast-dark` from [zacess.nvim](https://github.com/zacesshq/zacess.nvim) 0.6.0: white on pure black with deep, fully saturated colours, every syntax colour at 9:1 or more. All eight Zacess schemes are installed. `lua/config/theme.lua` reads the theme the `zt` command sets, so Neovim switches with the terminal and the other editors; `zt auto` makes it follow the system appearance, checked again whenever Neovim regains focus.
- Running `:colorscheme` by hand keeps that scheme until `:ZacessFollow` hands control back to `zt`.
- Meaning never rests on colour alone. Selection, search matches, the status line mode block and menus use reverse video. Keywords and errors are bold. Diagnostics are underlined in the text.
- Absolute and relative line numbers are both shown, so a motion such as `5j` needs no counting by eye.
- The sign column is always reserved, so diagnostics never push the text sideways.
- The current line is marked across the text and its line number (`cursorline`), so the cursor is never the only sign of where the edit is.
- Git changes carry a sign shape as well as a colour: `+` added, `~` changed, `_` deleted (`‾` at the top of the file, `~_` for a change next to a deletion) and `┆` untracked, with the line number coloured too. gitsigns' own signs draw the same bar for an addition and a change.
- Eight lines of context stay visible above and below the cursor. Half-page jumps keep the cursor centred.

> [!IMPORTANT]
> The Zacess schemes use exact colours, so `termguicolors` is on and the terminal needs true colour support. Without it Neovim rounds each colour to the nearest of 256 and the contrast is no longer what was measured. The earlier `high-contrast` scheme, which draws only with the terminal's 16 colours, stays available through `:colorscheme high-contrast`.

## Keyboard and motor

- The leader key is Space, the largest key on the keyboard.
- `j k` leaves insert mode without reaching for Esc.
- `Ctrl+H`, `Ctrl+J`, `Ctrl+K` and `Ctrl+L` move between windows and on into [tmux](../../terminal/tmux) panes, through vim-tmux-navigator, so one set of keys covers the whole screen.
- The start screen, file tree, lazygit window, indent guides and messages from snacks.nvim take the Zacess colour scheme's colours. Its scrolling, dimming and animations are turned off and the indent guides never animate, so nothing on screen moves by itself.
- Formatting on save only uses a formatter that is installed, a project's own first, so a file's layout never changes in a way the project did not ask for.
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
