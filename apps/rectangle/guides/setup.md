# Setup

## Applying the configuration

1. Install [Rectangle](https://rectangleapp.com).
2. Copy `RectangleConfig.json` to
   `~/Library/Application Support/Rectangle/RectangleConfig.json`.
3. Launch Rectangle (or quit and relaunch it if already running). It detects the file on startup
   and shows a confirmation dialog: "Apply Rectangle configuration? Applying it will overwrite
   your current Rectangle shortcuts and preferences." Choose Apply.
4. Rectangle renames the file to `RectangleConfig<timestamp>.json` in the same folder once applied,
   so it is not reapplied on every future launch.

Rectangle also has its own Import button under Settings, General, which points at the same
`load(fileUrl:)` code path and skips the confirmation dialog since it is a direct user action
rather than an on-disk file Rectangle discovered itself. Either path is safe to use.

## Why this cannot be applied silently

Rectangle deliberately refuses to auto-apply a config file it finds without asking first. Reading
its own source directly: it also refuses a symlink or a world-writable file outright, rather than
silently loading it, a defense against another process planting a config change unnoticed. That
confirmation click is a real, unavoidable step, not a gap in this folder's automation.

## Verifying it took

Open Rectangle's Settings, Keyboard Shortcuts tab, then check a couple of entries against
[guides/shortcuts.md](shortcuts.md) directly. Or just try `⌃ + ⌥` + ← on any window.
