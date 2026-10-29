#!/usr/bin/env bash
set -euo pipefail

# installs Menu11 - Next (GPL-2.0+, github.com/Eisteed/menu-11-next) for this user. Plasma's own Kickoff
# opens from the left edge of the screen and has no setting to centre it; Menu11 opens centred just above
# the taskbar, as the Windows 11 start menu does. The release is pinned to its tag's commit, so a moved
# tag is refused instead of installed. taskbar.js keeps Kickoff when this has not run.

REPO=https://github.com/Eisteed/menu-11-next.git
TAG=1.3
COMMIT=7d85ef7f04f6fd4ac370a14815e55a290d38fec5

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
git clone --quiet --depth 1 --branch "$TAG" "$REPO" "$work/menu11" 2>/dev/null
if [ "$(git -C "$work/menu11" rev-parse HEAD)" != "$COMMIT" ]; then
    printf 'Menu11 %s is not the pinned commit, so it was not installed.\n' "$TAG"
    exit 1
fi

if kpackagetool6 -t Plasma/Applet -s menu.11.next >/dev/null 2>&1; then
    kpackagetool6 -t Plasma/Applet -u "$work/menu11" >/dev/null
else
    kpackagetool6 -t Plasma/Applet -i "$work/menu11" >/dev/null
fi
