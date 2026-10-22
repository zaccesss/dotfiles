# Setup

> [!TIP]
> The apply scripts (`mac/apply.sh`, `linux/apply.sh` and `windows/apply.ps1`) install the theme
> plugin and do steps 4 to 6 for every IDE at once, with `~/dev/projects` for new projects. Each
> bootstrap runs them in its apps stage. See [Apply](../README.md#apply) in the README. The steps
> below are what they do, kept for doing it by hand.

## 1. Install the IDEs

Install whichever JetBrains IDEs you use, through JetBrains Toolbox or the platform's supported
manual installation.

## 2. Install the plugins

For each IDE, install the plugins in its `plugins/<ide>.txt` through Settings > Plugins >
Marketplace, searching by plugin id (the part before the `@`).

> [!TIP]
> Each line pins the version that was installed at the time. Marketplace only offers versions
> compatible with your IDE build, so search by id and take the current version rather than hunting
> for the exact pinned one.

> [!WARNING]
> `intellij.vitejs` in `plugins/dataspell.txt` does not install on DataSpell 2026.1: Marketplace
> offers no Vite build for DataSpell, so the headless `installPlugins`
> command reports it as an unknown plugin. Skip it there. Every other plugin in the list installs.

Install `com.intellij.plugins.vscodekeymap` before applying the custom keymap in step 4, since the
keymap's parent comes from that plugin.

## 3. Apply the Toolbox settings

Copy `toolbox/<platform>/settings.json` over Toolbox's own `settings.json` while Toolbox is not
running. Toolbox's default settings location differs per platform, see
[reference.md](reference.md#toolbox-settings).

## 4. Apply the keymap and file template

Use each IDE's own Settings UI:

- Keymap: Settings > Keymap > gear icon > Import Keymap, pick the file from `keymaps/` for your
  platform, then select it in the dropdown.
- File template: Settings > Editor > File and Code Templates > Files > Class, paste in the
  contents of `file-templates/Class.java`.

## 5. Use the Zacess Deep Contrast theme

The Zacess Themes plugin ([JetBrains Marketplace](https://plugins.jetbrains.com/plugin/35082-zacess-themes),
`com.zacess.themes`, in every list in `plugins/`) adds the eight Zacess themes, each with its own
editor colour scheme, the IDE's terminal colours included.

1. Settings > Plugins > Marketplace: install **Zacess Themes**.
2. Settings > Appearance & Behavior > Appearance: pick **Zacess Deep Contrast Dark** as the theme,
   with **Sync with OS** off so it stays fixed whatever the system appearance. Its editor scheme
   comes with it.
3. To follow the system instead, turn on **Sync with OS** and use the gear icon beside it to pick
   Zacess Deep Contrast Dark for dark and Zacess Deep Contrast Light for light.

The two schemes in `colors/`, High Contrast Dark and High Contrast Light, are the earlier setup:
they set only the console and terminal colours on top of a bundled editor scheme. They stay for
anyone who prefers the built-in High Contrast theme.

## 6. Set the fonts

The editor uses GeistMono Nerd Font and the built-in terminal uses its Mono build, GeistMono Nerd Font
Mono, whose icons fit one cell, so the Nerd Font symbols a themed prompt uses (branch, language and
battery icons) draw whole. The font is free under the SIL Open Font License; install it from the
[Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases) first.

1. Settings > Editor > Font: set **Font** to **GeistMono Nerd Font**.
2. Settings > Tools > Terminal: set **Font** to **GeistMono Nerd Font Mono**.

On Windows the same fonts are listed as **GeistMono NF** and **GeistMono NFM**. The IDE's Java
runtime only sees fonts installed for all users. Install the font for all users (right-click each
`.otf` file, then **Install for all users**) and pick those two names. A missing font falls back to
the IDE's default.

## Applying by file copy instead

Copying files straight into an IDE's config directory is safe only while that IDE is fully
closed. IntelliJ-family IDEs keep this state in memory while running and can overwrite an on-disk
file the moment a related setting changes.

Config directories are named per IDE and version, for example `IntelliJIdea2026.2` or
`PyCharm2026.2`:

| Platform | Config directory |
| --- | --- |
| macOS | `~/Library/Application Support/JetBrains/<IDE><version>` |
| Linux | `~/.config/JetBrains/<IDE><version>` |
| Windows | `%APPDATA%\JetBrains\<IDE><version>` |

Copy the keymap into that directory's `keymaps/` folder, the file template into
`fileTemplates/internal/` and the colour schemes into `colors/`, then select the keymap in
Settings > Keymap. With the plugin installed, steps 5 and 6 are the four files in `options/`, copied into
the directory's `options/` folder: `laf.xml` sets the Zacess Deep Contrast Dark theme with
`autodetect="false"` and the Deep Contrast pair ready for Sync with OS. `colors.scheme.xml` sets
the matching editor scheme. `editor-font.xml` and `terminal-font.xml` set the two fonts. On Windows,
copy the two font files from `options/windows/` instead, since they use the Windows font names.

## Adding another IDE

1. Build its plugin list from the installed plugins. For each plugin, read the real id and version
   from `META-INF/plugin.xml` inside its jar rather than guessing.
2. Save it as `plugins/<ide>.txt`, grouped under `//` category headers.
3. Add it to [plugins.md](plugins.md).
