# Accessibility

A high contrast text editor for HDL, Tcl and constraints with Geist Mono, so Vivado reads like the other editors.

> [!WARNING]
> Not yet checked against a real Vivado install. See the [README](README.md).

## Vision

- The text editor uses Zacess Deep Contrast Dark from [Zacess Themes](https://github.com/zacesshq/themes) 0.4.0: white on pure black with deep, fully saturated syntax colours. Any of the eight Zacess themes can be applied with `--theme` (`-Theme` on Windows).
- Every text style is at least 7:1 on the background, the current line and the selection in the Deep Contrast and High Contrast themes and at least 4.5:1 in the others.
- Colour is never the only signal: keywords and control flow are bold while comments are italic.
- Editor text is Geist Mono at the size already set in **Tools > Settings > Text Editor**.
- Vivado's window theme is picked by hand, so the editor can be matched with a dark or light window.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.
