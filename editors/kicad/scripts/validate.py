"""Checks the KiCad folder without KiCad: run from anywhere, exits non-zero on a problem.

- shared/colors holds the eight Zacess themes, each named after its file as KiCad expects
- every schematic, board and GerbView colour key KiCad 10 reads is present and is a CSS colour
- schematic text is at least 7:1 on the canvas and on a symbol's body fill in the Deep Contrast and
  High Contrast themes and at least 4.5:1 in the others; lines, layers and the grid are at least
  3:1 on the schematic, board and GerbView backgrounds
- in the Deep Contrast and High Contrast dark themes no colour is a pastel (bright but only weakly
  coloured: HSV value at least 0.8 with saturation between 0.08 and 0.55) and every copper layer is
  at least 7:1 on the board
- mac/apply.sh and linux/apply.sh are the same file
"""

import colorsys
import json
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
problems = []

IDS = ["deep-contrast-dark", "deep-contrast-light", "high-contrast-dark", "high-contrast-light",
       "dark", "light", "cream", "yellow-on-black"]
TEXT = ["fields", "hidden", "label_global", "label_hier", "label_local", "netclass_flag", "note",
        "private_note", "pin_name", "pin_number", "reference", "sheet_filename", "sheet_fields",
        "sheet_label", "sheet_name", "value", "op_voltages", "op_currents"]
LINES = ["bus", "component_outline", "cursor", "junction", "no_connect", "pin", "sheet", "wire",
         "grid", "worksheet", "page_limits", "anchor", "hovered", "brightened", "aux_items",
         "bus_junction", "rule_area", "grid_axes"]
SCHEMATIC = TEXT + LINES + ["background", "component_body", "dnp_marker", "excluded_from_sim",
                            "erc_error", "erc_warning", "erc_exclusion", "drag_net_collision",
                            "note_background", "shadow", "sheet_background"]
BOARD_LAYERS = (["b_adhes", "f_adhes", "b_silks", "f_silks", "dwgs_user", "cmts_user", "eco1_user",
                 "eco2_user", "edge_cuts", "margin", "b_crtyd", "f_crtyd", "b_fab", "f_fab",
                 "pad_plated_hole", "plated_hole", "via_hole", "via_hole_walls", "grid", "grid_axes",
                 "cursor", "anchor", "aux_items", "worksheet", "page_limits", "points"]
                + [f"user_{n}" for n in range(1, 46)])
BOARD_OTHER = ["background", "locked_shadow", "conflicts_shadow", "drc_error", "drc_warning",
               "drc_exclusion", "ratsnest", "outline_area", "track_net_names", "pad_net_names",
               "via_net_names", "b_paste", "f_paste", "b_mask", "f_mask"]
COPPER = ["f", "b"] + [f"in{n}" for n in range(1, 31)]
GERBVIEW = ["axes", "background", "dcodes", "grid", "negative_objects", "worksheet", "page_limits"]
CSS = re.compile(r"rgba?\((\d+), (\d+), (\d+)(?:, ([\d.]+))?\)")


def parse(value):
    m = CSS.fullmatch(value or "")
    if not m:
        return None
    return tuple(int(m.group(i)) for i in (1, 2, 3)), float(m.group(4) or 1)


def pastel(colour):
    _, sat, val = colorsys.rgb_to_hsv(*(c / 255 for c in colour))
    return val >= 0.8 and 0.08 < sat < 0.55


