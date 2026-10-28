# processing

Processing 4 setup: Geist Mono as the editor font plus the eight Zacess themes for the editor, console and toolbar, built from the Zacess palette.

Processing reads a theme as plain `key = value` lines. It loads its built-in theme first and then a `theme.txt` in the sketchbook folder on top, which is how a custom theme works. The apply scripts write the chosen Zacess theme there and set the editor font in `preferences.txt`.

## What it sets

| Setting | Value | Why |
| --- | --- | --- |
| `<sketchbook>/theme.txt` | Zacess Deep Contrast Dark | The default theme. `--theme` picks any of the eight |
| `editor.font.family` | `GeistMono Nerd Font Mono` | Geist Mono, the font every editor uses |

Every other line of `preferences.txt` stays as it was, the built-in theme choice (`theme=`) and the font size included.

## The themes

[`scripts/build-themes.py`](scripts/build-themes.py) builds [`shared/themes/`](shared/themes/) from the palette of [Zacess Themes](https://github.com/zacesshq/themes) 0.5.0, downloaded and checked against its SHA-256 digest. Every colour key Processing reads is written: the editor, the console, the tabs, the toolbar buttons, the error table and the Contribution Manager. The fonts in the theme are left to Processing.

| Processing token | Zacess colour |
| --- | --- |
| Java keywords (`keyword1`) | keyword, bold |
| Control flow (`keyword3`, `keyword6`, `function3`) | control, bold |
| Types (`keyword5`) | type |
| API functions and methods (`function1`, `function2`) | function |
| `setup`, `draw` and the other callbacks (`function4`) | function, bold |
| Built-in variables and constants (`keyword4`, `literal2`) | number |
| Strings (`literal1`) | string |
| Comments | comment |

Processing's token styles only know plain and bold, so the palette's italic comments come out plain. Line numbers keep their full colour rather than Processing's default fade.

## Where the settings live

| Platform | `preferences.txt` |
| --- | --- |
| macOS | `~/Library/Processing` |
| Linux | `~/.config/processing` |
| Linux (Flathub) | `~/.var/app/org.processing.processingide/config/processing` |
| Windows | `%APPDATA%\Processing` |

The sketchbook folder comes from `sketchbook.path.four` in `preferences.txt`. `--prefs` points the scripts at another `preferences.txt`.

## Apply

Quit Processing first. It holds its preferences in memory and writes them back on exit, so the scripts refuse to run while it is open.

```bash
mac/apply.sh                  # or linux/apply.sh
mac/apply.sh --theme cream    # another Zacess theme
```

The scripts print each change as `added`, `changed` or `unchanged`. Running one again changes nothing. A `theme.txt` in the sketchbook that these scripts did not write is never replaced: they stop and say so. Move that file out of the sketchbook first. Picking a built-in theme in **Tools > Theme Selector** moves the Zacess file aside the same way, so the script is the way back. When Processing has never been started the scripts say so and stop without an error. Nothing is backed up: this folder holds every value the scripts write. `mac/apply.sh` and `linux/apply.sh` are the same file and need `python3`.

```powershell
pwsh -File windows\apply.ps1
pwsh -File windows\apply.ps1 -Theme cream
```

The Windows script writes the same theme files and the same font key, under the name Java on Windows knows the font by: `GeistMono NFM`. When `sketchbook.path.four` points at a folder that no longer exists, as it does after Windows moves Documents into a cloud-synced folder, it uses the Processing folder in the real Documents folder and writes that path back.

`zt` switches Processing with the other editors on every platform by running these scripts.

## The sketchbook

The scripts set the sketchbook (`sketchbook.path.four`) to `~/dev/projects/processing`, the projects folder every editor shares on every machine, make the folder when it is missing and put `theme.txt` there. The sketchbook also holds installed libraries, modes and tools, so an existing one is moved by hand, with Processing closed:

```powershell
Move-Item "<old sketchbook>\*" "$HOME\dev\projects\processing"
```

```bash
mv "<old sketchbook>"/* ~/dev/projects/processing/
```

## Check it worked

1. Start Processing. The editor is black with bold blue keywords, yellow functions and green comments in Deep Contrast Dark. The text is Geist Mono.
2. **Processing > Settings** (**File > Preferences** on Linux) shows GeistMono Nerd Font Mono as the editor font.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks every theme starts with the marker line the scripts look for, that every colour is a hex value, that syntax and interface text is at least 7:1 on what it sits on in the Deep Contrast and High Contrast themes (4.5:1 in the others), that the font key is set and that the two shell scripts match.
