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
| `zt current` | The mode zt last set, then each installed tool's own setting read back: which theme, fixed or following the system |
| `zt doctor` | Every installed theme file against the repo copy for the active theme and every tool's own setting against the state, one line per tool. Exits 1 on any drift, so a copy that stopped matching the repo or a tool switched by hand shows up |
| `zt highlight [default]` | The system text highlight again from the active theme's selection colour; `default` puts the system's own highlight back |
| `zt pin <app> <theme>` | Keeps one app on its own theme while every other app follows `zt`. The theme can be a Zacess theme, `auto [dark] [light]` or the app's own built-in theme: `default` (following the system where the app can), `default-dark` or `default-light`. `terminals` in place of the app pins every terminal app at once |
| `zt unpin <app>` | The app follows `zt` again and is switched to the current state straight away. `terminals` unpins every terminal and `--all` every app |
| `zt current terminals` | What each terminal app is on, with its pin. `zt current <app>` shows one app |

Short names: `deep-dark`, `deep-light`, `hc-dark`, `hc-light`, `dark`, `light`, `cream` and `yellow`. `zacess-theme` is the same command under its full name.

| Tool | Fixed theme | `zt auto` |
| --- | --- | --- |
| VS Code | `workbench.colorTheme`, with `window.autoDetectColorScheme` off | `window.autoDetectColorScheme` on with the two preferred themes |
| Zed | `theme` with `mode` set to `dark` or `light` | `theme` with `mode` set to `system` |
| JetBrains IDEs | `options/laf.xml` and `options/colors.scheme.xml`, with Sync with OS off. Only while every IDE is closed and only where the Zacess Themes plugin is installed | Sync with OS on with the two themes |
| Neovim | A state file (`~/.local/state/zacess/theme`, `%LOCALAPPDATA%\zacess\theme` on Windows) that the Neovim config reads at start and on focus | The same file with `auto` and the pair; Neovim checks the system on focus |
| tmux | A link beside the state file (`~/.local/state/zacess/tmux.conf`) to the theme's file in `terminal/tmux/themes`, which `tmux.conf` sources; a running server takes it at once | Not supported by tmux: the theme matching the system at that moment |
| Eclipse | The theme's `.epf` merged into `~/eclipse-workspace`, with the matching Light or Dark workbench theme. Only while Eclipse is closed | Not supported by Eclipse: the theme matching the system at that moment |
| STM32CubeIDE | The same as Eclipse, in the newest `~/STM32CubeIDE/workspace_<version>`. Only while STM32CubeIDE is closed | Not supported by STM32CubeIDE: the theme matching the system at that moment |
| Terminal.app | The default profile plus every open tab on a Zacess profile | A login agent that switches the profile with the system |
| iTerm2 | The default profile | A "Zacess Auto" profile with separate light and dark colours |
| Kitty | The `include` line in `kitty.conf` | `dark-theme.auto.conf` and `light-theme.auto.conf`, which Kitty follows |
| Alacritty | The `import` line in `alacritty.toml` | Not supported by Alacritty: the theme matching the system at that moment |
| Ghostty | `theme =` in its config | `theme = light:...,dark:...` |
| Ptyxis (Linux) | The default profile's palette (`zacess-<id>`, from `~/.local/share/org.gnome.Ptyxis/palettes`) and the matching light or dark style | Not supported with one palette per theme: the theme matching the system at that moment |
| Windows Terminal | `profiles.defaults.colorScheme` set to one scheme | `colorScheme` as a dark and light pair |
| The system text highlight | macOS `AppleHighlightColor`, the selection of the installed KDE Plasma colour schemes, the GTK named colours on GNOME or `Hilight` and `HilightText` under `Control Panel\Colors` on Windows (read at the next sign in), all from the theme's selection colour in the generated terminal theme: iTerm2's profile on the Mac, Kitty's file on Linux, the Windows Terminal scheme on Windows. The value found first is recorded for `zt highlight default` | Not supported: the theme matching the system at that moment |
| KiCad, Processing, Nextpad++, Vivado, Arduino IDE, Thonny, MATLAB, LTspice, Zotero and Obsidian | Each app's own `apply.sh` in `editors/` or `apps/` (`apply.ps1` on Windows, which also covers Notepad++ and Proteus; Microchip Studio is left to its own script), so `zt` writes exactly what a fresh setup does. Only while the app is closed. Obsidian is switched only when `OBSIDIAN_VAULT` names the vault | Not supported by these apps: the theme matching the system at that moment |

