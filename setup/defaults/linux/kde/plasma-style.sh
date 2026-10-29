#!/usr/bin/env bash
set -euo pipefail

# builds the Zacess Dark Plasma style in ~/.local/share/plasma/desktoptheme/zacess-dark: Breeze Dark's own
# colours with one changed file, the taskbar background. The installed copy of Plasma's panel artwork is
# rewritten rather than a copy kept here, so it follows each Plasma release.
#
# Plasma draws a translucent panel from translucent/widgets/panel-background.svgz. Breeze fills it at 85
# percent, which reads as solid; a Windows 11 taskbar with TranslucentTB is a light tint over a soft
# blur, so the fill drops to 15 percent. Breeze also draws the panel's top edge in the panel's own colour, which
# leaves no line between the windows and the taskbar, so that edge takes the text colour at 30 percent.
#
# a style folder that holds only some files falls back to Plasma's default style for the rest, but only
# when it has its own metadata.json, colors and plasmarc. A bare folder named after an existing style
# hides that style instead, so this one has its own name.

SRC=/usr/share/plasma/desktoptheme
DEST="$HOME/.local/share/plasma/desktoptheme/zacess-dark"
PANEL="$SRC/default/translucent/widgets/panel-background.svgz"

if [ ! -f "$PANEL" ] || [ ! -f "$SRC/breeze-dark/colors" ]; then
    printf 'Breeze Dark is not installed, so the Zacess Dark style was skipped.\n'
    exit 1
fi

mkdir -p "$DEST/translucent/widgets"
cp "$SRC/breeze-dark/colors" "$SRC/breeze-dark/plasmarc" "$DEST/"
cat > "$DEST/metadata.json" <<'EOF'
{
    "KPlugin": {
        "Authors": [{"Name": "Isaac Adjei"}],
        "Description": "Breeze Dark with a see-through taskbar and a line along its top edge",
        "Id": "zacess-dark",
        "License": "LGPL",
        "Name": "Zacess Dark",
        "Version": "1.0"
    },
    "X-Plasma-API": "5.0"
}
EOF

zcat "$PANEL" | python3 -I -c '
import re, sys
svg = sys.stdin.read()
# the top edge: a one-unit line in the background colour at half opacity
line = re.compile(r"(<path\s+style=\")opacity:0\.5(\"\s+d=\"M 0,0 V 1 H 32 V 0 Z\"\s+id=\"path1337\"\s+class=\")ColorScheme-Background")
svg, edges = line.subn(r"\1opacity:0.3\2ColorScheme-Text", svg)
svg, fills = re.subn(r"opacity:0\.85;fill:currentColor", "opacity:0.15;fill:currentColor", svg)
if edges != 1 or fills == 0:
    sys.exit("the panel artwork has changed shape, so the Zacess Dark style was not built")
sys.stdout.write(svg)
' | gzip -9 -n > "$DEST/translucent/widgets/panel-background.svgz"

# Plasma keeps rendered artwork in these caches, so a rebuilt style only shows once they are gone
rm -rf "$HOME/.cache/ksvg-elements" "$HOME"/.cache/plasma_theme_*.kcache
