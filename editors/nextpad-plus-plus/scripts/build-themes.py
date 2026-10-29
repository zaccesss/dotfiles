"""Builds the eight Zacess themes for Nextpad++ in shared/themes from the Zacess palette.

usage: python3 scripts/build-themes.py [--model stylers.model.xml] [palette.json]

Nextpad++ (the Mac port of Notepad++) reads Notepad++ style files: one XML file per theme with a
style for every lexer's tokens plus the editor-wide styles. The list of lexers and styles comes
from the stylers.model.xml that ships with the app, so a new language in a later release is
picked up on the next build. With no --model the installed app's copy is read. Each style is
given a palette colour by what its name says it is (a comment, a string, a keyword and so on).

With no palette argument the palette is downloaded from the pinned Zacess Themes release and
checked against its digest. A local palette file (a clone of zacesshq/themes) can be passed
instead. The same files work in Notepad++ on Windows, which reads the same format.
"""

import hashlib
import json
import pathlib
import re
import sys
import urllib.request
import xml.etree.ElementTree as ET

PALETTE_URL = "https://raw.githubusercontent.com/zacesshq/themes/v0.6.0/palette/zacess.json"
PALETTE_SHA256 = "2907de45bc1403661aa447b3eb08a592e814c2ecf8f3cd0d1101e884548442f4"
MODEL = pathlib.Path("/Applications/Nextpad++.app/Contents/Resources/stylers.model.xml")
ORDER = ["deep-contrast-dark", "deep-contrast-light", "high-contrast-dark", "high-contrast-light",
         "dark", "light", "cream", "yellow-on-black"]
FONT = "GeistMono Nerd Font Mono"

# the first rule whose pattern matches a style's name decides its token, so the narrow names
# (an error inside a comment, a variable inside a string) come before the broad ones
RULES = [
    (r"ERROR|INVALID|UNKNOWN|WRONG|GARBAGE|NOT CLOSED|UNCLOSED|STRING EOL|\bBAD\b", "invalid"),
    (r"\bADDED\b|\bINSERTED\b|\bADD\b|ADDITION", "added"),
    (r"\bDELETED\b|\bREMOVED\b|\bDEL\b|DELETION", "removed"),
    (r"\bCHANGED\b|\bMODIFIED\b", "changed"),
    (r"COMMENT DOC KEYWORD|DOC KEYWORD|DOC TAG", "control"),
    (r"COMMENT|\bPOD\b|\bREM\b", "comment"),
    (r"REGEX|REGEXP|PATTERN", "regex"),
    (r"VAR IN|INTERPOLAT|ESCAPE", "parameter"),
    (r"STRING|CHARACTER|\bCHAR\b|VERBATIM|HEREDOC|BACKTICK|QUOTE|CDATA|TRIPLE|\bURL\b|\bURI\b", "string"),
    (r"NUMBER|NUMERIC|\bHEX|\bBIN|\bFLOAT|\bINT\b|DECIMAL|\bDATE\b|\bTIME\b", "number"),
    (r"CONSTANT|\bTRUE\b|\bFALSE\b|\bNULL\b|BOOLEAN|\bBOOL\b|ENTITY", "number"),
    (r"PREPROCESSOR|DIRECTIVE|MACRO|PRAGMA|DEFINE|INCLUDE|\bIMPORT", "control"),
    (r"CONTROL|STATEMENT|CONDITION|\bFLOW\b", "control"),
    (r"FUNCTION|METHOD|BUILTIN|BUILT-IN|COMMAND|\bCALL\b|PROCEDURE|SUBROUTINE|OPCODE|INSTRUCTION$", "function"),
    (r"TYPE|CLASS|INTERFACE|\bSTRUCT|\bENUM\b|MODULE|NAMESPACE|PACKAGE|REGISTER", "type"),
    (r"ATTRIBUTE|ATTR\b|PSEUDO|ANNOTATION|DECORATOR|LABEL", "attribute"),
    (r"\bTAG|ELEMENT|XML START|XML END|SGML", "tag"),
    (r"PROPERTY|\bKEY\b|FIELD|MEMBER|SELECTOR|\bID\b", "property"),
    (r"PARAMETER|PARAM\b|ARGUMENT", "parameter"),
    (r"VARIABLE|\bVAR\b|SCALAR|ARRAY|HASH|IDENTIFIER|GLOBAL", "variable"),
    (r"OPERATOR|DELIMITER|PUNCTUATION|BRACE|BRACKET|SYMBOL|ASSIGNMENT|SEPARATOR", "operator"),
    (r"KEYWORD|INSTRUCTION|WORD|RESERVED|SECTION|HEADER|HEADING|TITLE|SPECIAL", "keyword"),
    (r"VALUE", "string"),
]
STYLE_BITS = {"bold": 1, "italic": 2, "underline": 4}


