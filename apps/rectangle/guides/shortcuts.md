# Shortcuts

Every shortcut below is confirmed real: the 22 defaults come straight from Rectangle's own source
(`WindowAction.swift`'s `alternateDefault` for each action, active because
`alternateDefaultShortcuts` is `true` in `RectangleConfig.json`). The 2 Todo mode bindings are
custom. The 10 more under "Custom: filling real gaps"
were added deliberately, actions Rectangle ships with no default at all, confirmed empty
("Record Shortcut") in Rectangle's own Settings window. None were guessed.

## Active default shortcuts (Magnet-style)

`alternateDefaultShortcuts: true` switches Rectangle from its own original scheme to a set that
matches Magnet, another window manager, rather than Spectacle's older scheme.

| Shortcut | Action | What it does |
| --- | --- | --- |
| `⌃ + ⌥` + ← | Left Half | Snaps the window to the left half of the screen. |
| `⌃ + ⌥` + → | Right Half | Snaps the window to the right half of the screen. |
| `⌃ + ⌥` + ↑ | Top Half | Snaps the window to the top half of the screen. |
| `⌃ + ⌥` + ↓ | Bottom Half | Snaps the window to the bottom half of the screen. |
| `⌃ + ⌥` + U | Top Left | Snaps the window to the top-left quarter of the screen. |
| `⌃ + ⌥` + I | Top Right | Snaps the window to the top-right quarter of the screen. |
| `⌃ + ⌥` + J | Bottom Left | Snaps the window to the bottom-left quarter of the screen. |
| `⌃ + ⌥` + K | Bottom Right | Snaps the window to the bottom-right quarter of the screen. |
| `⌃ + ⌥` + Return | Maximize | Expands the window to fill the entire screen. |
| `⌃ + ⌥ + ⇧` + ↑ | Maximize Height | Expands the window to the screen's full height without changing its width. |
| `⌃ + ⌥` + Delete | Restore | Undoes the last Rectangle action, returning the window to its previous size and position. |
| `⌃ + ⌥` + `=` | Larger | Grows the window one step in whichever direction it's already snapped. |
| `⌃ + ⌥` + `-` | Smaller | Shrinks the window one step in whichever direction it's already snapped. |
| `⌃ + ⌥` + C | Center | Centres the window on the screen at its current size. |
| `⌃ + ⌥ + ⌘` + ← | Previous Display | Moves the window to the previous display, same relative position and size. |
| `⌃ + ⌥ + ⌘` + → | Next Display | Moves the window to the next display, same relative position and size. |
| `⌃ + ⌥` + D | First Third | Snaps the window to the left third of the screen. |
| `⌃ + ⌥` + F | Center Third | Snaps the window to the middle third of the screen. |
| `⌃ + ⌥` + G | Last Third | Snaps the window to the right third of the screen. |
| `⌃ + ⌥` + E | First Two Thirds | Snaps the window to the left two-thirds of the screen. |
| `⌃ + ⌥` + T | Last Two Thirds | Snaps the window to the right two-thirds of the screen. |
| `⌃ + ⌥` + R | Center Two Thirds | Snaps the window to the middle two-thirds of the screen, leaving equal margins on each side. |

That is every action with a real Rectangle-shipped default binding, all 22 rows above. Everything
below this point in Rectangle's own menu (sixths, eighths, ninths, twelfths, sixteenths, per-display
jumps, `tileAll`, `cascadeAll` and the rest) still has no keyboard shortcut,
reachable only from Rectangle's menu bar item or a screen-edge snap area. See
[guides/reference.md](reference.md#why-most-actions-have-no-shortcut) for why that's a real,
deliberate state rather than a gap.

## Custom: Todo mode

Rectangle's Todo mode pins a narrow sidebar window to one edge of the screen, useful for a
reference window (notes, a todo list, a chat window) kept visible alongside a maximised main
window. Both bindings below are custom, not a default Rectangle ships with.

| Shortcut | Action | What it does |
| --- | --- | --- |
| `⌃ + ⌥` + B | Toggle Todo | Turns Todo mode on or off for the frontmost window, pinning or unpinning it as the sidebar window. |
| `⌃ + ⌥` + N | Reflow Todo | Re-flows the remaining windows around the current Todo sidebar window. |

## Custom: filling real gaps

2 actions Rectangle ships with no default at all, both confirmed empty ("Record Shortcut") in
Rectangle's own Settings window, given a shortcut in the same `⌃ + ⌥` scheme as the defaults above.

| Shortcut | Action | What it does |
| --- | --- | --- |
| `⌃ + ⌥` + H | Centre Half | Snaps the window to a centred half-width column, full height. |
| `⌃ + ⌥` + M | Almost Maximise | Expands the window to nearly fill the screen, leaving a small margin on every edge, unlike Maximise which fills it completely. |

8 more actions with no Rectangle default, added on a separate modifier, `⌃ + ⌥ + ⇧`, so they never
collide with the bindings above: the 4 quarter-width columns Rectangle calls fourths, plus a
WASD-style nudge for moving a window without resizing it.

| Shortcut | Action | What it does |
| --- | --- | --- |
| `⌃ + ⌥ + ⇧` + 1 | First Fourth | Snaps the window to the leftmost quarter-width column of the screen. |
| `⌃ + ⌥ + ⇧` + 2 | Second Fourth | Snaps the window to the second quarter-width column from the left. |
| `⌃ + ⌥ + ⇧` + 3 | Third Fourth | Snaps the window to the third quarter-width column from the left. |
| `⌃ + ⌥ + ⇧` + 4 | Last Fourth | Snaps the window to the rightmost quarter-width column of the screen. |
| `⌃ + ⌥ + ⇧` + W | Move Up | Nudges the window up by a fixed step without changing its size. |
| `⌃ + ⌥ + ⇧` + A | Move Left | Nudges the window left by a fixed step without changing its size. |
| `⌃ + ⌥ + ⇧` + S | Move Down | Nudges the window down by a fixed step without changing its size. |
| `⌃ + ⌥ + ⇧` + D | Move Right | Nudges the window right by a fixed step without changing its size. |

`W`/`A`/`S`/`D` were picked over the arrow keys for the move actions specifically because
`⌃ + ⌥ + ⇧` + ↑ is already Maximize Height's shortcut above, arrow keys would have collided.
