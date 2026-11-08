# tmux

> tmux config with vi-style copy mode and pane navigation, a plain high-contrast status bar and
> TPM plugins for session persistence across restarts.

## In action

The whole setup in one session, in Zacess Deep Contrast Dark or Light to match the system
theme. The shot links to a short animation of it.

<a href="docs/demo/hero-dark.gif"><picture><source media="(prefers-color-scheme: light)" srcset="docs/demo/hero-light.webp"><source media="(prefers-color-scheme: dark)" srcset="docs/demo/hero-dark.webp"><img src="docs/demo/hero-dark.webp" alt="A tmux session in Zacess Deep Contrast, dark or light to match the system theme. Neovim runs across the top, its file tree listing the Zacess Scenes Lua files beside build-passed.lua open in the editor. Along the bottom, from left to right: a shell showing a five-line git log and a build that passed, btop with CPU load and network traffic, then the harbour scene from Zacess Scenes playing in the same theme"></picture></a>

Screenshots in four Zacess themes, Deep Contrast Dark and Light, Yellow on Black and Cream,
recorded in a demo project. Each one links to a short animation of the same scene.

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

- **[`tmux.conf`](tmux.conf)** - the full config: tmux's default `Ctrl-b` prefix, vi-style copy
  mode and pane navigation, a status bar in the terminal's own colours and TPM-managed plugins that save and restore
  sessions across a restart.
- **`themes/zacess-*.conf`** - one file per Zacess theme, generated from the terminal palette by
  `terminal/terminal/scripts/build-themes.py`: the status bar in the theme's text and background,
  the message line in its accent pair, copy mode in its selection pair, search matches in its find
  colour and the pane borders in two colours. `zt <theme>` links the active one to
  `~/.local/state/zacess/tmux.conf`, which `tmux.conf` sources. `zt doctor` checks it.

## Setup

Full walkthrough in [guides/setup.md](guides/setup.md): install tmux and TPM, copy the config,
install the plugins, start a session.

> [!IMPORTANT]
> tmux has no native Windows build, since it depends on POSIX pty support Windows does not have.
> On Windows the config only works inside WSL.

## Structure

| Path | Contents |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | The high-contrast status bar and short, consistent bindings |
| [`tmux.conf`](tmux.conf) | Installs to `~/.tmux.conf` on macOS, Linux and inside WSL |
| [`themes/`](themes/) | One generated theme file per Zacess theme, linked into place by `zt` |
| [`guides/`](guides/) | Setup walkthrough and full reference |
