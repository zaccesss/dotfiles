# scripts/

Standalone helper scripts that can be run from any platform.

| Script | What it does |
| --- | --- |
| `zt.py` | The `zt` theme switcher on macOS and Linux, run by the `zt` and `zacess-theme` functions in the `zacess-theme` topic file. See [Theme switching](#theme-switching) |
| `build-cmd-macros.py` | Writes `windows/cmd/macros.doskey` and the not ported list in `windows/cmd/README.md` from the PowerShell topic files. `--check` reports when they are out of date |
| `games.py` | Terminal games: 2048, Snake, Blocks, Meteors, Word and a typing test |

## Theme switching

`zt` switches every installed editor and terminal to one of the eight Zacess themes at once. Windows has the same command in [`windows/scripts/zt.ps1`](../windows/scripts/zt.ps1), with `zt.cmd` for Command Prompt.

| Command | What it does |
| --- | --- |
| `zt <theme>` | Fixes that theme everywhere and stops following the system. Takes a short name, an id or the full name |
| `zt auto [dark] [light]` | Follows the system light and dark appearance, Zacess Deep Contrast Dark and Light unless two others are named |
| `zt list` | The eight themes and their short names, the current one marked |
| `zt current` | The mode zt last set and what VS Code, Zed and the terminal are on now |

Short names: `deep-dark`, `deep-light`, `hc-dark`, `hc-light`, `dark`, `light`, `cream` and `yellow`. `zacess-theme` is the same command under its full name.

| Tool | Fixed theme | `zt auto` |
| --- | --- | --- |
| VS Code | `workbench.colorTheme`, with `window.autoDetectColorScheme` off | `window.autoDetectColorScheme` on with the two preferred themes |
| Zed | `theme` with `mode` set to `dark` or `light` | `theme` with `mode` set to `system` |
| JetBrains IDEs | `options/laf.xml` and `options/colors.scheme.xml`, with Sync with OS off. Only while every IDE is closed and only where the Zacess Themes plugin is installed | Sync with OS on with the two themes |
| Neovim | A state file (`~/.local/state/zacess/theme`, `%LOCALAPPDATA%\zacess\theme` on Windows) that the Neovim config reads at start and on focus | The same file with `auto` and the pair; Neovim checks the system on focus |
| Eclipse | The theme's `.epf` merged into `~/eclipse-workspace`, with the matching Light or Dark workbench theme. Only while Eclipse is closed | Not supported by Eclipse: the theme matching the system at that moment |
| Terminal.app | The default profile plus every open tab on a Zacess profile | A login agent that switches the profile with the system |
| iTerm2 | The default profile | A "Zacess Auto" profile with separate light and dark colours |
| Kitty | The `include` line in `kitty.conf` | `dark-theme.auto.conf` and `light-theme.auto.conf`, which Kitty follows |
| Alacritty | The `import` line in `alacritty.toml` | Not supported by Alacritty: the theme matching the system at that moment |
| Ghostty | `theme =` in its config | `theme = light:...,dark:...` |
| Windows Terminal | `profiles.defaults.colorScheme` set to one scheme | `colorScheme` as a dark and light pair |

A tool that is not installed is skipped and the output says so. Warp is set by hand under Settings > Appearance > Themes. The theme files themselves come from the Zacess extension, plugin and theme files that [vscode-config](https://github.com/zaccesss/vscode-config), [jetbrains-config](https://github.com/zaccesss/jetbrains-config), [zed-config](https://github.com/zaccesss/zed-config) and [terminal-config](https://github.com/zaccesss/terminal-config) install. Eclipse's are read from an [eclipse-config](https://github.com/zaccesss/eclipse-config) clone at `~/.eclipse-config-src/theme` unless `ZT_ECLIPSE_THEMES` names another folder. `ZT_ECLIPSE_WORKSPACE` picks another workspace.
