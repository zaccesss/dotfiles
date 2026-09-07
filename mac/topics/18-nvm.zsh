# =============================================================================
# Node version manager (nvm)
# I switch Node versions frequently between projects. nvm is loaded lazily
# here - it only initialises when one of these commands is actually called,
# which keeps shell startup fast.
# nvm install: https://github.com/nvm-sh/nvm
# =============================================================================

# Lazy-load nvm - sourcing nvm.sh on every shell start adds ~200ms.
# The first call to any nvm command triggers the real load.
# Returns 1 if nvm.sh wasn't found, so nvm() below can fail loudly instead of recursing into
# itself, a broken shell snapshot has silently dropped this function before while node()/npm()/
# npx() kept their wrapper definitions, turning a plain `node` call into infinite self-recursion.
_nvm_load() {
    unset -f nvm node npm npx nvmuse nvmls nvminstall nvmuninstall nvmdefault nvmls-remote nvmlts nvmcurrent
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
        [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
    else
        echo "nvm not found at $NVM_DIR, install it from https://github.com/nvm-sh/nvm" >&2
        return 1
    fi
}

# node/npm/npx call the real binary via `command`, never their own bare name, so a call is safe
# even when _nvm_load fails, unlike nvm itself, they have a real external binary to fall back to.
nvm()         { _nvm_load || return 1; nvm "$@"; }
node()        { _nvm_load; command node "$@"; }
npm()         { _nvm_load; command npm "$@"; }
npx()         { _nvm_load; command npx "$@"; }

# nvmuse: switch to a specific node version (installs if not present)
nvmuse()      { _nvm_load; nvm use "$@"; }

# nvmls: list all locally installed node versions
nvmls()       { _nvm_load; nvm ls; }

# nvmls-remote: list all available LTS versions on the nvm registry
nvmls-remote(){ _nvm_load; nvm ls-remote --lts; }

# nvminstall: install a specific node version
nvminstall()  { _nvm_load; nvm install "$@"; }

# nvmuninstall: remove a specific node version
nvmuninstall() { _nvm_load; nvm uninstall "$@"; }

# nvmcurrent: show the node version active in this shell
nvmcurrent()  { _nvm_load; nvm current; }

# nvmdefault: set the default node version for new shells
nvmdefault()  { _nvm_load; nvm alias default "$@"; }

# nvmlts: install and use the latest LTS release
nvmlts()      { _nvm_load; nvm install --lts && nvm use --lts; }
