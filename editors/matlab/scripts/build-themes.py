"""Builds the MATLAB themes in shared/themes and the colour schemes in shared/schemes from the Zacess VS Code themes.

usage: python scripts/build-themes.py <zacess-themes .vsix>

MATLAB keeps its colours in its settings tree (matlab.colors and matlab.appearance), which
shared/zacess_apply.m writes through MATLAB's own settings API. Each theme file maps a setting
path to its value: the Light or Dark desktop theme and an RGB triple for each colour.

That API only reaches the light theme's colours, so each theme also gets a colour scheme in the
format of MathWorks' Color Theme Extensions add-on (shared/base/scheme-template.json is its
template). The add-on's import_scheme applies a scheme to either theme, editor text and background
included, so the dark themes are fully set from code too. Every colour in the template takes the
theme colour for its role, found from its name: keywords, comments, strings, errors and so on.
"""

import json
import pathlib
import sys
import zipfile

THEMES = {
    "zacess-deep-contrast-dark": ("Zacess Deep Contrast Dark", "Dark"),
    "zacess-deep-contrast-light": ("Zacess Deep Contrast Light", "Light"),
    "zacess-high-contrast-dark": ("Zacess High Contrast Dark", "Dark"),
    "zacess-high-contrast-light": ("Zacess High Contrast Light", "Light"),
    "zacess-dark": ("Zacess Dark", "Dark"),
    "zacess-light": ("Zacess Light", "Light"),
    "zacess-cream": ("Zacess Cream", "Light"),
    "zacess-yellow-on-black": ("Zacess Yellow on Black", "Dark"),
}

# matlab setting: the TextMate scope or VS Code colour it takes
COLOURS = {
    "matlab.colors.KeywordColor": ("scope", "keyword"),
    "matlab.colors.CommentColor": ("scope", "comment"),
    "matlab.colors.StringColor": ("scope", "string"),
    "matlab.colors.SystemCommandColor": ("scope", "keyword.control"),
    "matlab.colors.ValidationSectionColor": ("scope", "entity.name.type"),
    "matlab.colors.UnterminatedStringColor": ("colour", "errorForeground"),
    "matlab.colors.SyntaxErrorColor": ("colour", "errorForeground"),
    "matlab.colors.commandwindow.ErrorColor": ("colour", "errorForeground"),
    "matlab.colors.commandwindow.WarningColor": ("scope", "constant.numeric"),
    "matlab.colors.commandwindow.HyperlinkColor": ("colour", "textLink.foreground"),
    "matlab.colors.programmingtools.CodeAnalyzerWarningColor": ("scope", "constant.numeric"),
    "matlab.colors.programmingtools.CodeAnalyzerInfoColor": ("colour", "textLink.foreground"),
    "matlab.colors.programmingtools.VariablesWithSharedScopeColor": ("scope", "entity.name.type"),
    "matlab.colors.programmingtools.VariableHighlightColor": ("colour", "editor.selectionBackground"),
    "matlab.colors.programmingtools.AutofixHighlightColor": ("colour", "editor.lineHighlightBackground"),
}


