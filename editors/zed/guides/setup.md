# Setup

## 1. Clone

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
```

## 2. Find your config folder

| Platform | Config folder |
| --- | --- |
| macOS | `~/.config/zed/` |
| Linux | `~/.config/zed/` (`$XDG_CONFIG_HOME/zed/` when that variable is set) |
| Windows | `%APPDATA%\Zed\` |

Zed creates the folder on first launch. The commands below also create it when Zed has not run
yet.

## 3. Copy the settings into place

macOS and Linux:

```bash
mkdir -p ~/.config/zed
cp ~/dev/github/repos/dotfiles/editors/zed/settings.json ~/.config/zed/settings.json
```

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\Zed" | Out-Null
Copy-Item "$HOME\dev\github\repos\dotfiles\editors\zed\settings.json" "$env:APPDATA\Zed\settings.json"
```

> [!WARNING]
> This overwrites the existing `settings.json`. Back up the old file first if it has settings
> worth keeping.

## 4. Install the extensions

`settings.json` lists both theme extensions under `auto_install_extensions`, so Zed installs
High Contrast Themes and Zacess Themes on its own the next time it starts with this file. To install
them by hand instead, open the Extensions page with `Cmd+Shift+X` on macOS (`Ctrl+Shift+X` on
Windows and Linux), search for **High Contrast Themes** and **Zacess Themes** and install both.
Zed always installs the latest version, the versions in `extensions.txt` only record the ones this
config was last checked against.

## 5. Install the theme file and set the theme

The extension store still has a Zacess Themes release without the two Deep Contrast themes, so the apply script puts the current theme file in Zed's `themes` folder and sets the theme block. Run it from this folder:

```bash
mac/apply.sh      # or linux/apply.sh
```

```powershell
pwsh -File windows\apply.ps1
```

Each bootstrap's apps stage runs this step for you. The Mac bootstrap's configs stage also links `settings.json` (step 3). See the [README](../README.md#apply) for what the script changes.

## Verify it worked

1. Zed should show black backgrounds with white text (`Zacess Deep Contrast Dark`), in light and
   dark mode alike.
2. Open the theme picker with `Cmd+K` then `Cmd+T` (`Ctrl+K` then `Ctrl+T` on Windows and Linux)
   to confirm all eight Zacess theme names exist.
3. To follow the system instead, set `theme.mode` to `system`. Picking a theme in the picker
   writes it into `settings.json`, so it stays until changed again.

## Updating after a change to this folder

```bash
cd ~/dev/github/repos/dotfiles/editors/zed
git pull
```

Then repeat the copy step in section 3. Zed picks up a new `settings.json` straight away, no
restart needed.
