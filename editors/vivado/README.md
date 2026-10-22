# vivado

AMD Vivado text editor setup for Windows and Linux: the eight Zacess themes for HDL, Tcl and constraint files, built from the Zacess palette, with Geist Mono as the editor font.

> [!WARNING]
> None of this has run against a real Vivado install yet. The file names and keys come from AMD's documentation and from a published Vivado theme, listed under [Sources](#sources). Check the result the first time Vivado is installed and fix anything that does not hold.

Vivado keeps every choice made in **Tools > Settings** in one `vivado.xml` and writes it back when it exits. The text editor's colours sit there as `CODE_EDITOR_*` entries under `general_color`, its token colours as one `syntax_style` per token inside a `code_editor_syntax_styles` block for each language and its font as `CODE_EDITOR_FONT`. The apply scripts merge those entries into `vivado.xml` and leave everything else alone: device views, the window layout and the window theme. Vivado has no macOS version, so there is no macOS script.

## What it sets

| Setting in `vivado.xml` | Value | Source |
| --- | --- | --- |
| `general_color/CODE_EDITOR_BACKGROUND`, `_FOREGROUND`, `_CURSOR_COLOR`, `_LINE_HIGHLIGHT`, `_SELECTION_BACKGROUND`, `_FIND_HIGHLIGHT_BACKGROUND`, `_MATCHING_WORD_HIGHLIGHT_BACKGROUND`, `_BREAKPOINT_BACKGROUND` | The theme's editor colours, written as Vivado writes them (hex without leading zeros) | The published theme |
| `general/code_editor_syntax_styles` and its `_Generic`, `_Verilog`, `_VHDL`, `_XDC`, `_Tcl`, `_TSM` and `_SyntaxCheck` copies | Styles 0 to 20 with colours as signed Java ARGB integers | The published theme |
| `general/CODE_EDITOR_FONT` `font_name` | `GeistMono Nerd Font Mono` on Linux, `GeistMono NFM` on Windows | The published theme. Java on Windows knows the font by its short family name |

The font size already in `vivado.xml` is kept. That `vivado.xml` holds the **Tools > Settings** choices and lives in a folder per version comes from AMD's UG893.

## The themes

[`scripts/build-themes.py`](scripts/build-themes.py) builds [`shared/themes/`](shared/themes/) from the palette of [Zacess Themes](https://github.com/zacesshq/themes) 0.4.0, downloaded and checked against its SHA-256 digest. Each theme is a small JSON file holding the editor colours and the 21 syntax styles. The token order follows the jEdit text area Vivado's editor descends from:

| Style | Token | Zacess colour |
| --- | --- | --- |
| 0 | Plain text | foreground |
| 1, 2 | Comments | comment, italic |
| 3, 4 | Strings and other literals | string, number |
| 5 | Labels | attribute |
| 6, 7, 8 | Three keyword sets | keyword (bold), type, control (bold) |
| 9 | Operators | operator |
| 10 | Invalid | invalid, bold |
| 11 | Error underline | error colour |
| 12 to 14 | Marker backgrounds | selection and current line colours |
| 15 to 20 | Extra styles | type, property, string, number, keyword and control, italic |

The meaning of styles 11 to 20 is read from how the published theme and Vivado's defaults use them, so it is the least certain part.

## Where the settings live

| Platform | Folder |
| --- | --- |
| Windows | `%APPDATA%\Xilinx\Vivado\<version>` |
| Linux | `~/.Xilinx/Vivado/<version>` |

The scripts use the newest version folder. `--config-dir` (`-ConfigDir` on Windows) points them anywhere else.

## Apply

Quit Vivado first. It writes `vivado.xml` back on exit, so the scripts refuse to run while it is open. It also has to have been started once, so `vivado.xml` exists.

```bash
linux/apply.sh
linux/apply.sh --theme cream    # another Zacess theme
```

```powershell
pwsh -File windows\apply.ps1
pwsh -File windows\apply.ps1 -Theme cream
```

The scripts print `changed` or `unchanged`. Running one again changes nothing. When Vivado is not installed or has never been started the scripts say so and stop without an error. Nothing is backed up: this folder holds every value the scripts write. The Linux script needs `python3`.

Vivado's window theme (**Tools > Settings > Display**, the Vivado Default or Vivado Light theme) is not touched, since its key is not documented. Pick the one that matches the editor theme by hand.

`zt` switches Vivado with the other editors on Linux by running the same script.

## Check it worked

1. Start Vivado and open a Verilog or VHDL file. The editor is black with bold blue keywords and green comments in Deep Contrast Dark, in Geist Mono.
2. **Tools > Settings > Text Editor > Fonts and Colors** shows the Zacess colours for each language.

If Vivado ignores or rewrites any of these entries, export its own settings from **Tools > Settings**, compare them with `shared/themes/` and fix the build script.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks every theme holds the eight editor colours and styles 0 to 20 in Vivado's formats and that every text style is at least 7:1 on the background, the current line and the selection in the Deep Contrast and High Contrast themes (4.5:1 in the others).

## Sources

- [UG893, Outputs for Environment Configuration](https://docs.amd.com/r/2025.1-English/ug893-vivado-ide/Outputs-for-Environment-Configuration): `vivado.xml` holds **Tools > Settings** and sits in a folder per version under `%APPDATA%\Xilinx` or `~/.Xilinx`
- [UG893, Specifying Text Editor Settings](https://docs.amd.com/r/en-US/ug893-vivado-ide/Specifying-Text-Editor-Settings): the editor's font, colours and per-language styles
- [UG893, Setting Display Themes](https://docs.amd.com/r/2025.1-English/ug893-vivado-ide/Setting-Display-Themes): the window theme
- [Dracula for Vivado](https://github.com/dracula/vivado): a published theme file showing the element names and colour formats
