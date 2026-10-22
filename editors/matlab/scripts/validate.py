"""Checks the MATLAB folder without MATLAB: run from anywhere, exits non-zero on a problem.

- shared/themes holds the eight Zacess themes, each with a Light or Dark desktop and RGB colours
- every platform's fonts.json names Geist Mono
- shared/zacess_apply.m defines the zacess_apply function
- shared/schemes holds a colour scheme per theme for the same desktop, setting every colour in
  the Color Theme Extensions template
- shared/scheme-tools.json pins the add-on by commit and digest
"""

import json
import pathlib
import re
import sys

NAMES = ["Zacess Deep Contrast Dark", "Zacess Deep Contrast Light", "Zacess High Contrast Dark",
         "Zacess High Contrast Light", "Zacess Dark", "Zacess Light", "Zacess Cream", "Zacess Yellow on Black"]
root = pathlib.Path(__file__).resolve().parent.parent
problems = []

for name in NAMES:
    path = root / "shared" / "themes" / f"{name}.json"
    if not path.exists():
        problems.append(f"themes: {name}.json is missing")
        continue
    settings = json.loads(path.read_text(encoding="utf-8"))["settings"]
    if settings.get("matlab.appearance.MATLABTheme") not in ("Light", "Dark"):
        problems.append(f"{path.name}: MATLABTheme is not Light or Dark")
    for key, value in settings.items():
        if key.startswith("matlab.colors.") and not (
                isinstance(value, list) and len(value) == 3 and all(isinstance(v, int) and 0 <= v <= 255 for v in value)):
            problems.append(f"{path.name}: {key} is not an RGB triple")
for platform in ("windows", "mac", "linux"):
    fonts = json.loads((root / platform / "fonts.json").read_text(encoding="utf-8"))["settings"]
    if "GeistMono" not in fonts.get("matlab.fonts.codefont.Name", ""):
        problems.append(f"{platform}/fonts.json: the code font is not Geist Mono")
template = json.loads((root / "shared" / "base" / "scheme-template.json").read_text(encoding="utf-8"))


def colours(node, prefix=""):
    for key, value in node.items():
        if isinstance(value, dict):
            yield from colours(value, f"{prefix}{key}.")
        elif isinstance(value, str) and value.startswith("#"):
            yield f"{prefix}{key}", value


wanted = {key for key, _ in colours(template)}
for name in NAMES:
    path = root / "shared" / "schemes" / f"{name}.json"
    if not path.exists():
        problems.append(f"schemes: {name}.json is missing")
        continue
    scheme = json.loads(path.read_text(encoding="utf-8"))
    desktop = json.loads((root / "shared" / "themes" / f"{name}.json").read_text(encoding="utf-8"))["settings"]
    if scheme.get("DesktopTheme") != desktop.get("matlab.appearance.MATLABTheme"):
        problems.append(f"schemes/{path.name}: DesktopTheme does not match the theme's desktop")
    found = dict(colours(scheme))
    if set(found) != wanted:
        problems.append(f"schemes/{path.name}: colours do not match the add-on's template")
    for key, value in found.items():
        if not re.fullmatch(r"#[0-9A-F]{6}", value):
            problems.append(f"schemes/{path.name}: {key} is not a #RRGGBB colour")
tools = json.loads((root / "shared" / "scheme-tools.json").read_text(encoding="utf-8"))
if not re.fullmatch(r"[0-9a-f]{40}", tools["commit"]):
    problems.append("scheme-tools.json: commit is not a full 40-character hash")
for name, digest in tools["files"].items():
    if not re.fullmatch(r"[0-9a-f]{64}", digest):
        problems.append(f"scheme-tools.json: {name} has no full SHA-256 digest")
if "import_scheme.p" not in tools["files"]:
    problems.append("scheme-tools.json: import_scheme.p is not pinned")
if "function zacess_apply" not in (root / "shared" / "zacess_apply.m").read_text(encoding="utf-8"):
    problems.append("shared/zacess_apply.m: no zacess_apply function")

for problem in problems:
    print(f"::error::{problem}")
print("matlab: ok" if not problems else f"matlab: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
