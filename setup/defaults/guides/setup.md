# Setup

Choose the implementation for the platform you are configuring.

## macOS

1. On a Mac already set up the way you like, record its settings with
   `bash mac/defaults.sh --capture`. Only keys listed in [mac/tracked.txt](../mac/tracked.txt) that
   are actually set get recorded in `mac/defaults.tsv`. The file shipped here holds example values.
2. Review `mac/defaults.tsv` and [guides/reference.md](reference.md), since applying changes real
   system behaviour.
3. Apply it on the next Mac with `bash mac/defaults.sh`. Only values that differ are written, and
   the Dock, Finder or SystemUIServer restart only when one of their own settings changed.
4. Settings macOS refuses to write from a script (some accessibility ones) are listed at the end so
   they can be set in System Settings.

To carry another setting, add its `domain key` line to `mac/tracked.txt` and capture again.

A colour setting, such as a custom pointer fill or outline, is a dictionary in macOS. It is
captured as its red, green, blue and alpha values on one line (type `colour`) and written back as
the same dictionary.

## Windows

1. On a PC set up the way you like, record its settings with `.\windows\defaults.ps1 -Capture`.
   [windows/tracked.txt](../windows/tracked.txt) lists the registry values, all under
   HKEY_CURRENT_USER, so no administrator rights are needed. The values file ships empty.
2. On the next PC, preview with `.\windows\defaults.ps1 -Plan`, then apply with
   `.\windows\defaults.ps1`. Only values that differ are written.
3. Explorer restarts only when a taskbar or Explorer setting changed. Some input and accessibility
   settings apply after signing out and back in; the script says when.

An expandable path (such as the Screenshots folder) counts as matching whether Windows stores it
with `%USERPROFILE%` or spelt out in full, so it is not rewritten on every run.

The screen saver values are in `tracked.txt`. Display and sleep timeouts belong to the power plan
rather than the registry, so set them with `powercfg /change` instead. After checking the screen
saver in Settings, close the Screen Saver window with **Cancel**. Clicking **OK** saves whatever
the window shows, which can reset the wait and the password on resume. If it was clicked, run
`windows/defaults.ps1` again to restore the captured values.

## Linux

1. Review [linux/defaults.sh](../linux/defaults.sh) and [guides/reference.md](reference.md) first,
   since this script changes real desktop behaviour the moment it runs.
2. Confirm the required GNOME settings are available with `gsettings`.
3. Run it: `bash linux/defaults.sh`.
4. The script applies only settings for schemas and keys available in the current GNOME environment.

## Cross-Platform Preferences

[common/preferences.md](../common/preferences.md) defines the preferences independently of the
operating system.

Platform implementations use native configuration mechanisms and only translate a preference
when the platform provides a meaningful equivalent.

## Why this is safe to run more than once

Every implementation should set values outright rather than toggle or increment them, so running
it a second time leaves the system in the same intended state as the first run.

## Reverting a setting

Each platform uses its own native mechanism for reverting settings. The platform-specific
reference documentation should describe how individual overrides can be removed or restored to
the operating system's built-in default.
