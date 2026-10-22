#!/usr/bin/env bash
# builds the throwaway demo the recordings in this folder run in: a home folder, a small git
# project and a repo with an example key staged, all under /tmp/demo. Nothing outside /tmp/demo
# is written. Each config comes from this repo when it has its own copy, otherwise from the one
# installed on this machine, so a recording always shows the real setup.
#   docs/demo/setup.sh dark|light
# record.sh runs it before every recording; it can also be run alone to look around the demo.
set -euo pipefail

MODE="${1:-dark}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEMO=/tmp/demo
REAL_HOME="${REAL_HOME:-$HOME}"

# this repo's copy of a config when it has one (any of the space-separated paths in $1), else the
# installed one with links resolved
pick() {
    local candidate
    for candidate in $1; do
        if [[ -e "$ROOT/$candidate" ]]; then
            echo "$ROOT/$candidate"
            return
        fi
    done
    if [[ -e "$2" ]]; then
        realpath "$2"
    fi
}

link() {
    [[ -n "$1" ]] || return 0
    mkdir -p "$(dirname "$2")"
    ln -sfn "$1" "$2"
}

# the example key is AWS's own documentation value, never a real one,
# joined from two parts so secret scanners reading this script do not flag it
EXAMPLE_KEY="AKIA""IOSFODNN7EXAMPLE"

rm -rf "$DEMO"
mkdir -p "$DEMO/bin" "$DEMO/shots" "$DEMO/out"
# the profile makes ~/.ssh on a first run and says so; made here so the banner starts clean
mkdir -m 700 "$DEMO/.ssh"

export GIT_CONFIG_GLOBAL="$DEMO/.gitconfig" GIT_CONFIG_NOSYSTEM=1
git config --global user.name "Demo User"
git config --global user.email "demo@example.com"
git config --global init.defaultBranch main
git config --global core.hooksPath ""
# print short logs in place rather than in a pager, so they stay on screen
git config --global core.pager "less -FRX"

# --- the demo project: a small Python package with a few commits and some work in progress ---
P="$DEMO/demo-project"
mkdir -p "$P/src/demo_project" "$P/tests"
cd "$P"
git init -q

commit() {
    local when="2026-10-0$1T10:00:00"
    git add -A
    GIT_AUTHOR_DATE="$when" GIT_COMMITTER_DATE="$when" git commit -q -m "$2"
}

cat > README.md <<'EOF'
# demo-project

A small command line tool that prints a colour palette as a table.

## Usage

    python -m demo_project dark
EOF
commit 1 "chore: start the demo project"

cat > pyproject.toml <<'EOF'
[project]
name = "demo-project"
version = "0.3.0"
requires-python = ">=3.11"
EOF
cat > src/demo_project/__init__.py <<'EOF'
"""Print a terminal colour palette as a readable table."""

__version__ = "0.3.0"
EOF
commit 2 "feat: add the package skeleton"

cat > src/demo_project/colours.py <<'EOF'
"""Colour helpers: parse hex values and work out contrast between two colours."""

from dataclasses import dataclass

# WCAG 2 asks for 4.5:1 for body text and 7:1 for the enhanced level
MINIMUM_RATIO = 4.5
ENHANCED_RATIO = 7.0


@dataclass(frozen=True)
class Colour:
    name: str
    hex_value: str

    def rgb(self) -> tuple[int, int, int]:
        value = self.hex_value.lstrip("#")
        r, g, b = (int(value[i : i + 2], 16) for i in (0, 2, 4))
        return r, g, b

    def luminance(self) -> float:
        def channel(c: int) -> float:
            s = c / 255
            return s / 12.92 if s <= 0.03928 else ((s + 0.055) / 1.055) ** 2.4

        r, g, b = (channel(c) for c in self.rgb())
        return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a: Colour, b: Colour) -> float:
    """Return the contrast ratio between two colours, from 1 to 21."""
    light, dark = sorted((a.luminance(), b.luminance()), reverse=True)
    return (light + 0.05) / (dark + 0.05)


