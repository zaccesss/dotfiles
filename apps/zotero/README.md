# zotero

Zotero settings: dark or light mode and the reader theme matched to the Zacess theme in use, plus larger text.

## What it sets

Zotero 7 has no custom interface colours, so each Zacess theme maps to Zotero's own dark or light mode and its nearest built-in reader theme ([`shared/themes.json`](shared/themes.json)):

| Zacess theme | Zotero mode | Reader theme |
| --- | --- | --- |
| Deep Contrast Dark, High Contrast Dark, Yellow on Black | Dark | Black |
| Dark | Dark | Dark |
| Deep Contrast Light, High Contrast Light | Light | Original (white) |
| Light | Light | Snow |
| Cream | Light | Sepia |

[`shared/prefs.json`](shared/prefs.json) adds a larger interface font (`extensions.zotero.fontSize` 1.15) and 16-point notes.

The values go in a marked block of the profile's `user.js`, which Zotero reads on every start:

```js
// zacess: managed by the Zacess apply script, edits inside this block are replaced
user_pref("browser.theme.toolbar-theme", 0);
// zacess: end
```

The rest of `user.js` and `prefs.js` is left as it was.

## Apply

Quit Zotero first: it rewrites `prefs.js` when it exits, so the scripts refuse to run while it is open. It also has to have been started once, so a profile exists.

```powershell
pwsh -File windows\apply.ps1
pwsh -File windows\apply.ps1 -Theme cream
```

```bash
mac/apply.sh
mac/apply.sh --theme cream
linux/apply.sh
linux/apply.sh --theme cream
```

The macOS script finds the profile under `~/Library/Application Support/Zotero/Profiles`. The Linux script finds it under `~/.zotero/zotero` or in the Flatpak's copy. Another profile folder can be passed as an argument. The work is done by [`shared/apply.py`](shared/apply.py), which the macOS script uses too. Each script prints every pref as `added`, `changed` or `unchanged`. Running one again changes nothing. Nothing is backed up.

## Known gap

Zotero's custom reader themes live in its synced database, not in prefs, so a Zacess reader theme cannot be scripted. The built-in reader themes above are the nearest match.

## Check it worked

1. Start Zotero. The window is dark for a dark theme and light for a light one.
2. Open a PDF. The reader page uses the theme in the table above.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks all eight themes map to a mode and one built-in reader theme and the apply script parses.
