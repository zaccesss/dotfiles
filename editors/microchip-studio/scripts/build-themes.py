"""Builds the Microchip Studio themes in themes/ from the Zacess VS Code themes.

usage: python scripts/build-themes.py <zacess-themes .vsix or the folder holding its theme JSON files>

Microchip Studio 7 is the Visual Studio 2015 shell, so its colours are a .vssettings file whose
Fonts and Colors category lists one item per editor element. Each item takes the VS Code colour
that plays the same part. Visual Assist, which Microchip Studio ships, adds the C items (macros,
methods, types and variables). Directives and macros take the colour of control keywords, which
every theme keeps apart from functions and plain keywords, as the Eclipse-based IDEs do.
"""

import json
import pathlib
import sys
import zipfile
from xml.sax.saxutils import quoteattr

THEMES = {
    "zacess-deep-contrast-dark": ("Zacess Deep Contrast Dark", "dark"),
    "zacess-deep-contrast-light": ("Zacess Deep Contrast Light", "light"),
    "zacess-high-contrast-dark": ("Zacess High Contrast Dark", "dark"),
    "zacess-high-contrast-light": ("Zacess High Contrast Light", "light"),
    "zacess-dark": ("Zacess Dark", "dark"),
    "zacess-light": ("Zacess Light", "light"),
    "zacess-cream": ("Zacess Cream", "light"),
    "zacess-yellow-on-black": ("Zacess Yellow on Black", "dark"),
}

# the Visual Studio 2015 environment themes the window chrome follows
VS_THEMES = {"dark": "{1DED0138-47CE-435E-84EF-9EC1F439B749}", "light": "{DE3DBBCD-F642-433C-8353-8F1DF4370ABA}"}

# Fonts and Colors categories: the text editor, then the text tool windows (Output, Find Results
# and the rest), which take the same font so build output reads like code
TEXT_EDITOR = "{A27B4E24-A735-4D1D-B8E7-9716E1E3D8E0}"
TOOL_WINDOWS = "{C34C709B-C855-459E-B38C-3021F162D3B1}"
# windows looks fonts up by their GDI family name, which Nerd Fonts shortens to GeistMono NF
FONT = "GeistMono NF"
FONT_SIZE = 14

# editor item: the VS Code TextMate scope whose colour it takes. None means the plain text colour
TOKENS = {
    "Identifier": None,
    "Keyword": "keyword",
    "Preprocessor Keyword": "keyword.control",
    "Comment": "comment",
    "String": "string",
    "Number": "constant.numeric",
    "Literal": "constant.numeric",
    "Operator": "keyword.operator",
    "VA Macro / Enum": "keyword.control",
    "VA Method": "entity.name.function",
    "VA Class": "entity.name.type",
    "VA Variable": "variable",
}


def load(source):
    source = pathlib.Path(source)
    themes = {}
    if source.suffix == ".vsix":
        with zipfile.ZipFile(source) as z:
            for key in THEMES:
                themes[key] = json.loads(z.read(f"extension/themes/{key}-color-theme.json"))
    else:
        for key in THEMES:
            themes[key] = json.loads((source / f"{key}-color-theme.json").read_text(encoding="utf-8"))
    return themes


def rgb(value, under="#000000"):
    """#rrggbb or #rrggbbaa as (r, g, b), with any alpha blended over the colour beneath."""
    value = value.lstrip("#")
    r, g, b = (int(value[i:i + 2], 16) for i in (0, 2, 4))
    if len(value) == 8:
        a = int(value[6:8], 16) / 255
        br, bg, bb = rgb(under)
        r, g, b = (round(c * a + d * (1 - a)) for c, d in ((r, br), (g, bg), (b, bb)))
    return r, g, b


def vs(colour):
    """visual studio stores colours as 0x00BBGGRR."""
    r, g, b = colour
    return f"0x00{b:02X}{g:02X}{r:02X}"


