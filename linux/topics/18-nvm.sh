# =============================================================================
# Node version manager (nvm) - lazy-loaded to keep bash startup fast
# nvm install: https://github.com/nvm-sh/nvm
# =============================================================================

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
nvm()          { _nvm_load || return 1; nvm "$@"; }
node()         { _nvm_load; command node "$@"; }
npm()          { _nvm_load; command npm "$@"; }
npx()          { _nvm_load; command npx "$@"; }
nvmuse()       { _nvm_load; nvm use "$@"; }
nvmls()        { _nvm_load; nvm ls; }
nvmls-remote() { _nvm_load; nvm ls-remote --lts; }
nvminstall()   { _nvm_load; nvm install "$@"; }
nvmuninstall() { _nvm_load; nvm uninstall "$@"; }
nvmcurrent()   { _nvm_load; nvm current; }
nvmdefault()   { _nvm_load; nvm alias default "$@"; }
nvmlts()       { _nvm_load; nvm install --lts && nvm use --lts; }
