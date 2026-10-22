# Setup

## Extensions

1. Install [Raycast](https://raycast.com).
2. Open Raycast, search Store and install each extension listed in
   [extensions.txt](../extensions.txt) by its slug (the part before `@`).
3. Sign in to Spotify and Slack from within their own extension preferences. Both need
   authentication that this folder never stores.

## Hotkeys

Raycast has no import for hotkeys, so each one in [hotkeys.md](../hotkeys.md) is entered by hand.

1. Open Raycast Settings, Extensions tab.
2. Find the extension, then the specific command inside it.
3. Click the Hotkey field and record the shortcut shown in the table.

Raycast's own built-in features, such as Clipboard History and Window Management, are in the same
Extensions tab under their own names.

## Why this cannot be automated further

Raycast keeps extensions and hotkeys in its own encrypted local database with no CLI, no export and
no settings file to script against. See [reference.md](reference.md#recommended-hotkeys).
