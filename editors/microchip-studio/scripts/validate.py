"""Checks the Microchip Studio folder without Studio: run from anywhere, exits non-zero on a problem.

Every theme in themes/ must parse as XML and hold only the Fonts and Colors category, with the
GDI font name, the editor and Visual Assist items and the environment theme that matches it.
"""

import importlib
import pathlib
import sys
import xml.etree.ElementTree as ET

root = pathlib.Path(__file__).resolve().parent.parent
# the build script is imported for its theme table, which would otherwise leave a __pycache__ folder
sys.dont_write_bytecode = True
sys.path.insert(0, str(root / "scripts"))

build = importlib.import_module("build-themes")

REQUIRED = ["Plain Text", "Selected Text", "Line Number", "Keyword", "Preprocessor Keyword", "Comment",
            "String", "Number", "VA Macro / Enum", "VA Method", "VA Class", "VA Variable"]
problems = []

for key, (name, mode) in build.THEMES.items():
    path = root / "themes" / f"{name}.vssettings"
    if not path.exists():
        problems.append(f"{path.name}: missing")
        continue
    tree = ET.parse(path)
    names = [c.get("name") for c in tree.iter("Category") if c.get("name")]
    if names != ["Environment_Group", "Environment_FontsAndColors"]:
        problems.append(f"{path.name}: should hold only the Fonts and Colors category, found {names}")
    theme = tree.find(".//FontsAndColors/Theme")
    if theme is None or theme.get("Id") != build.VS_THEMES[mode]:
        problems.append(f"{path.name}: environment theme is not the {mode} one")
    editor = [c for c in tree.iter("Category") if c.get("GUID") == build.TEXT_EDITOR]
    if not editor or editor[0].get("FontName") != build.FONT:
        problems.append(f"{path.name}: the text editor font is not {build.FONT}")
        continue
    items = {i.get("Name") for i in editor[0].iter("Item")}
    for label in REQUIRED:
        if label not in items:
            problems.append(f"{path.name}: no {label} item")

for problem in problems:
    print(f"::error::{problem}")
print("microchip-studio: ok" if not problems else f"microchip-studio: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
