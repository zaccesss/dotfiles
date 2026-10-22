"""Builds the eight Zacess colour themes for KiCad in shared/colors from the Zacess palette.

usage: python3 scripts/build-themes.py [palette.json]

With no argument the palette is downloaded from the pinned Zacess Themes release and checked
against its digest, so a rebuild always starts from the same colours. A local palette file (a
clone of zacesshq/themes) can be passed instead while a new release is being prepared.

KiCad keeps one JSON file per colour theme in <config>/colors and names it by the file's stem.
Every colour key KiCad 10 reads is written, so nothing falls back to KiCad's own dark default
inside a light theme. The 3D viewer's board, copper and mask colours are left out on purpose:
they model the real board, not the editor.
"""

import colorsys
import hashlib
import json
import pathlib
import sys
import urllib.request

PALETTE_URL = "https://raw.githubusercontent.com/zacesshq/themes/v0.4.0/palette/zacess.json"
PALETTE_SHA256 = "fd45d887c54703e639fe34e83dbc146c9f56d985fcaf9a0fb3a9233db9914c9c"
# KiCad 10's colour settings schema version (colorsSchemaVersion in color_settings.cpp)
SCHEMA_VERSION = 5
ORDER = ["deep-contrast-dark", "deep-contrast-light", "high-contrast-dark", "high-contrast-light",
         "dark", "light", "cream", "yellow-on-black"]

RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN = 1, 2, 3, 4, 5, 6
# the hue each terminal colour slot stands for in degrees plus how far a palette colour may sit
# from it and still count as that hue
HUES = {RED: 0, GREEN: 120, YELLOW: 60, BLUE: 225, MAGENTA: 300, CYAN: 180}
HUE_WINDOW = 35
# red sits next to orange, so it gets a narrower window: an orange top copper layer would not read as red
RED_WINDOW = 15


def load_palette(argv):
    if len(argv) > 1:
        return json.loads(pathlib.Path(argv[1]).read_text(encoding="utf-8"))
    data = urllib.request.urlopen(PALETTE_URL, timeout=60).read()
    if hashlib.sha256(data).hexdigest() != PALETTE_SHA256:
        sys.exit("the downloaded palette does not match its pinned digest")
    return json.loads(data)


