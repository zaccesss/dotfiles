"""Checks the Nextpad++ folder without Nextpad++: run from anywhere, exits non-zero on a problem.

- shared/themes holds the eight Zacess themes as Notepad++ style files that parse
- every style's text colour is at least 7:1 on the editor background, the current line and the
  selection in the Deep Contrast and High Contrast themes and at least 4.5:1 in the others, and
  so are the line numbers on their margin
- the Default Style names Geist Mono, which every style without a font of its own inherits
"""

import pathlib
import sys
import xml.etree.ElementTree as ET

root = pathlib.Path(__file__).resolve().parent.parent
problems = []

NAMES = {"deep-contrast-dark": "Zacess Deep Contrast Dark", "deep-contrast-light": "Zacess Deep Contrast Light",
         "high-contrast-dark": "Zacess High Contrast Dark", "high-contrast-light": "Zacess High Contrast Light",
         "dark": "Zacess Dark", "light": "Zacess Light", "cream": "Zacess Cream",
         "yellow-on-black": "Zacess Yellow on Black"}
FONT = "GeistMono Nerd Font Mono"


def luminance(hex_colour):
    out = []
    for i in (0, 2, 4):
        c = int(hex_colour[i:i + 2], 16) / 255
        out.append(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * out[0] + 0.7152 * out[1] + 0.0722 * out[2]


def contrast(a, b):
    hi, lo = sorted([luminance(a), luminance(b)], reverse=True)
    return (hi + 0.05) / (lo + 0.05)


for theme_id, name in NAMES.items():
    path = root / "shared" / "themes" / f"{name}.xml"
    if not path.exists():
        problems.append(f"{path.name}: missing")
        continue
    try:
        tree = ET.parse(path).getroot()
    except ET.ParseError as error:
        problems.append(f"{path.name}: does not parse: {error}")
        continue
    widgets = {w.get("name"): w for w in tree.iter("WidgetStyle")}
    default = widgets.get("Default Style")
    if default is None or default.get("fontName") != FONT:
        problems.append(f"{path.name}: the Default Style does not name {FONT}")
        continue
    floor = 7 if theme_id.startswith(("deep-", "high-")) else 4.5
    surfaces = {"background": default.get("bgColor"),
                "current line": widgets["Current line background colour"].get("bgColor"),
                "selection": widgets["Selected text colour"].get("bgColor")}
    worst = {}
    for style in tree.iter("WordsStyle"):
        fg = style.get("fgColor")
        if style.get("bgColor") != surfaces["background"]:
            problems.append(f"{path.name}: {style.get('name')} has its own background")
        for surface, bg in surfaces.items():
            ratio = contrast(fg, bg)
            if ratio < worst.get(surface, (99,))[0]:
                worst[surface] = (ratio, style.get("name"))
    for surface, (ratio, style_name) in worst.items():
        if ratio < floor:
            problems.append(f"{path.name}: {style_name} is {ratio:.2f}:1 on the {surface}, below {floor}:1")
    margin = widgets["Line number margin"]
    ratio = contrast(margin.get("fgColor"), margin.get("bgColor"))
    if ratio < floor:
        problems.append(f"{path.name}: line numbers are {ratio:.2f}:1 on their margin, below {floor}:1")

for problem in problems:
    print(f"::error::{problem}")
print("nextpad-plus-plus: ok" if not problems else f"nextpad-plus-plus: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
