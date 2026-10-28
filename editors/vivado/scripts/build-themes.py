"""Builds the eight Zacess text editor themes for AMD Vivado in shared/themes from the Zacess palette.

usage: python3 scripts/build-themes.py [palette.json]

With no argument the palette is downloaded from the pinned Zacess Themes release and checked
against its digest. A local palette file (a clone of zacesshq/themes) can be passed instead.

Vivado keeps its Tools > Settings choices in vivado.xml. The text editor's colours sit there as
CODE_EDITOR_* entries under general_color (RGB written as Java's Integer.toHexString, so without
leading zeros) and as one syntax_style per token under a code_editor_syntax_styles block for each
language (colours written as signed Java ARGB integers). Each theme here is that data in a small
JSON file, which the apply scripts merge into vivado.xml. The token order (0 to 10) is the jEdit
text area's (default, two comments, two literals, label, three keyword sets, operator, invalid);
11 is the error underline, 12 to 14 are marker backgrounds and 15 to 20 are the extra styles
Vivado adds. None of this is proven against a real Vivado install yet: see the README.
"""

import hashlib
import json
import pathlib
import sys
import urllib.request

PALETTE_URL = "https://raw.githubusercontent.com/zacesshq/themes/v0.5.0/palette/zacess.json"
PALETTE_SHA256 = "4fe26dbd819605ec5a17141eb5994ef5e0cb0eb7a2fc5fab93cdc82a21cf40cf"
ORDER = ["deep-contrast-dark", "deep-contrast-light", "high-contrast-dark", "high-contrast-light",
         "dark", "light", "cream", "yellow-on-black"]
# jEdit token order, then the styles Vivado adds; italic is font_style 2 and bold 1 (Java's Font)
TOKENS = ["foreground", "comment", "comment", "string", "number", "attribute", "keyword", "type",
          "control", "operator", "invalid"]
EXTRA = ["type", "property", "string", "number", "keyword", "control"]


def load_palette(argv):
    if len(argv) > 1:
        return json.loads(pathlib.Path(argv[1]).read_text(encoding="utf-8"))
    data = urllib.request.urlopen(PALETTE_URL, timeout=60).read()
    if hashlib.sha256(data).hexdigest() != PALETTE_SHA256:
        sys.exit("the downloaded palette does not match its pinned digest")
    return json.loads(data)


def rgb_hex(colour):
    # Integer.toHexString of the RGB value, as Vivado writes it
    return format(int(colour.lstrip("#"), 16), "x")


def argb(colour):
    # a signed 32-bit Java int with full alpha, as Vivado writes it
    value = 0xFF000000 | int(colour.lstrip("#"), 16)
    return str(value - (1 << 32))


def style(index, fg="null", bg="null", font=0, effect=0, effect_colour="null", stripe="null"):
    return {"style_index": str(index), "foreground_color": fg, "background_color": bg,
            "font_style": str(font), "effect": str(effect), "effect_color": effect_colour,
            "stripe_color": stripe}


def build(theme, token_styles):
    ui, syn = theme["ui"], theme["syntax"]

    def weight(token):
        bits = token_styles.get(token, [])
        return (1 if "bold" in bits else 0) | (2 if "italic" in bits else 0)

    styles = [style(i, argb(syn[t]), font=weight(t)) for i, t in enumerate(TOKENS)]
    styles[10] = style(10, argb(syn["invalid"]), font=1)
    styles.append(style(11, effect=2, effect_colour=argb(ui["error"]), stripe=argb(ui["error"])))
    styles.append(style(12, argb(syn["foreground"]), argb(ui["selection"]), stripe=argb(ui["warning"])))
    styles.append(style(13, argb(syn["foreground"]), argb(ui["lineHighlight"])))
    styles.append(style(14, argb(syn["foreground"]), argb(ui["selection"]), stripe=argb(ui["info"])))
    styles += [style(15 + i, argb(syn[t]), font=2) for i, t in enumerate(EXTRA)]
    return {
        "name": theme["name"],
        "appearance": theme["appearance"],
        "general_color": {
            "CODE_EDITOR_BACKGROUND": rgb_hex(ui["background"]),
            "CODE_EDITOR_FOREGROUND": rgb_hex(syn["foreground"]),
            "CODE_EDITOR_CURSOR_COLOR": rgb_hex(ui["cursor"]),
            "CODE_EDITOR_LINE_HIGHLIGHT": rgb_hex(ui["lineHighlight"]),
            "CODE_EDITOR_SELECTION_BACKGROUND": rgb_hex(ui["selection"]),
            "CODE_EDITOR_FIND_HIGHLIGHT_BACKGROUND": rgb_hex(ui["findMatch"]),
            "CODE_EDITOR_MATCHING_WORD_HIGHLIGHT_BACKGROUND": rgb_hex(ui["selection"]),
            "CODE_EDITOR_BREAKPOINT_BACKGROUND": rgb_hex(ui["diffRemovedBackground"]),
        },
        "syntax_styles": styles,
    }


def main():
    palette = load_palette(sys.argv)
    token_styles = {name: token["style"] for name, token in palette["tokens"].items()}
    themes = {t["id"]: t for t in palette["themes"]}
    if sorted(themes) != sorted(ORDER):
        sys.exit("the palette does not hold the eight expected Zacess themes")
    target = pathlib.Path(__file__).resolve().parent.parent / "shared" / "themes"
    target.mkdir(parents=True, exist_ok=True)
    for theme_id in ORDER:
        data = build(themes[theme_id], token_styles)
        (target / f"zacess-{theme_id}.json").write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(f"built {len(ORDER)} themes from palette {palette['version']} in {target}")


if __name__ == "__main__":
    main()
