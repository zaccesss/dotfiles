# neovim

> Neovim config in pure Lua: lazy.nvim, LSP through Mason, treesitter, Telescope, completion and
> a small set of vi-style keymaps.

## In action

Screenshots in four Zacess themes, Deep Contrast Dark and Light, Yellow on Black and Cream,
recorded in a demo project. Each one links to a short animation of the same scene.

### Neovim

| Deep Contrast Dark | Deep Contrast Light |
| --- | --- |
| [![Dark: Neovim with the high-contrast colour scheme, drawn in the terminal's Zacess Deep Contrast colours, editing a Python file, with relative line numbers and the status line at the bottom](docs/demo/neovim-dark.webp)](docs/demo/terminal-dark.gif) | [![Light: Neovim with the high-contrast colour scheme, drawn in the terminal's Zacess Deep Contrast colours, editing a Python file, with relative line numbers and the status line at the bottom](docs/demo/neovim-light.webp)](docs/demo/terminal-light.gif) |

| Yellow on Black | Cream |
| --- | --- |
| [![Yellow on Black: Neovim with the high-contrast colour scheme, drawn in the terminal's Zacess Yellow on Black colours, editing a Python file, with relative line numbers and the status line at the bottom](docs/demo/neovim-yellow-on-black.webp)](docs/demo/terminal-yellow-on-black.gif) | [![Cream: Neovim with the high-contrast colour scheme, drawn in the terminal's Zacess Cream colours, editing a Python file, with relative line numbers and the status line at the bottom](docs/demo/neovim-cream.webp)](docs/demo/terminal-cream.gif) |

The shots show the real config in a throwaway demo project, in
[Zacess Themes](https://github.com/zacesshq/themes) Deep Contrast Dark and Light, Yellow on Black
and Cream.

## What's here

- **[`nvim/`](nvim/)** - the full config. It is pure Lua with no OS-specific paths, so it is
  identical on every platform. `init.lua` loads core options and keymaps, then bootstraps
  `lazy.nvim`, which reads every file under `lua/plugins/`.
- **[`nvim/lazy-lock.json`](nvim/lazy-lock.json)** - the exact plugin commit each spec resolved
  to, so a fresh install gets the same versions rather than whatever is newest that day.
- **`.gitattributes`** - keeps `nvim/lazy-lock.json` on LF line endings, so a Windows checkout
  does not show it as modified after each plugin sync.

## Setup

Full walkthrough in [guides/setup.md](guides/setup.md): install Neovim, copy `nvim/` to your
config path, launch once to let `lazy.nvim` install everything.

## Structure

| Path | Contents |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | The high-contrast theme, readable layout and short key sequences |
| [`nvim/`](nvim/) | The config. Installs to `~/.config/nvim/` on macOS and Linux, `%LOCALAPPDATA%\nvim\` on Windows |
| [`guides/`](guides/) | Setup walkthrough and full reference |
