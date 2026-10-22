# Reference

## Plugin lists

Each `plugins/<ide>.txt` lists every non-bundled plugin installed in that IDE, grouped under `//`
category comments. Each line is `plugin.id@version`, both read from the plugin's own
`META-INF/plugin.xml`, not the folder name JetBrains uses on disk, which is often a shortened and
unstable identifier. What each plugin does is in [plugins.md](plugins.md).

A plugin id and version number do not change with the operating system the way a compiled binary
would, so there is one list per IDE rather than one per platform.

## Keymaps

The base keymap is `VSCode OSX` on macOS and `VSCode` on Windows and Linux, both supplied by the
`com.intellij.plugins.vscodekeymap` plugin. They give VS Code-equivalent shortcuts for the standard
editing, navigation and refactoring actions.

[`keymaps/`](../keymaps/) adds bindings on top for actions the base keymap leaves unbound. Each
action id was checked against the plugin's own `plugin.xml` first, since a wrong action id fails
silently rather than raising an error:

| Key (macOS / Windows and Linux) | Action id | What it does |
| --- | --- | --- |
| `cmd+alt+q` / `ctrl+alt+q` | `Console.Jdbc.Execute` | Run the current database console query |
| `cmd+alt+g` / `ctrl+alt+g` | `Git.Branches` | Open the Git branches popup |

## Toolbox settings

`toolbox/<platform>/settings.json` holds JetBrains Toolbox's user-configurable settings only, not
its auto-generated account and install state:

| Key | Value | What it does |
| --- | --- | --- |
| `shell_scripts.location` | Platform-specific, see below | Where Toolbox writes shell launcher scripts |
| `tools.update_all_automatically` | `true` | Auto-update every IDE Toolbox manages |
| `plugins.plugins_auto_updater` | `true` | Auto-update plugins across every IDE |
| `disk_usage.notification_threshold_bytes` | `10737418240` (10 GiB) | Warn when Toolbox's disk usage passes this |

`shell_scripts.location` is Toolbox's own default for each platform:

| Platform | `shell_scripts.location` |
| --- | --- |
| macOS | `~/Library/Application Support/JetBrains/Toolbox/scripts` |
| Linux | `~/.local/share/JetBrains/Toolbox/scripts` |
| Windows | `%LOCALAPPDATA%\JetBrains\Toolbox\scripts` |

Every other key is identical across all three files, checked in CI.

## What is deliberately not tracked

- **Per-IDE `options/*.xml`** - almost entirely generated usage state, feature flags and dismissed
  onboarding dialogs, not authored config.
- **Workspace state, caches and `.db` files** - regenerated automatically by the IDE.
- **`idea.key`** - the JetBrains licence activation file. A licence key is a credential, so it is
  never committed.
- **Toolbox account and install state** - `jetbrains_account.active` and the other files Toolbox
  generates on sign-in have no setting to reproduce.
