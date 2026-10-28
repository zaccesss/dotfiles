# Accessibility

The settings put readability first and every custom shortcut follows one pattern.

> [!NOTE]
> Some of these settings are preferences rather than requirements. Change them freely in your own copy. If a change would help other people too, open an issue or a pull request so I can consider it for everyone.

## Vision

- The colour theme is `Zacess Deep Contrast Dark` from the [Zacess Themes](https://marketplace.visualstudio.com/items?itemName=zacess.zacess-themes) extension: white on pure black with deep, fully saturated colours at about 9:1 and yellow and cyan outlines.
- The integrated terminal takes its 16 colours from the same theme. Bold text keeps its colour.
- Word wrap is on, so long lines never need horizontal scrolling. `Cmd+Alt+W` (`Ctrl+Alt+W` on Windows and Linux) switches it off for one file.
- The editor font is 14 points. Raise `editor.fontSize` in `settings.json` as needed.
- Git changes in the gutter have a shape as well as a colour: added and modified lines carry a striped mark, deleted lines a triangle. The diff editor draws `+` and `-` beside each changed line. The current line is marked across the text and the gutter.
- Text in the integrated terminal is held to 4.5:1 on whatever sits behind it (`terminal.integrated.minimumContrastRatio`), so a program's own colour pairs can never vanish.

> [!TIP]
> The theme stays on `Zacess Deep Contrast Dark` whatever the system appearance, since `window.autoDetectColorScheme` is `false`. All eight Zacess themes are in the theme picker (`Cmd+K Cmd+T`, `Ctrl+K Ctrl+T` on Windows and Linux). Set `window.autoDetectColorScheme` to `true` to switch between `Zacess Deep Contrast Dark` and `Zacess Deep Contrast Light` with the system instead.

## Keyboard

- Every custom shortcut starts with `Cmd+Alt` on macOS or `Ctrl+Alt` on Windows and Linux, some with Shift added, so there is one pattern to remember.
- [jetbrains](../jetbrains) uses the same pair. `Cmd+Alt+Q` runs a database query in both editors.
- Shortcuts cover focusing the terminal, running tests, toggling inline diagnostics and opening a markdown preview beside the editor. The full list is in [guides/reference.md](guides/reference.md).

## Memory

- Files save automatically when focus leaves VS Code, so switching apps never loses work.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.

## The shared statement

> [!NOTE]
> I keep one shared accessibility statement for all my projects: [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on [my site](https://isaacadjei.me/accessibility). This file takes precedence where the two differ.
