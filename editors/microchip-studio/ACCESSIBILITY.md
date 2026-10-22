# Accessibility

Larger text in a high contrast theme, with C macros kept apart from function calls by colour and weight.

## Vision

- Editor and output window text is GeistMono Nerd Font at 14 points, larger than Microchip Studio's default 10.
- The theme is Zacess Deep Contrast Dark from [Zacess Themes](https://github.com/zacesshq/themes) 0.4.0: white on pure black with deep, fully saturated colours. The window chrome uses the Dark environment theme to match. All eight Zacess themes are in `themes/`; `-Theme` imports any of them. Measured contrast is in the [Zacess Themes accessibility statement](https://github.com/zacesshq/themes/blob/main/ACCESSIBILITY.md).
- Macros and directives have their own colour, separate from functions and keywords in every theme, so a register macro is never confused with a function call.
- Colour is never the only signal: keywords, directives and macros are also bold.
- **Tools > Options > Environment > Fonts and Colors** changes any font or colour from the keyboard.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.
