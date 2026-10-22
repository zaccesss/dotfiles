"""Checks the LTspice folder without LTspice: run from anywhere, exits non-zero on a problem.

- shared/themes holds the eight Zacess themes, each a [Colors] section of name=number lines
- every colour is a 24-bit value and every theme sets the same entries
- shared/apply.py parses as Python
"""

import ast
import pathlib
import re
import sys

NAMES = ["Zacess Deep Contrast Dark", "Zacess Deep Contrast Light", "Zacess High Contrast Dark",
         "Zacess High Contrast Light", "Zacess Dark", "Zacess Light", "Zacess Cream", "Zacess Yellow on Black"]
root = pathlib.Path(__file__).resolve().parent.parent
problems = []

entries = {}
for name in NAMES:
    path = root / "shared" / "themes" / f"{name}.ini"
    if not path.exists():
        problems.append(f"themes: {name}.ini is missing")
        continue
    lines = [line for line in path.read_text(encoding="ascii").splitlines() if line and not line.startswith(";")]
    if not lines or lines[0] != "[Colors]":
        problems.append(f"{path.name}: does not start with [Colors]")
    keys = set()
    for line in lines[1:]:
        match = re.fullmatch(r"([A-Za-z0-9]+)=(\d+)", line)
        if not match or int(match.group(2)) > 0xFFFFFF:
            problems.append(f"{path.name}: bad line {line!r}")
        else:
            keys.add(match.group(1))
    entries[name] = frozenset(keys)
if len(set(entries.values())) > 1:
    problems.append("themes: not every theme sets the same entries")
try:
    ast.parse((root / "shared" / "apply.py").read_text(encoding="utf-8"))
except SyntaxError as error:
    problems.append(f"shared/apply.py: does not parse ({error.msg}, line {error.lineno})")

for problem in problems:
    print(f"::error::{problem}")
print("ltspice: ok" if not problems else f"ltspice: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
