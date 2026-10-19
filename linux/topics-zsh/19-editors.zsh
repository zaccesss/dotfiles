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

# JetBrains - prefer manual installations under ~/dev/tools/jetbrains,
# then fall back to JetBrains Toolbox shell scripts on PATH.
_jb_open() {
    local cmd="$1"
    local path="${2:-.}"
    local manual=""

    case "$cmd" in
        idea)     manual="$HOME/dev/tools/jetbrains/intellij/bin/idea.sh" ;;
        pycharm)  manual="$HOME/dev/tools/jetbrains/pycharm/bin/pycharm.sh" ;;
        webstorm) manual="$HOME/dev/tools/jetbrains/webstorm/bin/webstorm.sh" ;;
        clion)    manual="$HOME/dev/tools/jetbrains/clion/bin/clion.sh" ;;
        goland)   manual="$HOME/dev/tools/jetbrains/goland/bin/goland.sh" ;;
        rider)    manual="$HOME/dev/tools/jetbrains/rider/bin/rider.sh" ;;
        phpstorm) manual="$HOME/dev/tools/jetbrains/phpstorm/bin/phpstorm.sh" ;;
        datagrip) manual="$HOME/dev/tools/jetbrains/datagrip/bin/datagrip.sh" ;;
    esac

    if [[ -n "$manual" && -x "$manual" ]]; then
        "$manual" "$path"
    elif command -v "$cmd" &>/dev/null; then
        "$cmd" "$path"
    else
        echo "$cmd not found - install it through JetBrains Toolbox or configure a manual Linux installation"
        return 1
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
