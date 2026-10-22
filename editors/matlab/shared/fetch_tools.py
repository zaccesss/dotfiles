"""Downloads MathWorks' Color Theme Extensions add-on at the pinned commit and checks each file (macOS and Linux).

usage: python3 fetch_tools.py <empty folder>

The files and their SHA-256 digests are in scheme-tools.json. Nothing is written unless every
file matches, so a changed upstream file stops the apply script instead of running.
"""

import hashlib
import json
import pathlib
import sys
import urllib.request

here = pathlib.Path(__file__).resolve().parent
dest = pathlib.Path(sys.argv[1])
tools = json.loads((here / "scheme-tools.json").read_text(encoding="utf-8"))
base = tools["repository"].replace("https://github.com/", "https://raw.githubusercontent.com/")
fetched = {}
for name, digest in tools["files"].items():
    with urllib.request.urlopen(f"{base}/{tools['commit']}/{name}") as response:
        data = response.read()
    if hashlib.sha256(data).hexdigest() != digest:
        sys.exit(f"{name} from the Color Theme Extensions add-on does not match its pinned digest, so nothing was applied.")
    fetched[name] = data
dest.mkdir(parents=True, exist_ok=True)
for name, data in fetched.items():
    (dest / name).write_bytes(data)
