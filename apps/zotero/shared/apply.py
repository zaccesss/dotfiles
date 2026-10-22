"""Sets Zotero's light or dark mode, reader theme and text size to match a Zacess theme (macOS and Linux).

usage: python3 apply.py <full theme name> [profile folder]

Zotero has no custom interface colours, so each Zacess theme maps to Zotero's dark or light mode and
the nearest built-in reader theme (themes.json). The values go in a marked block of the profile's
user.js, which Zotero reads on every start; the rest of user.js and prefs.js is left as it was.
Nothing is backed up: the repo holds every value this writes. The apply scripts check Zotero is
closed first, since it rewrites prefs.js when it exits.
"""

import json
import pathlib
import re
import sys

here = pathlib.Path(__file__).resolve().parent
name = sys.argv[1]
themes = json.loads((here / "themes.json").read_text(encoding="utf-8"))
if name not in themes:
    sys.exit(f"Unknown theme: {name}")

if len(sys.argv) > 2:
    profiles = [pathlib.Path(sys.argv[2])]
else:
    home = pathlib.Path.home()
    roots = [home / "Library/Application Support/Zotero/Profiles", home / ".zotero/zotero",
             home / ".var/app/org.zotero.Zotero/.zotero/zotero"]
    profiles = [p for root in roots if root.is_dir() for p in sorted(root.iterdir()) if (p / "prefs.js").exists()]
if not profiles or not (profiles[0] / "prefs.js").exists():
    sys.exit("No Zotero profile found. Start Zotero once, quit it, then run this again or pass the profile folder.")
profile = profiles[0]
print(f"Profile: {profile}")

want = json.loads((here / "prefs.json").read_text(encoding="utf-8"))
want.update(themes[name])
begin = "// zacess: managed by the Zacess apply script, edits inside this block are replaced"
end = "// zacess: end"
lines = [f"user_pref({json.dumps(k)}, {json.dumps(v)});" for k, v in want.items()]
block = "\n".join([begin, *lines, end])

user_js = profile / "user.js"
old = user_js.read_text(encoding="utf-8").replace("\r\n", "\n") if user_js.exists() else ""
rest = re.sub(r"(?s)// zacess: managed[^\n]*\n.*?// zacess: end\n?", "", old).strip()
new = "\n".join(part for part in (rest, block) if part) + "\n"
for key, line in zip(want, lines):
    status = "unchanged" if line in old else ("changed  " if f"user_pref({json.dumps(key)}," in old else "added    ")
    print(f"  {status}  user.js  {key}")
if new != old:
    user_js.write_text(new, encoding="utf-8")
print(f"Theme: {name}")
