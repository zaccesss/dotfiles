"""Checks the Arduino IDE folder without the IDE: run from anywhere, exits non-zero on a problem.

- shared/settings.json parses and names one of the eight Zacess themes and a Geist Mono font
- shared/theme-package.json pins a release .vsix by version and a 64-character SHA-256 digest
- mac/apply.sh and linux/apply.sh are the same file
"""

import json
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
problems = []

settings = json.loads((root / "shared" / "settings.json").read_text(encoding="utf-8"))
package = json.loads((root / "shared" / "theme-package.json").read_text(encoding="utf-8"))

if settings.get("workbench.colorTheme") not in package["themes"]:
    problems.append("settings.json: workbench.colorTheme is not one of the packaged Zacess themes")
if "GeistMono Nerd Font" not in settings.get("editor.fontFamily", ""):
    problems.append("settings.json: editor.fontFamily does not name GeistMono Nerd Font")
if len(package["themes"]) != 8:
    problems.append("theme-package.json: expected the eight Zacess themes")
if not re.fullmatch(r"[0-9a-f]{64}", package["sha256"]):
    problems.append("theme-package.json: sha256 is not a 64-character lowercase hex digest")
expected = f"/releases/download/v{package['version']}/{package['name']}-{package['version']}.vsix"
if not package["url"].startswith("https://github.com/") or not package["url"].endswith(expected):
    problems.append("theme-package.json: url does not point at the pinned version's release asset")

mac = (root / "mac" / "apply.sh").read_bytes().replace(b"\r\n", b"\n")
linux = (root / "linux" / "apply.sh").read_bytes().replace(b"\r\n", b"\n")
if mac != linux:
    problems.append("mac/apply.sh and linux/apply.sh differ")

for problem in problems:
    print(f"::error::{problem}")
print("arduino: ok" if not problems else f"arduino: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
