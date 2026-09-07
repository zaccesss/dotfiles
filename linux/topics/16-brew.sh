# =============================================================================
# Homebrew on Linux (Linuxbrew)
# Install: https://docs.brew.sh/Homebrew-on-Linux
# If Linuxbrew is not installed, these aliases are harmless no-ops since
# 'brew' won't be on PATH and they'll simply fail with "command not found".
# =============================================================================

bup() {
    brew update && brew upgrade && brew cleanup
}

alias bls="brew list"
alias blsc="brew list --cask"
alias bsearch="brew search"
alias bins="brew install"
alias binsc="brew install --cask"
alias brm="brew uninstall"
alias binfo="brew info"
alias bdeps="brew deps --tree"
alias bdr="brew doctor"
alias bleave="brew autoremove"
alias brewclean="brew cleanup"
alias brewoutd="brew outdated"
alias bpin="brew pin"
alias bunpin="brew unpin"
alias buses="brew uses --installed"
alias bservices="brew services list"
alias bservicestart="brew services start"
alias bservicestop="brew services stop"
