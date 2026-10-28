# Accessibility

Large editor text, autosave, colours that keep macros apart from functions and the VS Code keys that are already habit, so STM32CubeIDE reads and behaves like the other editors.

> [!NOTE]
> Some of these settings are preferences rather than requirements. Change them freely in your own copy. If a change would help other people too, open an issue or a pull request so I can consider it for everyone.

## Vision

- Editor and console text is GeistMono Nerd Font at 18 points on the Mac and 14 on Windows and Linux (the same size on screen), larger than STM32CubeIDE's default. The C editor uses the same font. `Ctrl+=` and `Ctrl+-` (`Cmd+=` and `Cmd+-` on the Mac) zoom the editor text.
- The current line is highlighted and line numbers are always on, so the cursor and an error's line are quick to find.
- The editor uses Zacess Deep Contrast Dark from [Zacess Themes](https://github.com/zacesshq/themes) 0.5.0 with the **Dark** workbench theme: white on pure black with deep, fully saturated colours and a yellow outline on the focused tab. All eight Zacess themes are in `shared/theme/`; the apply scripts merge any of them with `--theme` (`-Theme` on Windows). Measured contrast is in the [Zacess Themes accessibility statement](https://github.com/zacesshq/themes/blob/main/ACCESSIBILITY.md).
- Macros and directives have their own colour, separate from functions and keywords in every theme, so a HAL macro is never confused with a function call. Colour is never the only signal: keywords are also bold.
- STM32CubeIDE cannot follow the system light and dark setting, so the theme stays fixed until another one is merged.
- The Terminal uses the Mono build of the same font, so the prompt's symbols draw inside one cell.

## Reading and writing

- Spell checking is on for comments and strings, C files included, in British English.
- Editors save themselves every 20 seconds, so nothing depends on remembering to save before a build or a flash.

## Keyboard

- 15 bindings bring VS Code's keys to STM32CubeIDE: `Ctrl+P` to open a file, `Ctrl+Shift+P` for quick access, `F12` for open declaration, `F2` to rename and `F5` to build, flash and debug again (`Cmd` in place of `Ctrl` on the Mac). The full table, with STM32CubeIDE's own default for each, is in [guides/reference.md](guides/reference.md#key-bindings).
- **General > Keys** in the preferences lists every binding and lets any of them be changed from the keyboard.

> [!IMPORTANT]
> On the Mac, `Ctrl+F5` belongs to macOS (*Move focus to the window toolbar*), so run is `Cmd+Shift+F5` instead of VS Code's `Ctrl+F5`.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.

## The shared statement

> [!NOTE]
> I keep one shared accessibility statement for all my projects: [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on [my site](https://isaacadjei.me/accessibility). This file takes precedence where the two differ.
