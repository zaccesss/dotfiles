"""Installs the Zacess theme plugin into Thonny and merges the tracked [view] settings.

Run by Thonny's own Python (the apply scripts find it), so the plugin lands in the exact
site-packages folder that Thonny version reads and THONNY_USER_DIR is Thonny's own answer.

usage: <thonny python> apply.py <overlay settings.json> [--theme <full theme name>] [--interpreter <python>]

--interpreter makes that Python the one Thonny runs code with: the apply scripts pass the
python of the virtual environment they keep for Thonny, so Tools > Manage packages installs
into it rather than the system Python's user folder.
"""

import ast
import configparser
import filecmp
import json
import pathlib
import shutil
import sys

from thonny import THONNY_USER_DIR
from thonny.misc_utils import get_user_site_packages_dir_for_base

here = pathlib.Path(__file__).resolve().parent
args = sys.argv[1:]
options = {}
for flag in ("--theme", "--interpreter"):
    if flag in args:
        i = args.index(flag)
        options[flag] = args[i + 1]
        del args[i:i + 2]
theme = options.get("--theme")
# thonny writes paths with forward slashes on Windows too
interpreter = options["--interpreter"].replace("\\", "/") if "--interpreter" in options else None
overlay = pathlib.Path(args[0])

want = json.loads((here / "settings.json").read_text(encoding="utf-8"))
want.update(json.loads(overlay.read_text(encoding="utf-8")))
if theme:
    want["ui_theme"] = theme
    want["syntax_theme"] = theme

user_dir = pathlib.Path(THONNY_USER_DIR)
config_file = user_dir / "configuration.ini"
if not config_file.exists():
    sys.exit(f"No Thonny settings at {config_file}. Start Thonny once, quit it, then run this again.")
print(f"Settings: {user_dir}")

# the plugin package is copied file by file, so a run with nothing new changes nothing
site = pathlib.Path(get_user_site_packages_dir_for_base(str(user_dir / "plugins")))
source = here / "thonnycontrib" / "zacess_themes"
target = site / "thonnycontrib" / "zacess_themes"
target.mkdir(parents=True, exist_ok=True)
for path in source.glob("*.py"):
    dest = target / path.name
    if dest.exists() and filecmp.cmp(path, dest, shallow=False):
        print(f"  unchanged  plugin  {path.name}")
    else:
        status = "changed  " if dest.exists() else "added    "
        shutil.copyfile(path, dest)
        print(f"  {status}  plugin  {path.name}")
stale = target / "__pycache__"
if stale.exists():
    shutil.rmtree(stale)

# thonny writes every value with str() and reads it back as a Python literal, so True and 16 are
# written the same way here
config = configparser.ConfigParser(interpolation=None)
config.optionxform = str
config.read(config_file, encoding="utf-8")
if not config.has_section("view"):
    config.add_section("view")
changed = False
for key, value in want.items():
    text = str(value)
    old = config.get("view", key, fallback=None)
    status = "added    " if old is None else ("unchanged" if old == text else "changed  ")
    print(f"  {status}  configuration.ini  view.{key}")
    if old != text:
        config.set("view", key, text)
        changed = True

if interpreter:
    for section in ("run", "LocalCPython"):
        if not config.has_section(section):
            config.add_section(section)
    # the interpreter goes first in Thonny's list of recent ones, so the old choices stay a click away
    entry = {"run.backend_name": "LocalCPython", "LocalCPython.executable": interpreter}
    try:
        recent = ast.literal_eval(config.get("LocalCPython", "last_configurations", fallback="[]"))
    except (ValueError, SyntaxError):
        recent = []
    recent = [entry] + [item for item in recent if item != entry]
    for section, key, text in (("run", "backend_name", "LocalCPython"),
                               ("LocalCPython", "executable", interpreter),
                               ("LocalCPython", "last_configurations", str(recent))):
        old = config.get(section, key, fallback=None)
        status = "added    " if old is None else ("unchanged" if old == text else "changed  ")
        print(f"  {status}  configuration.ini  {section}.{key}")
        if old != text:
            config.set(section, key, text)
            changed = True
# Thonny starts in ~/dev/projects/python on every OS, the projects folder every editor shares
projects = pathlib.Path.home() / "dev" / "projects" / "python"
if not projects.is_dir():
    projects.mkdir(parents=True)
    print(f"  added      folder  {projects}")
if not config.has_section("run"):
    config.add_section("run")
old = config.get("run", "working_directory", fallback=None)
status = "added    " if old is None else ("unchanged" if old == str(projects) else "changed  ")
print(f"  {status}  configuration.ini  run.working_directory")
if old != str(projects):
    config.set("run", "working_directory", str(projects))
    changed = True

if changed:
    with open(config_file, "w", encoding="utf-8") as handle:
        config.write(handle)
print(f"Theme: {want['syntax_theme']}")