def scope_style(theme, wanted):
    """foreground and bold for the most specific token rule that names the scope."""
    best = None
    for rule in theme.get("tokenColors", []):
        scopes = rule.get("scope", [])
        scopes = [s.strip() for s in (scopes.split(",") if isinstance(scopes, str) else scopes)]
        if wanted in scopes and "foreground" in rule.get("settings", {}):
            best = rule["settings"]
            break
    if best is None:
        raise SystemExit(f"no colour for {wanted} in {theme.get('name')}")
    return best["foreground"], "bold" in best.get("fontStyle", "")


def build(name, mode, theme):
    c = theme["colors"]
    bg = c["editor.background"]
    fg = c["editor.foreground"]
    items = []

    def item(label, fore=None, back=None, bold=False):
        attrs = f'Name={quoteattr(label)}'
        attrs += f' Foreground="{vs(rgb(fore, bg)) if fore else "0x02000000"}"'
        attrs += f' Background="{vs(rgb(back, bg)) if back else "0x02000000"}"'
        attrs += f' BoldFont="{"Yes" if bold else "No"}"'
        items.append(f"<Item {attrs} />")

    item("Plain Text", fg, bg)
    item("Selected Text", c.get("editor.selectionForeground", fg), c["editor.selectionBackground"])
    item("Inactive Selected Text", c.get("editor.selectionForeground", fg), c.get("editor.inactiveSelectionBackground", c["editor.selectionBackground"]))
    item("Line Number", c.get("editorLineNumber.foreground", fg), bg)
    item("Highlight Current Line (Active)", c.get("editor.lineHighlightBackground", bg), c.get("editor.lineHighlightBackground", bg))
    item("VA Current Line", None, c.get("editor.lineHighlightBackground", bg))
    for label, scope in TOKENS.items():
        if scope is None:
            item(label, fg)
        else:
            colour, bold = scope_style(theme, scope)
            item(label, colour, None, bold)

    tool = (f'<Category GUID="{TOOL_WINDOWS}" FontName="{FONT}" FontSize="{FONT_SIZE}" CharSet="1" FontIsDefault="No">'
            f'<Items><Item Name="Plain Text" Foreground="{vs(rgb(fg))}" Background="{vs(rgb(bg))}" BoldFont="No" /></Items></Category>')
    return (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        f"<!-- {name} for Microchip Studio 7, built by scripts/build-themes.py from the Zacess VS Code theme, do not edit by hand -->\n"
        '<UserSettings><ApplicationIdentity version="14.0"/><ToolsOptions><ToolsOptionsCategory name="Environment" RegisteredName="Environment"/></ToolsOptions>'
        '<Category name="Environment_Group" RegisteredName="Environment_Group">'
        '<Category name="Environment_FontsAndColors" Category="{1EDA5DD4-927A-43a7-810E-7FD247D0DA1D}" Package="{DA9FB551-C724-11d0-AE1F-00A0C90FFFC3}" RegisteredName="Environment_FontsAndColors" PackageName="Visual Studio Environment Package">'
        '<PropertyValue name="Version">2</PropertyValue><FontsAndColors Version="2.0">'
        f'<Theme Id="{VS_THEMES[mode]}"/><Categories>'
        f'<Category GUID="{TEXT_EDITOR}" FontName="{FONT}" FontSize="{FONT_SIZE}" CharSet="1" FontIsDefault="No"><Items>'
        + "".join(items)
        + "</Items></Category>"
        + tool
        + "</Categories></FontsAndColors></Category></Category></UserSettings>\n"
    )


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip().splitlines()[2])
    themes = load(sys.argv[1])
    target = pathlib.Path(__file__).resolve().parent.parent / "themes"
    target.mkdir(exist_ok=True)
    for key, (name, mode) in THEMES.items():
        (target / f"{name}.vssettings").write_text(build(name, mode, themes[key]), encoding="utf-8", newline="\n")
    print(f"built {len(THEMES)} themes in {target}")


if __name__ == "__main__":
    main()