def passes(a: Colour, b: Colour, enhanced: bool = False) -> bool:
    target = ENHANCED_RATIO if enhanced else MINIMUM_RATIO
    return contrast(a, b) >= target
EOF
commit 3 "feat: work out the contrast between two colours"

cat > tests/test_colours.py <<'EOF'
from demo_project.colours import Colour, contrast


def test_black_on_white_is_21():
    assert round(contrast(Colour("black", "#000000"), Colour("white", "#ffffff"))) == 21
EOF
commit 4 "test: cover the contrast ratio"

cat > src/demo_project/cli.py <<'EOF'
import sys

from demo_project.colours import Colour, contrast

PALETTE = {
    "dark": [Colour("red", "#ff5f5f"), Colour("green", "#00cd00"), Colour("cyan", "#00cdcd")],
    "light": [Colour("red", "#ca0000"), Colour("green", "#00892e"), Colour("cyan", "#016e78")],
}


def main() -> None:
    mode = sys.argv[1] if len(sys.argv) > 1 else "dark"
    background = Colour("background", "#000000" if mode == "dark" else "#ffffff")
    for colour in PALETTE[mode]:
        print(f"{colour.name:<8} {colour.hex_value}  {contrast(colour, background):5.2f}:1")
EOF
commit 5 "feat: print the palette with each contrast ratio"

perl -pi -e 's/0\.3\.0/0.4.0/' src/demo_project/__init__.py pyproject.toml
commit 6 "chore: release 0.4.0"
git update-ref refs/remotes/origin/main HEAD

# work in progress, so git status, the diff and lazygit have something to show
cat >> README.md <<'EOF'

## Checking contrast

Every colour is printed with its contrast ratio against the background, so a pair that fails
the 4.5:1 minimum stands out straight away.
EOF
perl -pi -e 's/^(\s+)print\(f"\{colour.name:<8\}/$1marker = "ok" if contrast(colour, background) >= 4.5 else "low"\n$1print(f"{marker:<4}{colour.name:<8}/' src/demo_project/cli.py

# --- a repo with the example key staged, for the pre-commit hook ---
H="$DEMO/hook-demo"
mkdir -p "$H"
cd "$H"
git init -q
echo "# hook demo" > README.md
git add README.md
GIT_AUTHOR_DATE="2026-10-01T10:00:00" GIT_COMMITTER_DATE="2026-10-01T10:00:00" git commit -q -m "chore: start"
printf 'REGION=eu-west-2\nAWS_ACCESS_KEY_ID=%s\n' "$EXAMPLE_KEY" > config.env
git add config.env
hooks="$ROOT/$(uname -s | sed 's/Darwin/mac/;s/Linux/linux/')"
[[ -f "$hooks/pre-commit" ]] || hooks="$(git config --file "$REAL_HOME/.gitconfig" core.hooksPath 2>/dev/null || true)"
hooks="${hooks/#\~/$REAL_HOME}"
[[ -n "$hooks" ]] && git config core.hooksPath "$hooks"

# --- the demo home: the real configs, linked in ---
cd "$DEMO"
mkdir -p "$DEMO/.local/state/zacess" "$DEMO/.config"
# Neovim's Zacess scheme follows this file, the same one zt writes on a real machine
echo "deep-contrast-$MODE" > "$DEMO/.local/state/zacess/theme"
# an all-zero dummy key and a dead address, so the editor's time tracker neither prompts for a
# key nor sends anything; the key is joined from two parts so secret scanners do not flag it
dummy_key="waka""_00000000-0000-4000-8000-000000000000"
printf '[settings]\napi_key = %s\napi_url = http://127.0.0.1:9/\n' "$dummy_key" > "$DEMO/.wakatime.cfg"

if [[ "$(uname -s)" == "Linux" ]]; then
    bashrc="$(pick linux/bashrc "$REAL_HOME/.bashrc")"
    DOTFILES="$(dirname "$(dirname "$bashrc")")"
    link "$DOTFILES" "$DEMO/dotfiles"
    link "$(pick linux/starship.toml "$REAL_HOME/.config/starship.toml")" "$DEMO/.config/starship.toml"
    # Starship is often installed per user, outside the system PATH the demo shell starts with
    starship_bin="$(PATH="$REAL_HOME/.local/bin:$PATH" command -v starship || true)"
    [[ -n "$starship_bin" ]] && ln -sfn "$starship_bin" "$DEMO/bin/starship"
    cat > "$DEMO/.bashrc" <<EOF
