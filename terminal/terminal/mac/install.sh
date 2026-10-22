#!/usr/bin/env bash
#
# installs all eight Zacess themes in every Mac terminal this repo covers and makes Zacess Deep
# Contrast Dark the default. Safe to run again: each step checks what is already in place first.
# Terminal.app and iTerm2 are set up always; Kitty and Alacritty only when their config folder
# already exists. Nothing follows the system appearance here: `zt auto` in the dotfiles turns
# that on, using the helper this script builds from terminal-app/terminal-appearance.swift.

set -Eeuo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HERE
readonly AGENT_BIN="${HOME}/.local/bin/terminal-appearance"
readonly DEFAULT_THEME="Zacess Deep Contrast Dark"

info() { printf '[INFO] %s\n' "$1"; }
ok() { printf '[ OK ] %s\n' "$1"; }
warn() { printf '[WARN] %s\n' "$1" >&2; }

link() {
    local source="$1" target="$2"
    mkdir -p "$(dirname "$target")"
    if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
        return
    fi
    if [[ -e "$target" && ! -L "$target" ]]; then
        mv "$target" "${target}.backup.$(date +%Y%m%d%H%M%S)"
    fi
    ln -sfn "$source" "$target"
    info "Linked ${target}"
}

running() { pgrep -x "$1" >/dev/null 2>&1; }

terminal_app() {
    local file name
    for file in "${HERE}"/terminal-app/*.terminal; do
        name="$(basename "$file" .terminal)"
        if defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -q "\"${name}\" ="; then
            continue
        fi
        if running Terminal; then
            # importing through the app opens one window per profile; the preferences file is
            # only safe to edit while Terminal.app is closed
            open -g "$file"
        else
            /usr/bin/python3 - "$file" <<'PY'
import plistlib, subprocess, sys
profile = plistlib.load(open(sys.argv[1], "rb"))
prefs = plistlib.loads(subprocess.run(["defaults", "export", "com.apple.Terminal", "-"],
                                      capture_output=True, check=True).stdout)
prefs.setdefault("Window Settings", {})[profile["name"]] = profile
subprocess.run(["defaults", "import", "com.apple.Terminal", "-"], input=plistlib.dumps(prefs), check=True)
PY
        fi
        info "Added the ${name} profile to Terminal.app"
    done
    if [[ "$(defaults read com.apple.Terminal "Default Window Settings" 2>/dev/null || true)" != "$DEFAULT_THEME" ]]; then
        if running Terminal; then
            osascript -e "tell application \"Terminal\" to set default settings to settings set \"${DEFAULT_THEME}\"" \
                -e "tell application \"Terminal\" to set startup settings to settings set \"${DEFAULT_THEME}\"" >/dev/null
        else
            defaults write com.apple.Terminal "Default Window Settings" -string "$DEFAULT_THEME"
            defaults write com.apple.Terminal "Startup Window Settings" -string "$DEFAULT_THEME"
        fi
        info "Made ${DEFAULT_THEME} Terminal.app's default profile"
    fi
}

# Terminal.app has no light and dark pair of its own, so `zt auto` runs this helper as a login
# agent; it is built here so that command never needs a compiler of its own
appearance_helper() {
    local source="${HERE}/terminal-app/terminal-appearance.swift"
    mkdir -p "$(dirname "$AGENT_BIN")"
    if [[ ! -x "$AGENT_BIN" || "$source" -nt "$AGENT_BIN" ]]; then
        swiftc -O "$source" -o "$AGENT_BIN"
        info "Built ${AGENT_BIN}"
    fi
}

iterm2() {
    local profiles="${HOME}/Library/Application Support/iTerm2/DynamicProfiles"
    # the earlier single-profile file is replaced by zacess.json, which keeps its Guid
    if [[ -L "${profiles}/high-contrast.json" ]]; then
        rm "${profiles}/high-contrast.json"
    fi
    link "${HERE}/iterm2/zacess.json" "${profiles}/zacess.json"
    local guid
    guid="$(/usr/bin/python3 -c 'import json,sys; print(next(p["Guid"] for p in json.load(open(sys.argv[1]))["Profiles"] if p["Name"] == sys.argv[2]))' "${HERE}/iterm2/zacess.json" "$DEFAULT_THEME")"
    if [[ "$(defaults read com.googlecode.iterm2 "Default Bookmark Guid" 2>/dev/null || true)" == "$guid" ]]; then
        return
    fi
    if running iTerm2; then
        warn "iTerm2 is open: pick ${DEFAULT_THEME} under Settings > Profiles > Other Actions > Set as Default"
    else
        defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$guid"
        info "Made ${DEFAULT_THEME} the default iTerm2 profile"
    fi
}

optional_apps() {
    local file
    if [[ -d "${HOME}/.config/kitty" ]]; then
        for file in "${HERE}"/kitty/zacess-*.conf; do
            link "$file" "${HOME}/.config/kitty/$(basename "$file")"
        done
    fi
    if [[ -d "${HOME}/.config/alacritty" ]]; then
        for file in "${HERE}"/alacritty/zacess-*.toml; do
            link "$file" "${HOME}/.config/alacritty/$(basename "$file")"
        done
    fi
}

terminal_app
appearance_helper
iterm2
optional_apps
ok "All eight Zacess themes installed, ${DEFAULT_THEME} is the default"