def rgb(hex_colour):
    h = hex_colour.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def luminance(hex_colour):
    out = []
    for c in rgb(hex_colour):
        c /= 255
        out.append(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * out[0] + 0.7152 * out[1] + 0.0722 * out[2]


def contrast(a, b):
    hi, lo = sorted([luminance(a), luminance(b)], reverse=True)
    return (hi + 0.05) / (lo + 0.05)


def hsv(hex_colour):
    h, sat, val = colorsys.rgb_to_hsv(*(c / 255 for c in rgb(hex_colour)))
    return h * 360, sat, val


def pastel(hex_colour):
    # a light tint: bright but only weakly coloured. greys and white are neutral, not pastel
    _, sat, val = hsv(hex_colour)
    return val >= 0.8 and 0.08 < sat < 0.55


def hue_distance(a, b):
    d = abs(a - b) % 360
    return min(d, 360 - d)


def css(hex_colour, alpha=1.0):
    r, g, b = rgb(hex_colour)
    # the same text KiCad writes itself (COLOR4D::ToCSSString), so a save from KiCad changes nothing
    return f"rgb({r}, {g}, {b})" if alpha == 1 else f"rgba({r}, {g}, {b}, {alpha:g})"


def build(theme):
    ui, syn, ansi = theme["ui"], theme["syntax"], theme["terminal"]["ansi"]
    bg = ui["background"]

    dark = theme["appearance"] == "dark"
    floor = 7 if theme["id"].startswith(("deep-", "high-")) else 4.5
    pool = [c for i, c in enumerate(ansi) if i not in (0, 7, 8, 15)] + list(syn.values()) + [
        ui[k] for k in ("error", "warning", "info", "accent", "link", "borderActive", "cursor")]

    def reads(colour, target=None):
        # text sits on the canvas and on a symbol's fill, so a colour has to clear both
        return min(contrast(colour, bg), contrast(colour, ui["surfaceAlt"])) >= (target or floor)

    def pick(degrees, exclude=()):
        # the most saturated palette colour of that hue that still clears the contrast floor, so
        # dark themes get deep colours rather than light tints
        found = [c for c in dict.fromkeys(pool)
                 if c not in exclude and hue_distance(hsv(c)[0], degrees) <= (RED_WINDOW if degrees % 360 == 0 else HUE_WINDOW)
                 and hsv(c)[1] >= 0.08 and not pastel(c) and reads(c)]
        found.sort(key=lambda c: (hsv(c)[1], contrast(c, bg)), reverse=True)
        return found[0] if found else None

    def deepen(degrees):
        # where the palette has no deep colour of a hue at this contrast (its dark themes lean on
        # light tints for red, blue and purple), the most saturated colour of that hue that still
        # reaches about 8:1 is made instead. pure blue and violet cannot be both deep and bright
        # enough on black, so they move to azure and to magenta violet, as the palette's own
        # Deep Contrast Dark blue does
        degrees %= 360
        if 225 <= degrees <= 255:
            degrees = 212
        elif 255 < degrees < 290:
            degrees = 290
        for target in (floor + 1, floor):
            for step in range(100, 54, -1):
                r, g, b = colorsys.hsv_to_rgb(degrees / 360, step / 100, 1)
                made = "#%02x%02x%02x" % (round(r * 255), round(g * 255), round(b * 255))
                if reads(made, target) and not pastel(made):
                    return made
        return None

    def vivid(colour):
        # in a dark theme a pastel palette colour is swapped for the deepest colour of its hue
        if not dark or not pastel(colour):
            return colour
        degrees = hsv(colour)[0]
        return pick(degrees) or deepen(degrees) or colour

    def col(colour, alpha=1.0):
        return css(vivid(colour), alpha)

    def hue(n, alt=False):
        # the deepest palette colour of that hue leads and the next one is the spare for a second
        # layer of the same hue. a dark theme without one gets a made colour of that hue (shifted a
        # little for the spare); a light theme falls back to its terminal pair
        first = pick(HUES[n])
        second = pick(HUES[n], exclude={first}) if first else None
        pair = sorted([ansi[n], ansi[n + 8]], key=lambda c: contrast(c, bg), reverse=True)
        if dark:
            first = first or deepen(HUES[n])
            second = second or deepen(HUES[n] + 20)
        if alt:
            return second or first or pair[1]
        return first or pair[0]

    layers = [hue(GREEN), hue(CYAN), hue(MAGENTA), hue(YELLOW), hue(RED, True), hue(GREEN, True),
              hue(BLUE, True), hue(CYAN, True), hue(MAGENTA, True), hue(YELLOW, True)]

    schematic = {
        "anchor": col(ui["accent"]),
        "aux_items": col(syn["foreground"]),
        "background": col(bg),
        "hovered": col(ui["accent"]),
        "brightened": col(syn["regex"]),
        "bus": col(syn["keyword"]),
        "bus_junction": col(syn["keyword"]),
        "component_body": col(ui["surfaceAlt"]),
        "component_outline": col(syn["control"]),
        "cursor": col(ui["cursor"]),
        "dnp_marker": col(ui["error"], 0.85),
        "excluded_from_sim": col(ui["muted"], 0.95),
        "erc_error": col(ui["error"], 0.8),
        "erc_warning": col(ui["warning"], 0.8),
        "erc_exclusion": col(ui["muted"], 0.8),
        "fields": col(syn["property"]),
        "grid": col(ui["indentGuide"]),
        "grid_axes": col(ui["accent"]),
        "hidden": col(ui["muted"]),
        "junction": col(syn["string"]),
        "label_global": col(syn["control"]),
        "label_hier": col(syn["attribute"]),
        "label_local": col(syn["foreground"]),
        "netclass_flag": col(ui["muted"]),
        "drag_net_collision": col(ui["error"], 0.8),
        "rule_area": col(ui["error"]),
        "no_connect": col(syn["keyword"]),
        "note": col(syn["comment"]),
        "private_note": col(syn["comment"]),
        "note_background": col(bg, 0),
        "pin": col(syn["control"]),
        "pin_name": col(syn["type"]),
        "pin_number": col(syn["number"]),
        "reference": col(syn["type"]),
        "shadow": col(ui["accent"], 0.5),
        "sheet": col(syn["keyword"]),
        "sheet_background": col(bg, 0),
        "sheet_filename": col(syn["attribute"]),
        "sheet_fields": col(syn["property"]),
        "sheet_label": col(syn["type"]),
        "sheet_name": col(syn["type"]),
        "value": col(syn["type"]),
        "wire": col(syn["string"]),
        "worksheet": col(ui["muted"]),
        "page_limits": col(ui["border"]),
        "op_voltages": col(syn["number"]),
        "op_currents": col(syn["regex"]),
        "override_item_colors": False,
    }

    board = {
        "anchor": col(hue(MAGENTA)),
        "locked_shadow": col(hue(MAGENTA), 0.5),
        "conflicts_shadow": col(ui["error"], 0.5),
        "aux_items": col(syn["foreground"]),
        "background": col(bg),
        "cursor": col(ui["cursor"]),
        "drc_error": col(ui["error"], 0.8),
        "drc_warning": col(ui["warning"], 0.8),
        "drc_exclusion": col(ui["muted"], 0.8),
        "grid": col(ui["indentGuide"]),
        "grid_axes": col(ui["border"]),
        "pad_plated_hole": col(hue(YELLOW)),
        "plated_hole": col(hue(CYAN)),
        "ratsnest": col(syn["foreground"], 0.6),
        "via_hole": col(hue(YELLOW, True)),
        "via_hole_walls": col(syn["foreground"]),
        "worksheet": col(ui["muted"]),
        "page_limits": col(ui["border"]),
        # the shading inside the board outline: black in dark themes so the board reads as the canvas
        "outline_area": col(bg if dark else ui["muted"], 0.35),
        "track_net_names": col(syn["foreground"], 0.7),
        "pad_net_names": col(syn["foreground"], 0.9),
        "via_net_names": col(syn["foreground"], 0.9),
        "points": col(hue(MAGENTA)),
        "copper": {"f": col(hue(RED)), "b": col(hue(BLUE))},
        "b_adhes": col(hue(BLUE, True)),
        "f_adhes": col(hue(MAGENTA, True)),
        "b_paste": col(hue(CYAN, True), 0.9),
        "f_paste": col(ui["muted"], 0.9),
        "b_silks": col(syn["control"]),
        "f_silks": col(syn["function"]),
        "b_mask": col(hue(CYAN), 0.4),
        "f_mask": col(hue(MAGENTA), 0.4),
        "dwgs_user": col(ui["muted"]),
        "cmts_user": col(syn["keyword"]),
        "eco1_user": col(syn["type"]),
        "eco2_user": col(syn["function"]),
        "edge_cuts": col(syn["foreground"]),
        "margin": col(syn["regex"]),
        "b_crtyd": col(hue(CYAN, True)),
        "f_crtyd": col(hue(MAGENTA, True)),
        "b_fab": col(syn["property"]),
        "f_fab": col(ui["muted"]),
    }
    for n in range(1, 31):
        board["copper"][f"in{n}"] = col(layers[(n - 1) % len(layers)])
    users = [ui["muted"], syn["keyword"], syn["type"], syn["function"]]
    for n in range(1, 46):
        board[f"user_{n}"] = col(users[(n - 1) % len(users)])

    gerber_cycle = [hue(RED), hue(GREEN), hue(YELLOW), hue(CYAN), hue(MAGENTA), hue(BLUE)]
    gerber_cycle += [hue(n, True) for n in (RED, GREEN, YELLOW, CYAN, MAGENTA, BLUE)]
    gerbview = {
        "axes": col(ui["border"]),
        "background": col(bg),
        "dcodes": col(syn["foreground"]),
        "grid": col(ui["indentGuide"]),
        "negative_objects": col(ui["muted"]),
        "worksheet": col(ui["muted"]),
        "page_limits": col(ui["border"]),
        "layers": {str(i): col(gerber_cycle[i % len(gerber_cycle)]) for i in range(64)},
    }

    viewer = {"background_top": col(ui["surfaceAlt"]), "background_bottom": col(bg)}

    file_id = f"zacess-{theme['id']}"
    return {
        "3d_viewer": viewer,
        "board": board,
        "gerbview": gerbview,
        "meta": {"filename": file_id, "name": theme["name"], "version": SCHEMA_VERSION},
        "schematic": schematic,
    }


def main():
    palette = load_palette(sys.argv)
    themes = {t["id"]: t for t in palette["themes"]}
    if sorted(themes) != sorted(ORDER):
        sys.exit("the palette does not hold the eight expected Zacess themes")
    target = pathlib.Path(__file__).resolve().parent.parent / "shared" / "colors"
    target.mkdir(parents=True, exist_ok=True)
    for theme_id in ORDER:
        data = build(themes[theme_id])
        path = target / f"zacess-{theme_id}.json"
        path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(f"built {len(ORDER)} themes from palette {palette['version']} in {target}")


if __name__ == "__main__":
    main()