def luminance(colour):
    out = []
    for c in colour:
        c /= 255
        out.append(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * out[0] + 0.7152 * out[1] + 0.0722 * out[2]


def contrast(a, b):
    hi, lo = sorted([luminance(a), luminance(b)], reverse=True)
    return (hi + 0.05) / (lo + 0.05)


for theme_id in IDS:
    path = root / "shared" / "colors" / f"zacess-{theme_id}.json"
    if not path.exists():
        problems.append(f"{path.name}: missing")
        continue
    data = json.loads(path.read_text(encoding="utf-8"))
    meta = data.get("meta", {})
    if meta.get("filename") != path.stem or not meta.get("name", "").startswith("Zacess "):
        problems.append(f"{path.name}: meta.filename must match the file and meta.name must be a Zacess name")
    sch, board, gerb = data.get("schematic", {}), data.get("board", {}), data.get("gerbview", {})
    colours = {}
    for section, keys, values in (("schematic", SCHEMATIC, sch), ("board", BOARD_LAYERS + BOARD_OTHER, board),
                                  ("gerbview", GERBVIEW, gerb)):
        for key in keys:
            parsed = parse(values.get(key))
            if parsed is None:
                problems.append(f"{path.name}: {section}.{key} is missing or not rgb()/rgba()")
            colours[(section, key)] = parsed
    for key in COPPER:
        parsed = parse(board.get("copper", {}).get(key))
        if parsed is None:
            problems.append(f"{path.name}: board.copper.{key} is missing or not rgb()/rgba()")
        colours[("copper", key)] = parsed
    for i in range(64):
        parsed = parse(gerb.get("layers", {}).get(str(i)))
        if parsed is None:
            problems.append(f"{path.name}: gerbview.layers.{i} is missing or not rgb()/rgba()")
        colours[("gerber", str(i))] = parsed
    if any(v is None for v in colours.values()):
        continue

    floor = 7 if theme_id.startswith(("deep-", "high-")) else 4.5
    sch_bg = colours[("schematic", "background")][0]
    body = colours[("schematic", "component_body")][0]
    for key in TEXT:
        for surface, name in ((sch_bg, "background"), (body, "component_body")):
            ratio = contrast(colours[("schematic", key)][0], surface)
            if ratio < floor:
                problems.append(f"{path.name}: schematic.{key} is {ratio:.2f}:1 on {name}, below {floor}:1")
    for key in LINES:
        ratio = contrast(colours[("schematic", key)][0], sch_bg)
        if ratio < 3:
            problems.append(f"{path.name}: schematic.{key} is {ratio:.2f}:1 on the canvas, below 3:1")
    pcb_bg = colours[("board", "background")][0]
    for key in BOARD_LAYERS:
        ratio = contrast(colours[("board", key)][0], pcb_bg)
        if ratio < 3:
            problems.append(f"{path.name}: board.{key} is {ratio:.2f}:1 on the board, below 3:1")
    for key in COPPER:
        ratio = contrast(colours[("copper", key)][0], pcb_bg)
        if ratio < 3:
            problems.append(f"{path.name}: board.copper.{key} is {ratio:.2f}:1 on the board, below 3:1")
    if theme_id in ("deep-contrast-dark", "high-contrast-dark"):
        for (section, key), (colour, _) in colours.items():
            if pastel(colour):
                problems.append(f"{path.name}: {section}.{key} is a pastel, rgb{colour}")
        for key in COPPER:
            ratio = contrast(colours[("copper", key)][0], pcb_bg)
            if ratio < 7:
                problems.append(f"{path.name}: board.copper.{key} is {ratio:.2f}:1 on the board, below 7:1")
    gerb_bg = colours[("gerbview", "background")][0]
    for i in range(64):
        ratio = contrast(colours[("gerber", str(i))][0], gerb_bg)
        if ratio < 3:
            problems.append(f"{path.name}: gerbview.layers.{i} is {ratio:.2f}:1, below 3:1")

mac = (root / "mac" / "apply.sh").read_bytes().replace(b"\r\n", b"\n")
linux = (root / "linux" / "apply.sh").read_bytes().replace(b"\r\n", b"\n")
if mac != linux:
    problems.append("mac/apply.sh and linux/apply.sh differ")

for problem in problems:
    print(f"::error::{problem}")
print("kicad: ok" if not problems else f"kicad: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