def rgb(value, under="#000000"):
    value = value.lstrip("#")
    r, g, b = (int(value[i:i + 2], 16) for i in (0, 2, 4))
    if len(value) == 8:
        a = int(value[6:8], 16) / 255
        u = [int(under.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
        r, g, b = (round(c * a + d * (1 - a)) for c, d in zip((r, g, b), u))
    return [r, g, b]


def scope(theme, wanted):
    for rule in theme.get("tokenColors", []):
        scopes = rule.get("scope", [])
        scopes = [s.strip() for s in (scopes.split(",") if isinstance(scopes, str) else scopes)]
        if wanted in scopes and "foreground" in rule.get("settings", {}):
            return rule["settings"]["foreground"]
    raise SystemExit(f"no colour for {wanted} in {theme.get('name')}")


# a scheme colour's role, from words in its name, checked in this order
ROLES = [
    (("Error", "Unterminated"), ("colour", "errorForeground")),
    (("Warning",), ("scope", "constant.numeric")),
    (("Hyperlink", "Links", "HTML", "Info"), ("colour", "textLink.foreground")),
    (("Comment", "BlockQuotes"), ("scope", "comment")),
    (("String", "AttributeValue", "CDATA", "Character"), ("scope", "string")),
    (("Preprocessor", "Macro", "ProcessingInstruction", "SystemCommands", "DOCTYPE"), ("scope", "keyword.control")),
    (("AttributeName", "Validation", "VariablesWithSharedScope"), ("scope", "entity.name.type")),
    (("Numbers", "Operators", "HorizontalRule"), ("scope", "constant.numeric")),
    (("Headings", "Bold", "Italic", "CodeBlocks"), ("scope", "entity.name.function")),
    (("Keyword", "Keys", "Tag", "Commands", "Lists"), ("scope", "keyword")),
]


def hexcolour(colour):
    return "#{:02X}{:02X}{:02X}".format(*colour)


def scheme(theme, mode, template):
    c = theme["colors"]
    bg, fg = c["editor.background"], c["editor.foreground"]
    fixed = {
        "TextColor": fg,
        "BackgroundColor": bg,
        "HighlightCurrentLineColor": c.get("editor.lineHighlightBackground", bg),
        "RightHandTextLimitLineColor": c.get("editorRuler.foreground", c.get("editorIndentGuide.background1", fg)),
        "AutofixHighlightColor": c.get("editor.lineHighlightBackground", bg),
        "AutomaticallyHighlightColor": c["editor.selectionBackground"],
    }

    def fill(node):
        out = {}
        for key, value in node.items():
            if isinstance(value, dict):
                out[key] = fill(value)
            elif key == "DesktopTheme":
                out[key] = mode
            elif isinstance(value, str) and value.startswith("#"):
                if key in fixed:
                    out[key] = hexcolour(rgb(fixed[key], bg))
                    continue
                for words, (kind, source) in ROLES:
                    if any(word in key for word in words):
                        colour = scope(theme, source) if kind == "scope" else c.get(source, fg)
                        out[key] = hexcolour(rgb(colour, bg))
                        break
                else:
                    raise SystemExit(f"no role for scheme colour {key}")
            else:
                out[key] = value
        return out

    return fill(template)


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip().splitlines()[2])
    with zipfile.ZipFile(sys.argv[1]) as z:
        themes = {key: json.loads(z.read(f"extension/themes/{key}-color-theme.json")) for key in THEMES}
    root = pathlib.Path(__file__).resolve().parent.parent / "shared"
    template = json.loads((root / "base" / "scheme-template.json").read_text(encoding="utf-8"))
    schemes = root / "schemes"
    schemes.mkdir(parents=True, exist_ok=True)
    for key, (name, mode) in THEMES.items():
        text = json.dumps(scheme(themes[key], mode, template), indent=2) + "\n"
        (schemes / f"{name}.json").write_text(text, encoding="utf-8", newline="\n")
    target = root / "themes"
    target.mkdir(parents=True, exist_ok=True)
    for key, (name, mode) in THEMES.items():
        theme = themes[key]
        bg = theme["colors"]["editor.background"]
        values = {"matlab.appearance.MATLABTheme": mode}
        for setting, (kind, source) in COLOURS.items():
            colour = scope(theme, source) if kind == "scope" else theme["colors"].get(source, theme["colors"]["editor.foreground"])
            values[setting] = rgb(colour, bg)
        text = json.dumps({"name": name, "settings": values}, indent=2) + "\n"
        (target / f"{name}.json").write_text(text, encoding="utf-8", newline="\n")
    print(f"built {len(THEMES)} themes in {target}")


if __name__ == "__main__":
    main()
