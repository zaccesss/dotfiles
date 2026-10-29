# Accessibility

What Zacess Games does on screen, in sound and at the keyboard once this folder has set it up. Nothing here changes a game's own defaults.

- **The theme follows `zt`.** The games take the colours of the Zacess theme the terminal is on. Every colour keeps at least 4.5:1 contrast on the theme's background and at least 7:1 on the High Contrast and Deep Contrast themes. Every cell is painted on the theme's own background, so the contrast holds even when the terminal is on another theme.
- **Colour is never the only signal.** Every piece, tile and state has a shape or letter of its own as well. `zg --basic` swaps the geometric shapes for plain characters when a font lacks them.
- **Nothing flashes.** No large area changes more than three times a second. Clears, merges and wins are marked by a calm change of shape rather than blinking.
- **Reduced motion.** `zg --reduced-motion`, `ZACESS_REDUCED_MOTION=1` or the system setting slows every game that runs in time. Only six of the fourteen games run in time at all.
- **Sound.** Effects start at 35 and music at 20, out of 100. `+` and `-` set the effects, `]` and `[` the music and `0` mutes everything. The status bar always shows both levels and changes are remembered. Every effect has a written twin on screen and music never carries meaning, so every game plays the same muted. `zg --no-sound` starts muted.
- **Keyboard only.** `Space` pauses (`Esc` in the typing games), `?` shows how to play (`F1` in the typing games) and `Ctrl+C` always leaves with the terminal restored. Arrow keys and `H`, `J`, `K` and `L` both move. Letters work in either case outside the typing games. The mouse is never needed.
- **Screen readers.** A plain line says which game started and how to pause, get help and quit before the screen is taken over, so a screen reader announces it.
- **Size.** Every game fits a window from 60 by 20. From 160 by 45 boards are drawn at twice the size, which helps at a distance.

Many of these are preferences. Change them in your own copy. Open an issue or a pull request if a change would help others.

> [!NOTE]
> **The shared statement.** The full statement for the games is in [zacesshq/games ACCESSIBILITY.md](https://github.com/zacesshq/games/blob/main/ACCESSIBILITY.md). The general statement for my projects is in [zaccesss/accessibility](https://github.com/zaccesss/accessibility) and on [isaacadjei.me/accessibility](https://isaacadjei.me/accessibility). This file takes precedence where they differ.
