# Accessibility

High contrast colours across the schematic, the PCB layout and the graphs, so Proteus reads like the other tools.

## Vision

- The default is Zacess Deep Contrast Dark: a black paper, white text and outlines and fully saturated wire, probe and layer colours. All eight Zacess themes are available, light ones included. Proteus's own colours come back with `-Theme proteus`.
- Selected parts take the theme's focus colour (yellow in Deep Contrast Dark), which no wire or outline uses, so a selection always stands out.
- PCB layers keep their usual hues in every theme: top copper red and bottom copper blue. Layers can still be told apart by name in the layer list, so colour is never the only signal.
- Measured contrast for each theme is in the [Zacess Themes accessibility statement](https://github.com/zacesshq/themes/blob/main/ACCESSIBILITY.md).

## Predictability

- New designs start in the chosen theme because every installed template carries it. An existing design only changes when it is named with `-Project`.
- Every colour can still be changed per design from the Template menu.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.
