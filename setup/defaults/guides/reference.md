# Reference

This reference documents the shared preference model and the native platform
implementations.

## Cross-Platform Preferences

The folder defines preferences independently of the operating system.
Platform implementations use native configuration mechanisms where a
meaningful equivalent exists.

| Preference | Intended behaviour |
| --- | --- |
| Clock format | Use a digital 12-hour clock with AM/PM where supported. |
| Weekday | Show the day of the week. |
| Date | Hide the date from the primary desktop clock. |
| Seconds | Hide seconds. |
| File manager | Use List view by default where supported. |
| File names | Do not intentionally hide file extensions. |
| Trash | Remove old items automatically where supported, using 30 days. |
| Input | Prefer physical clicking over tap-to-click where supported. |
| Workspaces | Prefer stable workspace ordering where supported. |

## Linux

The Linux implementation targets GNOME through `gsettings`.

### Clock

| Setting | Value | What it does |
| --- | --- | --- |
| `org.gnome.desktop.interface clock-format` | `12h` | Uses a 12-hour clock with AM/PM. |
| `org.gnome.desktop.interface clock-show-weekday` | `true` | Shows the day of the week. |
| `org.gnome.desktop.interface clock-show-date` | `false` | Hides the date. |
| `org.gnome.desktop.interface clock-show-seconds` | `false` | Hides seconds. |

### Files

| Setting | Value | What it does |
| --- | --- | --- |
| `org.gnome.nautilus.preferences default-folder-viewer` | `list-view` | New folders use List view by default. |

### Trash

| Setting | Value | What it does |
| --- | --- | --- |
| `org.gnome.desktop.privacy remove-old-trash-files` | `true` | Enables automatic removal of old Trash items. |
| `org.gnome.desktop.privacy old-files-age` | `30` | Uses a 30-day retention period. |

### Touchpad

| Setting | Value | What it does |
| --- | --- | --- |
| `org.gnome.desktop.peripherals.touchpad tap-to-click` | `false` | Tap to click is disabled. Physical clicking is required. |

### Workspaces

| Setting | Value | What it does |
| --- | --- | --- |
| `org.gnome.mutter dynamic-workspaces` | `false` | Keeps workspace ordering stable instead of dynamically creating and removing workspaces. |

The Linux implementation deliberately does not set scrolling direction or workspace monitor
assignment, since the macOS side has no corresponding preference.

## macOS

The values in `mac/defaults.tsv` were captured with `bash mac/defaults.sh --capture` from a real Mac,
not guessed or copied from a popular dotfiles script. The tables below explain what each one does.

### Dock

| Setting | Value | What it does |
| --- | --- | --- |
| `tilesize` | `128` | Dock icons are large. macOS's own default is `48`. |
| `minimize-to-application` | `true` | A minimised window's icon goes into its app's own Dock icon rather than getting a separate icon of its own. Default is `false`. |
| `show-recents` | `false` | Recently used apps do not show in a separate section of the Dock. Default is `true`. |
| `mru-spaces` | `false` | Mission Control does not reorder Spaces by most-recently-used, their order stays fixed. Default is `true`. |
| `wvous-br-corner` | `14` | The bottom-right hot corner triggers an action. Widely reported in community sources as Quick Note, not confirmed against Apple's own documentation since Apple does not publish these codes. |
| `wvous-br-corner-modifier` | `0` | No modifier key is needed to trigger that corner, hovering there alone is enough. |

### Finder

| Setting | Value | What it does |
| --- | --- | --- |
| `FXPreferredViewStyle` | `Nlsv` | New Finder windows default to List view. |
| `FXDefaultSearchScope` | `SCev` | A new Finder search defaults to searching this Mac rather than just the current folder. |
| `FXRemoveOldTrashItems` | `true` | Items in the Trash older than 30 days are removed automatically. |
| `NewWindowTarget` | `PfHm` | A new Finder window opens to the home folder rather than Recents or Desktop. |

### Global (all apps)

| Setting | Value | What it does |
| --- | --- | --- |
| `AppleShowAllExtensions` | `true` | Every file extension is shown in Finder, never hidden regardless of a file's own "hide extension" flag. Default is `false`. |

### Trackpad

| Setting | Value | What it does |
| --- | --- | --- |
| `Clicking` | `false` | Tap to click is off, a click needs an actual physical press. |
| `TrackpadThreeFingerDrag` | `false` | A 3-finger drag gesture is off. |
| `TrackpadRightClick` | `true` | A 2-finger tap or click in the trackpad's lower area registers as a right-click. |

### Screenshots

| Setting | Value | What it does |
| --- | --- | --- |
| `location` | `~/Pictures/Screenshots` | A screenshot saves into this folder rather than the Desktop. |

### Menu bar clock

| Setting | Value | What it does |
| --- | --- | --- |
| `ShowAMPM` | `true` | The clock shows AM/PM. |
| `ShowDayOfWeek` | `true` | The clock shows the day of the week. |
| `ShowDate` | `0` | The date is not shown alongside the time. |
| `ShowSeconds` | `false` | Seconds are not shown. |
| `IsAnalog` | `false` | The menu bar clock is digital, not an analogue face. |
| `FlashDateSeparators` | `false` | The colon between hours and minutes does not flash once per second. |

## Why `defaults write`, not a `.plist` file

macOS system preferences have no single import format. `defaults write` is the command macOS's own
Preferences panes use to persist a change. Running it twice leaves the same end state, so a
plain shell script is the standard way to apply these.

## Reverting a setting

Delete a single override with `defaults delete <domain> <key>` and restart the affected process
(`killall Dock`, `killall Finder` or `killall SystemUIServer`). On GNOME use
`gsettings reset <schema> <key>`.
