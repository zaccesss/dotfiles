# nextpad-plus-plus

Nextpad++ setup for macOS: the eight Zacess themes, built from the Zacess palette, with Geist Mono as the editor font.

Nextpad++ is a Mac port of Notepad++ and reads the same style files: one XML file per theme with a style for every language's tokens plus the editor-wide styles. It loads extra themes from `~/.nextpad++/themes` and keeps the active one, by name, in its own preferences (`org.nextpadplusplus.mac`). It only runs on macOS, so there is no Linux or Windows script.

## What it sets

| Setting | Value | Why |
| --- | --- | --- |
| `~/.nextpad++/themes/Zacess *.xml` | The eight Zacess themes | All eight show under **Settings > Style Configurator** |
| `NPPActiveTheme` | `Zacess Deep Contrast Dark` | The default theme. `--theme` picks any of the eight |
| `styleFontName` | `GeistMono Nerd Font Mono` | Geist Mono, the font every editor uses |
| `NPPStyleOverrides` | The Default Style's colour and font entries removed | An override made in the Style Configurator sits on top of every theme and would hide it |

Every other override stays, the text size included.

## The themes

[`scripts/build-themes.py`](scripts/build-themes.py) builds [`shared/themes/`](shared/themes/) from the palette of [Zacess Themes](https://github.com/zacesshq/themes) 0.4.0 and the `stylers.model.xml` that ships inside Nextpad++, which lists every language and token style the app knows. Each style takes a palette colour by what its name says it is: a comment, a string, a number, a keyword, a type, a function, an operator, a tag and so on. Bold and italic follow the palette (keywords and control flow bold, comments and parameters italic). Every style sits on the theme's own background. A newer Nextpad++ with more languages is covered by running the build again.

The same files work in Notepad++ on Windows, which reads the same format, so a Notepad++ setup can take them from `shared/themes/` as they are.

## Apply

Quit Nextpad++ first. It writes its preferences back while it runs, so the script refuses to run while it is open.

```bash
mac/apply.sh
mac/apply.sh --theme cream    # another Zacess theme
```

The script prints each change as `added`, `changed`, `removed` or `unchanged`. Running it again changes nothing. When Nextpad++ is not installed the script says so and stops without an error. Nothing is backed up: this folder holds every value the script writes.

`zt` switches Nextpad++ with the other editors by running the same script.

## Check it worked

1. Start Nextpad++ and open a C file. The editor is black with bold blue keywords, green comments and orange strings in Deep Contrast Dark, in Geist Mono.
2. **Settings > Style Configurator** shows Zacess Deep Contrast Dark as the theme.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks every theme parses, that every style's text is at least 7:1 on the editor background, the current line and the selection in the Deep Contrast and High Contrast themes (4.5:1 in the others), that line numbers pass the same floor and that the Default Style names Geist Mono.
