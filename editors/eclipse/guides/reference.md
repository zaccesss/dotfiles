# Reference

Every preference explained, the key bindings and the plugin list.

## Where Eclipse keeps these

Each workspace has its own preferences in `<workspace>/.metadata/.plugins/org.eclipse.core.runtime/.settings/`, one `.prefs` file per plugin. They are Java properties files: `key=value` per line, with `=` inside a value written as `\=` and a line break as `\n`. A new workspace starts on Eclipse's defaults, which is why the merge script takes the workspace path as an argument.

Each fragment in [`prefs/`](../prefs/) is named after the file it merges into. Lines starting with `#` are notes and are never written to the workspace.

## `org.eclipse.jdt.core.prefs`

| Key | Value | Why |
| --- | --- | --- |
| `org.eclipse.jdt.core.compiler.compliance` | `25` | Java SE 25 is the current LTS release, so new projects default to its language level. |
| `org.eclipse.jdt.core.compiler.source` | `25` | Accepts Java 25 syntax. |
| `org.eclipse.jdt.core.compiler.codegen.targetPlatform` | `25` | Class files built for a Java 25 runtime. |
| `org.eclipse.jdt.core.compiler.release` | `enabled` | Compiles against the Java 25 API itself (`--release 25`), so code that only builds on a newer JDK is caught. |

## `org.eclipse.ui.editors.prefs`

| Key | Value | Why |
| --- | --- | --- |
| `lineNumberRuler` | `true` | Line numbers on, to match compiler errors and stack traces to their line. |
| `spacesForTabs` | `true` | The Tab key inserts spaces, so code looks the same pasted into a report or another editor. |
| `tabWidth` | `4` | Four spaces per indent, the Java convention. |
| `highlightCurrentLine` | `true` | Shades the line holding the cursor, so it is easy to find again. |
| `spellingEnabled` | `true` | Spell checks comments and strings. |

## `org.eclipse.jdt.ui.prefs`

| Key | Value | Why |
| --- | --- | --- |
| `spelling_locale` | `en_GB` | British English for the spell checker instead of the US default. |

## `org.eclipse.ui.workbench.prefs`

| Key | Value | Why |
| --- | --- | --- |
| `SAVE_AUTOMATICALLY` | `true` | Saves open editors on its own. |
| `SAVE_AUTOMATICALLY_INTERVAL` | `20` | Every 20 seconds, so a crash or a closed lid loses very little. |
| `org.eclipse.ui.commands` | the key binding XML | The 15 user key bindings below. Eclipse stores every user binding in this one value, so it is merged as a whole. |

