"""Builds the eight Zacess themes for Processing 4 in shared/themes from the Zacess palette.

usage: python3 scripts/build-themes.py [palette.json]

With no argument the palette is downloaded from the pinned Zacess Themes release and checked
against its digest. A local palette file (a clone of zacesshq/themes) can be passed instead.

Processing reads a theme as plain key = value lines. It loads its own lib/theme/theme.txt first and
then a theme.txt in the sketchbook folder on top, so every colour key is written here and the
font keys are left to Processing. Token styles only know plain and bold: italic comments and
parameters from the palette come out plain.
"""

import hashlib
import json
import pathlib
import sys
import urllib.request

PALETTE_URL = "https://raw.githubusercontent.com/zacesshq/themes/v0.4.0/palette/zacess.json"
PALETTE_SHA256 = "fd45d887c54703e639fe34e83dbc146c9f56d985fcaf9a0fb3a9233db9914c9c"
ORDER = ["deep-contrast-dark", "deep-contrast-light", "high-contrast-dark", "high-contrast-light",
         "dark", "light", "cream", "yellow-on-black"]
# the first line marks a file as one of these themes, so the apply scripts only ever replace a
# sketchbook theme.txt that they wrote themselves
MARKER = "# Zacess theme for Processing"


def load_palette(argv):
    if len(argv) > 1:
        return json.loads(pathlib.Path(argv[1]).read_text(encoding="utf-8"))
    data = urllib.request.urlopen(PALETTE_URL, timeout=60).read()
    if hashlib.sha256(data).hexdigest() != PALETTE_SHA256:
        sys.exit("the downloaded palette does not match its pinned digest")
    return json.loads(data)


