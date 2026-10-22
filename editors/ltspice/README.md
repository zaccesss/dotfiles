# ltspice

LTspice colours: the Zacess themes in the schematic, the waveform viewer and the netlist.

## What it sets

LTspice keeps every colour in the `[Colors]` section of its ini file as a Windows colour number (`0x00BBGGRR` written in decimal). Each Zacess theme in [`shared/themes`](shared/themes) sets the same entries:

| Entries | Take |
| --- | --- |
| `SchematicColor12`, `WaveColor0`, `NetlistBackgroundColor` | The theme's background |
| `WaveColor1` and netlist text | The theme's text colour |
| `SchematicColor0` to `SchematicColor13` | The theme's keyword, function, type and comment colours, with selection and focus for highlights |
| `Grid` and `InActiveAxis` | The theme's dim colour |
| `WaveColor2` to `WaveColor13` (the traces) | The theme's terminal colours, so traces stay distinct |

The roles follow the widely used Dracula theme for LTspice. [`scripts/build-themes.py`](scripts/build-themes.py) builds the files from the Zacess Themes `.vsix`. LTspice has no font setting beyond sizes, so fonts are left alone.

## Where the settings live

| Platform | File |
| --- | --- |
| Windows | `%APPDATA%\LTspice.ini` (`LTspiceXVII.ini` from older versions) |
| Linux | The same file inside the Wine prefix, `~/.wine/drive_c/users/<you>/AppData/Roaming` |
| macOS | No ini: the native app (LTspice 17 for macOS) keeps its colours in its preferences, `com.analog.LTspice.App` |

The macOS app uses the same Windows colour numbers under slightly different names. [`mac/apply.sh`](mac/apply.sh) reads the same theme files and translates them: `Grid` becomes `GridColor`, `InActiveAxis` becomes `InActiveAxisColor` and the five netlist colours become `NetlistEditorColor0` to `NetlistEditorColor4` (normal text, comments, dot commands, continuation lines and background). `SchematicColor13` has no Mac counterpart and is skipped. The values are written with `defaults`, since the preferences daemon caches the plist file and would overwrite a direct edit.

## Apply

Quit LTspice first: it writes its ini back when it exits, so the scripts refuse to run while it is open. It also has to have been started once.

```powershell
pwsh -File windows\apply.ps1
pwsh -File windows\apply.ps1 -Theme cream
```

```bash
mac/apply.sh
mac/apply.sh --theme cream
linux/apply.sh
linux/apply.sh --theme cream
```

LTspice can write the start of its ini as UTF-16 and the rest as plain bytes, so the scripts replace each colour entry in place and write every other byte back exactly. They print each entry as `added`, `changed` or `unchanged`. Running one again changes nothing. The macOS script prints each preference the same way. Nothing is backed up.

## Check it worked

1. Start LTspice and open a schematic. The background is black in Deep Contrast Dark, with parts, wires and labels in the theme's syntax colours.
2. Run a simulation. The waveform window is black with distinct trace colours.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks all eight themes exist, every line is a colour entry with a 24-bit value and every theme sets the same entries.
