# matlab

MATLAB settings: the Zacess themes for the desktop, the editor and every language MATLAB highlights, plus Geist Mono as the code font.

## What it sets

| Setting | Value | Why |
| --- | --- | --- |
| `matlab.appearance.MATLABTheme` | `Dark` for the dark Zacess themes, `Light` for the light ones | The desktop follows the theme |
| Colour scheme | The theme's editor text and background, current line, syntax colours for MATLAB and every other language the editor highlights (C, C++, Python, Verilog, VHDL and more), Command Window colours and code analyser colours | The editor matches the other editors in both MATLAB themes |
| `matlab.fonts.codefont` | GeistMono Nerd Font at 14 points (GeistMono Nerd Font Mono at 18 on macOS) | The font every editor uses |

Each theme has two files, both built by [`scripts/build-themes.py`](scripts/build-themes.py) from the Zacess Themes `.vsix`:

- [`shared/themes`](shared/themes) holds the desktop theme and the light theme's colours, written through MATLAB's own settings API by [`shared/zacess_apply.m`](shared/zacess_apply.m).
- [`shared/schemes`](shared/schemes) holds the full colour scheme in the format of MathWorks' [Color Theme Extensions](https://github.com/mathworks/matlab-color-theme-extensions) add-on. MATLAB's settings API only reaches the light theme's colours. The add-on's `import_scheme` sets either theme's, so the dark themes are fully set from code too. [`shared/base/scheme-template.json`](shared/base/scheme-template.json) is the add-on's own template (BSD 3-Clause). Each colour in it takes the theme colour for its role, found from its name.

The fonts are in each platform's `fonts.json`.

## Apply

Quit MATLAB first: it writes its settings back when it exits, so the scripts refuse to run while it is open.

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

The script downloads the add-on at the commit pinned in [`shared/scheme-tools.json`](shared/scheme-tools.json) and checks every file against its SHA-256 digest before using it. The add-on needs MATLAB's full desktop. MATLAB also saves settings only when a session ends normally. So the script starts MATLAB (minimised on Windows), applies the settings and the scheme, then quits. That takes about a minute.

Each script finds the newest MATLAB release (`/Applications/MATLAB_R20*.app` on macOS). To use another one, pass the path to its `matlab` launcher. The script prints each setting as `added`, `changed` or `unchanged` and the scheme as `applied`. Nothing is backed up: this folder holds every value the scripts write.

A scheme can also be applied by hand from MATLAB with the add-on on the path: `import_scheme('shared/schemes/Zacess Cream.json')`.

Every run also adds a marked block to `startup.m` in MATLAB's userpath (`Documents\MATLAB` on Windows) and leaves the file's other lines as they are. The block runs [`shared/zacess_startup.m`](shared/zacess_startup.m), which applies a theme named in a pending file when MATLAB starts, then removes that file. The settings go in at once. The colour scheme follows from a timer once the desktop is ready. On Windows the pending file is `%LOCALAPPDATA%\zacess\matlab-theme` and the add-on is kept in `%LOCALAPPDATA%\zacess\matlab-tools`. On the Mac and Linux they are `~/.local/state/zacess/matlab-theme` and `~/.local/state/zacess/matlab-tools`, with `startup.m` in `~/Documents/MATLAB`.

`pwsh -File windows\apply.ps1 -Theme cream -Pending` only writes the pending file, so MATLAB is not started. `bash mac/apply.sh --theme cream --pending` and the Linux script do the same. `zt` uses it and reports the theme as "on next start".

## Its start folder

MATLAB starts in `~/dev/projects/matlab`, the projects folder every editor shares on every machine. [`shared/folders.json`](shared/folders.json) holds the setting once for every OS: `zacess_apply.m` turns `~/` into the home folder and makes the folder when it is missing.

## Check it worked

1. Start MATLAB. The desktop is dark for a dark theme and light for a light one.
2. Open a `.m` file. In Deep Contrast Dark the editor is black, with blue keywords, green comments and orange strings.
3. **Settings > MATLAB > Fonts** shows GeistMono Nerd Font for code (GeistMono Nerd Font Mono on macOS).

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks all eight themes have a Light or Dark desktop and RGB colours, every theme has a scheme for the same desktop with every colour set, the add-on is pinned by commit and digest, every platform names Geist Mono and `zacess_apply.m` defines its function.
