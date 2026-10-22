"""Builds the Zacess Thonny plugin in shared/thonnycontrib/zacess_themes from the Zacess VS Code themes.

usage: python scripts/build-themes.py <zacess-themes .vsix>

Thonny takes themes from plugins: a package under thonnycontrib whose load_plugin() registers a
syntax theme (the editor and shell colours) and a UI theme (the window around them). Each Zacess
theme becomes one of each, named the same, so zt and the preferences can pick them by name. The
syntax themes build on Thonny's Default Dark or Default Light, which supply the shell's ANSI
colours and everything else not set here.
"""

import json
import pathlib
import pprint
import sys
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


def hex6(value, under="#000000"):
    value = value.lstrip("#")
    if len(value) == 8:
        a = int(value[6:8], 16) / 255
        top = [int(value[i:i + 2], 16) for i in (0, 2, 4)]
        bottom = [int(under.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
        return "#" + "".join(f"{round(t * a + b * (1 - a)):02x}" for t, b in zip(top, bottom))
    return "#" + value[:6].lower()


def scope(theme, wanted):
    for rule in theme.get("tokenColors", []):
        scopes = rule.get("scope", [])
        scopes = [s.strip() for s in (scopes.split(",") if isinstance(scopes, str) else scopes)]
        if wanted in scopes and "foreground" in rule.get("settings", {}):
            return rule["settings"]["foreground"], rule["settings"].get("fontStyle", "")
    raise SystemExit(f"no colour for {wanted} in {theme.get('name')}")


def font(style, plain="EditorFont"):
    if "bold" in style:
        return "BoldEditorFont"
    if "italic" in style:
        return "ItalicEditorFont"
    return plain


def syntax(theme):
    c = theme["colors"]
    bg, fg = hex6(c["editor.background"]), hex6(c["editor.foreground"])
    sel = hex6(c["editor.selectionBackground"], bg)
    line = hex6(c.get("editor.lineHighlightBackground", c["editor.background"]), bg)
    keyword, keyword_style = scope(theme, "keyword")
    control, control_style = scope(theme, "keyword.control")
    function, _ = scope(theme, "entity.name.function")
    string, _ = scope(theme, "string")
    number, _ = scope(theme, "constant.numeric")
    comment, comment_style = scope(theme, "comment")
    error = c.get("errorForeground", c.get("editorError.foreground", "#ff0000"))
    link = c.get("textLink.foreground", function)
    return {
        "TEXT": {"foreground": fg, "insertbackground": hex6(c.get("editorCursor.foreground", fg)), "background": bg},
        "GUTTER": {"foreground": hex6(c.get("editorLineNumber.foreground", fg)), "background": bg},
        "current_line": {"background": line},
        "definition": {"foreground": hex6(function), "font": "BoldEditorFont"},
        "string": {"foreground": hex6(string)},
        "string3": {"foreground": hex6(string), "background": None, "font": "EditorFont"},
        "open_string": {"foreground": hex6(string), "background": line},
        "open_string3": {"foreground": hex6(string), "background": line, "font": "EditorFont"},
        "keyword": {"foreground": hex6(keyword), "font": font(keyword_style)},
        "builtin": {"foreground": hex6(function)},
        "number": {"foreground": hex6(number)},
        "comment": {"foreground": hex6(comment), "font": font(comment_style)},
        "welcome": {"foreground": hex6(comment)},
        "magic": {"foreground": hex6(comment)},
        "prompt": {"foreground": hex6(control), "font": font(control_style, "BoldEditorFont")},
        "stdin": {"foreground": hex6(string)},
        "stdout": {"foreground": fg},
        "stderr": {"foreground": hex6(error)},
        "value": {"foreground": hex6(function)},
        "hyperlink": {"foreground": hex6(link), "underline": True},
        "surrounding_parens": {"foreground": hex6(control), "font": "BoldEditorFont"},
        "unclosed_expression": {"background": line},
        "matched_name": {"background": sel},
        "found": {"foreground": fg, "underline": True},
        "current_found": {"foreground": fg, "background": sel},
    }


def luminance(colour):
    channels = [int(colour[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    r, g, b = (v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4 for v in channels)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    high, low = sorted((luminance(a), luminance(b)), reverse=True)
    return (high + 0.05) / (low + 0.05)


def tabs(theme):
    """text colours for the selected and hovered tabs.

    Thonny's Clean theme fills the selected tab with the border colour and a hovered one with the
    focus colour but keeps the normal text colour on both, which is white on cyan or yellow in the
    dark themes. each tab takes whichever of the theme's text and background colours reads better
    on its fill. where neither reaches 4.5:1 (a mid grey border) it takes pure black or white.
    """
    c = theme["colors"]
    bg = hex6(c["editor.background"])
    fg = hex6(c.get("foreground", c["editor.foreground"]), bg)
    border = hex6(c.get("contrastBorder", c.get("panel.border", c.get("editorGroup.border", "#808080"))), bg)
    focus = hex6(c.get("focusBorder", border), bg)
    def best(fill):
        pick = max((fg, bg), key=lambda text: contrast(text, fill))
        if contrast(pick, fill) < 4.5:
            pick = max(("#000000", "#ffffff"), key=lambda text: contrast(text, fill))
        return pick
    return {"selected": best(border), "active": best(focus)}


def ui(theme):
    c = theme["colors"]
    bg = hex6(c["editor.background"])
    border = hex6(c.get("contrastBorder", c.get("panel.border", c.get("editorGroup.border", "#808080"))), bg)
    focus = hex6(c.get("focusBorder", border), bg)
    return {
        "frame_background": hex6(c.get("activityBar.background", c.get("sideBar.background", c["editor.background"])), bg),
        "text_background": bg,
        "normal_detail": border,
        "high_detail": focus,
        "low_detail": hex6(c.get("editorIndentGuide.background1", border), bg),
        "normal_foreground": hex6(c.get("foreground", c["editor.foreground"]), bg),
        "high_foreground": hex6(c["editor.foreground"], bg),
        "low_foreground": hex6(c.get("descriptionForeground", c["editor.foreground"]), bg),
    }


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip().splitlines()[2])
    with zipfile.ZipFile(sys.argv[1]) as z:
        themes = {key: json.loads(z.read(f"extension/themes/{key}-color-theme.json")) for key in THEMES}
    entries = {name: (mode, syntax(themes[key]), ui(themes[key]), tabs(themes[key])) for key, (name, mode) in THEMES.items()}
    body = pprint.pformat(entries, width=100, sort_dicts=False)
    source = f'''"""The eight Zacess themes for Thonny, built by scripts/build-themes.py from the Zacess VS Code
themes, do not edit by hand. Each registers a syntax theme and a UI theme of the same name."""

from thonny import get_workbench
from thonny.plugins.clean_ui_themes import clean

THEMES = {body}


def load_plugin() -> None:
    workbench = get_workbench()
    for name, (mode, syntax, ui, tabs) in THEMES.items():
        workbench.add_syntax_theme(name, "Default Dark" if mode == "dark" else "Default Light", syntax)
        settings = clean(**ui)
        # the selected tab is filled with the border colour and a hovered one with the focus
        # colour, so each gets a text colour that reads on that fill
        settings["TNotebook.Tab"]["map"]["foreground"] = [("selected", tabs["selected"]), ("active", tabs["active"])]
        workbench.add_ui_theme(name, "Enhanced Clam", settings)
'''
    target = pathlib.Path(__file__).resolve().parent.parent / "shared" / "thonnycontrib" / "zacess_themes"
    target.mkdir(parents=True, exist_ok=True)
    (target / "__init__.py").write_text(source, encoding="utf-8", newline="\n")
    print(f"built {len(THEMES)} themes in {target}")


if __name__ == "__main__":
    main()
