# obsidian

Obsidian setup: the Zacess theme installed in a vault, the chosen variant picked through Style Settings and that vault opened by default.

## What it sets

| Where | What | Why |
| --- | --- | --- |
| `.obsidian/themes/Zacess` | The pinned Zacess Obsidian theme ([`shared/theme-package.json`](shared/theme-package.json)), checked against its SHA-256 digest | One copy of the theme for every machine |
| `.obsidian/appearance.json` | `cssTheme` Zacess, Obsidian's dark or light base and `monospaceFontFamily` GeistMono Nerd Font | The base follows the variant: dark for the dark themes, light for the light ones |
| Style Settings `data.json` | `zacess-theme@@zacess-contrast` set to the variant | Picks Deep Contrast, High Contrast, Cream or Yellow on Black within the theme |
| This machine's `obsidian.json` | The vault marked as the one that opens | Obsidian starts in that vault |

In a synced vault the `.obsidian` folder travels with it, so the theme and the variant are shared by every machine that opens it. `obsidian.json` is each machine's own. [`shared/themes.json`](shared/themes.json) maps each Zacess theme to its base and variant.

## Apply

Quit Obsidian first: it writes these files while it runs, so the scripts refuse to run while it is open.

```powershell
pwsh -File windows\apply.ps1 -Vault "$HOME\Documents\MyVault"
pwsh -File windows\apply.ps1 -Theme cream -Vault "$HOME\Documents\MyVault"
```

```bash
mac/apply.sh ~/Documents/MyVault
mac/apply.sh --theme cream ~/Documents/MyVault
linux/apply.sh ~/Documents/MyVault
linux/apply.sh --theme cream ~/Documents/MyVault
```

The vault is the folder passed to the script (`-Vault` on Windows). With none passed, the scripts use the `OBSIDIAN_VAULT` environment variable, which `zt` reads too, so setting it once lets `zt` switch Obsidian with the other apps:

```bash
export OBSIDIAN_VAULT="$HOME/Documents/MyVault"
```

The vault list is `~/Library/Application Support/obsidian/obsidian.json` on macOS, `~/.config/obsidian/obsidian.json` on Linux (the Flatpak's copy when `md.obsidian.Obsidian` is installed) and `%APPDATA%\obsidian\obsidian.json` on Windows. On Windows the script also keeps `.obsidian` on the device: a cloud-synced file that is only online cannot be read at start-up, which leaves Obsidian on its default theme. The macOS script does not pin files: if a sync client has a `.obsidian` file only online and cannot download it, the script stops with a timeout. Keep the vault's `.obsidian` folder on the device in Finder, wait for it to download and run the script again. The Linux and macOS scripts share [`shared/apply.py`](shared/apply.py). Every script prints each key and file as `added`, `changed` or `unchanged`. Running one again changes nothing. Nothing is backed up.

## Check it worked

1. Start Obsidian. It opens the vault in the Zacess theme.
2. **Settings > Appearance** shows Zacess as the theme and GeistMono Nerd Font as the monospace font.
3. **Settings > Style Settings > Zacess** shows the chosen variant.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks all eight themes map to a base and a variant, the theme package pins a release with a full digest and the appearance settings name the theme and Geist Mono.
