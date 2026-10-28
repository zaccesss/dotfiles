"""Checks the Processing folder without Processing: run from anywhere, exits non-zero on a problem.

- shared/themes holds the eight Zacess themes, each starting with the marker line the apply
  scripts look for, every line a comment or key = value and every colour a six-digit hex value
- every syntax colour and the editor, console, tab, status and error table text is at least 7:1
  on what it sits on in the Deep Contrast and High Contrast themes and at least 4.5:1 in the others;
  the selection fill is held to 4.5:1 in every theme, Zacess Themes' own selection rule
- shared/preferences.txt names Geist Mono for the editor
- mac/apply.sh and linux/apply.sh are the same file
"""

import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent.parent
problems = []

IDS = ["deep-contrast-dark", "deep-contrast-light", "high-contrast-dark", "high-contrast-light",
       "dark", "light", "cream", "yellow-on-black"]
MARKER = "# Zacess theme for Processing"
TOKENS = [f"editor.token.{t}.style" for t in
          ["function1", "function2", "function3", "function4", "keyword1", "keyword2", "keyword3",
           "keyword4", "keyword5", "keyword6", "literal1", "literal2", "operator", "label",
           "comment1", "comment2", "invalid"]]
PAIRS = [(t, b) for t in TOKENS + ["editor.fgcolor"]
         for b in ("editor.bgcolor", "editor.line.highlight.color", "editor.selection.color")] + [
    ("editor.gutter.text.color", "editor.bgcolor"),
    ("console.output.color", "console.color"),
    ("console.error.color", "console.color"),
    ("header.text.selected.color", "header.tab.selected.color"),
    ("header.text.unselected.color", "header.tab.unselected.color"),
    ("footer.text.selected.color", "footer.tab.selected.color"),
    ("footer.text.enabled.color", "footer.tab.enabled.color"),
    ("status.notice.fgcolor", "status.notice.bgcolor"),
    ("status.error.fgcolor", "status.error.bgcolor"),
    ("status.warning.fgcolor", "status.warning.bgcolor"),
    ("errors.row.fgcolor", "errors.row.bgcolor"),
    ("errors.header.fgcolor", "errors.header.bgcolor"),
    ("mode.popup.enabled.fgcolor", "mode.popup.enabled.bgcolor"),
    ("mode.popup.selected.fgcolor", "mode.popup.selected.bgcolor"),
    ("mode.title.color", "mode.background.color"),
    ("manager.list.text.color", "manager.list.background.color"),
]
HEX = re.compile(r"#[0-9A-F]{6}")


def luminance(hex_colour):
    out = []
    for i in (1, 3, 5):
        c = int(hex_colour[i:i + 2], 16) / 255
        out.append(c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * out[0] + 0.7152 * out[1] + 0.0722 * out[2]


def contrast(a, b):
    hi, lo = sorted([luminance(a), luminance(b)], reverse=True)
    return (hi + 0.05) / (lo + 0.05)


for theme_id in IDS:
    path = root / "shared" / "themes" / f"zacess-{theme_id}.txt"
    if not path.exists():
        problems.append(f"{path.name}: missing")
        continue
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or not lines[0].startswith(MARKER + ": Zacess "):
        problems.append(f"{path.name}: the first line is not the Zacess marker")
    values = {}
    for n, line in enumerate(lines, 1):
        if not line.strip() or line.startswith("#"):
            continue
        if " = " not in line:
            problems.append(f"{path.name}:{n}: not a comment or key = value line")
            continue
        key, value = line.split(" = ", 1)
        values[key] = value
        colour = value.split(",")[0]
        if (key.endswith(("color", "fgcolor", "bgcolor", ".top", ".bottom", ".field", ".glyph", ".stroke", ".style"))
                and colour != "none" and not HEX.fullmatch(colour)):
            problems.append(f"{path.name}:{n}: {key} is not a #RRGGBB colour")
    floor = 7 if theme_id.startswith(("deep-", "high-")) else 4.5
    for fg_key, bg_key in PAIRS:
        if fg_key not in values or bg_key not in values:
            problems.append(f"{path.name}: {fg_key} or {bg_key} is missing")
            continue
        ratio = contrast(values[fg_key].split(",")[0], values[bg_key])
        # the selection is a fill under the token's own colour, held to Zacess Themes' 4.5:1 selection rule
        limit = 4.5 if bg_key == "editor.selection.color" else floor
        if ratio < limit:
            problems.append(f"{path.name}: {fg_key} is {ratio:.2f}:1 on {bg_key}, below {limit}:1")

prefs = (root / "shared" / "preferences.txt").read_text(encoding="utf-8")
if "editor.font.family=GeistMono Nerd Font Mono" not in prefs.splitlines():
    problems.append("shared/preferences.txt: editor.font.family is not GeistMono Nerd Font Mono")

mac = (root / "mac" / "apply.sh").read_bytes().replace(b"\r\n", b"\n")
linux = (root / "linux" / "apply.sh").read_bytes().replace(b"\r\n", b"\n")
if mac != linux:
    problems.append("mac/apply.sh and linux/apply.sh differ")

for problem in problems:
    print(f"::error::{problem}")
print("processing: ok" if not problems else f"processing: {len(problems)} problem(s)")
sys.exit(1 if problems else 0)
