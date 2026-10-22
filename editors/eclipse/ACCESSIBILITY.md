# Accessibility

Visible line numbers, a highlighted current line, autosave and familiar VS Code keys, so Eclipse
reads and behaves like the other editors.

> [!NOTE]
> Some of these settings are preferences rather than requirements. Change them freely in your own
> copy. If a change would help other people too, open an issue or a pull request so I can consider
> it for everyone.

## Vision

- The current line is highlighted and line numbers are always on, so the cursor and an error's line
  are quick to find.
- The editor font is not set by the scripts, since Eclipse stores fonts in a platform-specific
  form. Set a size that reads comfortably once in the preferences, see
  [guides/setup.md](guides/setup.md#5-set-the-editor-font). `Cmd+=` and `Cmd+-` (`Ctrl+=` and
  `Ctrl+-` on Windows and Linux) zoom the editor text.
- The editor and Terminal view use Zacess Deep Contrast Dark from
  [Zacess Themes](https://github.com/zacesshq/themes) with Eclipse's own **Dark** workbench theme:
  white on pure black with deep, fully saturated colours. All eight Zacess themes are in `theme/`
  and the scripts import any of them. Measured contrast is in the
  [Zacess Themes accessibility statement](https://github.com/zacesshq/themes/blob/main/ACCESSIBILITY.md).
- Eclipse cannot follow the system light and dark setting, so the theme stays fixed until another
  one is imported.

## Reading and writing

- Spell checking is on for comments and strings, in British English.
- Editors save themselves every 20 seconds, so nothing depends on remembering to save before a run.

## Keyboard

- 15 bindings bring VS Code's keys to Eclipse: `Cmd+P` to open a file, `Cmd+Shift+P` for quick
  access, `F12` for open declaration, `F2` to rename and more (`Ctrl` in place of `Cmd` on Windows
  and Linux). The full table is in [guides/reference.md](guides/reference.md#key-bindings).
- **General > Keys** in the preferences lists every binding and lets any of them be changed from the
  keyboard.

> [!IMPORTANT]
> On macOS, `Ctrl+F5` belongs to the system (*Move focus to the window toolbar*), so run is
> `Cmd+Shift+F5` instead of VS Code's `Ctrl+F5`.

## Feedback wanted

If something here gets in the way, open an
[issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and
what would work better.

## The shared statement

> [!NOTE]
> I keep one shared accessibility statement for all my projects:
> [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on
> [my site](https://isaacadjei.me/accessibility). This file takes precedence where the two differ.
