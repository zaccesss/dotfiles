# Accessibility

Larger text, a high contrast theme and saving that never depends on memory, so Arduino IDE reads like the other editors.

## Vision

- Editor text is GeistMono Nerd Font at 16 points, larger than the default 14. **File > Preferences** also has **Interface scale**, which grows the whole window.
- The theme is Zacess Deep Contrast Dark from [Zacess Themes](https://github.com/zacesshq/themes) 0.4.0: white on pure black with deep, fully saturated colours. All eight Zacess themes install together and any of them can be picked with `--theme` or under **Theme** in the preferences. Measured contrast is in the [Zacess Themes accessibility statement](https://github.com/zacesshq/themes/blob/main/ACCESSIBILITY.md).
- Colour is never the only signal: keywords are also bold in every Zacess theme.

## Reading and writing

- Sketches save themselves shortly after each change, so an upload never runs on an unsaved file.
- Suggestions only appear when asked for (`Ctrl+Space`), so the text being typed is not covered by a popup.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.
