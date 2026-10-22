# Reference

Every tracked preference explained, the key bindings file, the themes and what is deliberately not
tracked.

## Where Xcode keeps these

Xcode's preferences are the `com.apple.dt.Xcode` defaults domain, stored in `~/Library/Preferences/com.apple.dt.Xcode.plist` and read with `defaults read com.apple.dt.Xcode`. Themes and key bindings are files under `~/Library/Developer/Xcode/UserData/`.

Each line of [`prefs.txt`](../prefs.txt) is `<type> <key> <value>`. The type is `string`, `bool`, `int` or `data` (written as hex) and the value runs to the end of the line. Lines starting with `#` are notes and are never written.

## `com.apple.dt.Xcode`

| Key | Value | Why |
| --- | --- | --- |
| `XCFontAndColorCurrentTheme` | `Default (Light).xccolortheme` | The editor theme for the light appearance in Xcode 26 and earlier. Xcode 27 reads `DVTWorkspaceThemeSettings` instead. |
| `XCFontAndColorCurrentDarkTheme` | `Default (Dark).xccolortheme` | The editor theme for the dark appearance in Xcode 26 and earlier. |
| `DVTWorkspaceThemeSettings` | hex data | The Xcode 27 theme for each appearance: a small JSON document naming the saved Zacess Deep Contrast Dark theme for both light and dark. It is binary data in the domain, so it is stored as hex. |
| `IDEKeyBindingCurrentPreferenceSet` | `Default.idekeybindings` | The key bindings set, the file in [`KeyBindings/`](../KeyBindings/). |
| `DVTEnableOnDeviceCodePredictions` | `false` | Predictive code completion off, so suggestions come only from the normal code completion list. |
| `IDEStringCatalogAutomaticCommentGenerationEnabled` | `false` | Xcode writes no comments into string catalogs by itself. |

Every other editor setting, such as line numbers, the page guide, trimming whitespace and indentation, is still at Xcode's own default, so none of them is recorded.

## Key bindings

[`KeyBindings/Default.idekeybindings`](../KeyBindings/Default.idekeybindings) is the property list Xcode keeps for the set. It is an empty dictionary: the bindings are Xcode's defaults. A binding changed in **Settings...**, **Key Bindings** lands in that file in `~/Library/Developer/Xcode/UserData/KeyBindings`, which can then be copied back here.

## Themes

[`theme/`](../theme/) holds the eight Zacess Xcode themes from [Zacess Themes](https://github.com/zacesshq/themes), generated there from its palette. Each sets the colour and font of every syntax type Xcode colours, the editor background, cursor, selection and current line, the console and the scroll bar marks.

| Theme | macOS appearance |
| --- | --- |
| Zacess Light | Light |
| Zacess Dark | Dark |
| Zacess Yellow on Black | Dark |
| Zacess Cream | Light |
| Zacess High Contrast Dark | Dark |
| Zacess High Contrast Light | Light |
| Zacess Deep Contrast Dark | Dark |
| Zacess Deep Contrast Light | Light |

Xcode 27 has a new theme system. A classic `.xccolortheme` file only shows up once it is brought in through **Settings...**, **Themes**, **Import Classic Theme**, which writes a `.xcworkspacecolortheme` file and records the choice in `DVTWorkspaceThemeSettings`. Zacess Deep Contrast Dark is included in both forms, as Xcode wrote them on import, so `apply.sh` sets it up on a new Mac without importing again. It is marked to show in every appearance.

## Not tracked

- Window sizes, recent files, first launch flags, analytics dates and SDK records, all written by Xcode for itself.
- Signed in Apple accounts, signing certificates and provisioning profiles, which belong to the keychain and the Apple account.
- Simulators, device support files and `DerivedData`.