def load_palette(path):
    if path:
        return json.loads(pathlib.Path(path).read_text(encoding="utf-8"))
    data = urllib.request.urlopen(PALETTE_URL, timeout=60).read()
    if hashlib.sha256(data).hexdigest() != PALETTE_SHA256:
        sys.exit("the downloaded palette does not match its pinned digest")
    return json.loads(data)


def token_for(name):
    upper = name.upper()
    for pattern, token in RULES:
        if re.search(pattern, upper):
            return token
    return "foreground"


def hexval(colour):
    return colour.lstrip("#").upper()


def build(model, theme, styles):
    ui, syn = theme["ui"], theme["syntax"]
    bg, fg = hexval(ui["background"]), hexval(syn["foreground"])
    root = ET.Element("NotepadPlus")
    lexers = ET.SubElement(root, "LexerStyles")
    for lexer in model.find("LexerStyles"):
        out = ET.SubElement(lexers, "LexerType", dict(lexer.attrib))
        for style in lexer:
            token = token_for(style.get("name", ""))
            attrs = dict(style.attrib)
            attrs.update(fgColor=hexval(syn[token]), bgColor=bg, fontName="", fontSize="",
                         fontStyle=str(sum(STYLE_BITS[s] for s in styles.get(token, []))))
            ET.SubElement(out, "WordsStyle", attrs)

    widget = {
        "Default Style": {"fgColor": fg, "bgColor": bg, "fontName": FONT, "fontStyle": "0"},
        # only used when "Enable global font" is ticked, which would otherwise bring back the stock
        # yellow on orange and Courier New
        "Global override": {"fgColor": fg, "bgColor": bg, "fontName": FONT},
        "Indent guideline style": {"fgColor": hexval(ui["indentGuide"]), "bgColor": bg},
        "Brace highlight style": {"fgColor": hexval(ui["accent"]), "bgColor": bg, "fontStyle": "1"},
        "Bad brace colour": {"fgColor": hexval(syn["invalid"]), "bgColor": bg, "fontStyle": "1"},
        "Current line background colour": {"bgColor": hexval(ui["lineHighlight"])},
        # the strong selection block with its own text colour, which Zacess Themes ships from 0.5.0;
        # an older palette keeps the editor fill. Background only widgets keep the fill
        "Selected text colour": {"bgColor": hexval(ui.get("selectionStrong", ui["selection"])),
                                 "fgColor": hexval(ui["selectionForeground"]) if "selectionForeground" in ui else fg},
        "Multi-selected text color": {"bgColor": hexval(ui["selection"])},
        "Caret colour": {"fgColor": hexval(ui["cursor"])},
        "Multi-edit carets color": {"fgColor": hexval(ui["cursor"])},
        "Edge colour": {"fgColor": hexval(ui["border"])},
        "Line number margin": {"fgColor": hexval(ui["lineNumber"]), "bgColor": hexval(ui["gutter"])},
        "Bookmark margin": {"bgColor": hexval(ui["gutter"])},
        "Change History margin": {"bgColor": hexval(ui["gutter"])},
        "Change History modified": {"fgColor": hexval(syn["changed"]), "bgColor": hexval(syn["changed"])},
        "Change History revert modified": {"fgColor": hexval(syn["number"]), "bgColor": hexval(syn["number"])},
        "Change History revert origin": {"fgColor": hexval(syn["type"]), "bgColor": hexval(syn["type"])},
        "Change History saved": {"fgColor": hexval(syn["added"]), "bgColor": hexval(syn["added"])},
        "Fold": {"fgColor": hexval(ui["muted"]), "bgColor": hexval(ui["surfaceAlt"])},
        "Fold active": {"fgColor": hexval(ui["accent"])},
        "Fold margin": {"fgColor": hexval(ui["gutter"]), "bgColor": hexval(ui["gutter"])},
        "White space symbol": {"fgColor": hexval(ui["whitespace"])},
        "Smart Highlighting": {"bgColor": hexval(ui["selection"])},
        "Find Mark Style": {"bgColor": hexval(ui["findMatch"])},
        "Find status: Not found": {"fgColor": hexval(ui["error"])},
        "Find status: Message": {"fgColor": hexval(ui["info"])},
        "Find status: Search end reached": {"fgColor": hexval(ui["warning"])},
        "Incremental highlight all": {"bgColor": hexval(ui["findMatch"])},
        "Tags match highlighting": {"bgColor": hexval(ui["selection"])},
        "Tags attribute": {"bgColor": hexval(ui["selection"])},
        "Active tab focused indicator": {"fgColor": hexval(ui["borderActive"])},
        "Active tab unfocused indicator": {"fgColor": hexval(ui["border"])},
        "Active tab text": {"fgColor": fg},
        "Inactive tabs": {"fgColor": hexval(ui["muted"]), "bgColor": hexval(ui["surfaceAlt"])},
        "URL hovered": {"fgColor": hexval(ui["link"])},
        "Document map": {"fgColor": hexval(ui["accent"]), "bgColor": bg},
        "EOL custom color": {"fgColor": hexval(ui["whitespace"])},
        "Non-printing characters custom color": {"fgColor": hexval(ui["whitespace"])},
    }
    # the five mark styles and the tab colours keep their own hues but come from the palette's
    # terminal colours, so they stay apart from each other in every theme
    ansi = [hexval(c) for c in theme["terminal"]["ansi"]]
    marks = {f"Mark Style {n}": {"bgColor": ansi[i]} for n, i in zip(range(1, 6), (6, 3, 11, 5, 2))}
    widget.update(marks)
    for n, i in zip(range(1, 6), (3, 2, 4, 1, 5)):
        widget[f"Tab color {n}"] = {"bgColor": ansi[i]}
        widget[f"Tab color dark mode {n}"] = {"bgColor": ansi[i]}

    globals_out = ET.SubElement(root, "GlobalStyles")
    for style in model.find("GlobalStyles"):
        attrs = dict(style.attrib)
        name = attrs.get("name")
        attrs.update(widget.get(name, {}))
        ET.SubElement(globals_out, "WidgetStyle", attrs)

    ET.indent(root, space="    ")
    header = (f'<?xml version="1.0" encoding="UTF-8" ?>\n'
              f"<!-- {theme['name']} for Nextpad++ and Notepad++, built by scripts/build-themes.py "
              f"from the Zacess palette. do not edit by hand -->\n")
    return header + ET.tostring(root, encoding="unicode") + "\n"


def main():
    args = sys.argv[1:]
    model_path = MODEL
    if args[:1] == ["--model"]:
        model_path, args = pathlib.Path(args[1]), args[2:]
    model = ET.parse(model_path).getroot()
    palette = load_palette(args[0] if args else None)
    styles = {name: token["style"] for name, token in palette["tokens"].items()}
    themes = {t["id"]: t for t in palette["themes"]}
    if sorted(themes) != sorted(ORDER):
        sys.exit("the palette does not hold the eight expected Zacess themes")
    target = pathlib.Path(__file__).resolve().parent.parent / "shared" / "themes"
    target.mkdir(parents=True, exist_ok=True)
    for theme_id in ORDER:
        theme = themes[theme_id]
        (target / f"{theme['name']}.xml").write_text(build(model, theme, styles), encoding="utf-8", newline="\n")
    print(f"built {len(ORDER)} themes from palette {palette['version']} and {model_path.name} in {target}")


if __name__ == "__main__":
    main()
