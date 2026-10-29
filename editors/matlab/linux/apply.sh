#!/usr/bin/env bash
# sets MATLAB's desktop theme, syntax colours and code font to one of the Zacess themes.
# usage: apply.sh [--theme <theme>] [--pending] [path to the matlab launcher]
#   (the launcher defaults to matlab on PATH, then the newest /usr/local/MATLAB/R20*/bin/matlab)
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# ../shared/zacess_apply.m writes the theme and fonts through MATLAB's own settings API, which
# reaches the light theme's colours only. the theme's colour scheme in ../shared/schemes is then
# applied with import_scheme from MathWorks' Color Theme Extensions add-on, which sets either
# theme's colours. ../shared/fetch_tools.py fetches the add-on at its pinned commit and checks its
# digests. the add-on needs the full desktop and MATLAB saves settings only when a session exits
# normally, so this starts MATLAB, applies both and quits (about a minute). nothing is backed up.
#
# --pending leaves the theme for MATLAB's next start instead (what zt uses, so a switch never
# starts MATLAB): the theme's name goes to ~/.local/state/zacess/matlab-theme and a marked block in
# startup.m runs ../shared/zacess_startup.m, which applies it and removes the file. every run keeps
# that block and the add-on tools in ~/.local/state/zacess/matlab-tools in place.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shared="$(cd "$here/../shared" && pwd)"
theme="deep-dark"
pending=0
while [ $# -gt 0 ]; do
  case "$1" in
    --theme) theme="${2:?--theme needs a theme name}"; shift 2 ;;
    --theme=*) theme="${1#--theme=}"; shift ;;
    --pending) pending=1; shift ;;
    *) break ;;
  esac
done

theme_name() {
  local key
  key="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -e 's/^zacess[ -]//' -e 's/ /-/g')"
  case "$key" in
    deep-dark|deep-contrast-dark) echo "Zacess Deep Contrast Dark" ;;
    deep-light|deep-contrast-light) echo "Zacess Deep Contrast Light" ;;
    hc-dark|high-contrast-dark) echo "Zacess High Contrast Dark" ;;
    hc-light|high-contrast-light) echo "Zacess High Contrast Light" ;;
    dark) echo "Zacess Dark" ;;
    light) echo "Zacess Light" ;;
    cream) echo "Zacess Cream" ;;
    yellow|yellow-on-black) echo "Zacess Yellow on Black" ;;
    *) return 1 ;;
  esac
}
if ! name="$(theme_name "$theme")"; then
  echo "Unknown theme: $theme" >&2
  echo "Pick one of deep-dark, deep-light, hc-dark, hc-light, dark, light, cream or yellow." >&2
  exit 1
fi

state="${XDG_STATE_HOME:-$HOME/.local/state}/zacess"
pending_file="$state/matlab-theme"
tools="$state/matlab-tools"
mkdir -p "$state"

# the add-on files are fetched once and kept, refetched only when one is missing or fails its digest
if ! python3 -B - "$shared/scheme-tools.json" "$tools" <<'PY'
import hashlib, json, pathlib, sys
files = json.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))["files"]
folder = pathlib.Path(sys.argv[2])
ok = all((folder / name).is_file() and hashlib.sha256((folder / name).read_bytes()).hexdigest() == digest
         for name, digest in files.items())
sys.exit(0 if ok else 1)
PY
then
  python3 -B "$shared/fetch_tools.py" "$tools"
fi

# the startup.m block sits between two marker lines: replaced in place when present and appended
# otherwise. every other line of the file is left as it was
userpath_dir="$HOME/Documents/MATLAB"
mkdir -p "$userpath_dir"
q() { printf '%s' "$1" | sed "s/'/''/g"; }
block="try, addpath('$(q "$shared")'); zacess_startup('$(q "$pending_file")', '$(q "$tools")', '$(q "$here/fonts.json")', '$(q "$shared/folders.json")'); catch zacessError, warning('zacess:startup', '%s', zacessError.message); end; clear zacessError"
python3 -B - "$userpath_dir/startup.m" "$block" <<'PY'
import pathlib, re, sys
path, block = pathlib.Path(sys.argv[1]), sys.argv[2]
start = "% >>> zacess theme: added by the dotfiles MATLAB apply script, applies a theme zt left for this start"
end = "% <<< zacess theme"
text = path.read_text(encoding="utf-8") if path.exists() else ""
section = f"{start}\n{block}\n{end}\n"
pattern = re.compile(re.escape(start) + r".*?" + re.escape(end) + r"\n?", re.S)
if pattern.search(text):
    new = pattern.sub(lambda _: section, text, count=1)
else:
    new = (text.rstrip("\n") + "\n\n" if text.strip() else "") + section
if new != text:
    path.write_text(new, encoding="utf-8")
PY

if [ "$pending" = 1 ]; then
  # allowed while MATLAB is open: the theme only applies at its next start
  if [ -f "$pending_file" ] && [ "$(cat "$pending_file")" = "$name" ]; then
    echo "  waiting    pending   $name"
  else
    printf '%s' "$name" > "$pending_file"
    echo "  changed    pending   $name"
  fi
  exit 0
fi
# a direct run applies the theme now, so nothing is left for the next start
rm -f "$pending_file"

matlab="${1:-}"
if [ -z "$matlab" ]; then
  if command -v matlab >/dev/null 2>&1; then
    matlab="$(command -v matlab)"
  else
    # the newest release folder holds the newest MATLAB
    mapfile -t releases < <(printf '%s\n' /usr/local/MATLAB/R20* | sort -r)
    for candidate in "${releases[@]}"; do
      if [ -x "$candidate/bin/matlab" ]; then matlab="$candidate/bin/matlab"; break; fi
    done
  fi
fi
if [ -z "$matlab" ] || [ ! -x "$matlab" ]; then
  echo "No MATLAB found. Pass the path to the matlab launcher." >&2
  exit 1
fi

# a running MATLAB writes its own settings back on exit, over the ones written here
if pgrep -x MATLAB >/dev/null 2>&1; then
  echo "MATLAB is running. Quit it first, then run this again." >&2
  exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
log="$work/matlab.log"
"$matlab" -nosplash -logfile "$log" \
  -r "addpath('$shared'); addpath('$tools'); zacess_apply('$shared/themes/$name.json', '$here/fonts.json', '$shared/folders.json'); try, import_scheme('$shared/schemes/$name.json'); fprintf('  applied    scheme    %s\n', '$name'); catch e, fprintf('  failed     scheme    %s\n', e.message); end; exit" >/dev/null 2>&1 || true
if ! grep -E '^  (added|changed|unchanged|applied|failed) ' "$log"; then
  echo "MATLAB ran but reported no settings. Run it by hand to see the error." >&2
  exit 1
fi
if grep -q '^  failed ' "$log"; then exit 1; fi
echo "Theme: $name"
echo "Done. Start MATLAB to see it."
