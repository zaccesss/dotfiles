"""Checks the Proteus folder without Proteus: run from anywhere, exits non-zero on a problem.

- shared/themes holds the eight Zacess themes with unique colour set names Proteus keeps whole
  (it cuts a name to 20 characters when it saves its settings)
- every PCB and graph value is a "(0xRR,0xGG,0xBB)" string, a number or a Yes/No show flag
- every theme's schematic colours cover exactly the slots in shared/base/schematic_default.json
"""

import json
import pathlib
import re
import sys

NAMES = ["Zacess Deep Contrast Dark", "Zacess Deep Contrast Light", "Zacess High Contrast Dark",
         "Zacess High Contrast Light", "Zacess Dark", "Zacess Light", "Zacess Cream", "Zacess Yellow on Black"]
root = pathlib.Path(__file__).resolve().parent.parent
problems = []

slots = set(json.loads((root / "shared" / "base" / "schematic_default.json").read_text(encoding="utf-8")))
sets = []
for name in NAMES:
    path = root / "shared" / "themes" / f"{name}.json"
    if not path.exists():
        problems.append(f"themes: {name}.json is missing")
        continue
    data = json.loads(path.read_text(encoding="utf-8"))
    sets.append(data["set"])
    if not re.fullmatch(r"ZACESS_[A-Z_]+", data["set"]) or len(data["set"]) > 20:
        problems.append(f"{path.name}: set {data['set']} is not a ZACESS_ name of at most 20 characters")
    for key, value in data["values"].items():
        if key.endswith(" Show"):
            if value not in ("Yes", "No"):
                problems.append(f"{path.name}: {key} is not Yes or No")
        elif not (isinstance(value, int) or re.fullmatch(r"\(0x[0-9A-F]{2},0x[0-9A-F]{2},0x[0-9A-F]{2}\)", str(value))):
            problems.append(f"{path.name}: {key} is not a Proteus colour or number")
    schematic = data["schematic"]
    if set(schematic["colours"]) != slots:
        problems.append(f"{path.name}: the schematic colours do not match the default template's slots")
    for key, value in [*schematic["colours"].items(), *schematic["fallback"].items()]:
        if not re.fullmatch(r"#[0-9a-f]{6}", value):
            problems.append(f"{path.name}: schematic {key} is not a #rrggbb colour")
if len(set(sets)) != len(sets):
    problems.append("themes: two themes share a colour set name")

for problem in problems:
    print(f"::error::{problem}")
print("proteus: ok" if not problems else f"proteus: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
