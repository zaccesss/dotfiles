"""Sets LTspice's colours to one of the Zacess themes (Linux, where LTspice runs under Wine).

usage: python3 apply.py <full theme name> <LTspice ini file>

Only the colour entries in themes/<name>.ini change. LTspice can write the start of its ini as
UTF-16 and the rest as plain bytes, so the file is read as latin-1 (one character per byte), each
entry is replaced in place and every other byte is written back exactly. Nothing is backed up: the
repo holds every value this writes. The apply scripts check LTspice is closed first.
"""

import pathlib
import re
import sys

here = pathlib.Path(__file__).resolve().parent
name, ini = sys.argv[1], pathlib.Path(sys.argv[2])
theme = here / "themes" / f"{name}.ini"
if not theme.exists():
    sys.exit(f"Unknown theme: {name}")
print(f"Settings: {ini}")

original = ini.read_bytes().decode("latin-1")
text = original
if not re.search(r"(?m)^\[Colors\]\r?$", text):
    sys.exit(f"{ini} has no [Colors] section yet. Open LTspice's colour settings once, quit it, then run this again.")
for line in theme.read_text(encoding="ascii").splitlines():
    match = re.fullmatch(r"([A-Za-z0-9]+)=(\d+)", line)
    if not match:
        continue
    entry, value = match.groups()
    pattern = re.compile(rf"(?m)^{re.escape(entry)}=(\d+)(\r?)$")
    found = pattern.search(text)
    if found:
        status = "unchanged" if found.group(1) == value else "changed  "
        text = pattern.sub(lambda m: f"{entry}={value}{m.group(2)}", text, count=1)
    else:
        status = "added    "
        text = re.sub(r"(?m)^\[Colors\](\r?)$", lambda m: f"[Colors]{m.group(1)}\n{entry}={value}{m.group(1)}", text, count=1)
    print(f"  {status}  [Colors]  {entry}")
if text != original:
    ini.write_bytes(text.encode("latin-1"))
print(f"Theme: {name}")
