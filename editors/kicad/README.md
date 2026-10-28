# kicad

KiCad colour themes: the eight Zacess themes for the schematic, symbol, PCB, footprint, GerbView and 3D viewer canvases, built from the Zacess palette and switched with one script on every platform.

KiCad keeps each colour theme as a JSON file in the `colors` folder of its settings and names it by the file's stem. Each editor picks its theme separately, with `appearance.color_theme` in its own settings file (`eeschema.json`, `pcbnew.json`, `fpedit.json`, `symbol_editor.json`, `gerbview.json`, `3d_viewer.json` and the rest). The apply scripts install all eight themes and point every editor at one of them.

## What it sets

| Setting | Value | Why |
| --- | --- | --- |
| `<config>/colors/zacess-*.json` | The eight Zacess themes | All eight show under **Preferences > Colors** in every editor |
| `appearance.color_theme` | `zacess-deep-contrast-dark` | The default theme in each editor. `--theme` (`-Theme` on Windows) picks any of the eight |

Nothing else in KiCad's settings changes.

KiCad has no setting for the font of its menus, panels or canvas text: the interface uses the system font and the canvas draws its own stroke font. The schematic editor's **Default font** (`appearance.default_font`) is the font new text in a schematic is saved with, so it is part of the design rather than the editor and is left as it is. Geist Mono therefore has nowhere to go in KiCad.

## The themes

[`scripts/build-themes.py`](scripts/build-themes.py) builds [`shared/colors/`](shared/colors/) from the palette of [Zacess Themes](https://github.com/zacesshq/themes) 0.5.0, downloaded and checked against its SHA-256 digest. Every colour key KiCad 10 reads is written, so a light theme never falls back to KiCad's dark defaults.

| Part | Colours |
| --- | --- |
| Schematic | Wires and junctions in the string colour, buses and no-connects in the keyword colour, symbol outlines and pins in the control colour, references, values and pin names in the type colour, notes in the comment colour |
| Board | Top copper red and bottom copper blue as in KiCad's own themes, inner layers green, cyan, magenta and yellow, board edges in the text colour, silkscreen in the function and control colours |
| GerbView | Layers cycle through the twelve terminal colours of each theme |
| 3D viewer | Only the background follows the theme; the board, copper and mask keep KiCad's realistic colours |

The board and GerbView colours come from each theme's terminal colours, taking whichever copy of a hue stands out more on that background.

## Where the settings live

| Platform | Folder |
| --- | --- |
| macOS | `~/Library/Preferences/kicad/<version>` |
| Linux | `~/.config/kicad/<version>` |
| Linux (Flathub) | `~/.var/app/org.kicad.KiCad/config/kicad/<version>` |
| Windows | `%APPDATA%\kicad\<version>` |

The scripts use the newest version folder. When `KICAD_CONFIG_HOME` is set they look there instead, as KiCad itself does. `--config-dir` (`-ConfigDir`) points them anywhere else.

## Apply

Quit KiCad and every editor it opened first. KiCad holds its settings in memory and writes every file back on exit, so the scripts refuse to run while any part of it is open.

```bash
mac/apply.sh                  # or linux/apply.sh
mac/apply.sh --theme cream    # another Zacess theme
```

```powershell
pwsh -File windows\apply.ps1
pwsh -File windows\apply.ps1 -Theme cream
```

The scripts print each theme file and settings file as `added`, `changed` or `unchanged`. Running one again changes nothing. When KiCad has never been started there is nothing to change, so the scripts say so and stop without an error. An editor's settings file only exists once that editor has been opened, so an editor used for the first time later starts on KiCad's default: run the script again after that. Nothing is backed up: this folder holds every value the scripts write. `mac/apply.sh` and `linux/apply.sh` are the same file and need `python3`.

`zt` switches KiCad with the other editors on macOS and Linux by running the same script.

## Check it worked

1. Start the Schematic Editor. The canvas is black with green notes, orange wires and a grey drawing sheet in Deep Contrast Dark.
2. **Preferences > Preferences > Schematic Editor > Colors** lists the eight Zacess themes, with Zacess Deep Contrast Dark selected.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks every theme holds every colour key, that schematic text is at least 7:1 on the canvas and on a symbol's fill in the Deep Contrast and High Contrast themes (4.5:1 in the others), that lines, layers and the grid are at least 3:1 and that the two shell scripts match.
