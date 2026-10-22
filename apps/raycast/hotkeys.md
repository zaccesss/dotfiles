# Hotkeys

## Symbol legend

| Symbol | Key |
| --- | --- |
| `⌘` | Command |
| `⌥` | Option (Alt) |
| `⌃` | Control (Raycast's own on-screen symbol for it, not the `^` caret character you get from Shift+6) |
| `⇧` | Shift |

Every modifier and key in a shortcut is joined with `+` below so a combination is never ambiguous
about how many keys are actually held down at once.

## Global

| Shortcut | Action | What it does |
| --- | --- | --- |
| `⌥` + Space | Open Raycast | Brings up Raycast's search bar from anywhere, the entry point to every command and Quicklink below. |

Every other binding below is a recommendation, since Raycast only stores hotkeys
in its own encrypted local database and offers no config file or CLI to set one from outside the
app. Setting one takes opening Raycast Settings, finding the command and recording the shortcut
against it directly. See [guides/reference.md](guides/reference.md#recommended-hotkeys) for why
each one was picked and the full command list each extension actually ships.

Every extension command and built-in feature below uses the same modifier pair, `⌥ + ⌃`, so muscle
memory transfers between them. A duplicate letter would collide, so each letter is used once.
Application Quicklinks are best kept on a different modifier pair such as `⌘ + ⌃`, so the two
kinds of binding never collide.

## Recommended: Spotify Player

| Shortcut | Command | What it does |
| --- | --- | --- |
| `⌥ + ⌃` + Space | Toggle Play/Pause | Pauses or resumes whatever is playing without switching to Spotify. |
| `⌥ + ⌃` + → | Next Track | Skips to the next track in the current queue. |
| `⌥ + ⌃` + ← | Previous Track | Goes back to the previous track. |
| `⌥ + ⌃` + ↑ | Volume Up | Raises Spotify's own playback volume one step. |
| `⌥ + ⌃` + ↓ | Volume Down | Lowers Spotify's own playback volume one step. |
| `⌥ + ⌃` + L | Like Current Song | Adds the currently playing track to your Liked Songs. |
| `⌥ + ⌃` + S | Toggle Shuffle | Turns shuffle play on or off for the current queue. |
| `⌥ + ⌃` + N | Now Playing | Opens a Raycast window showing the current track with playback controls, no need to switch to Spotify to see what's on. |

## Recommended: Kill Process

| Shortcut | Command | What it does |
| --- | --- | --- |
| `⌥ + ⌃` + K | Kill Process | Opens a searchable list of every running process and force-quits whichever one you pick. Faster than opening Activity Monitor for one hung app. |

## Recommended: Google Chrome

| Shortcut | Command | What it does |
| --- | --- | --- |
| `⌥ + ⌃` + T | Search Tabs | Searches every open Chrome tab by title or URL and jumps straight to it. |
| `⌥ + ⌃` + H | Search History | Searches Chrome's browsing history without opening Chrome first. |

## Recommended: Slack

| Shortcut | Command | What it does |
| --- | --- | --- |
| `⌥ + ⌃` + U | Unread Messages | Lists every channel and DM with unread messages and jumps straight to whichever one you pick. |

## Recommended: Raycast's own built-in features

These ship with Raycast itself, no extension install needed, worth turning on regardless of which
store extensions come and go.

| Shortcut | Feature | What it does |
| --- | --- | --- |
| `⌥ + ⌃` + V | Clipboard History | Shows everything recently copied to the clipboard, including text, links and images, then pastes whichever one you pick back in. |
| `⌥ + ⌃` + W | Window Management | Resizes and repositions the frontmost window into halves, thirds, quarters or full screen without dragging it by hand. |
| `⌥ + ⌃` + E | Emoji Search | Searches emoji by name or description and copies the one you pick to the clipboard. |
| `⌥ + ⌃` + C | Calculator | Evaluates a maths expression typed straight into Raycast and copies the result. |
