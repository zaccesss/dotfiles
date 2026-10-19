# =============================================================================
# Node version manager (nvm) - lazy-loaded to keep bash startup fast
# nvm install: https://github.com/nvm-sh/nvm
# =============================================================================

# puts nvm's default Node on PATH at shell start without loading nvm. a lazy `node` function is
# invisible to child processes, so anything started through sh (editor hooks, scripts, make) got
# "node: not found". this follows nvm's own resolution: alias files can chain (lts/* names
# lts/<codename>, which holds a version) and a partial version such as 26 means the highest
# installed v26.x.y. file reads, globs and parameter expansion only, no subshells, so it stays
# well under a millisecond.
_nvm_default_bin() {
    local dir="${NVM_DIR:-$HOME/.nvm}" v="default" hops=0 d name a b c n best="" bestn=-1
    while [[ $hops -lt 5 && -f "$dir/alias/$v" ]]; do
        read -r v < "$dir/alias/$v" || [[ -n "$v" ]] || return 1
        hops=$((hops + 1))
    done
    [[ $hops -gt 0 ]] || return 1
    v="${v#v}"
    case "$v" in
        node|stable) v="" ;;
        ""|system|iojs*|*/*) return 1 ;;
    esac
    # the glob also catches v260 for 26, so each name is checked against the alias before use
    for d in "$dir/versions/node/v$v"*; do
        name="${d##*/v}"
        [[ -z "$v" || "$name" == "$v" || "$name" == "$v".* ]] || continue
        [[ "$name" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && -x "$d/bin/node" ]] || continue
        a="${name%%.*}"; b="${name#*.}"; c="${b#*.}"; b="${b%%.*}"
        n=$(( a * 1000000 + b * 1000 + c ))
        if [[ $n -gt $bestn ]]; then bestn=$n; best="$d/bin"; fi
    done
    [[ -n "$best" ]] || return 1
    case ":$PATH:" in
        *":$best:"*) ;;
        *) export PATH="$best:$PATH" ;;
    esac
}

# returns 1 if nvm.sh wasn't found, so nvm() below can fail loudly instead of recursing into
# itself, a broken shell snapshot has silently dropped this function before while node()/npm()/
# npx() kept their wrapper definitions, turning a plain `node` call into infinite self-recursion.
# only the names nvm.sh replaces are unset: the nvmls/nvmuse style helpers go through `nvm`, so they
# keep working after the first load instead of vanishing. the unset is silenced because node/npm/
# npx only exist as functions when no default was found.
_nvm_load() {
    unset -f nvm node npm npx 2>/dev/null
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh"
        # explicit 0: a missing bash_completion leaves the test above false, which nvm() would read
        # as a failed load
        [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
        return 0
    else
        echo "nvm not found at $NVM_DIR, install it from https://github.com/nvm-sh/nvm" >&2
        return 1
    fi
}

# with the default Node already on PATH, node/npm/npx stay real binaries so child processes and
# `command -v` see the same thing as the shell. the wrappers are only a fallback for a machine
# with nvm installed but no resolvable default; they call the real binary via `command`, never
# their own bare name, so a call is safe even when _nvm_load fails. with no nvm.sh at all (Node
# from apt, dnf or another manager) no wrappers are defined, otherwise every node/npm/npx call
# would print the install hint first. only nvm() and its helpers remain then to print the hint.
if ! _nvm_default_bin && [[ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]]; then
    node()     { _nvm_load; command node "$@"; }
    npm()      { _nvm_load; command npm "$@"; }
    npx()      { _nvm_load; command npx "$@"; }
fi
unset -f _nvm_default_bin

nvm()          { _nvm_load || return 1; nvm "$@"; }
nvmuse()       { nvm use "$@"; }
nvmls()        { nvm ls; }
nvmls-remote() { nvm ls-remote --lts; }
nvminstall()   { nvm install "$@"; }
nvmuninstall() { nvm uninstall "$@"; }
nvmcurrent()   { nvm current; }
nvmdefault()   { nvm alias default "$@"; }
nvmlts()       { nvm install --lts && nvm use --lts; }