def build(theme):
    ui, syn = theme["ui"], theme["syntax"]
    u = {k: v.upper() for k, v in ui.items()}
    s = {k: v.upper() for k, v in syn.items()}
    bg, fg, chrome = u["background"], s["foreground"], u["surfaceAlt"]
    accent, on_accent, muted, border = u["accent"], u["accentForeground"], u["muted"], u["border"]

    def style(token, bold=None):
        weight = "bold" if (bold if bold is not None else "bold" in palette_styles[token]) else "plain"
        return f"{s[token]},{weight}"

    sections = [
        ("Look and feel", [
            ("laf.mode", theme["appearance"]),
            ("laf.accent.color", accent),
            ("label.link.color", u["link"]),
        ]),
        ("Toolbar", [
            ("toolbar.rollover.color", fg),
            ("toolbar.gradient.top", chrome),
            ("toolbar.gradient.bottom", chrome),
            ("mode.title.color", fg),
            ("mode.background.color", chrome),
            ("mode.outline.color", border),
            ("mode.popup.enabled.fgcolor", fg),
            ("mode.popup.enabled.bgcolor", bg),
            ("mode.popup.disabled.fgcolor", muted),
            ("mode.popup.disabled.bgcolor", bg),
            ("mode.popup.selected.fgcolor", on_accent),
            ("mode.popup.selected.bgcolor", accent),
        ] + [
            (f"toolbar.button.{group}{state}.{part}", value)
            for group in ("", "debug.")
            for state, field, glyph, stroke in (
                ("disabled", chrome, muted, "none"),
                ("enabled", bg, accent, border),
                ("pressed", accent, on_accent, fg),
                ("rollover", u["selection"], fg, border),
                ("selected", accent, on_accent, "none"),
            )
            for part, value in (("field", field), ("glyph", glyph), ("stroke", stroke))
        ]),
        ("Status bar", [
            ("status.notice.fgcolor", fg),
            ("status.notice.bgcolor", chrome),
            ("status.error.fgcolor", on_accent if theme["appearance"] == "light" else bg),
            ("status.error.bgcolor", u["error"]),
            ("status.warning.fgcolor", on_accent if theme["appearance"] == "light" else bg),
            ("status.warning.bgcolor", u["warning"]),
        ]),
        ("Tabs above the editor", [
            ("header.text.selected.color", fg),
            ("header.text.unselected.color", muted),
            ("header.tab.arrow.color", muted),
            ("header.tab.selected.color", bg),
            ("header.tab.unselected.color", chrome),
            ("header.tab.modified.color", accent),
            ("header.gradient.top", chrome),
            ("header.gradient.bottom", chrome),
        ]),
        ("Tabs below the editor", [
            ("footer.text.selected.color", fg),
            ("footer.text.enabled.color", muted),
            ("footer.icon.selected.color", fg),
            ("footer.icon.enabled.color", muted),
            ("footer.gradient.top", chrome),
            ("footer.gradient.bottom", chrome),
            ("footer.tab.selected.color", bg),
            ("footer.tab.enabled.color", chrome),
            ("footer.updates.text.color", on_accent),
            ("footer.updates.indicator.field.color", accent),
            ("footer.updates.indicator.text.color", on_accent),
        ]),
        ("Console", [
            ("console.color", bg),
            ("console.output.color", fg),
            ("console.error.color", u["error"]),
            ("console.scrollbar.thumb.enabled.color", border),
            ("console.scrollbar.thumb.rollover.color", muted),
            ("console.scrollbar.thumb.pressed.color", muted),
            ("console.scrollbar.color", chrome),
        ]),
        ("Editor", [
            ("editor.fgcolor", fg),
            ("editor.bgcolor", bg),
            ("editor.gradient.top", chrome),
            ("editor.gradient.bottom", chrome),
            ("editor.line.highlight", "true"),
            ("editor.line.highlight.color", u["lineHighlight"]),
            ("editor.caret.color", u["cursor"]),
            ("editor.selection.color", u["selection"]),
            ("editor.eol_markers", "false"),
            ("editor.eol_markers.color", u["whitespace"]),
            ("editor.bracket.highlight", "true"),
            ("editor.bracket.highlight.color", accent),
            ("editor.scrollbar.thumb.enabled.color", border),
            ("editor.scrollbar.thumb.rollover.color", muted),
            ("editor.scrollbar.thumb.pressed.color", muted),
            ("editor.scrollbar.color", chrome),
            ("editor.gutter.text.color", u["lineNumberActive"]),
            # line numbers keep their full colour: Processing's default fades them to 40 percent
            ("editor.gutter.text.active.alpha", "100"),
            ("editor.gutter.text.inactive.alpha", "100"),
            ("editor.gutter.highlight.color", u["lineHighlight"]),
            ("editor.error.underline.color", u["error"]),
            ("editor.warning.underline.color", u["warning"]),
            ("editor.column.error.color", u["error"]),
            ("editor.column.warning.color", u["warning"]),
        ]),
        ("Errors table", [
            ("errors.header.bgcolor", chrome),
            ("errors.header.fgcolor", fg),
            ("errors.bgcolor", bg),
            ("errors.row.fgcolor", fg),
            ("errors.row.bgcolor", bg),
            ("errors.selection.fgcolor", fg),
            ("errors.selection.bgcolor", u["selection"]),
            ("errors.selection.error.bgcolor", u["selection"]),
            ("errors.selection.warning.bgcolor", u["selection"]),
            ("errors.indicator.error.color", u["error"]),
            ("errors.indicator.warning.color", u["warning"]),
        ]),
        ("Contribution Manager", [
            ("manager.tab.selected.color", bg),
            ("manager.tab.unselected.color", chrome),
            ("manager.tab.text.selected.color", fg),
            ("manager.tab.text.unselected.color", muted),
            ("manager.tab.gradient.top", chrome),
            ("manager.tab.gradient.bottom", chrome),
            ("manager.tab.background", chrome),
            ("manager.categories.enabled.fgcolor", fg),
            ("manager.categories.enabled.bgcolor", bg),
            ("manager.categories.disabled.fgcolor", muted),
            ("manager.categories.disabled.bgcolor", bg),
            ("manager.categories.selected.fgcolor", on_accent),
            ("manager.categories.selected.bgcolor", accent),
            ("manager.error.close.icon.color", fg),
            ("manager.scrollbar.thumb.enabled.color", border),
            ("manager.scrollbar.thumb.rollover.color", muted),
            ("manager.scrollbar.thumb.pressed.color", muted),
            ("manager.scrollbar.color", chrome),
            ("manager.search.text.color", fg),
            ("manager.search.icon.color", muted),
            ("manager.search.background.color", bg),
            ("manager.search.caret.color", u["cursor"]),
            ("manager.search.placeholder.color", muted),
            ("manager.search.selection.text.color", fg),
            ("manager.search.selection.background.color", u["selection"]),
            ("manager.list.background.color", bg),
            ("manager.list.header.fgcolor", fg),
            ("manager.list.header.bgcolor", chrome),
            ("manager.list.section.color", bg),
            ("manager.list.selection.color", u["selection"]),
            ("manager.list.icon.color", accent),
            ("manager.list.text.color", fg),
            ("manager.list.foundation.color", accent),
            ("manager.list.incompatible.selection.color", u["selection"]),
            ("manager.list.incompatible.text.color", muted),
            ("manager.panel.background.color", chrome),
            ("manager.panel.text.color", fg),
            ("manager.panel.link.color", u["link"]),
            ("manager.panel.foundation.color", accent),
            ("manager.button.enabled.background.color", accent),
            ("manager.button.enabled.text.color", on_accent),
            ("manager.button.enabled.icon.color", on_accent),
            ("manager.button.pressed.background.color", fg),
            ("manager.button.pressed.text.color", bg),
            ("manager.button.pressed.icon.color", bg),
            ("manager.button.disabled.background.color", chrome),
            ("manager.button.disabled.text.color", muted),
            ("manager.button.disabled.icon.color", muted),
            ("manager.progress.complete.fgcolor", on_accent),
            ("manager.progress.complete.bgcolor", accent),
            ("manager.progress.incomplete.fgcolor", fg),
            ("manager.progress.incomplete.bgcolor", chrome),
        ]),
        # the theme selector is the same in every theme Processing ships, so it is left alone
        ("Syntax: Java keywords, control flow, the API, types and constants", [
            ("editor.token.function1.style", style("function")),
            ("editor.token.function2.style", style("function")),
            ("editor.token.function3.style", style("control")),
            ("editor.token.function4.style", style("function", bold=True)),
            ("editor.token.keyword1.style", style("keyword")),
            ("editor.token.keyword2.style", style("property")),
            ("editor.token.keyword3.style", style("control")),
            ("editor.token.keyword4.style", style("number")),
            ("editor.token.keyword5.style", style("type")),
            ("editor.token.keyword6.style", style("control")),
            ("editor.token.literal1.style", style("string")),
            ("editor.token.literal2.style", style("number")),
            ("editor.token.operator.style", style("operator")),
            ("editor.token.label.style", style("attribute", bold=True)),
            ("editor.token.comment1.style", style("comment")),
            ("editor.token.comment2.style", style("comment")),
            ("editor.token.invalid.style", style("invalid", bold=True)),
            ("editor.completion.class.color", s["type"]),
            ("editor.completion.field.color", s["property"]),
            ("editor.completion.local.color", s["variable"]),
            ("editor.completion.method.color", s["function"]),
        ]),
    ]
    lines = [f"{MARKER}: {theme['name']}",
             "# built by scripts/build-themes.py from the Zacess palette, do not edit by hand", ""]
    for title, pairs in sections:
        lines.append(f"## {title}")
        lines += [f"{key} = {value}" for key, value in pairs]
        lines.append("")
    return "\n".join(lines)


def main():
    global palette_styles
    palette = load_palette(sys.argv)
    palette_styles = {name: token["style"] for name, token in palette["tokens"].items()}
    themes = {t["id"]: t for t in palette["themes"]}
    if sorted(themes) != sorted(ORDER):
        sys.exit("the palette does not hold the eight expected Zacess themes")
    target = pathlib.Path(__file__).resolve().parent.parent / "shared" / "themes"
    target.mkdir(parents=True, exist_ok=True)
    for theme_id in ORDER:
        (target / f"zacess-{theme_id}.txt").write_text(build(themes[theme_id]), encoding="utf-8", newline="\n")
    print(f"built {len(ORDER)} themes from palette {palette['version']} in {target}")


palette_styles = {}

if __name__ == "__main__":
    main()
