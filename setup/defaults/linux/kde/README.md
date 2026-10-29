# KDE Plasma

The KDE Plasma half of `defaults`, tested on Fedora KDE Plasma 6.7. `linux/defaults.sh` covers
GNOME only; `apply.sh` here does the same job for KDE using Plasma's own widgets plus one start menu
add-on.

| File | Does |
| --- | --- |
| `apply.sh` | Applies everything below |
| `yellow-pointer.sh` | Builds the Zacess Yellow pointer in `~/.local/share/icons`: Breeze Light recoloured to a yellow fill with a black outline, as on the Mac |
| `plasma-style.sh` | Builds the **Zacess Dark** Plasma style: Breeze Dark with its taskbar background rewritten to a 15 percent tint and a faint line along the top edge, from the installed Plasma artwork |
| `menu11.sh` | Installs **Menu11 - Next** 1.3, a start menu that opens centred above the taskbar, pinned to its release's commit |
| `login-wallpaper.sh` | Root half: a readable copy of the lock screen wallpapers for the login screen (shared with the originals on Btrfs, so no extra space), a daily sync and a new random picture at every boot and log-in |
| `taskbar.js` | One see-through taskbar flat on the bottom edge in Windows 11 style: the start menu and Icons-only Task Manager centred on the screen (Settings, Dolphin, Kitty, Discord, Spotify, Chrome and VS Code pinned), the system tray with small icon spacing and a 24-hour clock with the date at a fixed size on the right |
| `color-schemes/` | `ZacessHighContrastLight` (black on white) and `ZacessHighContrastDark` (white on black), Breeze with no grey secondary text |
| `look-and-feel/` | Two global themes that pair Breeze with those colours; `apply.sh` copies Breeze's own previews and splash in |

Keys are written with Windows names: `Win` is the Windows logo key, which KDE's own settings
call Meta (other Linux apps call it Super).

## What it sets

- **Region and apps:** the UK region (24-hour clock), Kitty as the terminal and GeistMono Nerd Font
  Mono as the desktop's fixed-width font and in every Konsole profile (install the font first).
- **Themes:** the light and dark global themes switch by time of day. The text selection colour in
  both schemes follows the Zacess theme `zt` last set: `zt` writes it into the installed schemes,
  `apply.sh` reapplies it after copying the schemes in and `zt highlight default` puts KDE's own
  blue back.
- **Taskbar:** a 15 percent tint over KWin's blur at strength 2 with a faint line along its top,
  always translucent, with white text in both themes. It matches a Windows 11 taskbar with
  TranslucentTB. The tray keeps notifications, JetBrains Toolbox, OneDrive, volume, Bluetooth,
  network and battery beside the clock and puts the rest behind its arrow.
- **Start menu:** Menu11, centred above the taskbar with no recent files or apps. Kickoff takes
  over when Menu11 is not installed.
- **Wallpapers:** the desktop is a shuffled slideshow of `~/Pictures/Wallpapers` and its category
  folders, changing every 5 minutes. The lock screen shows `~/Pictures/Wallpapers/Lock screen` only
  and changes every minute. The login screen shows a new picture from the same folder at every boot
  and log-in through `login-wallpaper.sh`, which needs root, so `apply.sh` asks for a password.
- **Power:** the lock screen appears after 15 minutes, before the screen dims or goes blank. As on
  the Mac and Windows, the screen dims just before it turns off at 60 minutes on mains and battery.
  A laptop suspends at 60 minutes on battery but never on mains.
- **Input:** scroll bars work as on Windows (an arrow at each end, a click on the track moves a
  page, GTK apps keep theirs visible) and touchpads scroll the Windows 11 way.
- **Notifications and pointer:** Discord and Kitty keep their sound and badge without pop-ups. The
  pointer is larger and yellow with a black outline (Zacess Yellow at size 48, built from Breeze
  Light by `yellow-pointer.sh`).

Log out and back in afterwards.

| Keys | Does |
| --- | --- |
| `Win` | Opens the start menu |
| `Alt+Space` | Opens KRunner, the search bar |
| `Win+Shift+S` | Region screenshot |
| `PrtSc` | Full-screen screenshot |
| `Win+Left` and `Win+Right` | Snap to the left or right half (KDE's own) |
| `Win+Ctrl+U`, `I`, `J` or `K` | Snap to a quarter: top left, top right, bottom left or bottom right (Rectangle's keys from the Mac) |
| `Win+Ctrl+Enter` | Maximise the window |
| `Win+Ctrl+C` | Centre the window |
| `Win+Ctrl+Left` and `Win+Ctrl+Right` | Switch desktops, as on Windows |

## Setup

From the repository root:

```bash
bash setup/defaults/linux/kde/apply.sh
```
