"""Checks the JetBrains folder without an IDE: run from anywhere, exits non-zero on a problem.

- shared/theme-package.json pins the Zacess Themes plugin by id, version and a release zip with a
  64-character SHA-256 digest
- options/ names a Zacess theme and its editor scheme; every font file names Geist Mono
- each keymap's parent is the VSCode keymap its platform uses
- shared/apply.py parses as Python and mac/apply.sh and linux/apply.sh are the same file
"""

import ast
import json
import pathlib
import re
import sys
import xml.etree.ElementTree as ET

IDS = ["deep-contrast-dark", "deep-contrast-light", "high-contrast-dark", "high-contrast-light",
       "dark", "light", "cream", "yellow-on-black"]
NAMES = ["Zacess Deep Contrast Dark", "Zacess Deep Contrast Light", "Zacess High Contrast Dark",
         "Zacess High Contrast Light", "Zacess Dark", "Zacess Light", "Zacess Cream", "Zacess Yellow on Black"]
root = pathlib.Path(__file__).resolve().parent.parent
problems = []

package = json.loads((root / "shared" / "theme-package.json").read_text(encoding="utf-8"))
if package["id"] != "com.zacess.themes":
    problems.append("theme-package.json: id is not the Marketplace plugin id")
if not re.fullmatch(r"[0-9a-f]{64}", package["sha256"]):
    problems.append("theme-package.json: sha256 is not a 64-character lowercase hex digest")
expected = f"/releases/download/v{package['version']}/{package['name']}-{package['version']}.zip"
if not package["url"].startswith("https://github.com/zacesshq/") or not package["url"].endswith(expected):
    problems.append("theme-package.json: url does not point at the pinned version's release asset")
for plugins in root.glob("plugins/*.txt"):
    if f"{package['id']}@" not in plugins.read_text(encoding="utf-8"):
        problems.append(f"{plugins.relative_to(root)}: the Zacess Themes plugin is not listed")

laf = ET.parse(root / "options" / "laf.xml").getroot()
for tag in ("laf", "preferred-light-laf", "preferred-dark-laf"):
    node = laf.find(f".//{tag}")
    if node is None or node.get("themeId", "").removeprefix("zacess-") not in IDS:
        problems.append(f"laf.xml: {tag} does not name a Zacess theme")
scheme = ET.parse(root / "options" / "colors.scheme.xml").getroot().find(".//global_color_scheme")
if scheme is None or scheme.get("name") not in NAMES:
    problems.append("colors.scheme.xml: global_color_scheme is not a Zacess theme")
for folder in ("options", "options/windows"):
    for name in ("editor-font.xml", "terminal-font.xml"):
        font = ET.parse(root / folder / name).getroot().find(".//option[@name='FONT_FAMILY']")
        if font is None or "GeistMono" not in font.get("value", ""):
            problems.append(f"{folder}/{name}: FONT_FAMILY is not Geist Mono")

parents = {"JetBrains Custom (VSCode-based) mac.xml": "VSCode OSX",
           "JetBrains Custom (VSCode-based) windows-linux.xml": "VSCode"}
for name, parent in parents.items():
    keymap = ET.parse(root / "keymaps" / name).getroot()
    if keymap.get("parent") != parent:
        problems.append(f"keymaps/{name}: parent is not {parent}")

try:
    ast.parse((root / "shared" / "apply.py").read_text(encoding="utf-8"))
except SyntaxError as error:
    problems.append(f"apply.py: does not parse ({error.msg}, line {error.lineno})")
mac = (root / "mac" / "apply.sh").read_bytes().replace(b"\r\n", b"\n")
linux = (root / "linux" / "apply.sh").read_bytes().replace(b"\r\n", b"\n")
if mac != linux:
    problems.append("mac/apply.sh and linux/apply.sh differ")

for problem in problems:
    print(f"::error::{problem}")
print("jetbrains: ok" if not problems else f"jetbrains: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
