#!/usr/bin/env bash
set -euo pipefail

# defaults KDE Plasma implementation (tested on Fedora KDE Plasma 6.7)
# Windows 11-style floating taskbar, Breeze with high contrast colours switching light and dark
# by time of day, UK region and the screenshot shortcuts.

HERE="$(cd "$(dirname "$0")" && pwd)"
# colours and the two global themes (Breeze with the colour schemes above, no wallpaper or layout)
mkdir -p "$HOME/.local/share/color-schemes" "$HOME/.local/share/plasma/look-and-feel"
cp "$HERE"/color-schemes/*.colors "$HOME/.local/share/color-schemes/"
for theme in "$HERE"/look-and-feel/*; do
    # the previews, splash and logout screens come from Breeze itself
    base=org.kde.breeze.desktop; [[ "$theme" == *dark* ]] && base=org.kde.breezedark.desktop
    dest="$HOME/.local/share/plasma/look-and-feel/$(basename "$theme")"
    rm -rf "$dest"; cp -r "/usr/share/plasma/look-and-feel/$base" "$dest"; rm -rf "$dest/contents/layouts"
    cp "$theme/metadata.json" "$dest/"; cp "$theme/contents/defaults" "$dest/contents/"
done
kwriteconfig6 --file kdeglobals --group KDE --key AutomaticLookAndFeel true
kwriteconfig6 --file kdeglobals --group KDE --key DefaultLightLookAndFeel zacess.highcontrastlight.desktop
kwriteconfig6 --file kdeglobals --group KDE --key DefaultDarkLookAndFeel zacess.highcontrastdark.desktop

# UK region (24-hour clock) and Kitty as the terminal
kwriteconfig6 --file plasma-localerc --group Formats --key LANG en_GB.UTF-8
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty
kwriteconfig6 --file kdeglobals --group General --key TerminalService kitty.desktop

# Geist Mono's Nerd Font Mono build as the desktop's fixed-width font at Plasma's own size and in
# every Konsole profile at Kitty's 13 points. Konsole's built-in profile follows the fixed font, so
# a machine with no profile of its own still gets it. Install the font first or Plasma falls back to
# its own monospace font
kwriteconfig6 --file kdeglobals --group General --key fixed "GeistMono Nerd Font Mono,10,-1,5,50,0,0,0,0,0"
# GTK apps read GNOME's key, which only Plasma's own settings app copies across
gsettings set org.gnome.desktop.interface monospace-font-name 'GeistMono Nerd Font Mono 10'
for profile in "$HOME"/.local/share/konsole/*.profile; do
    [[ -f "$profile" ]] || continue
    kwriteconfig6 --file "$profile" --group Appearance --key Font "GeistMono Nerd Font Mono,13,-1,5,50,0,0,0,0,0"
done

# Meta+Shift+S for a region screenshot, PrtSc for the full screen
G=(--file kglobalshortcutsrc --group services --group org.kde.spectacle.desktop)
kwriteconfig6 "${G[@]}" --key _launch none
kwriteconfig6 "${G[@]}" --key RectangularRegionScreenShot $'Meta+Shift+S\tMeta+Shift+Print'
kwriteconfig6 "${G[@]}" --key FullScreenScreenShot $'Print\tShift+Print'

# Rectangle's quarters, centre and maximise on Meta+Ctrl (Ctrl+Alt would take over JetBrains'
# defaults); halves stay on KDE's own Meta+arrows and Meta+Ctrl+arrows keeps switching desktops
K=(--file kglobalshortcutsrc --group kwin)
kwriteconfig6 "${K[@]}" --key "Window Quick Tile Top Left" "Meta+Ctrl+U,none,Quick Tile Window to the Top Left"
kwriteconfig6 "${K[@]}" --key "Window Quick Tile Top Right" "Meta+Ctrl+I,none,Quick Tile Window to the Top Right"
kwriteconfig6 "${K[@]}" --key "Window Quick Tile Bottom Left" "Meta+Ctrl+J,none,Quick Tile Window to the Bottom Left"
kwriteconfig6 "${K[@]}" --key "Window Quick Tile Bottom Right" "Meta+Ctrl+K,none,Quick Tile Window to the Bottom Right"
kwriteconfig6 "${K[@]}" --key "Window Move Center" "Meta+Ctrl+C,none,Move Window to the Centre"
kwriteconfig6 "${K[@]}" --key "Window Maximize" $'Meta+PgUp\tMeta+Ctrl+Return,Meta+PgUp,Maximise Window'

# kglobalaccel only reads that file at log-in and writes its own copy back at log-out, so the keys
# are also registered live; the numbers are Qt key codes (Meta 0x10000000, Ctrl 0x04000000)
live_key() {
    gdbus call --session -d org.kde.kglobalaccel -o /kglobalaccel \
        -m org.kde.KGlobalAccel.setForeignShortcutKeys "['kwin','$1','KWin','']" "$2" >/dev/null
}
if gdbus introspect --session -d org.kde.kglobalaccel -o /kglobalaccel >/dev/null 2>&1; then
    MC=$((0x10000000 | 0x04000000))
    live_key "Window Quick Tile Top Left" "[([$((MC | 0x55)),0,0,0],)]"
    live_key "Window Quick Tile Top Right" "[([$((MC | 0x49)),0,0,0],)]"
    live_key "Window Quick Tile Bottom Left" "[([$((MC | 0x4A)),0,0,0],)]"
    live_key "Window Quick Tile Bottom Right" "[([$((MC | 0x4B)),0,0,0],)]"
    live_key "Window Move Center" "[([$((MC | 0x43)),0,0,0],)]"
    live_key "Window Maximize" "[([$((0x10000000 | 0x01000016)),0,0,0],),([$((MC | 0x01000004)),0,0,0],)]"
fi

# a see-through taskbar like Windows 11 with TranslucentTB (a light tint over a soft blur):
# the Zacess Dark Plasma style (both global themes above name it) with KWin's blur at 2, its closest
# match to TranslucentTB's 9 pixel radius. Blur has to be reloaded as an effect to take a new strength
if bash "$HERE/plasma-style.sh"; then
    plasma-apply-desktoptheme zacess-dark >/dev/null
fi
kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled true
kwriteconfig6 --file kwinrc --group Effect-blur --key BlurStrength 2
gdbus call --session -d org.kde.KWin -o /Effects -m org.kde.kwin.Effects.reconfigureEffect blur >/dev/null 2>&1 || true

# the centred start menu; without it the taskbar keeps Kickoff
bash "$HERE/menu11.sh" || printf 'Menu11 skipped, so the start menu stays Kickoff.\n'

# the taskbar replaces every existing panel
qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$HERE/taskbar.js")" >/dev/null
# start menu favourites live in the activity manager's database, not in the panel's config. The web
# app not installed yet is skipped
link() {
    gdbus call --session -d org.kde.ActivityManager -o /ActivityManager/Resources/Linking \
        -m org.kde.ActivityManager.ResourcesLinking."$1" org.kde.plasma.favorites.applications "$2" :global >/dev/null 2>&1 || true
}
for app in preferred://browser org.kde.kontact org.kde.kwrite org.kde.konsole org.kde.discover systemsettings; do
    [[ "$app" == *://* ]] || app="applications:$app.desktop"
    link UnlinkResourceFromActivity "$app"
done
FAVOURITES=(kitty google-chrome com.microsoft.VSCode org.kde.dolphin com.discordapp.Discord com.spotify.Client
    md.obsidian.Obsidian org.zotero.Zotero)
order=()
for app in "${FAVOURITES[@]}"; do
    link LinkResourceToActivity "applications:$app.desktop"
    order+=("applications:$app.desktop")
done
# Menu11 keeps its own order per panel widget, for all activities and for the current one, so every
# Menu11 on the panel gets the list's order in both
activity="$(qdbus-qt6 org.kde.ActivityManager /ActivityManager/Activities CurrentActivity 2>/dev/null || true)"
for id in $(qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
        'print(panels()[0].widgets("menu.11.next").map(function (w) { return w.id; }).join(" "))'); do
    for scope in global ${activity:+"$activity"}; do
        kwriteconfig6 --file kactivitymanagerd-statsrc --group "Favorites-org.kde.plasma.kicker.favorites.instance-$id-$scope" \
            --key ordering "$(IFS=,; printf '%s' "${order[*]}")"
    done
done

# the desktop is a shuffled slideshow of the local wallpaper copy, changing every 5 minutes; the slideshow
# reads any category folders inside it. The lock screen is a slideshow of its Lock screen folder only,
# changing every minute, as on Windows
WALLPAPERS="$HOME/Pictures/Wallpapers/"
mkdir -p "$WALLPAPERS/Lock screen"
qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
desktops().forEach(function (d) {
    d.wallpaperPlugin = 'org.kde.slideshow';
    d.currentConfigGroup = ['Wallpaper', 'org.kde.slideshow', 'General'];
    d.writeConfig('SlidePaths', ['$WALLPAPERS']);
    d.writeConfig('SlideInterval', 300);
    d.writeConfig('SlideshowMode', 0);
    d.reloadConfig();
});" >/dev/null
kwriteconfig6 --file kscreenlockerrc --group Greeter --key WallpaperPlugin org.kde.slideshow
L=(--file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.slideshow --group General)
kwriteconfig6 "${L[@]}" --key SlidePaths "${WALLPAPERS}Lock screen/"
kwriteconfig6 "${L[@]}" --key SlideInterval 60

# the lock screen and its slideshow come before the screen dims or goes blank: the lock comes at 15 minutes,
# and dimming and turning the screen off wait longer on every power profile than Plasma's defaults do
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock true
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 15
power() { kwriteconfig6 --file powerdevilrc --group "$1" --group Display --key "$2" "$3"; }
# the same order as the Mac and Windows: the lock and its slideshow at 15 minutes, dimming just before
# the screen goes off at 60 minutes on mains and battery. The locked timeout counts from the lock, so
# 45 more minutes gives the same 60. The laptop never suspends on mains so long jobs keep running
power AC DimDisplayIdleTimeoutSec 3300
power AC TurnOffDisplayIdleTimeoutSec 3600
power AC TurnOffDisplayIdleTimeoutWhenLockedSec 2700
power Battery DimDisplayIdleTimeoutSec 3300
power Battery TurnOffDisplayIdleTimeoutSec 3600
power Battery TurnOffDisplayIdleTimeoutWhenLockedSec 2700
autosuspend() { kwriteconfig6 --file powerdevilrc --group "$1" --group SuspendAndShutdown --key "$2" "$3"; }
autosuspend AC AutoSuspendAction 0
autosuspend Battery AutoSuspendAction 1
autosuspend Battery AutoSuspendIdleTimeoutSec 3600
power LowBattery DimDisplayIdleTimeoutSec 360
power LowBattery TurnOffDisplayIdleTimeoutSec 420
power LowBattery TurnOffDisplayIdleTimeoutWhenLockedSec 120
kwriteconfig6 "${L[@]}" --key SlideshowMode 0

# Windows-style scroll bars: an arrow at each end and a click on the track moves one page; GTK apps
# (Firefox among them) otherwise hide theirs until hovered
kwriteconfig6 --file breezerc --group Style --key ScrollBarAddLineButtons 1
kwriteconfig6 --file breezerc --group Style --key ScrollBarSubLineButtons 1
kwriteconfig6 --file kdeglobals --group KDE --key ScrollbarLeftClickNavigatesByPage true
mkdir -p "$HOME/.config/environment.d"
printf 'GTK_OVERLAY_SCROLLING=0\n' > "$HOME/.config/environment.d/50-scrollbars.conf"

# Discord and Kitty: sound, badge and history stay, but no pop-ups over the screen
for app in com.discordapp.Discord kitty; do
    D=(--file plasmanotifyrc --group Applications --group "$app")
    kwriteconfig6 "${D[@]}" --key ShowPopups false
    kwriteconfig6 "${D[@]}" --key ShowInHistory true
    kwriteconfig6 "${D[@]}" --key ShowBadges true
done

# a larger yellow pointer with a black outline, matching Windows and the Mac; yellow-pointer.sh builds it
# from Breeze Light, so without Breeze Light the pointer is left alone
if bash "$HERE/yellow-pointer.sh" >/dev/null && command -v plasma-apply-cursortheme >/dev/null; then
    plasma-apply-cursortheme Zacess_Yellow --size 48 >/dev/null
    # Kitty and other apps that draw their own pointer read these instead of Plasma's setting, from the next log-in
    printf 'XCURSOR_THEME=Zacess_Yellow\nXCURSOR_SIZE=48\n' > "$HOME/.config/environment.d/40-cursor.conf"
else
    printf 'Yellow pointer skipped.\n'
fi

# touchpads scroll the Windows 11 way (content follows the fingers); KWin keys the setting by each
# device's vendor, product and name, so every touchpad present is set live and in kcminputrc
for dev in $(gdbus call --session -d org.kde.KWin -o /org/kde/KWin/InputDevice \
        -m org.freedesktop.DBus.Properties.Get org.kde.KWin.InputDeviceManager devicesSysNames 2>/dev/null |
        grep -o "event[0-9]*"); do
    prop() {
        gdbus call --session -d org.kde.KWin -o "/org/kde/KWin/InputDevice/$dev" \
            -m org.freedesktop.DBus.Properties.Get org.kde.KWin.InputDevice "$1" | sed -E "s/^\(<(uint32 )?'?//; s/'?>,\)$//"
    }
    [ "$(prop touchpad)" = true ] || continue
    gdbus call --session -d org.kde.KWin -o "/org/kde/KWin/InputDevice/$dev" \
        -m org.freedesktop.DBus.Properties.Set org.kde.KWin.InputDevice naturalScroll '<true>' >/dev/null
    kwriteconfig6 --file kcminputrc --group Libinput --group "$(prop vendor)" --group "$(prop product)" \
        --group "$(prop name)" --key NaturalScroll true
done

# the login screen needs root (see login-wallpaper.sh); sudo asks in a terminal, pkexec in a window
if [ -t 0 ]; then
    sudo bash "$HERE/login-wallpaper.sh" "$USER" || printf 'Login screen wallpapers skipped.\n'
elif command -v pkexec >/dev/null; then
    pkexec bash "$HERE/login-wallpaper.sh" "$USER" || printf 'Login screen wallpapers skipped.\n'
fi


printf 'KDE defaults applied. Log out and back in for the screenshot keys and the light and dark switch.\n'

# the text selection colour follows the Zacess theme zt last set, so the schemes copied in above get
# it back now rather than at the next zt run
if [[ -f "${XDG_STATE_HOME:-$HOME/.local/state}/zacess/theme" ]]; then
    python3 "$HERE/../../../../shell/scripts/zt.py" highlight
fi
