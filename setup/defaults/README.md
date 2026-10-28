# defaults

> Desktop preference scripts for macOS, Linux (GNOME) and Windows, driven by one shared
> cross-platform preference model. macOS and Windows settings are captured from a machine set up
> the way you like, then replayed on the next one.

Preferences are defined once, independently of the operating system, then implemented through each
platform's native configuration mechanism. A setting is only translated across platforms where a
meaningful native equivalent exists, otherwise it stays platform-specific.

## What's here

- [`common/preferences.md`](common/preferences.md) - the cross-platform preference model.
- [`mac/defaults.sh`](mac/defaults.sh) - the macOS implementation. It applies [`mac/defaults.tsv`](mac/defaults.tsv)
  (example values) and captures your own with `--capture`, using the keys in [`mac/tracked.txt`](mac/tracked.txt); the text highlight colour is left out, since `zt` sets it from the Zacess theme.
- [`windows/defaults.ps1`](windows/defaults.ps1) - the Windows implementation, the same way, for the
  registry values in [`windows/tracked.txt`](windows/tracked.txt). Run `-Capture` on your PC first.
- [`linux/defaults.sh`](linux/defaults.sh) - the GNOME implementation, using `gsettings`. It only
  applies settings for schemas and keys available in the current environment.
- [`guides/reference.md`](guides/reference.md) - every setting and what it does.
- [`guides/setup.md`](guides/setup.md) - how to apply the scripts safely.

## Setup

```bash
bash mac/defaults.sh --capture   # macOS: record this Mac's settings into mac/defaults.tsv
bash mac/defaults.sh             # macOS: apply mac/defaults.tsv, writing only values that differ
bash linux/defaults.sh           # Linux with GNOME
```

```powershell
.\windows\defaults.ps1 -Capture   # Windows: record this PC's settings
.\windows\defaults.ps1 -Plan      # Windows: show what applying would change
.\windows\defaults.ps1            # Windows: apply them
```

> [!IMPORTANT]
> Applying changes real system behaviour: Dock icon size, Finder defaults, trackpad clicking,
> screenshot location and more. The macOS values in `mac/defaults.tsv` are examples. Capture your
> own first, otherwise read the file and change any value you do not want.

## Structure

| Path | Contents |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Larger Dock icons, a still clock, visible extensions and predictable layouts |
| [`common/`](common/) | The shared preference model |
| [`mac/`](mac/) | macOS implementation |
| [`linux/`](linux/) | GNOME implementation |
| [`guides/`](guides/) | Setup walkthrough and settings reference |
