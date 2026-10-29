# Notice

Copyright (c) 2026 Isaac Adjei ([isaacadjei.me](https://isaacadjei.me))

## Licences

This repository is licensed under the MIT licence. See [LICENSE](LICENSE).

The three bootstraps are the exception. [setup/mac-bootstrap](setup/mac-bootstrap),
[setup/linux-bootstrap](setup/linux-bootstrap) and [setup/windows-bootstrap](setup/windows-bootstrap)
are licensed under the Apache License 2.0, each with its own `LICENSE` and `NOTICE.md`.

## Third-party credits

Nothing below is bundled in this repository. Each one is installed, downloaded or followed at run
time and stays under its own licence. The generated theme files in the editor folders are built
from the Zacess palette. Where a build reads an app's own file to learn which styles exist, only
the list of style names and slots is followed.

| Material | Where it is used | Credit |
| --- | --- | --- |
| Zacess Themes | The eight colour themes in every terminal, editor and IDE folder. The KiCad, Processing, Nextpad++, Vivado, Notepad++, Thonny, MATLAB, LTspice, Proteus and Microchip Studio themes are built from its palette. Zed's theme file in `editors/zed/shared/themes` is the one Zacess Themes 0.5.0 ships for Zed, copied as released. The JetBrains IDEs get the Zacess Themes plugin from the JetBrains Marketplace. When an IDE's launcher cannot be found they get it from a pinned release checked against its digest | [zacesshq/themes](https://github.com/zacesshq/themes) |
| Geist Mono and Nerd Fonts | The terminal and editor font; the Windows bootstrap downloads the Nerd Fonts build of Geist Mono | [Geist](https://github.com/vercel/geist-font) by Vercel and [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts), both under the SIL Open Font License |
| Starship | The prompt in the [shell](shell) folder | [starship/starship](https://github.com/starship/starship) |
| zsh-syntax-highlighting | Typed-command colours in the zsh profiles | [zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) |
| Community dotfiles | The ideas behind the helpers in `shell/mac/topics/08-community.zsh` and its Linux and Windows twins | The dotfiles of Mathias Bynens, Zach Holman and thoughtbot |
| lazy.nvim and the Neovim plugins | Installed by the [neovim](editors/neovim) config at the versions in `lazy-lock.json` | [folke/lazy.nvim](https://github.com/folke/lazy.nvim) and each plugin's own authors |
| Tmux Plugin Manager | Installs the [tmux](terminal/tmux) plugins | [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) |
| Toshy | Mac-style keys in a Linux VM, installed by the linux-bootstrap `mac-keys` extra | [RedBearAK/toshy](https://github.com/RedBearAK/toshy) |
| Rectangle | The [rectangle](apps/rectangle) config follows the shape of Rectangle's own config file | [rxhanson/Rectangle](https://github.com/rxhanson/Rectangle) |
| Breeze and Plasma's panel artwork | The Zacess Dark Plasma style, built from the installed Breeze Dark by [plasma-style.sh](setup/defaults/linux/kde/plasma-style.sh); the KDE global themes copy Breeze's previews and splash at run time | The KDE Visual Design Group, [plasma/libplasma](https://invent.kde.org/plasma/libplasma) under LGPL-2.0-or-later |
| Menu11 - Next | The centred start menu, installed by [menu11.sh](setup/defaults/linux/kde/menu11.sh) from its pinned release | [Eisteed/menu-11-next](https://github.com/Eisteed/menu-11-next), from Menu 11 by adhec, under GPL-2.0-or-later |
| OneDrive Client for Linux and OneDriveGUI | The OneDrive sync and its tray icon in [apps/onedrive](apps/onedrive) | [abraunegg/onedrive](https://github.com/abraunegg/onedrive) and [bpozdena/OneDriveGUI](https://github.com/bpozdena/OneDriveGUI), both under GPL-3.0 |
| KiCad | The [kicad](editors/kicad) themes follow KiCad's own colour theme format and keep its copper colours | [KiCad](https://www.kicad.org) |
| Processing | The [processing](editors/processing) themes follow the `theme.txt` format of Processing's built-in theme | [processing/processing4](https://github.com/processing/processing4) |
| Notepad++ stylers model | The [notepad-plus-plus](editors/notepad-plus-plus) and [nextpad-plus-plus](editors/nextpad-plus-plus) builds read the language and style list from Notepad++'s `DarkModeDefault.xml` and the `stylers.model.xml` that ships with Nextpad++ | [notepad-plus-plus/notepad-plus-plus](https://github.com/notepad-plus-plus/notepad-plus-plus) |
| Thonny plugin API | The [thonny](editors/thonny) plugin registers its themes through Thonny's plugin API and builds on Thonny's Clean themes | [thonny/thonny](https://github.com/thonny/thonny) |
| Dracula for Vivado and LTspice | The published Dracula themes show which entry is a background, a line or text in the [vivado](editors/vivado) and [ltspice](editors/ltspice) themes | [dracula/vivado](https://github.com/dracula/vivado) and [Dracula for LTspice](https://draculatheme.com/ltspice) |
| Style Settings | The [obsidian](apps/obsidian) setup picks the Zacess variant through this Obsidian plugin | [mgmeyers/obsidian-style-settings](https://github.com/mgmeyers/obsidian-style-settings) |

## Bundled third-party file

One file in this repository comes from someone else. `editors/matlab/shared/base/scheme-template.json`
is the colour scheme template from MathWorks' [Color Theme Extensions](https://github.com/mathworks/matlab-color-theme-extensions)
add-on, kept unchanged so the MATLAB build fills in the same colour names the add-on's `import_scheme`
reads. It is Copyright (c) 2025, The MathWorks, Inc. under the BSD 3-Clause licence, whose full text
sits beside it in [`LICENSE.txt`](editors/matlab/shared/base/LICENSE.txt). The add-on's own code is
not bundled: the MATLAB apply scripts download it at a pinned commit and check it against its digests.

## Trademarks

Product names such as macOS, Windows, Ubuntu, Visual Studio Code, JetBrains, Eclipse, STM32CubeIDE,
Xcode, Arduino, Microchip Studio, KiCad, Vivado, Processing, Notepad++, Nextpad++, Thonny, MATLAB,
LTspice, Proteus, Obsidian, Zotero, Raycast and GitHub belong to their respective owners. They are named here only to say which
tool a config is for.
