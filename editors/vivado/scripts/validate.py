"""Checks the Vivado folder without Vivado: run from anywhere, exits non-zero on a problem.

- shared/themes holds the eight Zacess themes, each with the eight CODE_EDITOR_* colours as
  Vivado's short hex and syntax styles 0 to 20 with colours as signed Java ARGB integers
- every text style is at least 7:1 on the editor background and the current line in the Deep
  Contrast and High Contrast themes and at least 4.5:1 in the others; the selection fill is held to
  4.5:1 in every theme, Zacess Themes' own selection rule
"""

import json
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
problems = []

IDS = ["deep-contrast-dark", "deep-contrast-light", "high-contrast-dark", "high-contrast-light",
       "dark", "light", "cream", "yellow-on-black"]
COLOURS = ["CODE_EDITOR_BACKGROUND", "CODE_EDITOR_FOREGROUND", "CODE_EDITOR_CURSOR_COLOR",
           "CODE_EDITOR_LINE_HIGHLIGHT", "CODE_EDITOR_SELECTION_BACKGROUND",
           "CODE_EDITOR_FIND_HIGHLIGHT_BACKGROUND", "CODE_EDITOR_MATCHING_WORD_HIGHLIGHT_BACKGROUND",
           "CODE_EDITOR_BREAKPOINT_BACKGROUND"]
TEXT_STYLES = list(range(0, 11)) + list(range(15, 21))
FIELDS = {"style_index", "foreground_color", "background_color", "font_style", "effect",
          "effect_color", "stripe_color"}


def rgb_of_hex(value):
    return int(value, 16)


def rgb_of_argb(value):
    return int(value) & 0xFFFFFF


def luminance(rgb):
    out = []
    for shift in (16, 8, 0):
        c = ((rgb >> shift) & 0xFF) / 255
        out.append(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * out[0] + 0.7152 * out[1] + 0.0722 * out[2]


def contrast(a, b):
    hi, lo = sorted([luminance(a), luminance(b)], reverse=True)
    return (hi + 0.05) / (lo + 0.05)


for theme_id in IDS:
    path = root / "shared" / "themes" / f"zacess-{theme_id}.json"
    if not path.exists():
        problems.append(f"{path.name}: missing")
        continue
    data = json.loads(path.read_text(encoding="utf-8"))
    colours = data.get("general_color", {})
    if sorted(colours) != sorted(COLOURS) or not all(re.fullmatch(r"[0-9a-f]{1,6}", v) for v in colours.values()):
        problems.append(f"{path.name}: general_color must hold the eight CODE_EDITOR_* colours as short hex")
        continue
    styles = data.get("syntax_styles", [])
    if [s.get("style_index") for s in styles] != [str(i) for i in range(21)] or any(set(s) != FIELDS for s in styles):
        problems.append(f"{path.name}: syntax_styles must be styles 0 to 20 with the seven Vivado fields")
        continue
    for style in styles:
        for field in ("foreground_color", "background_color", "effect_color", "stripe_color"):
            if style[field] != "null" and not re.fullmatch(r"-\d+", style[field]):
                problems.append(f"{path.name}: style {style['style_index']} {field} is not a Java ARGB integer")
    floor = 7 if theme_id.startswith(("deep-", "high-")) else 4.5
    for surface in ("CODE_EDITOR_BACKGROUND", "CODE_EDITOR_LINE_HIGHLIGHT", "CODE_EDITOR_SELECTION_BACKGROUND"):
        bg = rgb_of_hex(colours[surface])
        # the selection is a fill under the style's own colour, held to Zacess Themes' 4.5:1 selection rule
        limit = 4.5 if surface == "CODE_EDITOR_SELECTION_BACKGROUND" else floor
        for index in TEXT_STYLES:
            ratio = contrast(rgb_of_argb(styles[index]["foreground_color"]), bg)
            if ratio < limit:
                problems.append(f"{path.name}: style {index} is {ratio:.2f}:1 on {surface}, below {limit}:1")
        ratio = contrast(rgb_of_hex(colours["CODE_EDITOR_FOREGROUND"]), bg)
        if ratio < limit:
            problems.append(f"{path.name}: CODE_EDITOR_FOREGROUND is {ratio:.2f}:1 on {surface}, below {limit}:1")

for problem in problems:
    print(f"::error::{problem}")
print("vivado: ok" if not problems else f"vivado: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
