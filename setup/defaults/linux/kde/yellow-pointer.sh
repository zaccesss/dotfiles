#!/usr/bin/env bash
set -euo pipefail

# a yellow mouse pointer with a black outline, the KDE match for the Mac's yellow fill and black
# outline. No packaged theme has that pair (Oxygen Yellow has no outline), so Breeze Light (white
# with a dark grey outline) is copied and recoloured into ~/.local/share/icons/Zacess_Yellow

SRC=/usr/share/icons/Breeze_Light
DEST="$HOME/.local/share/icons/Zacess_Yellow"
FILL=fffb00
[ -d "$SRC/cursors" ] || { printf 'Breeze Light cursors not found in %s\n' "$SRC" >&2; exit 1; }

rm -rf "$DEST"; mkdir -p "$DEST"
cp -a "$SRC/cursors" "$DEST/"
printf '[Icon Theme]\nName=Zacess Yellow\nComment=Breeze Light recoloured: yellow fill, black outline\nInherits=Breeze_Light\n' > "$DEST/index.theme"

# the scalable SVGs drive the pointer at any size on Wayland; only the fill and outline change, so
# the coloured busy and drag badges keep Breeze's own colours
if [ -d "$SRC/cursors_scalable" ]; then
    cp -a "$SRC/cursors_scalable" "$DEST/"
    find "$DEST/cursors_scalable" -name '*.svg' -exec sed -i -E \
        -e "s/#(fff|ffffff|FFF|FFFFFF)\b/#$FILL/g" -e 's/#(333|333333)\b/#000000/g' {} +
fi

# the Xcursor bitmaps (used by X11 apps and as a fallback) are premultiplied ARGB: each pixel's
# brightness picks a point between black and the fill, so the anti-aliased edge stays smooth
python3 -I - "$DEST/cursors" "$FILL" <<'PY'
import os, struct, sys
folder, fill = sys.argv[1], bytes.fromhex(sys.argv[2])
for name in os.listdir(folder):
    path = os.path.join(folder, name)
    if os.path.islink(path) or not os.path.isfile(path):
        continue
    data = bytearray(open(path, 'rb').read())
    if data[:4] != b'Xcur':
        continue
    count = struct.unpack_from('<I', data, 12)[0]
    for i in range(count):
        kind, _, pos = struct.unpack_from('<III', data, 16 + 12 * i)
        if kind != 0xfffd0002:
            continue
        width, height = struct.unpack_from('<II', data, pos + 16)
        start = pos + 36
        for p in range(start, start + 4 * width * height, 4):
            b, g, r, a = data[p:p + 4]
            if a == 0:
                continue
            level = (r + g + b) / 3 / a
            # the outline's dark grey becomes black; white and the grey edge pixels scale to the fill
            level = 0 if level < 0.35 else level
            data[p + 2] = round(fill[0] * level * a / 255)
            data[p + 1] = round(fill[1] * level * a / 255)
            data[p] = round(fill[2] * level * a / 255)
    open(path, 'wb').write(bytes(data))
PY
printf 'Zacess Yellow pointer built in %s\n' "$DEST"
