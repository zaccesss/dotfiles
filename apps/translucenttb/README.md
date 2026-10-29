# TranslucentTB

A dark see-through Windows taskbar over the desktop that turns solid when a window is maximised or
battery saver is on. Pair it with Windows mode Dark (**Settings > Personalisation > Colours**) so
the taskbar text is white over any wallpaper.

## What it sets

[`windows/settings.json`](windows/settings.json) holds only the values that differ from
TranslucentTB's defaults:

| State | Look |
| --- | --- |
| Desktop | The blur accent at radius 0: a `#1C1C1C` tint at 65 percent with no blur, with the line but no Peek button. TranslucentTB only reads `blur_radius` with the blur accent, so acrylic always blurs |
| A window maximised | Solid `#1C1C1C` with the Peek button and line |
| Task View open | Windows' normal taskbar with the line |
| Battery saver on | Solid `#1C1C1C` with the Peek button and line |
| A window visible, Start or search open | Off, so the desktop look carries on |

A PC can keep its own values in `windows/machines/<computer name>.json`, laid over `windows/settings.json` by `windows/apply.ps1` on that PC. The same blur looks heavier on a large low-density monitor than on a high-density laptop screen, so each PC can keep its own look while the shared file stays the default.

## Install

```powershell
winget install CharlesMilette.TranslucentTB
```

The Windows bootstrap installs it from [`packages/winget.json`](../../setup/windows-bootstrap/packages/winget.json).
Start it once so it writes its settings file, then turn on **Open at boot** from its tray menu.

## Apply

```powershell
& "$HOME\dev\github\repos\dotfiles\apps\translucenttb\windows\apply.ps1"
```

The script merges the tracked values into
`%LOCALAPPDATA%\Packages\28017CharlesMilette.TranslucentTB_v826wp6bftszj\RoamingState\settings.json`
and prints each one as `added`, `changed` or `unchanged`. Every other value in that file is left as
it was. TranslucentTB watches the file, so most changes show while it runs. The taskbar line only appears
after TranslucentTB restarts: quit it from its tray menu and start it again. Before the first start
there is no file yet, so the script says it skipped. The bootstrap's apps stage runs it. Nothing is
backed up: this folder holds every value it writes.

`scripts/validate.py` checks the settings without Windows and runs in CI.
