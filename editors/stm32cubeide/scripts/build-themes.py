"""Builds the STM32CubeIDE themes in shared/theme from the Zacess Eclipse themes.

usage: python scripts/build-themes.py <folder with the Zacess Eclipse .epf files>

The Eclipse themes colour Java code. STM32CubeIDE edits C through CDT, which keeps its colours
under other keys, so each Java colour is copied to the C key that plays the same part. The
plain editor colours carry over as they are. the Terminal colours are written twice: under
org.eclipse.terminal.control for STM32CubeIDE 2.2 and later and under the older
org.eclipse.tm.terminal.control for 2.1.
"""

import pathlib
import sys

THEMES = [
    "Zacess Deep Contrast Dark", "Zacess Deep Contrast Light", "Zacess High Contrast Dark",
    "Zacess High Contrast Light", "Zacess Dark", "Zacess Light", "Zacess Cream",
    "Zacess Yellow on Black",
]

# CDT syntax colour key: the JDT key it takes its colour and style from. CDT has no number
# token in JDT's sense, so numbers follow JDT's number highlighting. directives and macros take
# the colour of Java's return keyword, which every theme keeps apart from functions and keywords,
# so a HAL macro never reads as a function call
TOKENS = {
    "c_default": "java_default",
    "c_keyword": "java_keyword",
    "c_type": "java_keyword",
    "c_string": "java_string",
    "c_operators": "java_operator",
    "c_braces": "java_bracket",
    "c_numbers": "semanticHighlighting.number",
    "c_single_line_comment": "java_single_line_comment",
    "c_multi_line_comment": "java_multi_line_comment",
    "c_comment_task_tag": "java_comment_task_tag",
    "pp_default": "java_default",
    "pp_directive": "java_keyword_return",
    "pp_header": "java_string",
    "asm_directive": "java_keyword",
    "asm_label": "semanticHighlighting.methodDeclarationName",
}

# Doxygen comments, CDT's counterpart to Javadoc
DOXYGEN = {
    "org.eclipse.cdt.internal.ui.text.doctools.doxygen.multi": "java_doc_default",
    "org.eclipse.cdt.internal.ui.text.doctools.doxygen.single": "java_doc_default",
    "org.eclipse.cdt.internal.ui.text.doctools.doxygen.recognizedTag": "java_doc_tag",
}

# CDT semantic highlighting: the JDT semantic highlighting it copies. a token: prefix names a
# JDT syntax colour instead
SEMANTIC = {
    "class": "class",
    "enum": "enum",
    "enumerator": "staticFinalField",
    "field": "field",
    "staticField": "staticField",
    "globalVariable": "staticField",
    "function": "staticMethodInvocation",
    "functionDeclaration": "methodDeclarationName",
    "method": "method",
    "methodDeclaration": "methodDeclarationName",
    "staticMethod": "staticMethodInvocation",
    "localVariable": "localVariable",
    "localVariableDeclaration": "localVariableDeclaration",
    "parameterVariable": "parameterVariable",
    "macroDefinition": "token:java_keyword_return",
    "macroSubstitution": "token:java_keyword_return",
    "templateParameter": "typeParameter",
    "typedef": "class",
}

STYLES = ["bold", "italic", "underline", "strikethrough"]


def read(path):
    values = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.startswith("/instance/"):
            plugin, _, rest = line[len("/instance/"):].partition("/")
            key, _, value = rest.partition("=")
            values[(plugin, key)] = value
    return values


def token(jdt, source):
    """colour and style lines for a JDT token or semantic highlighting key."""
    if source.startswith("semanticHighlighting."):
        out = {"": jdt.get(("org.eclipse.jdt.ui", source + ".color"))}
        for style in STYLES:
            out["_" + style] = jdt.get(("org.eclipse.jdt.ui", f"{source}.{style}"))
    else:
        out = {"": jdt.get(("org.eclipse.jdt.ui", source))}
        for style in STYLES:
            out["_" + style] = jdt.get(("org.eclipse.jdt.ui", f"{source}_{style}"))
    return out


def build(name, values):
    lines = [
        f"# {name} for STM32CubeIDE, built by scripts/build-themes.py from the Zacess Eclipse theme,",
        "# do not edit by hand. editor, C syntax and Terminal colours; merged by the apply scripts",
        "file_export_version=3.0",
    ]
    for (plugin, key), value in values.items():
        if plugin == "org.eclipse.ui.editors" and not key.startswith("jdt."):
            lines.append(f"/instance/{plugin}/{key}={value}")
        elif plugin == "org.eclipse.ui.workbench":
            lines.append(f"/instance/{plugin}/{key}={value}")
        elif plugin == "org.eclipse.terminal.control":
            lines.append(f"/instance/{plugin}/{key}={value}")
            lines.append(f"/instance/org.eclipse.tm.terminal.control/{key}={value}")
    for c_key, source in list(TOKENS.items()) + list(DOXYGEN.items()):
        for suffix, value in token(values, source).items():
            if value is not None:
                lines.append(f"/instance/org.eclipse.cdt.ui/{c_key}{suffix}={value}")
    for c_name, j_name in SEMANTIC.items():
        if j_name.startswith("token:"):
            parts = token(values, j_name[len("token:"):])
            if parts[""] is None:
                continue
            lines.append(f"/instance/org.eclipse.cdt.ui/semanticHighlighting.{c_name}.color={parts['']}")
            for style in STYLES:
                if parts["_" + style] is not None:
                    lines.append(f"/instance/org.eclipse.cdt.ui/semanticHighlighting.{c_name}.{style}={parts['_' + style]}")
            lines.append(f"/instance/org.eclipse.cdt.ui/semanticHighlighting.{c_name}.enabled=true")
            continue
        source = f"semanticHighlighting.{j_name}"
        color = values.get(("org.eclipse.jdt.ui", source + ".color"))
        if color is None:
            continue
        lines.append(f"/instance/org.eclipse.cdt.ui/semanticHighlighting.{c_name}.color={color}")
        for style in STYLES + ["enabled"]:
            value = values.get(("org.eclipse.jdt.ui", f"{source}.{style}"))
            if value is not None:
                lines.append(f"/instance/org.eclipse.cdt.ui/semanticHighlighting.{c_name}.{style}={value}")
    return "\n".join(lines) + "\n"


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__.strip().splitlines()[2])
    source = pathlib.Path(sys.argv[1])
    target = pathlib.Path(__file__).resolve().parent.parent / "shared" / "theme"
    target.mkdir(parents=True, exist_ok=True)
    for name in THEMES:
        values = read(source / f"{name}.epf")
        if not values:
            sys.exit(f"no preferences in {source / (name + '.epf')}")
        (target / f"{name}.epf").write_text(build(name, values), encoding="utf-8", newline="\n")
        borders = source / f"{name} borders.epf"
        if borders.exists():
            (target / borders.name).write_bytes(borders.read_bytes().replace(b"\r\n", b"\n"))
    print(f"built {len(THEMES)} themes in {target}")


if __name__ == "__main__":
    main()
