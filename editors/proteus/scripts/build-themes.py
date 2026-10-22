"""Builds the Proteus colour sets and schematic colours in shared/themes from the Zacess VS Code themes.

usage: python scripts/build-themes.py <zacess-themes .vsix>

Each theme file holds two parts. "values" is the PCB layout and graph viewer colour set below.
"schematic" is the design colours, graphics styles and text styles that windows/apply.ps1 writes
into Proteus's design templates, built from Proteus's own defaults in shared/base/schematic_default.json.

Proteus keeps a named colour set for its PCB layout and its graph viewer in the registry, one
"(0xRR,0xGG,0xBB)" string per item. Each Zacess set starts from Proteus's own Black Paper set (dark
themes) or White Paper set (light themes) in shared/base, so every item and show flag exists.
The paper, grid and highlights take the theme's background, dim and focus colours. Every other
colour (copper layers, silk, pads, vias, the ratsnest) moves to the theme's terminal colour
nearest its own hue, so top copper stays red and bottom copper blue in every theme.
"""

import colorsys
import json
import pathlib
import re
import sys
import zipfile

# theme id: (full name, paper, colour set name). Proteus cuts a colour set name to 20 characters
# when it saves its settings, so the set names are short
THEMES = {
    "zacess-deep-contrast-dark": ("Zacess Deep Contrast Dark", "dark", "ZACESS_DEEP_DARK"),
    "zacess-deep-contrast-light": ("Zacess Deep Contrast Light", "light", "ZACESS_DEEP_LIGHT"),
    "zacess-high-contrast-dark": ("Zacess High Contrast Dark", "dark", "ZACESS_HC_DARK"),
    "zacess-high-contrast-light": ("Zacess High Contrast Light", "light", "ZACESS_HC_LIGHT"),
    "zacess-dark": ("Zacess Dark", "dark", "ZACESS_DARK"),
    "zacess-light": ("Zacess Light", "light", "ZACESS_LIGHT"),
    "zacess-cream": ("Zacess Cream", "light", "ZACESS_CREAM"),
    "zacess-yellow-on-black": ("Zacess Yellow on Black", "dark", "ZACESS_YELLOW"),
}

ANSI = ["Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "BrightRed", "BrightGreen", "BrightYellow",
        "BrightBlue", "BrightMagenta", "BrightCyan", "White", "BrightBlack", "BrightWhite"]



