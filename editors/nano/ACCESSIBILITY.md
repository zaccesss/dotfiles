# Accessibility

> Part of [nano](README.md). What the nano config changes on screen and at the keyboard.

## Contrast

Every interface colour comes from the Zacess palette through [`build-themes.py`](../../terminal/terminal/scripts/build-themes.py). nano takes a colour as three hex digits and shows the nearest of the 216 colours in the terminal's colour cube, so the generator measures each pair as nano shows it rather than as the palette has it. It stops if a text colour falls under 4.5:1. The lowest text contrast across the eight themes is 5.4:1 (the error bar on the light themes) and the title bar keeps at least 6.45:1.

| What | Colour slot | Floor |
| --- | --- | --- |
| Title bar, status line, prompts and key tags | Accent text on the accent | 4.5:1 |
| Editor text and the function names in the help lines | Foreground on the theme background | 4.5:1 |
| Line numbers | Muted text on the theme background | 4.5:1 |
| Selected text | Selection text on the selection background | 4.5:1 |
| Search match | Foreground on the find match highlight | 4.5:1 |
| Error bar | The theme's red under whichever of its foreground and background reads better | 4.5:1 |
| Scrollbar | Muted text, not text itself | 3:1 |

Syntax highlighting uses nano's own definitions, which name the terminal's sixteen colours, so it has the contrast of the terminal palette the Zacess theme set.

## Colour is never the only signal

- The cursor position is written on the status line at all times (`constantshow`) and the mode flags sit top right (`stateflags`), so where the cursor is and whether the mark is on are read as text.
- Line numbers are on, so a position is a number as well as a place on screen.
- A modified file shows a star after its name in the title bar.
- The bottom two lines name every key, so no shortcut has to be remembered.

## Keyboard

`Ctrl+S` saves, `Ctrl+Q` quits, `Ctrl+Z` undoes, `Ctrl+Y` redoes and `Ctrl+F` finds, the same keys as VS Code, so the hands do not change between editors. nano's own keys stay too. `Ctrl+T` then `Ctrl+Z` suspends, since `Ctrl+Z` alone is undo. The mouse is on for the cursor and the menus but nothing needs it.

## Layout

The title bar, the text, the status line and the two help lines are always in the same places. Long lines wrap at a space (`softwrap`, `atblanks`) instead of scrolling sideways, so nothing sits off screen.

## Motion

nano draws nothing that moves on its own.

## Where it does not apply

Apple's `/usr/bin/nano` is Pico, which reads no configuration file, so none of this reaches it. Homebrew's GNU nano, which the Brewfile installs, is the one on `PATH` on a Mac that has run the bootstrap.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.

> [!NOTE]
> I keep one shared accessibility statement for all my projects: [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on [my site](https://isaacadjei.me/accessibility). This file takes precedence where the two differ.