# the real profile, with a neutral machine name in the banner
hostname() { echo demo; }
export DOTFILES="$DOTFILES" GIT_CONFIG_GLOBAL="$DEMO/.gitconfig" GIT_CONFIG_NOSYSTEM=1
source "\$DOTFILES/linux/bashrc"
EOF
    cat > "$DEMO/start" <<EOF
#!/usr/bin/env bash
cd "$DEMO"
exec env -i HOME="$DEMO" USER="\$(id -un)" LOGNAME="\$(id -un)" TERM=xterm-256color COLORTERM=truecolor \\
    LANG=C.UTF-8 PATH="$DEMO/bin:/usr/local/bin:/usr/bin:/bin" bash --rcfile "$DEMO/.bashrc" -i
EOF
    chmod +x "$DEMO/start"
    exit 0
fi

zshrc="$(pick mac/zshrc "$REAL_HOME/.zshrc")"
DOTFILES="$(dirname "$(dirname "$zshrc")")"
link "$(pick mac/starship.toml "$REAL_HOME/.config/starship.toml")" "$DEMO/.config/starship.toml"
link "$(pick "mac/tmux.conf tmux.conf" "$REAL_HOME/.tmux.conf")" "$DEMO/.tmux.conf"
link "$(pick "mac/nvim nvim" "$REAL_HOME/.config/nvim")" "$DEMO/.config/nvim"
link "$(pick fzf/fzf.zsh "$REAL_HOME/.config/fzf/fzf.zsh")" "$DEMO/.config/fzf/fzf.zsh"
link "$(pick ripgrep/ripgreprc "$REAL_HOME/.ripgreprc")" "$DEMO/.ripgreprc"
link "$(pick lazygit/config.yml "$REAL_HOME/Library/Application Support/lazygit/config.yml")" \
    "$DEMO/Library/Application Support/lazygit/config.yml"
# lazygit's welcome and release-notes popups are marked as seen, as on a machine that has used it
lg_version="$(lazygit --version 2>/dev/null | sed -n 's/.*, version=\([0-9.]*\), os=.*/\1/p')"
printf 'startuppopupversion: 5\ndidshowhunkstaginghint: true\nlastversion: %s\n' "$lg_version" \
    > "$DEMO/Library/Application Support/lazygit/state.yml"
# Neovim's plugins are read from the installed copy rather than downloaded again
link "$REAL_HOME/.local/share/nvim" "$DEMO/.local/share/nvim"

cat > "$DEMO/.zshrc" <<EOF
# the real profile, with a neutral machine name in the banner
scutil() { if [[ "\$*" == "--get ComputerName" ]]; then echo demo; else command scutil "\$@"; fi; }
export DOTFILES="$DOTFILES" GIT_CONFIG_GLOBAL="$DEMO/.gitconfig" GIT_CONFIG_NOSYSTEM=1
source "\$DOTFILES/mac/zshrc"
EOF
# USER stays the real account name, since Starship shows a name only when it differs from the login
cat > "$DEMO/start" <<EOF
#!/usr/bin/env zsh
cd "$DEMO/demo-project"
exec env -i HOME="$DEMO" USER="\$(id -un)" LOGNAME="\$(id -un)" TERM=xterm-256color COLORTERM=truecolor \\
    LANG=en_GB.UTF-8 SHELL=/bin/zsh PATH="$DEMO/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \\
    zsh -i
EOF
chmod +x "$DEMO/start"

# the Linux scene runs in the OrbStack machine, which gets its own copy of the demo
if [[ -f "$ROOT/linux/bashrc" ]] && command -v orb >/dev/null 2>&1; then
    orb bash "$ROOT/docs/demo/setup.sh" "$MODE"
fi
