"""Builds the Notepad++ themes in themes/ from the Zacess VS Code themes.

usage: python scripts/build-themes.py <zacess-themes .vsix> <a Notepad++ theme to copy the structure from>

Notepad++ themes list every language's styles by name (COMMENT, STRING, INSTRUCTION WORD and the
rest) with plain RRGGBB colours. The structure comes from a theme Notepad++ ships, usually
themes/DarkModeDefault.xml in its install folder. Each style takes the Zacess colour its name
describes. Directives and macros take the colour of control keywords, which every theme keeps
apart from functions and plain keywords, as the other editors here do.
"""

import json
import pathlib
import re
import sys
import xml.etree.ElementTree as ET
import zipfile

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

# windows looks fonts up by their GDI family name, which Nerd Fonts shortens to GeistMono NF
FONT = "GeistMono NF"
FONT_SIZE = "14"

# style name pattern: the TextMate scope whose colour it takes, checked in order. whole words
# only, since INSTRUCTION WORD would otherwise match STRUCT
ROLES = [
    (r"\bCOMMENTS?\b", "comment"),
    (r"\b(PREPROCESSOR|DIRECTIVES?|MACROS?|PRAGMA|DEFINE)\b", "keyword.control"),
    (r"\bREGEXP?\b", "string.regexp"),
    (r"\b(STRINGS?|CHARACTERS?|VERBATIM|HEREDOC|QUOTED?|CHAR|TRIPLE)\b", "string"),
    (r"\bDEF NAME\b", "entity.name.function"),
    (r"\b(NUMBERS?|NUMERIC|DIGITS?|HEX|CONSTANTS?)\b", "constant.numeric"),
    (r"\b(TYPES?|CLASS(ES)?|STRUCTS?)\b", "entity.name.type"),
    (r"\b(FUNCTIONS?|METHODS?|BUILTINS?|BUILT-IN)\b", "entity.name.function"),
    (r"\b(INSTRUCTION|KEYWORDS?|WORDS?|RESERVED|STATEMENTS?)\b", "keyword"),
    (r"\bATTRIBUTES?\b", "entity.other.attribute-name"),
    (r"\b(TAGS?|ELEMENTS?)\b", "entity.name.tag"),
    (r"\b(OPERATORS?|DELIMITERS?|PUNCTUATION|BRACES?|BRACKETS?)\b", "keyword.operator"),
]


def load(vsix):
    with zipfile.ZipFile(vsix) as z:
        return {key: json.loads(z.read(f"extension/themes/{key}-color-theme.json")) for key in THEMES}


def hex6(value, under="#000000"):
    """#rrggbb or #rrggbbaa as RRGGBB, with any alpha blended over the colour beneath."""
    value = value.lstrip("#")
    if len(value) == 8:
        a = int(value[6:8], 16) / 255
        top = [int(value[i:i + 2], 16) for i in (0, 2, 4)]
        bottom = [int(under.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
        return "".join(f"{round(t * a + b * (1 - a)):02X}" for t, b in zip(top, bottom))
    return value[:6].upper()


def scope_style(theme, wanted):
    for rule in theme.get("tokenColors", []):
        scopes = rule.get("scope", [])
        scopes = [s.strip() for s in (scopes.split(",") if isinstance(scopes, str) else scopes)]
        if wanted in scopes and "foreground" in rule.get("settings", {}):
            style = rule["settings"].get("fontStyle", "")
            return rule["settings"]["foreground"], ("bold" in style) + 2 * ("italic" in style)
    raise SystemExit(f"no colour for {wanted} in {theme.get('name')}")


def build(name, theme, template):
    c = theme["colors"]
    bg, fg = c["editor.background"], c["editor.foreground"]
    root = ET.fromstring(template)
    for words in root.iter("WordsStyle"):
        label = words.get("name", "").upper()
        colour, style = fg, 0
        for pattern, scope in ROLES:
            if re.search(pattern, label):
                colour, style = scope_style(theme, scope)
                break
        words.set("fgColor", hex6(colour, bg))
        words.set("bgColor", hex6(bg))
        words.set("fontStyle", str(style))
        words.set("fontName", "")
        words.set("fontSize", "")
    widgets = {
        "Default Style": (fg, bg),
        "Current line background colour": (None, c.get("editor.lineHighlightBackground", bg)),
        "Selected text colour": (c.get("editor.selectionForeground", fg), c["editor.selectionBackground"]),
        "Caret colour": (c.get("editorCursor.foreground", fg), None),
        "Line number margin": (c.get("editorLineNumber.foreground", fg), bg),
        "Indent guideline style": (c.get("editorIndentGuide.background", c.get("editorLineNumber.foreground", fg)), bg),
        "Brace highlight style": (fg, c["editor.selectionBackground"]),
        "Fold margin": (bg, bg),
        "Bookmark margin": (None, bg),
        "Change History margin": (None, bg),
        # only used when "Enable global font" is ticked, which would otherwise bring back Consolas on grey
        "Global override": (fg, bg),
    }
    for widget in root.iter("WidgetStyle"):
        pair = widgets.get(widget.get("name"))
        if pair is None:
            continue
        fore, back = pair
        if fore is not None:
            widget.set("fgColor", hex6(fore, bg))
        if back is not None:
            widget.set("bgColor", hex6(back, bg))
        if widget.get("name") == "Global override":
            widget.set("fontName", FONT)
        if widget.get("name") == "Default Style":
            widget.set("fontName", FONT)
            widget.set("fontSize", FONT_SIZE)
    header = (f"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<!-- {name} for Notepad++, built by scripts/build-themes.py "
              "from the Zacess VS Code theme, do not edit by hand -->\n")
    return header + ET.tostring(root, encoding="unicode") + "\n"


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__.strip().splitlines()[2])
    themes = load(sys.argv[1])
    template = pathlib.Path(sys.argv[2]).read_text(encoding="utf-8")
    target = pathlib.Path(__file__).resolve().parent.parent / "themes"
    target.mkdir(exist_ok=True)
    for key, (name, _mode) in THEMES.items():
        (target / f"{name}.xml").write_text(build(name, themes[key], template), encoding="utf-8", newline="\n")
    print(f"built {len(THEMES)} themes in {target}")


if __name__ == "__main__":
    main()
