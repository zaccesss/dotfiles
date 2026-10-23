# microchip-studio

Microchip Studio 7 fonts and colours: the eight Zacess themes converted for it, with Geist Mono in the editor and the output windows.

Microchip Studio (formerly Atmel Studio) is the Visual Studio 2015 shell with Microchip's AVR and SAM tools. It is Windows only. On macOS and Linux the route is MPLAB X, which is not set up here yet.

## What it sets

| Item | Value | Why |
| --- | --- | --- |
| Font | `GeistMono NF`, 14 points | Geist Mono's Nerd Font build. Windows looks fonts up by their GDI family name, which Nerd Fonts shortens to `GeistMono NF`; the long name would fall back to another font |
| Font in the output windows | the same | Output, Find Results, Command and Immediate windows read like the editor |
| Environment theme | Dark for the dark themes, Light for the light ones | The window chrome follows the editor |
| Editor colours | from the Zacess VS Code theme | Plain text, selection, current line, line numbers, keywords, comments, strings, numbers and operators |
| C colours | from the same theme | Visual Assist, which ships with Microchip Studio, colours macros and enums, methods, types and variables. Directives and macros take the colour of control keywords, which every theme keeps apart from functions and plain keywords |

Comments are not italic: Visual Studio 2015 has no italic style.

## The themes

[`themes/`](themes/) holds one `.vssettings` file per Zacess theme, built by [`scripts/build-themes.py`](scripts/build-themes.py) from the Zacess Themes `.vsix`. Each file holds only the Fonts and Colors category, so importing it changes nothing else. Rebuild after a Zacess Themes release:

```bash
python scripts/build-themes.py zacess-themes-0.4.0.vsix
```

## Apply

Quit Microchip Studio first, then from PowerShell 7:

```powershell
pwsh -File windows\apply.ps1                 # Zacess Deep Contrast Dark
pwsh -File windows\apply.ps1 -Theme cream    # another Zacess theme
```

Microchip Studio only takes colours through its own **Import and Export Settings** command. The script starts Studio with that command and the chosen theme, waits until Studio reports the matching environment theme. Studio stays open. The fonts and colours are saved when it exits. The import cannot take a path with spaces, which is why the theme is copied to a temporary path first. That copy stays until Studio has closed, since Studio can still be reading it after it reports the theme. The next run clears any copy left behind. Nothing is backed up: this folder holds every value it imports.

`-Studio` points the script at another `AtmelStudio.exe` than `C:\Program Files (x86)\Atmel\Studio\7.0\AtmelStudio.exe`.

## Its projects folder

New projects go in `~\dev\projects\avr`, the projects folder every editor shares on every machine. The script writes Studio's `DefaultNewProjectLocation` and `VisualStudioProjectsLocation` before it starts Studio and makes the folder when it is missing. The folder Studio opens projects from is left as it is.

## Check it worked

1. **Tools > Options > Environment > Fonts and Colors** shows `GeistMono NF` at 14 for the text editor.
2. A C file shows keywords bold blue, macros and `#define` pink, functions yellow, strings orange and comments green in Deep Contrast Dark.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. Every theme must parse, hold only the Fonts and Colors category, use `GeistMono NF`, carry the editor and Visual Assist items and name the matching environment theme.