The editor font is left out on purpose. Eclipse stores a font as a string that ends in the windowing system (`COCOA` on macOS, for example) and a native font name, so one string cannot serve every platform. Set it once by hand, see [setup.md](setup.md#5-set-the-editor-font). The same goes for the Terminal view font, where a Nerd Font such as GeistMono Nerd Font draws prompt symbols.

## Key bindings

Eclipse writes modifiers as `M1` to `M4` so one binding works on every platform: `M1` is `Cmd` on the Mac and `Ctrl` elsewhere, `M2` is `Shift`, `M3` is `Option` on the Mac and `Alt` elsewhere and `M4` is `Ctrl` on the Mac only. The 15 bindings cover 12 actions. They sit on top of Eclipse's default scheme and bring the keys VS Code users already know.

| Action | Mac | Windows and Linux | Where it works | Eclipse's default |
| --- | --- | --- | --- | --- |
| Open resource (find a file by name) | `Cmd+P` | `Ctrl+P` | Everywhere | `Cmd+Shift+R` (`Ctrl+Shift+R`). Print loses `Cmd+P` |
| Quick access (the command palette) | `Cmd+Shift+P` | `Ctrl+Shift+P` | Everywhere, plus a second binding in the Java editor | `Cmd+3` (`Ctrl+3`) |
| Delete line | `Cmd+Shift+K` | `Ctrl+Shift+K` | Text editors | `Cmd+D` (`Ctrl+D`) |
| Copy line down | `Shift+Option+Down` | `Shift+Alt+Down` | Text editors and the Java editor | `Cmd+Option+Down` (`Ctrl+Alt+Down`) |
| Copy line up | `Shift+Option+Up` | `Shift+Alt+Up` | Text editors and the Java editor | `Cmd+Option+Up` (`Ctrl+Alt+Up`) |
| Rename symbol | `F2` | `F2` | Java editor | `Shift+Option+R` (`Shift+Alt+R`) |
| Open declaration | `F12` | `F12` | Java editor | `F3` |
| Format document | `Shift+Option+F` | `Shift+Alt+F` | Java editor | `Cmd+Shift+F` (`Ctrl+Shift+F`) |
| Toggle word wrap | `Cmd+Option+W` | `Ctrl+Alt+W` | Text editors | `Cmd+Option+Y` (`Shift+Alt+Y`) |
| Show in Finder or Explorer | `Cmd+Option+E` | `Ctrl+Alt+E` | Everywhere | None |
| Debug the current Java file | `F5` | `F5` | Everywhere | `Cmd+F11` (`F11`) |
| Run the current Java file | `Cmd+Shift+F5` | `Ctrl+Shift+F5` | Everywhere | `Cmd+Shift+F11` (`Ctrl+F11`) |

Why some need two bindings or a different key:

- **Quick access in the Java editor.** The Java editor binds `Cmd+Shift+P` to *Go to matching bracket*, which would win over a window-wide binding. A second binding scoped to the Java editor takes it back.
- **Copy line in the Java editor.** On Windows and Linux the Java editor binds `Shift+Alt+Up` and `Shift+Alt+Down` to *Expand selection to enclosing element* and *Restore last selection*. The same fix applies, so the binding behaves the same on every platform.
- **Run on `Cmd+Shift+F5`.** VS Code uses `Ctrl+F5`, but macOS keeps `Ctrl+F5` for *Move focus to the window toolbar*, so the run binding moves to a key no system shortcut uses. The same file then gives `Ctrl+Shift+F5` on Windows and Linux.
- **`F5` while debugging.** The debugger binds `F5` to *Step Into* in its own context, which is narrower than the window, so `F5` still steps into while a program is paused. The rest of the time it debugs the Java file open in the editor, as VS Code does. *Refresh* loses `F5` and stays in the **File** menu.
- **`Cmd+Option+W` on the Mac.** Eclipse's default there is *Show In*, which still works outside a text editor.

The full binding list as stored, with the command and context ids, is the `org.eclipse.ui.commands` line in [`prefs/org.eclipse.ui.workbench.prefs`](../prefs/org.eclipse.ui.workbench.prefs). **Window > Preferences > General > Keys** (**Eclipse > Settings** on the Mac) shows each with a `U` in the User column.

> [!WARNING]
> `org.eclipse.ui.commands` is one value holding every user binding. Merging it replaces any binding added by hand in that workspace. Add a new binding through the Keys page, then copy the line back into the fragment so your copy keeps up.

## Plugins

| Plugin | Update site | Why |
| --- | --- | --- |
| WakaTime | `https://wakatime.com/eclipse/update-site/` | Coding time tracking, matching the WakaTime plugins for other editors. Needs a WakaTime account. |

The update site is the one [WakaTime's Eclipse page](https://wakatime.com/eclipse) gives. Its own instructions prefer **Help > Eclipse Marketplace**, searching for `wakatime`.

## Default JRE

Eclipse Temurin 25, installed with the lines in [setup.md](setup.md#1-install-the-jdk-and-eclipse). **Installed JREs** in the preferences shows the JDKs Eclipse found with the default one ticked. That list is stored as machine-specific paths and ids in `org.eclipse.jdt.launching.prefs`, so it is not merged. Tick Temurin 25 once by hand.

## Colours

`theme/` holds the eight Zacess Eclipse files from [Zacess Themes](https://github.com/zacesshq/themes) 0.3.0 (`Zacess <name>.epf`, editor and Terminal view colours), the tab outline files for the two Deep Contrast themes and `e4-dark_mac.css`.

The scripts import a theme after merging the preferences: each `/instance/<plugin>/<key>=<value>` line of the `.epf` merges into that plugin's `.prefs` file the same way. `org.eclipse.e4.ui.css.swt.theme.prefs` gets the matching workbench theme (`e4_dark` for the dark themes, `e4_default` for the light ones). Zacess Deep Contrast Dark is the default.

| Short name | Theme | Workbench |
| --- | --- | --- |
| `deep-dark` | Zacess Deep Contrast Dark | Dark |
| `deep-light` | Zacess Deep Contrast Light | Light |
| `hc-dark` | Zacess High Contrast Dark | Dark |
| `hc-light` | Zacess High Contrast Light | Light |
| `dark` | Zacess Dark | Dark |
| `light` | Zacess Light | Light |
| `cream` | Zacess Cream | Light |
| `yellow` | Zacess Yellow on Black | Dark |

Eclipse has no setting to follow the system light and dark appearance, so the theme stays fixed. By hand, **File > Import > General > Preferences** imports any `.epf`, then **General > Appearance** picks Light or Dark and Eclipse restarts.

On macOS, `e4-dark_mac.css` draws yellow and cyan frames around views and editors under the Dark theme. Copy it to `<Eclipse.app>/Contents/Eclipse/configuration/org.eclipse.e4.ui.css.swt.theme/e4-dark_mac.css`, where it replaces the Dark theme's own file of that name.

## Terminal view

On Windows the plain terminal button always starts `ComSpec`, which is Command Prompt. `apply.ps1` adds PowerShell 7 to the list of local shells in `<workspace>\.metadata\.plugins\org.eclipse.terminal.view.ui\.executables\data.properties`, so it is picked from the button's dropdown. Shells already in that list, such as Git Bash or a WSL distribution, keep every field and move down behind it. A list that already has PowerShell 7 is left alone.
