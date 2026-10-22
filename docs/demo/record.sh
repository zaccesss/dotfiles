#!/usr/bin/env bash
# re-records the screenshots and clips in this folder, once in Zacess Deep Contrast Dark and once
# in Zacess Deep Contrast Light, from the scene scripts (*.tape) next to this file.
#   docs/demo/record.sh           every scene
#   docs/demo/record.sh tmux      one scene, by its file name
# a scene's clip is saved as <scene>-<mode>.gif and each Screenshot it takes as <name>-<mode>.webp.
# needs vhs, gifsicle and cwebp: brew install vhs gifsicle webp
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."
DIR=docs/demo
DEMO=/tmp/demo

if [[ $# -eq 0 ]]; then
    for tape in "$DIR"/*.tape; do
        name="$(basename "$tape" .tape)"
        [[ "$name" == theme-* ]] || set -- "$@" "$name"
    done
fi

for scene in "$@"; do
    for mode in dark light; do
        echo "Recording $scene ($mode)"
        bash "$DIR/setup.sh" "$mode" >/dev/null
        printf 'Output "%s"\nSource "%s"\nSource "%s"\n' \
            "$DEMO/out/$scene.gif" "$DIR/theme-$mode.tape" "$DIR/$scene.tape" > "$DEMO/run.tape"
        vhs -q "$DEMO/run.tape"
        gifsicle -O3 --lossy=40 "$DEMO/out/$scene.gif" -o "$DIR/$scene-$mode.gif"
        for shot in "$DEMO"/shots/*.png; do
            [[ -e "$shot" ]] || continue
            cwebp -quiet -q 90 "$shot" -o "$DIR/$(basename "$shot" .png)-$mode.webp"
        done
    done
done
