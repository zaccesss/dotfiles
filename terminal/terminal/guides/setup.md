# Setup

Copy the config for your platform and terminal to the path in the table, creating the folder if it
does not exist. Restart the terminal afterwards.

## Config paths

| Terminal | macOS | Linux | Windows |
| --- | --- | --- | --- |
| Alacritty | `~/.config/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | `%APPDATA%\alacritty\alacritty.toml` |
| Kitty | `~/.config/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` | not available |
| Hyper | `~/.hyper.js` | `~/.hyper.js` | `%APPDATA%\Hyper\.hyper.js` |

## Zacess themes

Alacritty imports `zacess-deep-contrast-dark.toml` from the same folder and Kitty includes
`zacess-deep-contrast-dark.conf`, so copy the `zacess-*` files alongside the main config. Change
that one line to switch theme. The eight themes and how each terminal switches are in
[themes.md](themes.md).

### macOS

```sh
./mac/install.sh
```

It adds a Terminal.app profile for each of the eight themes and makes Zacess Deep Contrast Dark the
default, links the iTerm2 Dynamic Profiles and makes Zacess Deep Contrast Dark iTerm2's default,
then links the Kitty, Alacritty and Ghostty theme files for any already set up. It also builds the
helper that switches Terminal.app with the system, without starting it.

> [!NOTE]
> With Terminal.app open, importing a profile opens one window per profile; close them once the
> profiles appear under Settings > Profiles. With iTerm2 open, pick Zacess Deep Contrast Dark under
> Settings > Profiles > Other Actions > Set as Default instead.

### Linux

- **Ptyxis** (Ubuntu 25.10 and later): copy `linux/ptyxis/zacess-*.palette` to
  `~/.local/share/org.gnome.Ptyxis/palettes/`, then pick Zacess Deep Contrast Dark under
  Preferences > Profile.
- **GNOME Terminal** (Ubuntu 24.04): `dconf load` a theme's file in `linux/gnome-terminal/` onto a
  profile, as its first lines show.
- **Ghostty**: copy `linux/ghostty/zacess-*` to `~/.config/ghostty/themes/` and start from
  `linux/ghostty/config`, which picks Zacess Deep Contrast Dark and sets the contrast floor.

### Windows Terminal

Copy `windows/windows-terminal/zacess.json` to
`%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\Zacess\`, which adds all eight schemes, then
set the colour scheme in `settings.json`:

```json
"profiles": { "defaults": { "colorScheme": "Zacess Deep Contrast Dark", "intenseTextStyle": "bold" } }
```

A `{ "dark": ..., "light": ... }` pair in place of the name follows the system instead.
`intenseTextStyle` keeps bold text in its own colour rather than the bright row.

## Examples

```sh
mkdir -p ~/.config/alacritty
cp mac/alacritty/*.toml ~/.config/alacritty/                         # use linux/ on Linux

mkdir -p ~/.config/kitty
cp mac/kitty/*.conf ~/.config/kitty/                                 # use linux/ on Linux

mkdir -p ~/.config/ghostty/themes
cp mac/ghostty/zacess-* ~/.config/ghostty/themes/                   # use linux/ on Linux
cp mac/ghostty/config ~/.config/ghostty/config

cp mac/hyper/hyper.js ~/.hyper.js                                    # use linux/ on Linux
```

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force $env:APPDATA\alacritty
Copy-Item windows\alacritty\*.toml $env:APPDATA\alacritty\
Copy-Item windows\hyper\hyper.js $env:APPDATA\Hyper\.hyper.js
```

## Verify it worked

Open a new terminal window. In dark mode the background should be pure black with near-white text
and vivid colours; in light mode, white with near-black text, for the terminals that follow the
system setting. If it is not, check the terminal's own config path documentation, since the default
location differs between versions.
