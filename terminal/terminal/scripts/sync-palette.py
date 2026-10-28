#!/usr/bin/env python3
"""Copies the eight Zacess themes from a pinned Zacess Themes release into palette/zacess.json.

    scripts/sync-palette.py                    the release pinned in palette/zacess.json
    scripts/sync-palette.py --version 0.5.0    move the pin to that release and copy it
    scripts/sync-palette.py --from <clone>     read the release from a local clone's tag, offline
    scripts/sync-palette.py --palette-only     the palette and the generated files, leaving the editor pins
    scripts/sync-palette.py --check            exit 1 when the palette or a pin differs from the release

The palette here is a copy of the terminal colours and the interface tokens the generated files
use, taken from palette/zacess.json in zacesshq/themes at the pinned tag. This script is the only
way it changes: it writes the palette, runs build-themes.py so every generated theme file follows
and moves the two editor pins that name the same release, the Zed theme file in editors/zed and
the zacess.nvim release in editors/neovim. A release that has no strong selection pair yet keeps
the selection the palette already holds, so an older tag never puts a weaker selection back.
"""

import json
import re
import subprocess
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REPO = ROOT.parent.parent
PALETTE = ROOT / "palette" / "zacess.json"
REPOSITORY = "zacesshq/themes"
NVIM_REPOSITORY = "zacesshq/zacess.nvim"
SHORT = {"deep-contrast-dark": "deep-dark", "deep-contrast-light": "deep-light", "high-contrast-dark": "hc-dark",
         "high-contrast-light": "hc-light", "dark": "dark", "light": "light", "cream": "cream",
         "yellow-on-black": "yellow"}
# palette key: the upstream ui token it copies. tmux's theme files and the contrast checks use these
UI_TOKENS = {"surface": "surface", "surface_alt": "surfaceAlt", "muted": "muted", "border": "border",
             "border_active": "borderActive", "accent": "accent", "accent_foreground": "accentForeground",
             "line_highlight": "lineHighlight", "find_match": "findMatch", "find_match_border": "findMatchBorder"}


def read_release(path, version, clone):
    """A file from the release: its tag in a local clone when one is given, GitHub otherwise."""
    if clone:
        result = subprocess.run(["git", "-C", str(clone), "show", f"v{version}:{path}"], capture_output=True, text=True)
        if result.returncode:
            raise SystemExit(f"{clone} has no tag v{version} with {path}: {result.stderr.strip()}")
        return result.stdout
    url = f"https://raw.githubusercontent.com/{REPOSITORY}/v{version}/{path}"
    try:
        with urllib.request.urlopen(url, timeout=60) as response:
            return response.read().decode("utf-8")
    except OSError as error:
        raise SystemExit(f"could not fetch {url}: {error}")


def convert(upstream, version, current):
    """The palette in this folder's shape: the terminal colours plus the interface tokens the files use."""
    themes = []
    previous = {t["id"]: t for t in current.get("themes", [])} if current else {}
    for theme in upstream["themes"]:
        ui, terminal = theme["ui"], theme["terminal"]
        # the terminal text and cursor can differ from the editor's (Yellow on Black prints white text
        # with a yellow cursor), as the release's own terminal files do
        foreground = terminal.get("foreground", ui["foreground"])
        old = previous.get(theme["id"], {})
        if "selectionStrong" in ui:
            selection = (ui["selectionStrong"], ui.get("selectionForeground", foreground))
        else:
            selection = (old.get("selection_background", ui["selection"]), old.get("selection_foreground", foreground))
        themes.append({
            "id": theme["id"],
            "short": SHORT[theme["id"]],
            "name": theme["name"],
            "appearance": theme["appearance"],
            "background": ui["background"],
            "foreground": foreground,
            "cursor": terminal.get("cursor", ui["cursor"]),
            "selection_background": selection[0],
            "selection_foreground": selection[1],
            "ansi": terminal["ansi"][:8],
            "bright": terminal["ansi"][8:],
            "dim": terminal.get("dim", []),
            "background_role": terminal.get("backgroundRole", []),
            "ui": {key: ui[token] for key, token in UI_TOKENS.items()},
        })
    return {
        "source": {
            "repository": REPOSITORY,
            "version": version,
            "file": "palette/zacess.json",
            "note": "copied by scripts/sync-palette.py: the terminal colours and the interface tokens the generated files use",
        },
        "default": "deep-contrast-dark",
        "themes": themes,
    }


def dump(data):
    return json.dumps(data, indent=2) + "\n"


def pinned_version():
    if not PALETTE.exists():
        return None
    source = json.loads(PALETTE.read_text(encoding="utf-8")).get("source")
    return source.get("version") if isinstance(source, dict) else None


