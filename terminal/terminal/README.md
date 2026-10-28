# terminal

> The eight Zacess colour themes for Terminal.app, iTerm2, Windows Terminal, Ptyxis, GNOME
> Terminal, Alacritty, Kitty and Hyper, with Zacess Deep Contrast Dark as the default, plus starter
> configs with per-platform fonts.

## In action

Screenshots in four Zacess themes, Deep Contrast Dark and Light, Yellow on Black and Cream,
recorded in a demo project. Each one links to a short animation of the same scene.

### Shell

| Deep Contrast Dark | Deep Contrast Light |
| --- | --- |
| [![Dark: the shell showing a coloured git log, a ripgrep search and a diff summary in a demo project](docs/demo/shell-dark.webp)](docs/demo/terminal-dark.gif) | [![Light: the shell showing a coloured git log, a ripgrep search and a diff summary in a demo project](docs/demo/shell-light.webp)](docs/demo/terminal-light.gif) |

| Yellow on Black | Cream |
| --- | --- |
| [![Yellow on Black: the shell showing a coloured git log, a ripgrep search and a diff summary in a demo project](docs/demo/shell-yellow-on-black.webp)](docs/demo/terminal-yellow-on-black.gif) | [![Cream: the shell showing a coloured git log, a ripgrep search and a diff summary in a demo project](docs/demo/shell-cream.webp)](docs/demo/terminal-cream.gif) |

### Neovim

| Deep Contrast Dark | Deep Contrast Light |
| --- | --- |
| [![Dark: Neovim with the Zacess colour scheme editing a Python file, with relative line numbers and the status line at the bottom](docs/demo/neovim-dark.webp)](docs/demo/terminal-dark.gif) | [![Light: Neovim with the Zacess colour scheme editing a Python file, with relative line numbers and the status line at the bottom](docs/demo/neovim-light.webp)](docs/demo/terminal-light.gif) |

| Yellow on Black | Cream |
| --- | --- |
| [![Yellow on Black: Neovim with the Zacess colour scheme editing a Python file, with relative line numbers and the status line at the bottom](docs/demo/neovim-yellow-on-black.webp)](docs/demo/terminal-yellow-on-black.gif) | [![Cream: Neovim with the Zacess colour scheme editing a Python file, with relative line numbers and the status line at the bottom](docs/demo/neovim-cream.webp)](docs/demo/terminal-cream.gif) |

### tmux

| Deep Contrast Dark | Deep Contrast Light |
| --- | --- |
| [![Dark: tmux with four coloured tabs named editor, git, search and shell, the editor window split into Neovim, a ripgrep search, a git log and a diff summary](docs/demo/tmux-dark.webp)](docs/demo/tmux-dark.gif) | [![Light: tmux with four coloured tabs named editor, git, search and shell, the editor window split into Neovim, a ripgrep search, a git log and a diff summary](docs/demo/tmux-light.webp)](docs/demo/tmux-light.gif) |

| Yellow on Black | Cream |
| --- | --- |
| [![Yellow on Black: tmux with four coloured tabs named editor, git, search and shell, the editor window split into Neovim, a ripgrep search, a git log and a diff summary](docs/demo/tmux-yellow-on-black.webp)](docs/demo/tmux-yellow-on-black.gif) | [![Cream: tmux with four coloured tabs named editor, git, search and shell, the editor window split into Neovim, a ripgrep search, a git log and a diff summary](docs/demo/tmux-cream.webp)](docs/demo/tmux-cream.gif) |

The shots show the real config in a throwaway demo project, in
[Zacess Themes](https://github.com/zacesshq/themes) Deep Contrast Dark and Light, Yellow on Black
and Cream.

## What's here

Every terminal gets all eight Zacess themes from [Zacess Themes](https://github.com/zacesshq/themes),
with Zacess Deep Contrast Dark as the default: white on pure black with deep, fully saturated
colours. The theme stays fixed whatever the system appearance until it is changed. The colours live
in one file, [`palette/zacess.json`](palette/zacess.json).
[`scripts/sync-palette.py`](scripts/sync-palette.py) copies it from a pinned Zacess Themes release and
[`scripts/build-themes.py`](scripts/build-themes.py) writes every theme file and the tmux theme files from it. Every theme's
colours and how each terminal switches are in [guides/themes.md](guides/themes.md).

| Terminal | macOS | Linux | Windows |
| --- | --- | --- | --- |
| Alacritty | [`mac/alacritty/`](mac/alacritty/) | [`linux/alacritty/`](linux/alacritty/) | [`windows/alacritty/`](windows/alacritty/) |
| Kitty | [`mac/kitty/`](mac/kitty/) | [`linux/kitty/`](linux/kitty/) | not available, Kitty has no Windows build |
| Hyper | [`mac/hyper/`](mac/hyper/) | [`linux/hyper/`](linux/hyper/) | [`windows/hyper/`](windows/hyper/) |
| Terminal.app | [`mac/terminal-app/`](mac/terminal-app/) | not available | not available |
| iTerm2 | [`mac/iterm2/`](mac/iterm2/) | not available | not available |
| Ptyxis and GNOME Terminal | not available | [`linux/ptyxis/`](linux/ptyxis/), [`linux/gnome-terminal/`](linux/gnome-terminal/) | not available |
| Windows Terminal | not available | not available | [`windows/windows-terminal/`](windows/windows-terminal/) |

## Setup

Full walkthrough in [guides/setup.md](guides/setup.md), with the install path for each terminal
on each platform. Palette and font choices are explained in [guides/reference.md](guides/reference.md).

## Structure

| Path | Contents |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Light and dark contrast, opaque windows and font sizing |
| [`palette/`](palette/) | The eight Zacess themes' terminal colours, the single source for every colour |
| [`scripts/`](scripts/) | `build-themes.py` writes every theme file from the palette and `sync-palette.py` copies the palette from a pinned Zacess Themes release |
| `<platform>/<terminal>/` | That terminal's config file for that platform |
| [`guides/`](guides/) | Setup walkthrough and reference |
