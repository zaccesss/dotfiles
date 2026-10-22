"""Checks the Obsidian folder without Obsidian: run from anywhere, exits non-zero on a problem.

- shared/themes.json maps all eight Zacess themes to Obsidian's dark or light base and a Style
  Settings variant
- shared/theme-package.json pins a release zip by version and a 64-character SHA-256 digest
- shared/appearance.json names the Zacess theme and Geist Mono
- shared/apply.py parses as Python
"""

import ast
import json
import pathlib
import re
import sys

NAMES = ["Zacess Deep Contrast Dark", "Zacess Deep Contrast Light", "Zacess High Contrast Dark",
         "Zacess High Contrast Light", "Zacess Dark", "Zacess Light", "Zacess Cream", "Zacess Yellow on Black"]
root = pathlib.Path(__file__).resolve().parent.parent
problems = []

themes = json.loads((root / "shared" / "themes.json").read_text(encoding="utf-8"))
if sorted(themes) != sorted(NAMES):
    problems.append("themes.json: does not hold exactly the eight Zacess themes")
for name, choice in themes.items():
    if choice.get("base") not in ("obsidian", "moonstone"):
        problems.append(f"themes.json: {name} base is not obsidian (dark) or moonstone (light)")
    if not str(choice.get("contrast", "")).startswith("zacess-"):
        problems.append(f"themes.json: {name} has no Zacess Style Settings variant")
package = json.loads((root / "shared" / "theme-package.json").read_text(encoding="utf-8"))
if not re.fullmatch(r"[0-9a-f]{64}", package["sha256"]):
    problems.append("theme-package.json: sha256 is not a 64-character lowercase hex digest")
if not package["url"].endswith(f"/releases/download/v{package['version']}/{package['name']}-{package['version']}.zip"):
    problems.append("theme-package.json: url does not point at the pinned version's release asset")
appearance = json.loads((root / "shared" / "appearance.json").read_text(encoding="utf-8"))
if appearance.get("cssTheme") != package["folder"] or "GeistMono" not in appearance.get("monospaceFontFamily", ""):
    problems.append("appearance.json: does not name the Zacess theme and Geist Mono")
try:
    ast.parse((root / "shared" / "apply.py").read_text(encoding="utf-8"))
except SyntaxError as error:
    problems.append(f"shared/apply.py: does not parse ({error.msg}, line {error.lineno})")

for problem in problems:
    print(f"::error::{problem}")
print("obsidian: ok" if not problems else f"obsidian: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
