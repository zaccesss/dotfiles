# =============================================================================
# Editor and IDE launchers
# VS Code and JetBrains IDE shortcuts. JetBrains Toolbox on Linux installs
# scripts to ~/.local/share/JetBrains/Toolbox/scripts/ - ensure that path
# is on your PATH (added in 01-path.sh).
# =============================================================================

alias e="code ."
alias ec="code"

alias extls="code --list-extensions"
alias extinstall="code --install-extension"
alias extrm="code --uninstall-extension"

extdump() {
    code --list-extensions > "${1:-extensions.txt}"
    echo "Saved to ${1:-extensions.txt}"
}

extrestore() {
    local file="${1:-extensions.txt}"
    [[ -f "$file" ]] || { echo "File not found: $file"; return 1; }
    while IFS= read -r ext; do
        code --install-extension "$ext"
    done < "$file"
}

# JetBrains - Toolbox scripts are already on PATH from 01-path.sh
# These functions check for the script and print a helpful message if missing.
_jb_open() {
    local cmd="$1"; local path="${2:-.}"
    if command -v "$cmd" &>/dev/null; then
        "$cmd" "$path"
    else
        echo "$cmd not found - enable shell scripts in JetBrains Toolbox settings"
    fi
}

idea()     { _jb_open idea     "${1:-.}"; }
pycharm()  { _jb_open pycharm  "${1:-.}"; }
webstorm() { _jb_open webstorm "${1:-.}"; }
goland()   { _jb_open goland   "${1:-.}"; }
clion()    { _jb_open clion    "${1:-.}"; }
rider()    { _jb_open rider    "${1:-.}"; }
phpstorm() { _jb_open phpstorm "${1:-.}"; }
datagrip() { _jb_open datagrip "${1:-.}"; }