def zed_pin(version, clone, check):
    """The Zed theme file kept beside its settings while the extension store lags, with its package pin."""
    package = REPO / "editors" / "zed" / "shared" / "theme-package.json"
    if not package.exists():
        return []
    data = json.loads(package.read_text(encoding="utf-8"))
    wanted = read_release(f"editors/zed/themes/{data['file']}", version, clone)
    target = package.parent / "themes" / data["file"]
    data["version"] = version
    data["source"] = f"https://github.com/{REPOSITORY}/blob/v{version}/editors/zed/themes/{data['file']}"
    changes = []
    if not target.exists() or target.read_text(encoding="utf-8") != wanted:
        changes.append(str(target.relative_to(REPO)))
        if not check:
            target.write_text(wanted, encoding="utf-8")
    if package.read_text(encoding="utf-8") != dump(data):
        changes.append(str(package.relative_to(REPO)))
        if not check:
            package.write_text(dump(data), encoding="utf-8")
    return changes


def tag_commit(version):
    """The commit a zacess.nvim release tag points at or None without a network."""
    result = subprocess.run(["git", "ls-remote", f"https://github.com/{NVIM_REPOSITORY}.git",
                             f"refs/tags/v{version}^{{}}", f"refs/tags/v{version}"], capture_output=True, text=True)
    lines = [line.split("\t") for line in result.stdout.splitlines() if "\t" in line]
    # an annotated tag lists its peeled commit under ^{} first; a lightweight tag only lists itself
    peeled = [sha for sha, ref in lines if ref.endswith("^{}")]
    plain = [sha for sha, ref in lines if not ref.endswith("^{}")]
    return (peeled or plain or [None])[0]


def neovim_pin(version, check):
    """The zacess.nvim release lazy.nvim installs, in every colorscheme.lua that names it, with its lock."""
    changes = []
    commit = None
    for spec in sorted((REPO / "editors" / "neovim").rglob("colorscheme.lua")):
        text = spec.read_text(encoding="utf-8")
        if NVIM_REPOSITORY not in text:
            continue
        new = re.sub(r'(version\s*=\s*)"[^"]*"', rf'\1"{version}"', text, count=1)
        if new != text:
            changes.append(str(spec.relative_to(REPO)))
            if not check:
                spec.write_text(new, encoding="utf-8")
        lock = spec.parents[2] / "lazy-lock.json"
        if not lock.exists():
            continue
        if commit is None:
            commit = tag_commit(version)
            if commit is None:
                print(f"  lazy-lock.json keeps its zacess.nvim commit: tag v{version} could not be looked up (offline?)")
                continue
        locked = json.loads(lock.read_text(encoding="utf-8"))
        entry = locked.get("zacess.nvim")
        if entry and entry.get("commit") != commit:
            changes.append(str(lock.relative_to(REPO)))
            if not check:
                lock_text = lock.read_text(encoding="utf-8")
                lock.write_text(lock_text.replace(entry["commit"], commit), encoding="utf-8")
    return changes


def main(argv):
    check = "--check" in argv
    palette_only = "--palette-only" in argv
    version = clone = None
    args = [a for a in argv if a not in ("--check", "--palette-only")]
    while args:
        flag = args.pop(0)
        if flag == "--version" and args:
            version = args.pop(0)
        elif flag.startswith("--version="):
            version = flag.split("=", 1)[1]
        elif flag == "--from" and args:
            clone = Path(args.pop(0)).expanduser()
        elif flag.startswith("--from="):
            clone = Path(flag.split("=", 1)[1]).expanduser()
        else:
            print(__doc__.strip(), file=sys.stderr)
            return 2
    version = version or pinned_version()
    if not version or not re.fullmatch(r"\d+\.\d+\.\d+", version):
        print("Pass --version x.y.z: the palette has no pinned release to read.", file=sys.stderr)
        return 2
    current = json.loads(PALETTE.read_text(encoding="utf-8")) if PALETTE.exists() else {}
    upstream = json.loads(read_release("palette/zacess.json", version, clone))
    if upstream.get("version") != version:
        raise SystemExit(f"the release's palette says {upstream.get('version')}, not {version}")
    palette = dump(convert(upstream, version, current))
    changes = []
    if not PALETTE.exists() or PALETTE.read_text(encoding="utf-8") != palette:
        changes.append(str(PALETTE.relative_to(REPO)))
        if not check:
            PALETTE.write_text(palette, encoding="utf-8")
    if not palette_only:
        changes += zed_pin(version, clone, check)
        changes += neovim_pin(version, check)
    if check:
        if changes:
            print(f"out of step with Zacess Themes {version}:\n  " + "\n  ".join(changes))
            return 1
        print(f"palette and pins match Zacess Themes {version}")
        return 0
    for change in changes:
        print(f"wrote {change}")
    if not changes:
        print(f"palette and pins already match Zacess Themes {version}")
    # every generated terminal and tmux theme file follows the palette
    result = subprocess.run([sys.executable, str(ROOT / "scripts" / "build-themes.py")])
    return result.returncode


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
