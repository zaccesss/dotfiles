"""Builds the LTspice colour sets in shared/themes from the Zacess VS Code themes.

usage: python scripts/build-themes.py <zacess-themes .vsix>

LTspice keeps its colours in the [Colors] section of its ini file as numbered entries, each a
decimal 0x00BBGGRR value. LTspice does not name the entries, so the roles below come from the
published Dracula theme for LTspice, whose own colours show which entry is a background, a line
or text: WaveColor0, SchematicColor12 and NetlistBackgroundColor are the backgrounds, WaveColor1
is the axis and label text and WaveColor2 to WaveColor13 are the trace colours. The traces take
the theme's terminal colours, which every Zacess theme keeps distinct from each other and from
its background.
"""

import json
import pathlib
import sys
import zipfile

THEMES = {
    "zacess-deep-contrast-dark": "Zacess Deep Contrast Dark",
    "zacess-deep-contrast-light": "Zacess Deep Contrast Light",
    "zacess-high-contrast-dark": "Zacess High Contrast Dark",
    "zacess-high-contrast-light": "Zacess High Contrast Light",
    "zacess-dark": "Zacess Dark",
    "zacess-light": "Zacess Light",
    "zacess-cream": "Zacess Cream",
    "zacess-yellow-on-black": "Zacess Yellow on Black",
}

TRACES = ["terminal.ansiGreen", "terminal.ansiBlue", "terminal.ansiRed", "terminal.ansiCyan",
          "terminal.ansiMagenta", "terminal.ansiYellow", "terminal.ansiBrightGreen", "terminal.ansiBrightBlue",
          "terminal.ansiBrightRed", "terminal.ansiBrightCyan", "terminal.ansiBrightMagenta", "terminal.ansiBrightYellow"]


def rgb(value, under="#000000"):
    value = value.lstrip("#")
    r, g, b = (int(value[i:i + 2], 16) for i in (0, 2, 4))
    if len(value) == 8:
        a = int(value[6:8], 16) / 255
        u = [int(under.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)]
        r, g, b = (round(c * a + d * (1 - a)) for c, d in zip((r, g, b), u))
    return r, g, b


def ltspice(colour, under):
    r, g, b = rgb(colour, under)
    return (b << 16) | (g << 8) | r


def scope(theme, wanted):
    for rule in theme.get("tokenColors", []):
        scopes = rule.get("scope", [])
        scopes = [s.strip() for s in (scopes.split(",") if isinstance(scopes, str) else scopes)]
        if wanted in scopes and "foreground" in rule.get("settings", {}):
            return rule["settings"]["foreground"]
    raise SystemExit(f"no colour for {wanted} in {theme.get('name')}")


def build(theme):
    c = theme["colors"]
    bg, fg = c["editor.background"], c["editor.foreground"]
    keyword, control, kind = scope(theme, "keyword"), scope(theme, "keyword.control"), scope(theme, "entity.name.type")
    comment, function = scope(theme, "comment"), scope(theme, "entity.name.function")
    dim = c.get("descriptionForeground", c.get("editorLineNumber.foreground", fg))
    focus = c.get("focusBorder", control)
    selection = c["editor.selectionBackground"]
    values = {
        "Grid": dim,
        "InActiveAxis": dim,
        "WaveColor0": bg,
        "WaveColor1": fg,
    }
    for i, key in enumerate(TRACES):
        values[f"WaveColor{i + 2}"] = c.get(key, fg)
    schematic = [keyword, function, kind, keyword, selection, fg, fg, comment, function, keyword, focus, comment, bg, kind]
    for i, colour in enumerate(schematic):
        values[f"SchematicColor{i}"] = colour
    values.update({
        "NetlistNormalTextColor": fg,
        "NetlistCommentTextColor": comment,
        "NetlistDotcmdTextColor": control,
        "NetlistBackgroundColor": bg,
        "ContinuationLineColor": control,
    })
    return {key: ltspice(value, bg) for key, value in values.items()}


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip().splitlines()[2])
    with zipfile.ZipFile(sys.argv[1]) as z:
        themes = {key: json.loads(z.read(f"extension/themes/{key}-color-theme.json")) for key in THEMES}
    target = pathlib.Path(__file__).resolve().parent.parent / "shared" / "themes"
    target.mkdir(parents=True, exist_ok=True)
    for key, name in THEMES.items():
        lines = [f"; {name} for LTspice, built by scripts/build-themes.py from the Zacess VS Code theme, do not edit by hand", "[Colors]"]
        lines += [f"{k}={v}" for k, v in build(themes[key]).items()]
        (target / f"{name}.ini").write_text("\n".join(lines) + "\n", encoding="ascii", newline="\n")
    print(f"built {len(THEMES)} themes in {target}")


if __name__ == "__main__":
    main()
