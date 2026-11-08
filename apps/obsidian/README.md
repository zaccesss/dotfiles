# obsidian

Obsidian setup: the four Zacess community themes installed in a vault, the chosen look picked by theme and base colour scheme and that vault opened by default.

## What it sets

| Where | What | Why |
| --- | --- | --- |
| `.obsidian/themes/<theme>` | The four pinned Zacess Obsidian themes ([`shared/theme-package.json`](shared/theme-package.json)), Zacess, Zacess Cream, Zacess High Contrast and Zacess Deep Contrast, each checked against its SHA-256 digest | One copy of every theme for every machine, so a switch between looks needs no download |
| `.obsidian/appearance.json` | `cssTheme` (the theme that carries the chosen look), `theme` (its dark `obsidian` or light `moonstone` half) and `monospaceFontFamily` GeistMono Nerd Font | Each Zacess theme follows Obsidian's own base colour scheme between its light and dark look, so no plugin is needed |
| This machine's `obsidian.json` | The vault marked as the one that opens | Obsidian starts in that vault |

In a synced vault the `.obsidian` folder travels with it, so the themes and the look are shared by every machine that opens it. `obsidian.json` is each machine's own. [`shared/themes.json`](shared/themes.json) maps each of the ten looks to its theme and base colour scheme: Zacess Deep Contrast Dark is `Zacess Deep Contrast` plus `obsidian`, Zacess Cream is `Zacess Cream` plus `moonstone`, Zacess Yellow on Black is `Zacess Cream` plus `obsidian` and so on.

## Apply

Quit Obsidian first: it writes these files while it runs, so the scripts refuse to run while it is open.

```powershell
pwsh -File windows\apply.ps1
pwsh -File windows\apply.ps1 -Theme cream -Vault "$HOME\Documents\MyVault"
```

```bash
mac/apply.sh
mac/apply.sh --theme cream ~/Documents/MyVault
linux/apply.sh
linux/apply.sh --theme cream ~/Documents/MyVault
```

The vault defaults to `~/Obsidian/Vault` on every platform (`%USERPROFILE%\Obsidian\Vault` on Windows), a plain folder outside any cloud-synced folder, since two sync engines on one folder produce conflict copies. Another vault is the folder passed to the script (`-Vault` on Windows) or, with none passed, the `OBSIDIAN_VAULT` environment variable, which `zt` and the bootstraps read too, so setting it once moves every script to it:

```bash
export OBSIDIAN_VAULT="$HOME/Documents/MyVault"
```

The vault list is `~/Library/Application Support/obsidian/obsidian.json` on macOS, `~/.config/obsidian/obsidian.json` on Linux (the Flatpak's copy when `md.obsidian.Obsidian` is installed) and `%APPDATA%\obsidian\obsidian.json` on Windows. On Windows the script also keeps `.obsidian` on the device: a cloud-synced file that is only online cannot be read at start-up, which leaves Obsidian on its default theme. The macOS script does not pin files: if a sync client has a `.obsidian` file only online and cannot download it, the script stops with a timeout. Keep the vault's `.obsidian` folder on the device in Finder, wait for it to download and run the script again. The Linux and macOS scripts share [`shared/apply.py`](shared/apply.py). Every script prints each key and file as `added`, `changed` or `unchanged`. Running one again changes nothing. Nothing is backed up.

`zt <theme>` runs the script for the chosen look and `zt current` and `zt doctor` read `cssTheme` and `theme` back from `appearance.json` to name it. A vault left on **Adapt to system** is reported as following the system between the theme's two looks.

## Check it worked

1. Start Obsidian. It opens the vault in the chosen Zacess look.
2. **Settings > Appearance** shows the theme (Zacess, Zacess Cream, Zacess High Contrast or Zacess Deep Contrast) under **Themes**, the matching **Base color scheme** (dark or light) and GeistMono Nerd Font as the monospace font.
3. **Settings > Appearance > Themes > Manage** lists all four Zacess themes as installed.

## Validation

[`scripts/validate.py`](scripts/validate.py) runs in CI on Linux. It checks all ten looks map to an installed theme and a base colour scheme, every theme package pins a release zip with a full digest and the appearance settings name Geist Mono.
