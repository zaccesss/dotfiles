#!/usr/bin/env bash
set -euo pipefail

# sets up Zacess Scenes on macOS and Linux: puts the newest release binary in ~/.local/bin after
# checking it against its published checksum, installs bacon for watch mode with cargo and links
# scenes.toml into the config folder. Safe to run again. The theme needs nothing here: Scenes reads
# the one zt last set.
#
#   bash apps/zacess-scenes/setup.sh            install or update, then link the config
#   bash apps/zacess-scenes/setup.sh --link     only link the config

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="zacesshq/scenes"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zacess"
export PATH="$BIN_DIR:$HOME/.cargo/bin:$PATH"

link_config() {
    mkdir -p "$CONFIG_DIR/scenes"
    local target="$CONFIG_DIR/scenes.toml"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        # a file made by hand goes to the Bin rather than being overwritten
        local bin="$HOME/.Trash"
        [ -d "$bin" ] || bin="${XDG_DATA_HOME:-$HOME/.local/share}/Trash/files"
        mkdir -p "$bin"
        mv "$target" "$bin/scenes.toml.$(date +%Y%m%d%H%M%S)"
        printf 'Moved the old %s to the Bin.\n' "$target"
    fi
    ln -sfn "$HERE/scenes.toml" "$target"
    printf 'Linked %s\n' "$target"
}

# the release target for this machine, as the release files name it
target_triple() {
    local arch
    arch="$(uname -m)"
    case "$(uname -s)-$arch" in
        Darwin-arm64) echo aarch64-apple-darwin ;;
        Darwin-x86_64) echo x86_64-apple-darwin ;;
        Linux-x86_64) echo x86_64-unknown-linux-musl ;;
        Linux-aarch64 | Linux-arm64) echo aarch64-unknown-linux-musl ;;
        *) return 1 ;;
    esac
}

install_scenes() {
    local triple tag have work archive
    if ! triple="$(target_triple)"; then
        printf 'No Zacess Scenes build for %s %s, skipped.\n' "$(uname -s)" "$(uname -m)"
        return 0
    fi
    # the newest vX.Y.Z tag; the release workflow attaches the binaries to it within minutes
    tag="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | sed -n 's/.*"tag_name": *"\(v[0-9.]*\)".*/\1/p' | head -1)"
    if [ -z "$tag" ]; then
        printf 'Could not find the latest Zacess Scenes release, skipped.\n'
        return 0
    fi
    have="$(zacess-scenes --version 2>/dev/null | awk '{print $2}' || true)"
    if [ "v$have" = "$tag" ]; then
        printf 'Zacess Scenes %s is up to date.\n' "$have"
        return 0
    fi
    work="$(mktemp -d)"
    trap 'rm -rf "$work"' RETURN
    archive="zacess-scenes-$tag-$triple.tar.gz"
    printf 'Installing Zacess Scenes %s...\n' "$tag"
    curl -fsSL -o "$work/$archive" "https://github.com/$REPO/releases/download/$tag/$archive"
    curl -fsSL -o "$work/$archive.sha256" "https://github.com/$REPO/releases/download/$tag/$archive.sha256"
    # the .sha256 file holds the digest and the archive name, as shasum -c expects
    if ! (cd "$work" && shasum -a 256 -c "$archive.sha256" >/dev/null 2>&1); then
        printf 'The Zacess Scenes download does not match its checksum, so it was not installed.\n'
        return 1
    fi
    tar -xzf "$work/$archive" -C "$work"
    mkdir -p "$BIN_DIR"
    install -m 755 "$(find "$work" -type f -name zacess-scenes | head -1)" "$BIN_DIR/zacess-scenes"
    printf 'Installed %s\n' "$(zacess-scenes --version)"
}

install_bacon() {
    if command -v bacon >/dev/null 2>&1; then
        printf 'bacon %s is installed.\n' "$(bacon --version | awk '{print $2}')"
        return 0
    fi
    if ! command -v cargo >/dev/null 2>&1; then
        printf 'cargo is not installed, so bacon (for zacess-scenes watch) was skipped.\n'
        return 0
    fi
    cargo install --locked bacon
}

if [ "${1:-}" != "--link" ]; then
    install_scenes
    install_bacon
fi
link_config
