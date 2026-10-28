# Accessibility

The bindings keep tmux's defaults where tutorials rely on them and shorten the actions used most. The status bar is plain and high contrast.

> [!NOTE]
> Some of these settings are preferences rather than requirements. Change them freely in your own copy. If a change would help other people too, open an issue or a pull request so I can consider it for everyone.

## Vision

- The status bar uses the terminal's own background and text colours, so its contrast is the terminal's own in both light and dark mode. Each window name has its own colour (editor cyan, git green, search yellow, shell magenta, anything else blue). The current window is a solid block of its colour, bold and marked with `*`, so it is never told apart by colour alone.
- True colour is forced on for every pane, so Neovim's colour scheme keeps its intended contrast inside tmux.
- The active pane is marked by arrows in its border (`pane-border-indicators both`) and by a border colour of its own, so it is never told apart by colour alone.
- Copy mode, search matches, the message line and the pane borders take their colours from the active Zacess theme through the theme file `zt` links in, so they keep the theme's contrast instead of tmux's defaults (black on yellow, which is unreadable on the light themes). Without the link tmux keeps the terminal's own colours.
- Windows and panes are numbered from 1, matching how they are counted on the status bar.

## Keyboard and motor

- The prefix stays at tmux's default `Ctrl+B`, so every tutorial and cheat sheet still applies.
- `h`, `j`, `k` and `l` move between panes, the same letters [neovim](../../editors/neovim) uses for windows.
- Resizing with `H`, `J`, `K` and `L` repeats while the key is held, without pressing the prefix again each time.
- `|` and `-` split panes, matching the shape of the split.
- Mouse support is on, so a pane can be clicked into or resized by dragging instead of with a key chord.
- Esc reacts after 10 ms rather than 500 ms, so it never lags in Neovim.
- Sessions save every 15 minutes and come back after a restart, so a layout never has to be rebuilt by hand.

> [!IMPORTANT]
> Session saving and restore come from the tmux-resurrect and tmux-continuum plugins, installed through TPM with `Ctrl+B` then `I` once the config is in place, see [guides/setup.md](guides/setup.md). Until then a restart loses the layout.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.

## The shared statement

> [!NOTE]
> I keep one shared accessibility statement for all my projects: [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on [my site](https://isaacadjei.me/accessibility). This file takes precedence where the two differ.
