"""Installs the Zacess Obsidian theme into a vault, picks a variant and opens that vault by default (macOS and Linux).

usage: python3 apply.py <full theme name> <vault folder> <obsidian.json path>

The pinned theme release (theme-package.json) is downloaded, checked against its digest and
unpacked into the vault's .obsidian/themes. appearance.json and the Style Settings choice are
merged key by key. obsidian.json, this machine's vault list, marks the vault as the one that
opens. Only the keys this script owns change and nothing is backed up: this folder holds every
value it writes. The apply scripts check Obsidian is closed first, since it writes these files while it runs.
"""

import hashlib
import io
import json
import pathlib
import secrets
import sys
import time
import urllib.request
import zipfile

here = pathlib.Path(__file__).resolve().parent
name, vault, vault_list = sys.argv[1], pathlib.Path(sys.argv[2]).resolve(), pathlib.Path(sys.argv[3])
themes = json.loads((here / "themes.json").read_text(encoding="utf-8"))
if name not in themes:
    sys.exit(f"Unknown theme: {name}")
dot = vault / ".obsidian"
if not dot.is_dir():
    sys.exit(f"No Obsidian vault at {vault} (no .obsidian folder).")
print(f"Vault: {vault}")


def merge(path, want, label):
    current = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
    for key, value in want.items():
        status = "added    " if key not in current else ("unchanged" if current[key] == value else "changed  ")
        print(f"  {status}  {label}  {key}")
    merged = {**current, **want}
    if merged != current:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(merged, indent=2) + "\n", encoding="utf-8")


package = json.loads((here / "theme-package.json").read_text(encoding="utf-8"))
with urllib.request.urlopen(package["url"]) as response:
    data = response.read()
if hashlib.sha256(data).hexdigest().upper() != package["sha256"].upper():
    sys.exit("The Zacess Obsidian download does not match its pinned checksum, so it was not installed")
target = dot / "themes" / package["folder"]
target.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(io.BytesIO(data)) as z:
    for member in z.infolist():
        if member.is_dir():
            continue
        content = z.read(member)
        dest = target / pathlib.PurePosixPath(member.filename).name
        status = "added    " if not dest.exists() else ("unchanged" if dest.read_bytes() == content else "changed  ")
        if status != "unchanged":
            dest.write_bytes(content)
        print(f"  {status}  themes/{package['folder']}  {dest.name}")

choice = themes[name]
appearance = json.loads((here / "appearance.json").read_text(encoding="utf-8"))
appearance["theme"] = choice["base"]
merge(dot / "appearance.json", appearance, "appearance.json")
merge(dot / "plugins" / "obsidian-style-settings" / "data.json",
      {"zacess-theme@@zacess-contrast": choice["contrast"]}, "style settings")

# this machine's vault list: the vault is the one marked open, so Obsidian starts in it
listing = json.loads(vault_list.read_text(encoding="utf-8")) if vault_list.exists() else {"vaults": {}}
vaults = listing.setdefault("vaults", {})
before = json.dumps(listing, sort_keys=True)
vault_id = next((k for k, v in vaults.items() if v.get("path") == str(vault)), None)
if vault_id is None:
    vault_id = secrets.token_hex(8)
    vaults[vault_id] = {"path": str(vault), "ts": int(time.time() * 1000)}
for key, entry in vaults.items():
    if key == vault_id:
        entry["open"] = True
    else:
        entry.pop("open", None)
after = json.dumps(listing, sort_keys=True)
print(f"  {'unchanged' if after == before else 'changed  '}  obsidian.json  default vault")
if after != before:
    vault_list.parent.mkdir(parents=True, exist_ok=True)
    vault_list.write_text(json.dumps(listing, indent=2) + "\n", encoding="utf-8")
print(f"Theme: {name}")
