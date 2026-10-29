#!/usr/bin/env bash
set -euo pipefail

# sets up a personal OneDrive on Linux: the OneDrive client (Fedora's onedrive package) syncing in
# full into ~/OneDrive, with OneDriveGUI for its tray icon, started minimised at login. The sign-in
# and the first sync stay manual, since the sign-in opens a browser. See ../README.md.
#
# the config is copied, never linked: OneDriveGUI rewrites the client's config with only the values
# that differ from the defaults, which through a link would land in the repository

HERE="$(cd "$(dirname "$0")" && pwd)"
GUI_VERSION=1.3.2
GUI_URL="https://github.com/bpozdena/OneDriveGUI/releases/download/v${GUI_VERSION}/OneDriveGUI-${GUI_VERSION}-x86_64.AppImage"
GUI_SHA256=d2a3b21ff12de975a4d6d52c4a997a276ecb60ea342d18b0787479280207558d
GUI_DIR="$HOME/.local/opt/onedrivegui"
GUI_BIN="$GUI_DIR/OneDriveGUI-${GUI_VERSION}-x86_64.AppImage"

if ! command -v onedrive >/dev/null; then
    # the AppImage also needs FUSE 2, which Fedora ships as fuse-libs
    printf 'Install the client first:\n    sudo dnf install onedrive fuse-libs\n'
    exit 1
fi

CONF="$HOME/.config/onedrive"
mkdir -p "$CONF"
if [ ! -f "$CONF/config" ]; then
    cp "$HERE/config" "$CONF/config"
fi

# OneDriveGUI 2.x is a new major line, so the last 1.x release is pinned and checked against the
# digest GitHub publishes for it
if [ ! -x "$GUI_BIN" ]; then
    mkdir -p "$GUI_DIR"
    curl -fsSL -o "$GUI_BIN.part" "$GUI_URL"
    if ! printf '%s  %s\n' "$GUI_SHA256" "$GUI_BIN.part" | sha256sum --check --status; then
        rm -f "$GUI_BIN.part"
        printf 'The OneDriveGUI download does not match its pinned checksum, so it was not installed.\n'
        exit 1
    fi
    mv "$GUI_BIN.part" "$GUI_BIN"
    chmod +x "$GUI_BIN"
fi

# its own settings: in the tray at login and quiet logs. The profile points at the client's config
GUI_CONF="$HOME/.config/onedrive-gui"
mkdir -p "$GUI_CONF"
if [ ! -f "$GUI_CONF/gui_settings" ]; then
    cp "$HERE/gui_settings" "$GUI_CONF/gui_settings"
fi
if [ ! -f "$GUI_CONF/profiles" ]; then
    printf '[Personal.]\nconfig_file = %s\nauto_sync = True\naccount_type = \nfree_space = \n' \
        "$CONF/config" > "$GUI_CONF/profiles"
fi

entry() {
    mkdir -p "$(dirname "$1")"
    cat > "$1" <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=OneDrive
Comment=OneDrive sync status and settings
Exec=$GUI_BIN
Icon=OneDriveGUI
Terminal=false
Categories=Network;Office;
StartupNotify=false
EOF
}
entry "$HOME/.local/share/applications/OneDriveGUI.desktop"
entry "$HOME/.config/autostart/OneDriveGUI.desktop"

if [ ! -f "$CONF/refresh_token" ]; then
    printf 'Next: sign in with onedrive, run the first sync with onedrive --sync, then start OneDrive from the menu.\n'
fi
