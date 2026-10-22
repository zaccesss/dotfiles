"""Checks the Zotero folder without Zotero: run from anywhere, exits non-zero on a problem.

- shared/themes.json maps all eight Zacess themes to Zotero's dark (0) or light (1) mode and one
  built-in reader theme
- shared/prefs.json parses and shared/apply.py parses as Python
"""

import ast
import json
import pathlib
import sys

NAMES = ["Zacess Deep Contrast Dark", "Zacess Deep Contrast Light", "Zacess High Contrast Dark",
         "Zacess High Contrast Light", "Zacess Dark", "Zacess Light", "Zacess Cream", "Zacess Yellow on Black"]
READER = {"", "black", "dark", "snow", "sepia"}
root = pathlib.Path(__file__).resolve().parent.parent
problems = []

themes = json.loads((root / "shared" / "themes.json").read_text(encoding="utf-8"))
if sorted(themes) != sorted(NAMES):
    problems.append("themes.json: does not hold exactly the eight Zacess themes")
for name, prefs in themes.items():
    if prefs.get("browser.theme.toolbar-theme") not in (0, 1):
        problems.append(f"themes.json: {name} has no dark or light mode")
    reader = [value for key, value in prefs.items() if key.startswith("extensions.zotero.reader.")]
    if len(reader) != 1 or reader[0] not in READER:
        problems.append(f"themes.json: {name} does not pick one built-in reader theme")
json.loads((root / "shared" / "prefs.json").read_text(encoding="utf-8"))
try:
    ast.parse((root / "shared" / "apply.py").read_text(encoding="utf-8"))
except SyntaxError as error:
    problems.append(f"shared/apply.py: does not parse ({error.msg}, line {error.lineno})")

for problem in problems:
    print(f"::error::{problem}")
print("zotero: ok" if not problems else f"zotero: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
