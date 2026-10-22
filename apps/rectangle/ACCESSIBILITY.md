# Accessibility

Rectangle moves and resizes windows from the keyboard, so window layout never depends on precise dragging. It works through macOS's own Accessibility APIs, so macOS asks for Accessibility permission on first launch.

> [!NOTE]
> Some of these settings are preferences rather than requirements. Change them freely in your own copy. If a change would help other people too, open an issue or a pull request so I can consider it for everyone.

## Keyboard and motor

- The Magnet-style default shortcuts put a window into halves, corners, thirds or full screen with one key combination, nearly all on `Control+Option`. 12 custom bindings add Todo mode and fill gaps the defaults leave. Every shortcut is listed in [guides/shortcuts.md](guides/shortcuts.md).
- Pressing a left or right half shortcut again moves the window on to the next display, so no extra shortcut is needed.
- Snapping when a window is dragged to a screen edge is off, so an accidental drag never resizes a window.
- The menu bar icon is hidden and everything runs from the keyboard.

> [!WARNING]
> VoiceOver uses Control+Option as its own modifier, the VO keys, so with VoiceOver running the default shortcuts collide with VoiceOver commands. Set the VoiceOver modifier to Caps Lock in VoiceOver Utility. Another fix is moving the shortcuts to Command+Control in Rectangle's settings.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.

## The shared statement

> [!NOTE]
> I keep one shared accessibility statement for all my projects: [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on [my site](https://isaacadjei.me/accessibility). This file takes precedence where the two differ.
