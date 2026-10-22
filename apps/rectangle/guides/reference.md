# Reference

## Why no `windows/` or `linux/`

Rectangle is macOS only, it moves and resizes windows through macOS's own Accessibility APIs which
have no equivalent this folder could target on another OS. The closest analogues, PowerToys FancyZones
on Windows and gTile on Linux, are separate projects with their own separate config, not something
this folder could extend to.

## Why `RectangleConfig.json` is a real, importable file

Rectangle reads a plain JSON file at
`~/Library/Application Support/Rectangle/RectangleConfig.json` on launch and also exposes an
Import/Export button in its own Settings window. That means the whole
configuration can be tracked as a file. Confirmed by reading Rectangle's own source (`Config.swift`, `WindowAction.swift`, `ShortcutManager.swift`,
`Defaults.swift` in [rxhanson/Rectangle](https://github.com/rxhanson/Rectangle)), not guessed:

- `shortcuts` is a map of action name to `{ "keyCode": Int, "modifierFlags": UInt }`, matching the
  `Shortcut` struct exactly.
- `defaults` is a map of settings key to a `CodableDefault`, an object with exactly one of
  `bool`, `int`, `float`, `double` or `string` set, the rest omitted rather than set to `null`
  (Swift's synthesised `Codable` conformance uses `encodeIfPresent` for optional fields).
- `bundleId` and `version` are metadata Rectangle checks but does not currently gate the import on.

See [guides/setup.md](setup.md) for what actually happens on import, including the confirmation
dialog Rectangle shows, this is not a silent write.

## Why most actions have no shortcut

`WindowAction.swift` defines around 130 possible actions (Rectangle's full menu, including sixths,
eighths, ninths, twelfths, sixteenths and per-display jumps), but only 22 of them have a built-in
default keyboard shortcut, listed in full in
[guides/shortcuts.md](shortcuts.md#active-default-shortcuts-magnet-style). The rest exist as menu
items and screen-edge snap areas rather than shortcuts, since Rectangle does not invent a keyboard
combination for every possible tiling position out of the box, that decision is left to whoever
actually wants one badly enough to bind it by hand in Settings.

## What each real setting means

Read straight from `Defaults.swift`'s own comments and enum definitions, not guessed:

| Setting | Value | What it means |
| --- | --- | --- |
| `alternateDefaultShortcuts` | `true` | Uses the Magnet-style default shortcut set (documented in [guides/shortcuts.md](shortcuts.md)) instead of Rectangle's original Spectacle-style set. |
| `subsequentExecutionMode` | `1` | Pressing a left/right half shortcut again while the window is already there cycles it to the next display instead of doing nothing. |
| `windowSnapping` | `2` | An `OptionalBoolDefault`, where `0` means unset, `1` means enabled, `2` means explicitly disabled. Dragging a window to a screen edge does not trigger a snap area. |
| `hideMenubarIcon` | `true` | Rectangle's menu bar icon is hidden, everything is driven through keyboard shortcuts instead. |
| `allowAnyShortcut` | `true` | Matches Settings' own "Remove keyboard shortcut restrictions" checkbox, removing Rectangle's default restriction against binding a shortcut that might conflict with a system-reserved combination. |

Cross-checked against Rectangle's own Settings window (Shortcuts and General tabs): every default
shortcut, the "Remove keyboard shortcut restrictions" and "Hide menu bar icon" checkboxes and the
"Repeated commands" dropdown matched. Centre Half and Almost Maximise showed an empty
"Record Shortcut" before this folder filled them in.

## Why Todo mode's 2 shortcuts live outside `WindowAction`

`reflowTodo` and `toggleTodo` are not entries in the `WindowAction` enum, they are separate
`UserDefaults` keys owned by `TodoManager`, confirmed via `Config.swift`'s reference to
`TodoManager.defaultsKeys` when building the exportable shortcut list. That is why they are
included as top-level `shortcuts` entries in `RectangleConfig.json` rather than as a
`WindowAction` case.

## Why 10 more shortcuts were added deliberately

Centre Half, Almost Maximise and 8 more actions (the 4 fourths, `moveUp`/`moveLeft`/`moveDown`/
`moveRight`) have no entry at all in `alternateDefault` or `spectacleDefault`, confirmed empty in
Rectangle's own Settings window too. Rather than leave genuinely useful actions unreachable by
keyboard, they were given real bindings: Centre Half and Almost Maximise stay in the same
`⌃ + ⌥` scheme as the shipped defaults since neither collides with an existing one, while the
fourths and moves use `⌃ + ⌥ + ⇧` so a wider expansion never risks colliding with Rectangle's own
default set on a future version. `W`/`A`/`S`/`D` were used for the moves rather than arrow keys
specifically because `⌃ + ⌥ + ⇧` + ↑ already belongs to Maximize Height.
