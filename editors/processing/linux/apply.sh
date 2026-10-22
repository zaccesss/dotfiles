#!/usr/bin/env bash
# puts one of the eight Zacess themes in Processing's sketchbook and sets Geist Mono as its editor font.
# usage: apply.sh [--theme <theme>] [--prefs <preferences.txt>]
#   (preferences.txt defaults to ~/Library/Processing on the Mac, ~/.config/processing on Linux,
#   then the Flathub copy)
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# Processing loads theme.txt from the sketchbook folder over whichever built-in theme is picked,
# so the chosen theme is written there. a theme.txt this script did not write is never replaced.
# the keys in ../shared/preferences.txt are merged into preferences.txt and every other line is
# left as it was. nothing is backed up: the repo holds every value this writes.
#
# mac/apply.sh and linux/apply.sh are the same file.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shared="$here/../shared"
theme="deep-dark"
prefs=""
while [ $# -gt 0 ]; do
  case "$1" in
    --theme) theme="${2:?--theme needs a theme name}"; shift 2 ;;
    --theme=*) theme="${1#--theme=}"; shift ;;
    --prefs) prefs="${2:?--prefs needs a file}"; shift 2 ;;
    --prefs=*) prefs="${1#--prefs=}"; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

theme_id() {
  local key
  key="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/^zacess[ -]//' -e 's/ /-/g')"
  case "$key" in
    deep-dark|deep-contrast-dark) echo "deep-contrast-dark" ;;
    deep-light|deep-contrast-light) echo "deep-contrast-light" ;;
    hc-dark|high-contrast-dark) echo "high-contrast-dark" ;;
    hc-light|high-contrast-light) echo "high-contrast-light" ;;
    dark) echo "dark" ;;
    light) echo "light" ;;
    cream) echo "cream" ;;
    yellow|yellow-on-black) echo "yellow-on-black" ;;
    *) return 1 ;;
  esac
}

if ! id="$(theme_id "$theme")"; then
  echo "Unknown theme: $theme" >&2
  echo "Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow." >&2
  exit 1
fi

if [ -z "$prefs" ]; then
  for candidate in "$HOME/Library/Processing/preferences.txt" "$HOME/.config/processing/preferences.txt" \
                   "$HOME/.var/app/org.processing.processingide/config/processing/preferences.txt"; do
    if [ -f "$candidate" ]; then prefs="$candidate"; break; fi
  done
fi
if [ -z "$prefs" ] || [ ! -f "$prefs" ]; then
  echo "Processing is not set up here (no preferences.txt in ~/Library/Processing, ~/.config/processing or the Flatpak's copy), skipped."
  echo "Start Processing once, quit it, then run this again or pass --prefs."
  exit 0
fi

# macOS pgrep leaves out its own ancestors unless given -a, so an app whose built-in terminal
# runs this script would look closed. procps pgrep on Linux has no such exclusion and its -a
# means something else
pgrep_flags=()
if [ "$(uname -s)" = Darwin ]; then
  pgrep_flags=(-a)
fi

# Processing holds its preferences in memory and writes them back on exit, so a change made while
# it runs is lost
if pgrep ${pgrep_flags[@]+"${pgrep_flags[@]}"} -f 'Processing\.app/Contents/|(^|/)[Pp]rocessing( |$)|processing\.app\.(Base|ProcessingKt)' >/dev/null 2>&1; then
  echo "Processing is running. Quit it first, then run this again." >&2
  exit 1
fi

echo "Preferences: $prefs"
python3 - "$shared" "$prefs" "$id" <<'PYEOF'
import pathlib, sys

shared, prefs, theme_id = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), sys.argv[3]
marker = "# Zacess theme for Processing"

lines = prefs.read_text().splitlines()
# the sketchbook is ~/dev/projects/processing, the projects folder every editor shares. it holds
# the installed libraries, modes and tools too, so moving an existing sketchbook there is a step of
# its own (README)
sketchbook = pathlib.Path.home() / "dev" / "projects" / "processing"
if not sketchbook.is_dir():
    sketchbook.mkdir(parents=True)
    print(f"  added      folder  {sketchbook}")

target = sketchbook / "theme.txt"
text = (shared / "themes" / f"zacess-{theme_id}.txt").read_text()
if target.exists() and not target.read_text().startswith(marker):
    sys.exit(f"{target} is a theme this script did not write, so it was left alone. "
             "Move it out of the sketchbook to use a Zacess theme.")
if not target.exists():
    print(f"  added      {target}")
elif target.read_text() != text:
    print(f"  changed    {target}")
else:
    print(f"  unchanged  {target}")
if not target.exists() or target.read_text() != text:
    target.write_text(text)

want = {"sketchbook.path.four": str(sketchbook)}
for line in (shared / "preferences.txt").read_text().splitlines():
    if line and not line.startswith("#"):
        key, value = line.split("=", 1)
        want[key] = value
out, done = [], set()
for line in lines:
    key = line.split("=", 1)[0] if "=" in line else None
    if key in want:
        print(f"  {'unchanged' if line == f'{key}={want[key]}' else 'changed  '}  preferences.txt  {key}")
        out.append(f"{key}={want[key]}")
        done.add(key)
    else:
        out.append(line)
for key in want:
    if key not in done:
        print(f"  added      preferences.txt  {key}")
        out.append(f"{key}={want[key]}")
# Processing keeps the file sorted by key, so a new key goes where it would put it
out = sorted(out) if any(k not in done for k in want) else out
text = "\n".join(out) + "\n"
if prefs.read_text() != text:
    prefs.write_text(text)
PYEOF

echo "Theme: zacess-$id"
echo "Done. Start Processing to pick up the changes."
