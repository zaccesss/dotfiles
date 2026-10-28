# Accessibility

A high contrast editor and console, line numbers at full strength and Geist Mono, so sketches read like the other editors.

## Vision

- The theme is Zacess Deep Contrast Dark from [Zacess Themes](https://github.com/zacesshq/themes) 0.5.0: white on pure black with deep, fully saturated syntax colours. All eight Zacess themes are in `shared/themes/` and any of them can be applied with `--theme`.
- Syntax colours and interface text are at least 7:1 on what they sit on in the Deep Contrast and High Contrast themes (the current line included) and at least 4.5:1 in the others. The selection is a fill under the token's own colour, held to 4.5:1 in every theme, Zacess Themes' selection rule.
- Line numbers are drawn at full strength. Processing's own themes fade them to 40 percent.
- Colour is never the only signal: keywords, control flow and the `setup` and `draw` callbacks are also bold.
- Editor text is GeistMono Nerd Font Mono. **Processing > Settings** keeps its own size and zoom controls. `Cmd+=` and `Cmd+-` (`Ctrl` on Linux and Windows) zoom the editor.
- Processing cannot follow the system light and dark setting, so the theme stays fixed until another one is applied.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.
