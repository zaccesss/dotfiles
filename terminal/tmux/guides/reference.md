# Reference

## Key bindings

`+` means the keys are held together, for example `Ctrl+B` means hold Ctrl and press B. Every
binding below is pressed after the prefix, `Ctrl+B` then the key, unless marked otherwise.
`Ctrl+B` itself is the prefix, tmux's real default, not remapped (see the design notes below).

> [!IMPORTANT]
> `h`/`j`/`k`/`l` and `H`/`J`/`K`/`L` are deliberately two different sets of bindings, not a typo.
> Lowercase moves between panes, a small, frequent action. Shift held with the same letter resizes
> a pane instead, a bigger, less frequent action. `-r` on the resize bindings also
> lets the key repeat without pressing the prefix again each time, holding `H` after one
> `Ctrl+B H` keeps resizing.

| Keys | Action |
| --- | --- |
| `Ctrl+B` then `\|` | Split the pane vertically (left/right) |
| `Ctrl+B` then `-` | Split the pane horizontally (top/bottom) |
| `Ctrl+B` then `h` / `j` / `k` / `l` | Move to the pane left/below/above/right |
| `Ctrl+B` then `H` / `J` / `K` / `L` | Resize the pane left/down/up/right, repeatable |
| `Ctrl+B` then `r` | Reload the config without restarting the session |
| `Ctrl+B` then `f` | A fuzzy list of the project folders; the one picked opens in `ide` (its open session when there is one). Replaces tmux's own find-window on that key |
| `Ctrl+H` / `Ctrl+J` / `Ctrl+K` / `Ctrl+L` (no prefix) | Move to the pane or Neovim split left/below/above/right, through vim-tmux-navigator |
| `Ctrl+B` then `Ctrl+H` / `Ctrl+J` / `Ctrl+K` / `Ctrl+L` | Send that key on to the shell: delete back, new line, cut to the end of the line, clear the screen |
| `Ctrl+B` then `v` (in copy mode) | Start a text selection |
| `Ctrl+B` then `y` (in copy mode) | Copy the selection and exit copy mode |

## Plugins (via TPM)

| Plugin | What it does |
| --- | --- |
| `tmux-plugins/tpm` | The plugin manager itself |
| `tmux-plugins/tmux-sensible` | A widely-used baseline of sane tmux defaults |
| `tmux-plugins/tmux-resurrect` | Saves and restores the full session layout across a restart |
| `tmux-plugins/tmux-continuum` | Auto-saves the session every 15 minutes, restores on tmux start |
| `christoomey/vim-tmux-navigator` | `Ctrl+H/J/K/L` across tmux panes and Neovim splits as one set. The Neovim half is in the Neovim config. Install it once with `Ctrl+B` then `I` |

## The ide layout

`ide` (or `ide <folder>`) opens a project in its own tmux session, named after the folder, with a
dot or colon in the name turned into a dash:

| Window | Pane | Runs |
| --- | --- | --- |
| `editor` (cyan tab) | Top, 70 percent of the height | `nvim .`, with the cursor there |
| `editor` | Bottom left, 65 percent of the width | A shell in the project folder |
| `editor` | Bottom right | `zacess-scenes follow`: calm while the shell's commands work, stormy when one fails, TYPO for a mistyped command. Left out without Zacess Scenes |
| `git` (green tab) | The whole window | `lazygit`, only for a git repository with lazygit installed |

Running `ide` again for a folder whose session is open goes back to it. Inside tmux it switches
to the session, outside it attaches. `Ctrl+B` then `f` lists every folder in `IDE_ROOTS` (folders
separated by colons, `~/dev/github/repos` by default) with fzf and opens the one picked.

> [!NOTE]
> With vim-tmux-navigator, `Ctrl+H`, `Ctrl+J`, `Ctrl+K` and `Ctrl+L` move between panes even in a
> shell pane, where readline would otherwise use them. Press the prefix first to send one to the
> shell, for example `Ctrl+B` then `Ctrl+L` to clear the screen.

## Settings

- Mouse support on, so a pane can be clicked into or resized with the mouse.
- Windows and panes are numbered from 1, not 0, matching how they are counted on the status bar.
- `escape-time` set to 10ms instead of tmux's default 500ms, so Neovim inside a pane never lags
  behind an Esc keypress.
- True colour (`Tc`) forced on for every pane, so Neovim's own colourscheme renders correctly
  inside tmux, not a degraded 256-colour approximation.
- `pane-border-indicators both`, so the active pane carries arrows in its border as well as its
  own border colour.
- The theme file linked to `~/.local/state/zacess/tmux.conf` by `zt` is sourced last, with
  `source-file -q` so a missing link is silent. Each `themes/zacess-*.conf` sets `status-style`,
  `message-style` and `message-command-style` (the accent pair, bold), `mode-style` (the selection
  pair), `copy-mode-match-style` and `copy-mode-current-match-style` (the find colour, the current
  match bold and underlined), `pane-border-style` and `pane-active-border-style` (two border
  colours), the `display-panes` colours and `clock-mode-colour`.

## Design notes

- **Why is the prefix still Ctrl-b instead of the more common Ctrl-a remap?** Most shells already
  bind every Ctrl-letter combo through readline. Ctrl-a is beginning-of-line and Ctrl-b is
  backward-char, so moving the prefix does not remove a collision, it only swaps which readline
  binding gets shadowed inside a tmux pane. There was nothing to gain by breaking the default
  every tmux tutorial teaches.
- **Why does the status bar use the terminal's own colours instead of a themed colour scheme?** It
  follows whatever the terminal shows, so it stays high contrast in both light and dark mode. The
  current window is bold and reversed so it stands out in either. The High Contrast palette in
  [terminal](../../terminal) is one pairing that switches with
  the system appearance.