def rgb(value, under="#000000"):
    value = value.lstrip("#")
    r, g, b = (int(value[i:i + 2], 16) for i in (0, 2, 4))
    if len(value) == 8:
        a = int(value[6:8], 16) / 255
        u = [int(under.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
        r, g, b = (round(c * a + d * (1 - a)) for c, d in zip((r, g, b), u))
    return r, g, b


def nearest(colour, palette):
    """the palette colour closest in hue. greys go by lightness instead."""
    h, light, s = colorsys.rgb_to_hls(*(c / 255 for c in colour))
    best, score = None, None
    for candidate in palette:
        ch, c_light, cs = colorsys.rgb_to_hls(*(c / 255 for c in candidate))
        if s < 0.15 or cs < 0.15:
            distance = abs(light - c_light) + (0 if (s < 0.15) == (cs < 0.15) else 1)
        else:
            dh = abs(h - ch)
            distance = min(dh, 1 - dh) + 0.25 * abs(light - c_light)
        if score is None or distance < score:
            best, score = candidate, distance
    return best


def proteus(colour):
    return "({})".format(",".join(f"0x{c:02X}" for c in colour))


def build(theme, base):
    c = theme["colors"]
    bg = c["editor.background"]
    palette = [rgb(c[f"terminal.ansi{n}"], bg) for n in ANSI if f"terminal.ansi{n}" in c]
    chrome = {
        "Paper Colour": rgb(bg),
        "Grid Colour": rgb(c.get("descriptionForeground", c["editor.foreground"]), bg),
        "Hilite Colour": rgb(c.get("focusBorder", c["editor.foreground"]), bg),
        "Dimmed Colour": rgb(c["editor.selectionBackground"], bg),
        "Empty Zone Colour": rgb(c.get("editor.lineHighlightBackground", bg), bg),
        "Pin Number Colour": rgb(c["editor.foreground"], bg),
    }
    out = {}
    for key, value in base.items():
        # numbers (registry DWORDs) are copied as they are
        match = isinstance(value, str) and re.fullmatch(r"\(0x([0-9A-F]{2}),0x([0-9A-F]{2}),0x([0-9A-F]{2})\)", value, re.I)
        if key in chrome:
            out[key] = proteus(chrome[key])
        elif match:
            out[key] = proteus(nearest(tuple(int(x, 16) for x in match.groups()), palette))
        else:
            out[key] = value
    return out


def hexcolour(colour):
    return "#{:02x}{:02x}{:02x}".format(*colour)


def grey(colour, limit=0.15):
    return colorsys.rgb_to_hls(*(c / 255 for c in colour))[2] < limit


def build_schematic(theme, base):
    """the schematic colours for the design template, keyed by the slots in shared/base/schematic_default.json.

    the paper takes the theme's background and the grid its indent guide colour, which Proteus fades
    against the paper. selection takes the focus colour. outlines, wires and text that were black or grey take the theme's text colour;
    every coloured one moves to the terminal colour nearest its hue, so wires stay green and probes
    blue. pale component fills take the line highlight shade, so a part reads as a block on the paper.
    """
    c = theme["colors"]
    bg = c["editor.background"]
    palette = [rgb(c[f"terminal.ansi{n}"], bg) for n in ANSI if f"terminal.ansi{n}" in c]
    text = rgb(c["editor.foreground"], bg)
    dim = rgb(c.get("descriptionForeground", c["editor.foreground"]), bg)
    panel = rgb(c.get("editor.lineHighlightBackground", bg), bg)

    def ink(colour):
        return text if grey(colour) else nearest(colour, palette)

    fixed = {
        "design.paper": rgb(bg),
        "design.grid": rgb(c.get("editorIndentGuide.background1", c.get("editorIndentGuide.background", c["editor.foreground"])), bg),
        # selected parts would vanish into red component outlines, so selection takes the focus colour
        "design.highlight": rgb(c.get("focusBorder", c["editor.foreground"]), bg),
        "design.hidden": dim,
        "design.logicUnknown": dim,
    }
    out = {}
    for slot, value in base.items():
        colour = rgb(value)
        if slot in fixed:
            out[slot] = fixed[slot]
        elif slot.endswith((".fill", ".back")):
            out[slot] = panel if grey(colour, 0.25) else ink(colour)
        else:
            out[slot] = ink(colour)
    return {"colours": {k: hexcolour(v) for k, v in out.items()},
            "fallback": {"line": hexcolour(text), "fill": hexcolour(panel), "text": hexcolour(text)}}


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip().splitlines()[2])
    root = pathlib.Path(__file__).resolve().parent.parent
    bases = {mode: json.loads((root / "shared" / "base" / f"{paper}.json").read_text(encoding="utf-8"))
             for mode, paper in (("dark", "black_paper"), ("light", "white_paper"))}
    schematic = json.loads((root / "shared" / "base" / "schematic_default.json").read_text(encoding="utf-8"))
    with zipfile.ZipFile(sys.argv[1]) as z:
        themes = {key: json.loads(z.read(f"extension/themes/{key}-color-theme.json")) for key in THEMES}
    target = root / "shared" / "themes"
    target.mkdir(parents=True, exist_ok=True)
    for key, (name, mode, colour_set) in THEMES.items():
        data = {"name": name, "set": colour_set, "values": build(themes[key], bases[mode]),
                "schematic": build_schematic(themes[key], schematic)}
        (target / f"{name}.json").write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8", newline="\n")
    print(f"built {len(THEMES)} themes in {target}")


if __name__ == "__main__":
    main()
