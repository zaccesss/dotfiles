# rectangle

> Rectangle window manager setup for macOS: an importable `RectangleConfig.json` with default and
> custom shortcuts, plus a full shortcut reference.

Rectangle reads a plain JSON config file on launch and ships an Import and Export button in its own
Settings window, so the whole setup can be tracked as a file.

## What's here

- **[RectangleConfig.json](RectangleConfig.json)** - the importable config: every active default
  shortcut, 12 custom bindings (2 for Todo mode and 10 filling genuine gaps) and every non-default
  setting. The schema was confirmed against Rectangle's own source, see
  [guides/reference.md](guides/reference.md).
- **[guides/shortcuts.md](guides/shortcuts.md)** - all 34 bound actions with what each does. It
  also covers the roughly 100 remaining actions Rectangle ships with no shortcut at all.
- **[guides/](guides/)** - setup walkthrough and full reference.

## Setup

Full walkthrough in [guides/setup.md](guides/setup.md): copy the config file into place, launch
Rectangle and confirm the import dialog it shows.

> [!IMPORTANT]
> Applying `RectangleConfig.json` overwrites your current Rectangle shortcuts and preferences.
> Rectangle shows a confirmation dialog first, so it never happens silently, but there is no undo
> beyond re-exporting your previous config beforehand.

## Structure

| Path | Contents |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | Keyboard-driven window layout without precise dragging |
| [`RectangleConfig.json`](RectangleConfig.json) | The importable Rectangle configuration |
| [`guides/`](guides/) | Setup walkthrough, full reference and the complete shortcut list |
