# Accessibility

A taskbar whose text stays readable over any wallpaper.

## Vision

- With Windows mode Dark the taskbar has white text and icons. Windows cannot change the taskbar's
  text colour with the wallpaper, so a fixed light-on-dark pair is the choice that holds everywhere.
- Over the desktop the taskbar is a dark grey tint at 65 percent with no blur, so the wallpaper
  stays sharp behind it but muted rather than showing through at full strength.
- With a window maximised or battery saver on, the taskbar is solid dark grey, which gives the
  white text its full contrast.

## Known gap

Over a very bright, busy wallpaper the tinted taskbar has less contrast than the solid one, more so
with no blur to soften the detail behind the text. A `blur_radius` above 0 softens it again. Setting
`desktop_appearance.accent` to `opaque` in [`windows/settings.json`](windows/settings.json) makes it
solid everywhere.

## Feedback wanted

If something here gets in the way, open an issue describing what happened and what would work better.
