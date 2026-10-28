# arduino

Arduino IDE 2 settings: the Zacess themes, Geist Mono and the editor basics, merged into the IDE's own `settings.json` without touching anything else.

Arduino IDE 2 is built on Eclipse Theia, the same editor parts as VS Code. It keeps its settings in one `settings.json` and loads VS Code colour themes from a `plugins` folder, so the Zacess themes come straight from the Zacess Themes `.vsix` rather than a converted copy.

## What it sets

| Setting | Value | Why |
| --- | --- | --- |
| `workbench.colorTheme` | `Zacess Deep Contrast Dark` | The default theme. `--theme` (`-Theme` on Windows) picks any of the eight |
| `editor.fontFamily` | `'GeistMono Nerd Font', 'GeistMono NF', monospace` | Geist Mono's Nerd Font build, the font every editor uses. The second name is the one Windows' older font lookup knows, as a fallback |
| `editor.fontSize` | `16` | Larger than the default 14 |
| `files.autoSave` | `afterDelay` | Sketches save themselves, so nothing depends on saving before an upload |
| `editor.quickSuggestions` | off for code, comments and strings | Suggestions only when asked for with `Ctrl+Space` |
| `window.titleBarStyle` | `native` | The system's own title bar |

Every key lives in [`shared/settings.json`](shared/settings.json). The scripts merge only those keys and leave the rest of the file as it was, including the IDE's own board and port choices.

## The themes

[`shared/theme-package.json`](shared/theme-package.json) pins Zacess Themes 0.5.0 by its release URL and SHA-256 digest. The apply script downloads it, checks the digest and puts `zacess-themes-0.5.0.vsix` in the `plugins` folder. Arduino IDE unpacks it into `deployedPlugins` on its next start. An older `zacess-themes-*.vsix` in the folder is removed, so the themes never load twice. To move to a new release, change the version, URL and digest together.

## Where the settings live

| Platform | Folder |
| --- | --- |
| Windows | `%USERPROFILE%\.arduinoIDE` |
| macOS | `~/.arduinoIDE` |
| Linux | `~/.arduinoIDE` for the AppImage or zip |
| Linux (Flathub) | `~/.var/app/cc.arduino.IDE2/.arduinoIDE`, since the `cc.arduino.IDE2` sandbox on Fedora keeps its own home folder |

The Linux script tries both Linux folders in that order. `--config-dir` points it anywhere else.

## Apply

Quit Arduino IDE first. It holds its settings in memory and writes them back when it exits, so the scripts refuse to run while it is open. It also has to have been started once, so `settings.json` exists.

```bash
mac/apply.sh                 # or linux/apply.sh
mac/apply.sh --theme cream   # another Zacess theme
```

```powershell
pwsh -File windows\apply.ps1
pwsh -File windows\apply.ps1 -Theme cream
```

The scripts print each key and the theme package as `added`, `changed`, `unchanged` or `removed`. Running one again changes nothing. Nothing is backed up: this folder holds every value the scripts write. `mac/apply.sh` and `linux/apply.sh` are the same file. The shell script needs `python3` for the JSON merge and the download check.

## The sketchbook

The scripts set the sketchbook (`directories.user` in `arduino-cli.yaml`) to `~/dev/projects/arduino`, the projects folder every editor shares on every machine. They make the folder when it is missing. The sketchbook also holds installed libraries, so an existing one is moved by hand, with Arduino IDE closed:

```powershell
Move-Item "<old sketchbook>\*" "$HOME\dev\projects\arduino"
```

```bash
mv "<old sketchbook>"/* ~/dev/projects/arduino/
```

## Check it worked

1. Start Arduino IDE. **File > Preferences** (**Arduino IDE > Settings** on macOS) shows the Zacess theme under **Theme** and an editor font size of 16.
2. A sketch shows Geist Mono, with keywords bold blue, functions yellow, strings orange and comments green in Deep Contrast Dark.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks the settings parse and name a packaged theme and Geist Mono, that the theme package pins a real release with a full digest and that the two shell scripts match.
