# raycast

> Raycast setup for macOS: an extension list and a recommended hotkey scheme with one consistent
> modifier pair, plus setup and reference guides.

Raycast has no config file, no export and no CLI, only an encrypted local database. This folder is
the plain-text record of which extensions to install and which hotkeys are worth setting by hand.

## What's here

- **[extensions.txt](extensions.txt)** - every Store extension, one `slug@author` per line under a
  category header. Full description of each in [guides/extensions.md](guides/extensions.md).
- **[hotkeys.md](hotkeys.md)** - the global hotkey that opens Raycast plus a recommended scheme
  across every extension and Raycast's own built-in features. Why in
  [guides/reference.md](guides/reference.md#recommended-hotkeys).
- **[guides/](guides/)** - setup walkthrough, reference and per-extension detail.

## Setup

Full walkthrough, including why hotkeys have to be entered by hand rather than imported, in
[guides/setup.md](guides/setup.md).

> [!IMPORTANT]
> Raycast is macOS only, so there are no Linux or Windows folders. Nothing here can be applied by
> copying a file into place, the hotkeys are entered by hand in Raycast Settings.

## Structure

| Path | Contents |
| --- | --- |
| [`ACCESSIBILITY.md`](ACCESSIBILITY.md) | How the hotkey scheme stays consistent and easy to remember |
| [`extensions.txt`](extensions.txt) | The extension list |
| [`hotkeys.md`](hotkeys.md) | The recommended hotkey scheme |
| [`guides/`](guides/) | Setup walkthrough, reference and per-extension detail |
