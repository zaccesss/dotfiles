"""Checks the Notepad++ folder without Notepad++: run from anywhere, exits non-zero on a problem.

- themes/ holds the eight Zacess themes, each well-formed XML
- each theme's Default Style and Global override use GeistMono NF with six-digit hex colours
"""

import pathlib
import re
import sys
import xml.etree.ElementTree as ET

NAMES = ["Zacess Deep Contrast Dark", "Zacess Deep Contrast Light", "Zacess High Contrast Dark",
         "Zacess High Contrast Light", "Zacess Dark", "Zacess Light", "Zacess Cream", "Zacess Yellow on Black"]
root = pathlib.Path(__file__).resolve().parent.parent
problems = []

for name in NAMES:
    path = root / "themes" / f"{name}.xml"
    if not path.exists():
        problems.append(f"themes: {name}.xml is missing")
        continue
    try:
        tree = ET.parse(path)
    except ET.ParseError as error:
        problems.append(f"{path.name}: not well-formed XML ({error})")
        continue
    for widget in tree.iter("WidgetStyle"):
        if widget.get("name") in ("Default Style", "Global override"):
            if widget.get("fontName") != "GeistMono NF":
                problems.append(f"{path.name}: {widget.get('name')} does not use GeistMono NF")
            for attr in ("fgColor", "bgColor"):
                if not re.fullmatch(r"[0-9A-F]{6}", widget.get(attr, "")):
                    problems.append(f"{path.name}: {widget.get('name')} {attr} is not a six-digit hex colour")

for problem in problems:
    print(f"::error::{problem}")
print("notepad-plus-plus: ok" if not problems else f"notepad-plus-plus: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
