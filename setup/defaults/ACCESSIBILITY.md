# Accessibility

The scripts apply a handful of desktop preferences on macOS, GNOME and KDE Plasma. Several of them make the desktop easier to read and more predictable.

## Vision

- Dock icons are 128 points, against a macOS default of 48.
- The menu bar clock is digital with AM/PM and the day of the week. Seconds are hidden and the colon does not flash, so nothing on screen ticks or blinks.
- Finder opens in List view and every file extension is shown, so a file's type never has to be guessed.

## Motor

- Tap to click is off on macOS and GNOME, so a resting hand or a light brush on the trackpad never clicks.
- A two-finger tap or click is a right-click on macOS. Three-finger drag stays off.

## Predictability

- Spaces on macOS keep a fixed order instead of rearranging by recent use. On GNOME, workspaces stay fixed rather than being created and removed automatically.
- New Finder windows open to the home folder. Screenshots go to their own folder instead of the Desktop.

## KDE Plasma

- Two high contrast colour schemes, black on white and white on black, with no grey secondary
  text. The desktop switches between them by time of day.
- The pointer is size 48 and yellow with a black outline, so it stands out on light and dark
  backgrounds alike.
- Taskbar text is white in both themes over a tinted strip with a line along its top edge, so the
  taskbar's edge stays visible over any wallpaper. Very light wallpapers make the tray icons
  fainter, since the tint is light.
- Scroll bars keep an arrow at each end and stay visible in GTK apps instead of hiding until
  hovered.
- Discord and Kitty keep their sound and badge but no pop-ups over the screen.

## Not changed here

macOS's own Reduce motion, Increase contrast and display zoom settings live under System Settings, Accessibility. These scripts leave them alone.

## Feedback wanted

If something here gets in the way, open an [issue](https://github.com/zaccesss/dotfiles/issues/new/choose) describing what happened and what would work better.
