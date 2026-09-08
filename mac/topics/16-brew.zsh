# =============================================================================
# Homebrew package manager
# Shortcuts for the operations I run most often. bup is the one I run weekly
# to keep everything current without having to type two long commands.
# =============================================================================

# bup: update Homebrew index, upgrade all packages, then clean up old versions.
# I run this every week to keep everything current.
bup() {
    brew update && brew upgrade && brew cleanup
}

# bls: list all installed formulae
alias bls="brew list"

# blsc: list installed casks (GUI apps)
alias blsc="brew list --cask"

# bsearch: search for a formula or cask
alias bsearch="brew search"

# bins: install a formula
alias bins="brew install"

# binsc: install a cask
alias binsc="brew install --cask"

# brm: uninstall a formula
alias brm="brew uninstall"

# binfo: show info about a formula (version, deps, options)
alias binfo="brew info"

# bdeps: show the dependency tree for a formula
alias bdeps="brew deps --tree"

# bdr: run brew doctor - checks for common problems
alias bdr="brew doctor"

# bleave: remove a package and all packages that depend on it
alias bleave="brew autoremove"

# brewclean: remove old versions of installed formulae
alias brewclean="brew cleanup"

# brewoutd: list formulae that have an update available
alias brewoutd="brew outdated"

# bpin: pin a formula to prevent it being upgraded
alias bpin="brew pin"

# bunpin: unpin a formula
alias bunpin="brew unpin"

# buses: show what depends on a formula - check before uninstalling something
# that looks unused, it might be a dependency of something else you still need
alias buses="brew uses --installed"

# bservices: list background services managed by brew (postgres, redis etc)
alias bservices="brew services list"

# bservicestart/bservicestop: start or stop a brew-managed background service
alias bservicestart="brew services start"
alias bservicestop="brew services stop"

# bbundle: install every package listed in mac/Brewfile, the way a new machine gets set up
alias bbundle='brew bundle install --file="$DOTFILES/mac/Brewfile"'

# bdump: regenerate mac/Brewfile from what is actually installed right now.
# --no-vscode skips VS Code extensions, the separate .vscode repo is the source of truth there.
alias bdump='brew bundle dump --describe --no-vscode --force --file="$DOTFILES/mac/Brewfile"'
