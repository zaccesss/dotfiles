# Accessibility

The Zacess high contrast colours in the editor and familiar default keys, so Xcode reads like the
other editors.

> [!NOTE]
> Some of these settings are preferences rather than requirements. Change them freely in your own
> copy. If a change would help other people too, open an issue or a pull request so I can consider
> it for everyone.

## Vision

- The editor uses Zacess Deep Contrast Dark from
  [Zacess Themes](https://github.com/zacesshq/themes) in Xcode 27: white on pure black with deep,
  fully saturated colours. All eight Zacess themes are in `theme/` and the script installs every
  one: Light, Dark, Yellow on Black, Cream, High Contrast Dark, High Contrast Light, Deep Contrast
  Dark and Deep Contrast Light. Measured contrast is in the
  [Zacess Themes accessibility statement](https://github.com/zacesshq/themes/blob/main/ACCESSIBILITY.md).
- Colour is never the only signal in the themes: keywords are bold, comments are italic and
  documentation tags are bold italic.
- Zacess Deep Contrast Dark is set for both the light and the dark appearance, so the editor stays
  the same when macOS switches. Another Zacess theme is chosen in **Settings...**, **Themes**, see
  [guides/setup.md](guides/setup.md#4-choose-a-theme).
- The editor font is Xcode's default, SF Mono at 12 points, as set by the themes. `Cmd+=` and
  `Cmd+-` make the editor text larger and smaller.

## Keyboard

- The key bindings are Xcode's own defaults, with no custom bindings yet. **Settings...**,
  **Key Bindings** lists every one and lets any of them be changed from the keyboard.

## Feedback wanted

If something here gets in the way, open an
[issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and
what would work better.

## The shared statement

> [!NOTE]
> I keep one shared accessibility statement for all my projects:
> [zaccesss/accessibility](https://github.com/zaccesss/accessibility) or on
> [my site](https://isaacadjei.me/accessibility). This file takes precedence where the two differ.
