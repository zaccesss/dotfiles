# OneDrive

A personal OneDrive on Linux, set up the way it works on Windows: the whole drive synced into `~/OneDrive` with a OneDrive icon in the tray. macOS and Windows use Microsoft's own OneDrive app, so this folder is Linux only.

| File | Does |
| --- | --- |
| [`linux/setup.sh`](linux/setup.sh) | Copies the client config, installs OneDriveGUI 1.3.2 checked against its published digest and starts it minimised at login |
| [`linux/config`](linux/config) | The [OneDrive Client for Linux](https://github.com/abraunegg/onedrive) config: `~/OneDrive` as the sync folder and 16 transfers at once |
| [`linux/gui_settings`](linux/gui_settings) | [OneDriveGUI](https://github.com/bpozdena/OneDriveGUI)'s settings: start in the tray at login, INFO logging |

## Setup

1. Install the client and the FUSE 2 library the OneDriveGUI AppImage needs (Fedora package names):

   ```bash
   sudo dnf install onedrive fuse-libs
   ```

2. From the repository root, run the setup script:

   ```bash
   bash apps/onedrive/linux/setup.sh
   ```

3. Sign in once in a terminal. The client opens Microsoft's sign-in page in the browser and picks up the reply itself:

   ```bash
   onedrive
   ```

   It ends with *The application has been successfully authorised*. Never paste the `refresh_token` file anywhere; it is the sign-in.
4. Run the first sync in a terminal, since it downloads the whole drive:

   ```bash
   onedrive --sync
   ```

5. Start **OneDrive** from the start menu. Its icon sits in the tray beside the clock (set by the KDE defaults' [`taskbar.js`](../../setup/defaults/linux/kde/taskbar.js)) and keeps the folder in sync from then on.

## Notes

- **The config is copied, not linked.** OneDriveGUI rewrites the client's config with only the values that differ from the defaults, so a link would let it edit the repository. The rewritten file keeps `threads = "16"` and drops `sync_dir`, since `~/OneDrive` is the client's own default.
- **OneDriveGUI 1.3.2 is pinned.** 2.x is a new major line; move the pin and its digest together.
- **A work or school account** can refuse the client with *Need admin approval*. Such an account still works through the Microsoft 365 web apps in a browser.
- **`zt --all`** reads its push file from `~/OneDrive/.zacess` when `ZACESS_SHARED_DIR` is not set, so the folder has to be synced before a theme change from another device reaches this one.

## Verify

1. `onedrive --display-config | grep -E "'sync_dir'|'threads'"` shows `~/OneDrive` and `16`.
2. The OneDrive icon is in the tray after logging in again. Its window shows the profile syncing.
3. A file saved into `~/OneDrive` on another device appears here within a few minutes.
