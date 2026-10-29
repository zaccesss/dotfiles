#!/usr/bin/env bash
set -euo pipefail

# Root half of the KDE defaults: the login screen (Plasma Login Manager) runs as the plasmalogin
# account, which cannot read a private home folder, so it gets its own copy of the Lock screen
# wallpapers and a new random one at every boot and every log-in, matching the lock screen. Run
# through apply.sh or directly with sudo bash login-wallpaper.sh <user>.

TARGET_USER="${1:-${SUDO_USER:-}}"
[ -n "$TARGET_USER" ] && [ "$TARGET_USER" != root ] || { printf 'Usage: sudo bash %s <user>\n' "$0" >&2; exit 1; }
[ "$(id -u)" -eq 0 ] || { printf 'Error: run this as root.\n' >&2; exit 1; }
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
TARGET_UID="$(id -u "$TARGET_USER")"

# the copy shares its data with the originals on Btrfs (cp --reflink), so it takes no extra space
cat > /usr/local/sbin/login-wallpapers-sync <<SYNC
#!/bin/bash
set -euo pipefail
SRC="$TARGET_HOME/Pictures/Wallpapers/Lock screen"
DEST=/var/lib/login-wallpapers
mkdir -p "\$DEST"
# the lock screen pictures may sit in subfolders; the copy is flat, since
# the login screen only ever needs one picture picked from all of them
find "\$SRC" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0 |
    while IFS= read -r -d '' f; do
        # copied every run, not only when missing: a sync tool replaces files it updates. A copy
        # left pointing at the old data would hold that space on its own
        cp --reflink=auto -f "\$f" "\$DEST/"
    done
# pictures removed from the source go from the copy too
keep=\$(find "\$SRC" -type f -printf '%f\\n')
for f in "\$DEST"/*; do grep -Fxq -- "\$(basename "\$f")" <<<"\$keep" || rm -f -- "\$f"; done
chmod 755 "\$DEST"; chmod 644 "\$DEST"/* 2>/dev/null || true
SYNC

cat > /usr/local/sbin/login-wallpaper-pick <<'PICK'
#!/bin/bash
set -euo pipefail
SRC=/var/lib/login-wallpapers
DIR=/var/lib/plasmalogin/wallpapers
CONF=/etc/plasmalogin.conf
pick=$(find "$SRC" -maxdepth 1 -type f | shuf -n 1)
[ -n "$pick" ] || exit 0
ext="${pick##*.}"
mkdir -p "$DIR"
rm -f "$DIR"/daily.*
cp "$pick" "$DIR/daily.${ext,,}"
chown plasmalogin:plasmalogin "$DIR/daily.${ext,,}"
chmod 644 "$DIR/daily.${ext,,}"
# earlier copies made by System Settings are no longer needed
find "$DIR" -maxdepth 1 -type f ! -name 'daily.*' -delete
# only the Image line changes, so anything else System Settings saved in this file is kept
if grep -q '^Image=' "$CONF" 2>/dev/null; then
    sed -i "s|^Image=.*|Image=file://$DIR/daily.${ext,,}|" "$CONF"
else
    printf '\n[Greeter][Wallpaper][org.kde.image][General]\nImage=file://%s/daily.%s\n' "$DIR" "${ext,,}" >> "$CONF"
fi
PICK
chmod 755 /usr/local/sbin/login-wallpapers-sync /usr/local/sbin/login-wallpaper-pick

cat > /etc/systemd/system/login-wallpapers-sync.service <<'UNIT'
[Unit]
Description=Copy the wallpapers where the login screen can read them

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/login-wallpapers-sync
UNIT
cat > /etc/systemd/system/login-wallpapers-sync.timer <<'UNIT'
[Unit]
Description=Daily wallpaper copy for the login screen

[Timer]
OnBootSec=2min
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
UNIT
cat > /etc/systemd/system/login-wallpaper-pick.service <<'UNIT'
[Unit]
Description=Pick a new login screen wallpaper
Before=plasmalogin.service

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/login-wallpaper-pick

[Install]
WantedBy=plasmalogin.service
UNIT
mkdir -p "/etc/systemd/system/user@$TARGET_UID.service.d"
cat > "/etc/systemd/system/user@$TARGET_UID.service.d/login-wallpaper.conf" <<'UNIT'
[Service]
# + runs this one step as root although the unit runs as the user; - means a failed pick can never
# stop the log-in itself
ExecStartPost=-+/usr/local/sbin/login-wallpaper-pick
UNIT

systemctl daemon-reload
systemctl enable --now login-wallpapers-sync.timer
systemctl enable login-wallpaper-pick.service
/usr/local/sbin/login-wallpapers-sync
/usr/local/sbin/login-wallpaper-pick
printf 'Login screen wallpapers: %s pictures, a new one at every boot and log-in.\n' "$(find /var/lib/login-wallpapers -maxdepth 1 -type f | wc -l)"
