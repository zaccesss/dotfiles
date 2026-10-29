#!/usr/bin/env bash
set -euo pipefail

# sets up Zacess Games on macOS and Linux: puts the newest release binary in ~/.local/bin after
# checking it against its published checksum. Safe to run again: it only downloads when the
# installed version is older. The theme needs nothing here: the games read the one zt last set.
#
#   bash apps/zacess-games/setup.sh

REPO="zacesshq/games"
BIN_DIR="$HOME/.local/bin"
export PATH="$BIN_DIR:$PATH"

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

install_games() {
    local triple tag have work archive
    if ! triple="$(target_triple)"; then
        printf 'No Zacess Games build for %s %s, skipped.\n' "$(uname -s)" "$(uname -m)"
        return 0
    fi
    # the newest vX.Y.Z tag; the release workflow attaches the binaries to it within minutes
    tag="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | sed -n 's/.*"tag_name": *"\(v[0-9.]*\)".*/\1/p' | head -1)"
    if [ -z "$tag" ]; then
        printf 'Could not find the latest Zacess Games release, skipped.\n'
        return 0
    fi
    have="$(zacess-games --version 2>/dev/null | awk '{print $2}' || true)"
    if [ "v$have" = "$tag" ]; then
        printf 'Zacess Games %s is up to date.\n' "$have"
        return 0
    fi
    work="$(mktemp -d)"
    trap 'rm -rf "$work"' RETURN
    archive="zacess-games-$tag-$triple.tar.gz"
    printf 'Installing Zacess Games %s...\n' "$tag"
    curl -fsSL -o "$work/$archive" "https://github.com/$REPO/releases/download/$tag/$archive"
    curl -fsSL -o "$work/$archive.sha256" "https://github.com/$REPO/releases/download/$tag/$archive.sha256"
    # the .sha256 file holds the digest and the archive name, as shasum -c expects
    if ! (cd "$work" && shasum -a 256 -c "$archive.sha256" >/dev/null 2>&1); then
        printf 'The Zacess Games download does not match its checksum, so it was not installed.\n'
        return 1
    fi
    tar -xzf "$work/$archive" -C "$work"
    mkdir -p "$BIN_DIR"
    install -m 755 "$(find "$work" -type f -name zacess-games | head -1)" "$BIN_DIR/zacess-games"
    printf 'Installed %s\n' "$(zacess-games --version)"
}

install_games
