# =============================================================================
# Editor and IDE launchers
# VS Code and JetBrains IDE shortcuts. JetBrains ones require Toolbox shell
# scripts to be enabled in Toolbox -> Settings -> Shell scripts.
# VS Code requires 'code' to be installed: Cmd+Shift+P -> "Shell Command: Install"
# =============================================================================

# VS Code
alias e="code ."                                    # open current dir
alias ec="code"                                     # open a specific file or dir

# VS Code extension management
alias extls="code --list-extensions"
alias extinstall="code --install-extension"
alias extrm="code --uninstall-extension"

# extdump: export all installed extensions to a file (useful for restoring a machine)
extdump() {
    code --list-extensions > "${1:-extensions.txt}"
    echo "Saved to ${1:-extensions.txt}"
}

# extrestore: install all extensions from a dumped list
extrestore() {
    local file="${1:-extensions.txt}"
    [[ -f "$file" ]] || { echo "File not found: $file"; return 1; }
    while IFS= read -r ext; do
        code --install-extension "$ext"
    done < "$file"
}

# JetBrains IDE launchers - open the current dir (or a path) in each IDE.
# these use the Toolbox shell scripts. If Toolbox is not installed, fall back
# to 'open -a' which opens the app without passing a path argument.
idea()     { if command -v idea     &>/dev/null; then idea "${1:-.}";     else open -a "IntelliJ IDEA" "${1:-.}"; fi }
pycharm()  { if command -v pycharm  &>/dev/null; then pycharm "${1:-.}";  else open -a "PyCharm" "${1:-.}"; fi }
# whence -p finds only the real program and command runs it, since command -v also finds
# the function itself, which then called itself until zsh stopped it
webstorm() { if whence -p webstorm &>/dev/null; then command webstorm "${1:-.}"; else open -a "WebStorm" "${1:-.}"; fi }
goland()   { if command -v goland   &>/dev/null; then goland "${1:-.}";   else open -a "GoLand" "${1:-.}"; fi }
clion()    { if command -v clion    &>/dev/null; then clion "${1:-.}";    else open -a "CLion" "${1:-.}"; fi }
rider()    { if command -v rider    &>/dev/null; then rider "${1:-.}";    else open -a "Rider" "${1:-.}"; fi }
phpstorm() { if whence -p phpstorm &>/dev/null; then command phpstorm "${1:-.}"; else open -a "PhpStorm" "${1:-.}"; fi }
datagrip() { if whence -p datagrip &>/dev/null; then command datagrip "${1:-.}"; else open -a "DataGrip" "${1:-.}"; fi }
