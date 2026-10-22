"""Checks the Zed folder without Zed: run from anywhere, exits non-zero on a problem.

- shared/themes/*.json parse and together define exactly the eight themes theme-package.json names
- theme-package.json pins a version and points at that version's file in the Zacess Themes repository
- settings.json names a theme from the theme file for both halves of the pair
- shared/apply.py parses as Python and mac/apply.sh and linux/apply.sh are the same file
"""

import ast
import json
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
problems = []

package = json.loads((root / "shared" / "theme-package.json").read_text(encoding="utf-8"))
defined = []
for path in sorted((root / "shared" / "themes").glob("*.json")):
    try:
        family = json.loads(path.read_text(encoding="utf-8"))
    except ValueError as error:
        problems.append(f"{path.name}: does not parse ({error})")
        continue
    for theme in family.get("themes", []):
        if theme.get("appearance") not in ("light", "dark"):
            problems.append(f"{path.name}: {theme.get('name')} has no light or dark appearance")
        defined.append(theme.get("name"))
if sorted(defined) != sorted(package["themes"]):
    problems.append(f"shared/themes: the files define {sorted(defined)}, theme-package.json names {sorted(package['themes'])}")
if len(package["themes"]) != 8:
    problems.append("theme-package.json: expected the eight Zacess themes")
if not re.fullmatch(r"\d+\.\d+\.\d+", package["version"]):
    problems.append("theme-package.json: version is not x.y.z")
expected = f"/themes/blob/v{package['version']}/editors/zed/themes/{package['file']}"
if not package["source"].startswith("https://github.com/zacesshq/") or not package["source"].endswith(expected):
    problems.append("theme-package.json: source does not point at the pinned version's theme file")
if not (root / "shared" / "themes" / package["file"]).exists():
    problems.append(f"theme-package.json: file {package['file']} is not in shared/themes")


def load_settings(path):
    # Zed's file allows // comments and trailing commas, which a strict parser does not
    text = re.sub(r"(?m)^\s*//.*$", "", path.read_text(encoding="utf-8"))
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", text))


theme = load_settings(root / "settings.json").get("theme", {})
for half in ("dark", "light"):
    if theme.get(half) not in defined:
        problems.append(f"settings.json: theme.{half} is not in the theme file")

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
print("zed: ok" if not problems else f"zed: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
