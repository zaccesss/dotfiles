# Reference

## Why there is no Linux or Windows folder

Raycast is macOS only, so there is nothing to mirror across platforms.

## Why extensions.txt has no version

Raycast Store extensions auto-update in the background. There is no setting to pin a version and no
version number exposed in the local extension folder, only the author's account and the
extension's own slug. `extensions.txt` therefore records identity (`slug@author`) and not version.

## Recommended hotkeys

Raycast stores every hotkey inside its own encrypted local database
(`~/Library/Application Support/com.raycast.macos/raycast-enc.sqlite`), with no export, config
file or CLI to read or write one from outside the app. So [hotkeys.md](../hotkeys.md) records
recommendations to apply by hand in Raycast Settings, not a state that can be imported.

The picks use one consistent modifier pair, `⌥⌃`, across every extension, so muscle memory
transfers between Spotify, Slack, Chrome and the rest instead of each command needing its own
scheme. Each one binds a command the matching extension ships, checked against the extension's own
commands rather than guessed from its README.

## Why keep Quicklinks on a different modifier pair

A Quicklink that opens an application is best kept on its own modifier combination, such as `⌘⌃`,
separate from `⌥⌃`'s extension commands and built-in features. The two kinds of binding then never
collide and stay easy to tell apart by feel alone. A letter can repeat across groups since the full
combination still differs.

## The store extensions

| Extension | Author | Package name |
| --- | --- | --- |
| Spotify Player | mattisssa | `spotify-player` |
| Kill Process | rolandleth | `kill-process` |
| Google Chrome | Codely | `google-chrome` |
| Slack | mommertf | `slack` |

What each one does is in [extensions.md](extensions.md).
