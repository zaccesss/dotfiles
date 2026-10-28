# Accessibility

High contrast canvases and layer colours that stay apart, so schematics and boards read like the other editors.

## Vision

- Every editor uses Zacess Deep Contrast Dark from [Zacess Themes](https://github.com/zacesshq/themes) 0.5.0: a black canvas with white board edges and deep, fully saturated layer and net colours. All eight Zacess themes install together and any of them can be picked with `--theme` or under **Preferences > Colors**.
- Schematic text (references, values, pin names and numbers, labels and notes) is at least 7:1 on the canvas and on a symbol's fill in the Deep Contrast and High Contrast themes and at least 4.5:1 in the others. Wires, buses, pins, the grid and every board and Gerber layer are at least 3:1.
- Top copper stays red and bottom copper blue, as in KiCad's own themes, so boards look familiar and other people's screenshots still make sense.
- Colour is never the only signal: KiCad names every layer in the Appearance panel and can show one layer at a time. Net names are drawn on tracks and pads.
- KiCad cannot follow the system light and dark setting, so the theme stays fixed until another one is applied.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.
