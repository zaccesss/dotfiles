# Cross-Platform Preferences

This document defines user preferences independently of the operating system.

Platform-specific configuration files implement these preferences using the
native configuration mechanisms available on each platform.

## Clock

- Use a digital clock.
- Use a 12-hour clock with AM/PM where the platform supports it.
- Show the day of the week.
- Hide the date from the primary desktop clock.
- Hide seconds.

## File Manager

- Use list view as the default folder view where the platform supports it.
- Show complete file names and do not intentionally hide file extensions.

## Trash

- Automatically remove old items from the trash where the platform supports it.
- Use a 30-day retention period.

## Input

- Prefer physical clicking over tap-to-click where the platform supports it.
- Preserve accessible right-click behaviour.
- Do not prescribe a scrolling direction unless it is explicitly defined by the
  platform-specific preference set.

## Workspaces

- Prefer stable workspace ordering where the platform supports it.
- Do not force platform-specific workspace or display behaviour when there is
  no meaningful equivalent.

## Platform-Specific Preferences

Some settings are inherently tied to a platform and should remain in their
platform-specific implementation.

Examples include:

- macOS Dock and Mission Control behaviour
- macOS Finder-specific behaviour
- GNOME Shell behaviour
- Windows Explorer and taskbar behaviour
- macOS hot corners
