# Setup

## 1. Install Xcode

Install Xcode from the [Mac App Store](https://apps.apple.com/app/xcode/id497799835). Open it once,
accept the licence, install the components it offers and quit it again.

## 2. Clone

```bash
git clone https://github.com/zaccesss/dotfiles.git ~/dev/github/repos/dotfiles
```

## 3. Apply

Quit Xcode first, then run:

```bash
~/dev/github/repos/dotfiles/editors/xcode/apply.sh            # install everything
~/dev/github/repos/dotfiles/editors/xcode/apply.sh --dry-run  # only show what would change
```

The script:

1. refuses to run while a process called `Xcode` is open (a dry run is allowed, since it writes
   nothing)
2. copies the eight `.xccolortheme` files and the Xcode 27 `.xcworkspacecolortheme` file from
   [`theme/`](../theme/) into `~/Library/Developer/Xcode/UserData/FontAndColorThemes`
3. copies [`KeyBindings/Default.idekeybindings`](../KeyBindings/Default.idekeybindings) into
   `~/Library/Developer/Xcode/UserData/KeyBindings`
4. reads each key in [`prefs.txt`](../prefs.txt) and writes it only when the current value differs,
   after saving the whole domain to `~/Library/Developer/Xcode/UserData/Backups/`
5. prints `added`, `changed`, `set` or `unchanged` for every file and key

Running it again changes nothing and ends with `Xcode matches the recorded setup.`

> [!TIP]
> `defaults import com.apple.dt.Xcode <backup>` puts the saved domain back, using the file the
> script named when it made the backup.

## 4. Choose a theme

In Xcode 27, Zacess Deep Contrast Dark is already chosen for both appearances. To use another
Zacess theme:

1. Open **Xcode**, **Settings...** (`Cmd+,`) and select **Themes**.
2. Choose **Import Classic Theme** and pick a Zacess file from
   `~/Library/Developer/Xcode/UserData/FontAndColorThemes`.
3. Keep the colours and fonts selected and finish the import.

Xcode 26 and earlier list the files under **Settings...**, **Themes** straight away. Those versions
keep one theme for the light appearance and one for the dark, which is what the two
`XCFontAndColorCurrent...Theme` keys in `prefs.txt` record.

## 5. WakaTime

Install the [WakaTime app for macOS](https://wakatime.com/mac), sign in and give it the
accessibility permission it asks for in **System Settings**, **Privacy & Security**,
**Accessibility**. It tracks Xcode through that permission, so Xcode itself needs no plugin.

## Verify it worked

1. **Settings...**, **Themes** shows Zacess Deep Contrast Dark selected in Xcode 27.
2. **Settings...**, **Key Bindings** shows the **Default** set.
3. `defaults read com.apple.dt.Xcode DVTEnableOnDeviceCodePredictions` prints `0`, so predictive
   code completion is off.
4. A second `apply.sh` run ends with `Xcode matches the recorded setup.`

## Updating after a change to this folder

```bash
cd ~/dev/github/repos/dotfiles/editors/xcode
git pull
```

Then quit Xcode and repeat step 3.
