"""Checks the Thonny folder without Thonny: run from anywhere, exits non-zero on a problem.

- the generated plugin and shared/apply.py parse as Python
- the plugin defines all eight Zacess themes
- shared/settings.json names a Zacess theme and every platform's overlay names Geist Mono
"""

import ast
import json
import pathlib
import sys

NAMES = ["Zacess Deep Contrast Dark", "Zacess Deep Contrast Light", "Zacess High Contrast Dark",
         "Zacess High Contrast Light", "Zacess Dark", "Zacess Light", "Zacess Cream", "Zacess Yellow on Black"]
root = pathlib.Path(__file__).resolve().parent.parent
problems = []

plugin = root / "shared" / "thonnycontrib" / "zacess_themes" / "__init__.py"
for path in (plugin, root / "shared" / "apply.py"):
    try:
        ast.parse(path.read_text(encoding="utf-8"))
    except SyntaxError as error:
        problems.append(f"{path.name}: does not parse ({error.msg}, line {error.lineno})")
text = plugin.read_text(encoding="utf-8")
for name in NAMES:
    if repr(name) not in text:
        problems.append(f"plugin: {name} is not defined")

shared = json.loads((root / "shared" / "settings.json").read_text(encoding="utf-8"))
for key in ("ui_theme", "syntax_theme"):
    if shared.get(key) not in NAMES:
        problems.append(f"shared/settings.json: {key} is not a Zacess theme")
for platform in ("windows", "mac", "linux"):
    overlay = json.loads((root / platform / "settings.json").read_text(encoding="utf-8"))
    if "GeistMono" not in overlay.get("editor_font_family", ""):
        problems.append(f"{platform}/settings.json: editor_font_family is not Geist Mono")

for problem in problems:
    print(f"::error::{problem}")
print("thonny: ok" if not problems else f"thonny: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
