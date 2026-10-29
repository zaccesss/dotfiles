// one taskbar flat on the bottom edge, Windows 11 style: launcher and apps centred, tray and clock right
panels().forEach(function (p) { p.remove(); });

var bar = new Panel;
bar.location = "bottom";
// 50 rather than Plasma's 48: at 120 percent scale 48 lands on 57.6 pixels. The blur
// behind the panel then stops two rows short of the screen edge
bar.height = 50;
bar.floating = false;
bar.hiding = "none";
bar.lengthMode = "fill";
// always see-through, as on Windows. Plasma's default goes solid whenever a window is maximised
bar.opacity = "translucent";

bar.addWidget("org.kde.plasma.panelspacer");
// Menu11 opens centred above the taskbar (menu11.sh installs it); Kickoff stays as the fallback
var centred = knownWidgetTypes.indexOf("menu.11.next") >= 0;
var launcher = bar.addWidget(centred ? "menu.11.next" : "org.kde.plasma.kickoff");
launcher.currentConfigGroup = ["Shortcuts"];
launcher.writeConfig("global", "Alt+F1");
if (centred) {
    launcher.currentConfigGroup = ["General"];
    launcher.writeConfig("displayPosition", 2);
    launcher.writeConfig("showRecentDocs", false);
    launcher.writeConfig("showRecentApps", false);
}
var tasks = bar.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", ["applications:systemsettings.desktop", "applications:org.kde.dolphin.desktop", "applications:kitty.desktop", "applications:com.discordapp.Discord.desktop", "applications:com.spotify.Client.desktop", "applications:google-chrome.desktop", "applications:com.microsoft.VSCode.desktop"]);
bar.addWidget("org.kde.plasma.panelspacer");

// apps that sit in the tray for no reason go behind its arrow, as on Windows; JetBrains Toolbox,
// OneDrive, volume, network, Bluetooth, battery and notifications stay beside the clock
var tray = bar.addWidget("org.kde.plasma.systemtray");
tray.currentConfigGroup = ["General"];
tray.writeConfig("shownItems", ["toolbox", "OneDriveGUI", "org.kde.plasma.bluetooth", "org.kde.plasma.battery"]);
tray.writeConfig("hiddenItems", ["Xwayland Video Bridge", "Discover Notifier_org.kde.DiscoverNotifier", "org.kde.kdeconnect", "org.kde.plasma.clipboard", "org.kde.plasma.brightness"]);
tray.writeConfig("iconSpacing", 1);
// a fixed size: the automatic one fills the panel's height and comes out larger than the Windows clock.
// the weight has to be named, since an unset weight renders the fixed size as Thin
var clock = bar.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("use24hFormat", 2);
clock.writeConfig("showDate", true);
clock.writeConfig("dateDisplayFormat", "BelowTime");
clock.writeConfig("dateFormat", "shortDate");
clock.writeConfig("autoFontAndSize", false);
clock.writeConfig("fontFamily", "Noto Sans");
clock.writeConfig("fontWeight", 400);
clock.writeConfig("fontStyleName", "Regular");
clock.writeConfig("fontSize", 10);
print(bar.id);