## Pins

A pin keeps one app on its own theme while `zt <theme>`, `zt auto`, `zt undo` and `zt sync` switch everything else. Pins live in a `pins` file beside the state file (`~/.local/state/zacess/pins`, `%LOCALAPPDATA%\zacess\pins` on Windows), one app per line followed by its value. Both versions of `zt` read the same format:

```text
iterm2 cream
neovim default-light
terminal auto deep-contrast-dark deep-contrast-light
```

| App | `default`, `default-dark` and `default-light` |
| --- | --- |
| `vscode` (VS Code) | Default Dark Modern and Default Light Modern, following the system for `default` |
| `zed` | One Dark and One Light, following the system for `default` |
| `jetbrains` | `default` only: no theme named and Sync with OS on, so each IDE uses its own pair |
| `neovim` | Neovim's built-in `default` scheme, with the background following the system, dark or light. Neovim reads the pin itself |
| `terminal` (Terminal.app) | `default` only: the Basic profile, which follows the system |
| `iterm2` | `default` only: iTerm2's own Default profile |
| `ghostty` | Builtin Dark and Builtin Light, following the system for `default` |
| `kitty`, `alacritty` | `default` only: the Zacess include or import is removed, leaving the terminal's own colours |
| `tmux` | `default` only: the theme link is removed and a running server forgets the theme's colours |
| `ptyxis` (Linux) | The GNOME palette, following the desktop for `default` |
| `windows-terminal` (Windows) | The Campbell and One Half Light schemes, following Windows for `default` |
| `highlight` | `default` only: the system's own highlight, as `zt highlight default` |

The Eclipse family and the apps with an apply script (KiCad, Processing, Nextpad++, Vivado, Arduino IDE, Thonny, MATLAB, LTspice, Zotero, Obsidian, Notepad++, Proteus and Microchip Studio) can be pinned to a Zacess theme or `auto` only: `zt pin` says so rather than guess at their built-in theme. Warp is set by hand, so it cannot be pinned. `zt current` lists every pin and marks each pinned tool. `zt doctor` counts a pinned tool as matching.

`termtheme` is the terminals-only front end: `termtheme <theme>` runs `zt pin terminals <theme>`, `termtheme auto` and `termtheme default` pin the terminals to the system or to their own themes, `termtheme follow` runs `zt unpin terminals` and `termtheme` on its own runs `zt current terminals`. `termtheme dark` and `termtheme light` keep their earlier meaning, the Zacess Deep Contrast pair; `zacess-dark` and `zacess-light` reach the themes `zt` calls `dark` and `light`.

A tool that is not installed is skipped and the output says so. Warp is set by hand under Settings > Appearance > Themes. The Ghostty and tmux theme files come from `terminal/terminal/<os>/ghostty` and `terminal/tmux/themes`, both generated from the terminal palette. The theme files themselves come from the Zacess extension, plugin and theme files that [vscode](../../editors/vscode), [jetbrains](../../editors/jetbrains), [zed](../../editors/zed) and [terminal](../../terminal/terminal) install. Eclipse's are read from the [eclipse](../../editors/eclipse) folder's `theme` folder in the same clone unless `ZT_ECLIPSE_THEMES` names another folder. `ZT_ECLIPSE_WORKSPACE` picks another workspace. STM32CubeIDE's themes come from [stm32cubeide](../../editors/stm32cubeide) the same way, with `ZT_STM32_THEMES` and `ZT_STM32_WORKSPACE` in their place.
