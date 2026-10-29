"""Checks the TranslucentTB folder without TranslucentTB: run from anywhere, exits non-zero on a problem.

- windows/settings.json and every windows/machines/<computer name>.json parse and only use
  appearance sections TranslucentTB knows
- every accent is one TranslucentTB offers and every colour is #RRGGBBAA
"""

import json
import pathlib
import re
import sys

SECTIONS = {"desktop_appearance", "visible_window_appearance", "maximized_window_appearance",
            "start_opened_appearance", "search_opened_appearance", "task_view_opened_appearance",
            "battery_saver_appearance"}
TOP_LEVEL = SECTIONS | {"disable_saving", "verbosity"}
ACCENTS = {"normal", "opaque", "clear", "blur", "acrylic"}
COLOUR = re.compile(r"^#[0-9A-F]{8}$")
root = pathlib.Path(__file__).resolve().parent.parent
problems = []

files = [root / "windows" / "settings.json"] + sorted((root / "windows" / "machines").glob("*.json"))
for path in files:
    name = path.relative_to(root / "windows").as_posix()
    try:
        settings = json.loads(path.read_text(encoding="utf-8"))
    except ValueError as error:
        problems.append(f"{name}: not valid JSON ({error})")
        continue
    for key, value in settings.items():
        if key not in TOP_LEVEL:
            problems.append(f"{name}: {key} is not a TranslucentTB setting this folder tracks")
        if key in SECTIONS:
            if not isinstance(value, dict):
                problems.append(f"{name}: {key} is not an object")
                continue
            if "accent" in value and value["accent"] not in ACCENTS:
                problems.append(f"{name}: {key}.accent {value['accent']} is not one of {sorted(ACCENTS)}")
            if "color" in value and not COLOUR.match(value["color"]):
                problems.append(f"{name}: {key}.color {value['color']} is not #RRGGBBAA")

if problems:
    print("\n".join(problems))
    sys.exit(1)
print("translucenttb: ok")
