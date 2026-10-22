#!/usr/bin/env bash
# gives the AMD Vivado text editor one of the eight Zacess themes and Geist Mono.
# usage: apply.sh [--theme <theme>] [--config-dir <dir>]
#   (the config folder defaults to the newest ~/.Xilinx/Vivado/<version>)
#
# --theme picks one of the eight Zacess themes by short name (deep-dark, deep-light, hc-dark,
# hc-light, dark, light, cream, yellow), id (deep-contrast-dark) or full name. the default is
# deep-dark.
#
# Vivado keeps Tools > Settings in <config>/vivado.xml and writes it back on exit. this merges the
# text editor's CODE_EDITOR_* colours, its syntax styles for every language and its font name
# from ../shared/themes into that file and leaves every other setting (device views, layouts, the
# window theme) as it was. the keys come from AMD's UG893 and a published Vivado theme, not yet
# from a real install: see the README. nothing is backed up: the repo holds every value this
# writes.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shared="$here/../shared"
theme="deep-dark"
config=""
font="GeistMono Nerd Font Mono"
while [ $# -gt 0 ]; do
  case "$1" in
    --theme) theme="${2:?--theme needs a theme name}"; shift 2 ;;
    --theme=*) theme="${1#--theme=}"; shift ;;
    --config-dir) config="${2:?--config-dir needs a folder}"; shift 2 ;;
    --config-dir=*) config="${1#--config-dir=}"; shift ;;
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

# AMD's guide spells the folder both Vivado and vivado, so both are tried
if [ -z "$config" ]; then
  for base in "$HOME/.Xilinx/Vivado" "$HOME/.Xilinx/vivado"; do
    [ -d "$base" ] || continue
    found="$(find "$base" -mindepth 1 -maxdepth 1 -type d -name '20[0-9][0-9].[0-9]*' 2>/dev/null | sort -V | tail -n 1)"
    if [ -n "$found" ]; then config="$found"; break; fi
  done
fi
if [ -z "$config" ] || [ ! -f "$config/vivado.xml" ]; then
  echo "Vivado is not set up here (no vivado.xml under ~/.Xilinx/Vivado/<version>), skipped."
  echo "Install Vivado, start it once, quit it, then run this again or pass --config-dir."
  exit 0
fi

# Vivado holds its settings in memory and writes vivado.xml back on exit, so a change made while
# it runs is lost
if pgrep -f '(^|/)vivado( |$)|/Vivado/20[0-9][0-9]\.[0-9]+/' >/dev/null 2>&1; then
  echo "Vivado is running. Quit it first, then run this again." >&2
  exit 1
fi

echo "Settings: $config/vivado.xml"
python3 - "$shared/themes/zacess-$id.json" "$config/vivado.xml" "$font" <<'PYEOF'
import json, pathlib, sys
import xml.etree.ElementTree as ET

theme = json.loads(pathlib.Path(sys.argv[1]).read_text())
path, font = pathlib.Path(sys.argv[2]), sys.argv[3]
# every language the text editor styles, plus the shared and generic blocks
SECTIONS = ["code_editor_syntax_styles"] + [f"code_editor_syntax_styles_{lang}" for lang in
            ("Generic", "Verilog", "VHDL", "XDC", "Tcl", "TSM", "SyntaxCheck")]

tree = ET.parse(path)
root = tree.getroot()
colours = root.find("general_color")
if colours is None:
    colours = ET.SubElement(root, "general_color")
for key, value in theme["general_color"].items():
    node = colours.find(key)
    if node is None:
        node = ET.SubElement(colours, key)
    node.set("color", value)
general = root.find("general")
if general is None:
    general = ET.SubElement(root, "general")
for section in SECTIONS:
    node = general.find(section)
    if node is None:
        node = ET.SubElement(general, section)
    for child in list(node):
        node.remove(child)
    for style in theme["syntax_styles"]:
        ET.SubElement(node, "syntax_style", dict(sorted(style.items())))
font_node = general.find("CODE_EDITOR_FONT")
if font_node is None:
    font_node = ET.SubElement(general, "CODE_EDITOR_FONT", font_size="14")
font_node.set("font_name", font)
ET.indent(tree, space="    ")
text = '<?xml version="1.0" encoding="UTF-8"?>\n' + ET.tostring(root, encoding="unicode") + "\n"
if path.read_text() == text:
    print("  unchanged  vivado.xml  text editor colours, syntax styles and font")
else:
    path.write_text(text)
    print("  changed    vivado.xml  text editor colours, syntax styles and font")
PYEOF

echo "Theme: zacess-$id"
echo "Done. Start Vivado to pick up the changes. Its window theme (Tools > Settings > Display) is not changed: pick the dark or light one by hand to match."
