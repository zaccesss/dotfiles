# notepad-plus-plus

Notepad++ setup: the eight Zacess themes with Geist Mono, used together with Notepad++'s own dark mode. Notepad++ runs on Windows only. On macOS, [Nextpad++](../nextpad-plus-plus/) reads the same theme format.

## What it sets

| Setting | Value | Why |
| --- | --- | --- |
| `%APPDATA%\Notepad++\themes\Zacess *.xml` | The eight Zacess themes | All eight show under **Settings > Style Configurator** |
| `DarkMode` `enable` in `config.xml` | `yes` for a dark theme, `no` for a light one | Menus, tabs and dialogs match the editor |
| `DarkMode` `darkThemeName` or `lightThemeName` | The chosen theme's file | Notepad++ loads that theme whenever it switches to that mode |
| Default Style font | GeistMono NF at 14 points | Geist Mono's Nerd Font build, under the short name Windows' older font lookup knows |

Notepad++ rewrites `stylerTheme` itself when it exits, so the script sets the theme through the dark mode keys, which it keeps.

## The themes

[`scripts/build-themes.py`](scripts/build-themes.py) builds [`themes/`](themes/) from the Zacess Themes `.vsix` and Notepad++'s own `DarkModeDefault.xml`, which lists every language and token style Notepad++ knows (91 languages). Each style takes a palette colour by what its name says it is: a comment, a string, a number, a keyword, a type, a function or an operator. Every style sits on the theme's own background. The Global override, used only when **Enable global font** is ticked, also takes the theme's colours and Geist Mono.

## Apply

Quit Notepad++ first: it writes `config.xml` back when it exits, so the script refuses to run while it is open.

```powershell
pwsh -File windows\apply.ps1
pwsh -File windows\apply.ps1 -Theme cream
```

The script prints each file and key as `added`, `changed` or `unchanged`. Running it again changes nothing. Nothing is backed up: this folder holds every value it writes.

## Check it worked

1. Start Notepad++. Menus and tabs are dark and the editor is black with Geist Mono in Deep Contrast Dark.
2. **Settings > Style Configurator** shows the Zacess theme selected, with all eight in the list.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks all eight themes are well-formed XML and their Default Style and Global override use Geist Mono with valid colours.
