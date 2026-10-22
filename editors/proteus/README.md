# proteus

Proteus 8 Professional colours: the Zacess themes in the schematic, the PCB layout and the graph viewer, with Proteus's own colours one command away. Proteus runs on Windows only, so this folder has only a Windows script.

## What it sets

| Part of Proteus | Where Proteus keeps it | What the script does |
| --- | --- | --- |
| PCB layout and graphs | Named colour sets in the registry, under `HKCU\Software\Labcenter Electronics\Proteus 8 Professional\ARES` and `GVIEW` | Adds all eight Zacess sets beside Proteus's own Black Paper, White Paper and Monochrome and makes the chosen one active |
| Schematic | Each design's template, copied into the design when it is made | Writes the chosen theme into every template in `%ProgramData%\Labcenter Electronics\Proteus 8 Professional\Templates`, so every new design starts in it |
| Existing designs | Inside each `.pdsprj` | Only with `-Project`: rewrites the colours in the named projects and nothing else in them |

In the schematic the paper takes the theme's background, the grid its indent guide colour and selection its focus colour. Black or grey outlines, wires and text take the theme's text colour. Every coloured part moves to the theme's terminal colour nearest its hue, so wires stay green, probes blue and component outlines red. Component bodies take the line highlight shade, so a part reads as a block on the paper.

## Apply

Quit Proteus first: it writes its settings back when it exits, so the script refuses to run while it is open.

```powershell
pwsh -File windows\apply.ps1                      # Zacess Deep Contrast Dark, the default
pwsh -File windows\apply.ps1 -Theme deep-light    # any of the eight, light ones included
pwsh -File windows\apply.ps1 -Theme proteus       # back to Proteus's own colours
```

`-Theme` takes a short name (`deep-dark`, `deep-light`, `hc-dark`, `hc-light`, `dark`, `light`, `cream`, `yellow`), the theme id (`deep-contrast-dark`) or the full name. `zt <theme>` runs this script along with every other app.

To bring existing designs onto the theme too, name the project files or a folder of them. Only the colours inside each project change:

```powershell
pwsh -File windows\apply.ps1 -Theme deep-dark -Project "$HOME\Documents\Proteus Projects"
```

A cloud-synced project that is only online is skipped with a note. Keep it on the device (right-click, **Always keep on this device**) and run the script again.

The script prints each part as `changed`, `unchanged`, `removed` or `skipped`. Running it again changes nothing. Nothing is backed up: this folder holds every value it writes. `-Theme proteus` writes back Proteus's own defaults from [`shared/base/schematic_default.json`](shared/base/schematic_default.json), byte for byte.

## Switching inside Proteus

Every theme stays available without the script:

- **PCB layout and graphs:** **System > Set Colour Scheme** lists all eight Zacess sets (`ZACESS_DEEP_DARK`, `ZACESS_CREAM` and so on) beside Black Paper, White Paper and Monochrome.
- **Schematic:** **Template > Set Design Colours**, **Set Graphic Styles** and **Set Text Styles** change the open design. **Template > Apply Styles From Template** copies another template's styles into it.

## How the schematic part works

Proteus has no setting or command line for schematic colours. A design template (`.DTF`) and the schematic inside a project (`ROOT.DSN` in the `.pdsprj` zip) share one binary layout, which [`windows/template.ps1`](windows/template.ps1) reads:

- **Design colours:** a fixed record after the `DESIGN CONFIGURATION DATA` marker holds paper, grid, work area, world box, highlight, drag, hidden and the five animation colours.
- **Graphics styles:** a counted list of named styles (COMPONENT, PIN, WIRE and so on), each with a line colour, a fill and a background fill.
- **Text styles:** a counted list of named text styles, each with a text colour.

Every colour is a Windows `COLORREF` (red, green, blue, zero). The layout was mapped by writing a distinct colour into each slot of a scratch copy and reading it back in Proteus's own dialogs. A file that does not match the layout is skipped, never written.

## Files

| File | What it is |
| --- | --- |
| [`shared/themes`](shared/themes) | One file per theme: the PCB and graph colour set (`values`) and the schematic colours (`schematic`) |
| [`shared/base`](shared/base) | Proteus's own Black Paper, White Paper and default schematic colours, the starting points the build reads |
| [`scripts/build-themes.py`](scripts/build-themes.py) | Builds `shared/themes` from the Zacess Themes `.vsix` |
| [`windows/apply.ps1`](windows/apply.ps1) | The apply script |
| [`windows/template.ps1`](windows/template.ps1) | Reads and writes the colours in a template or a design |

## Check it worked

1. Start Proteus and make a new project. The schematic paper is black, wires green, component outlines red and text white in Deep Contrast Dark.
2. Open a PCB layout. **System > Set Colour Scheme** shows `ZACESS_DEEP_DARK` as the active set.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks all eight themes exist with short, unique set names (Proteus cuts a set name to 20 characters when it saves), every PCB value is a colour, a number or a Yes/No flag and every theme's schematic colours cover exactly the default template's slots.
