"""Checks the Obsidian folder without Obsidian: run from anywhere, exits non-zero on a problem.

- shared/themes.json maps all eight Zacess looks to the community theme that carries each (cssTheme)
  and Obsidian's dark (obsidian) or light (moonstone) base colour scheme
- shared/theme-package.json pins one release zip per theme by version and a 64-character SHA-256
  digest. Every theme themes.json names has a package
- shared/appearance.json names Geist Mono and leaves the theme to themes.json
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
    problems.append("themes.json: does not hold exactly the eight Zacess looks")
for name, choice in themes.items():
    if choice.get("theme") not in ("obsidian", "moonstone"):
        problems.append(f"themes.json: {name} theme is not obsidian (dark) or moonstone (light)")
    if not str(choice.get("cssTheme", "")).startswith("Zacess"):
        problems.append(f"themes.json: {name} names no Zacess community theme")
package = json.loads((root / "shared" / "theme-package.json").read_text(encoding="utf-8"))
version = package.get("version", "")
if not re.fullmatch(r"\d+\.\d+\.\d+", version):
    problems.append("theme-package.json: version is not x.y.z")
folders = []
for entry in package.get("themes", []):
    folders.append(entry.get("folder"))
    if not re.fullmatch(r"[0-9a-f]{64}", entry.get("sha256", "")):
        problems.append(f"theme-package.json: {entry.get('folder')} sha256 is not a 64-character lowercase hex digest")
    expected = f"/releases/download/v{version}/{entry.get('name')}-{version}.zip"
    if not entry.get("url", "").startswith("https://github.com/zacesshq/") or not entry.get("url", "").endswith(expected):
        problems.append(f"theme-package.json: {entry.get('folder')} url does not point at the pinned version's release asset")
if len(folders) != len(set(folders)):
    problems.append("theme-package.json: a theme folder is listed twice")
for name, choice in themes.items():
    if choice.get("cssTheme") not in folders:
        problems.append(f"themes.json: {name} names {choice.get('cssTheme')}, which theme-package.json does not install")
for folder in folders:
    if not any(choice.get("cssTheme") == folder for choice in themes.values()):
        problems.append(f"theme-package.json: {folder} is installed but no look in themes.json uses it")
appearance = json.loads((root / "shared" / "appearance.json").read_text(encoding="utf-8"))
if "GeistMono" not in appearance.get("monospaceFontFamily", ""):
    problems.append("appearance.json: does not name Geist Mono")
if "cssTheme" in appearance or "theme" in appearance:
    problems.append("appearance.json: sets a theme, which themes.json decides per look")
try:
    ast.parse((root / "shared" / "apply.py").read_text(encoding="utf-8"))
except SyntaxError as error:
    problems.append(f"shared/apply.py: does not parse ({error.msg}, line {error.lineno})")

for problem in problems:
    print(f"::error::{problem}")
print("obsidian: ok" if not problems else f"obsidian: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
