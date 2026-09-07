# 003 - Why nvm is lazy-loaded

**Date:** June 2026
**Status:** Complete

---

## The problem

The standard nvm installation instructions tell you to add this to your shell profile:

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

This sources `nvm.sh` on every single shell start - every new tab, every SSH session, every subshell. `nvm.sh` is not a small file. It sets up the nvm internals, walks the available version directories and configures completion. On the MacBook Air this adds roughly 200ms to shell startup time.

200ms does not sound like much, but I open a lot of terminal tabs. Ten tabs is two full seconds of startup time just for nvm. On top of that, the vast majority of shell sessions never touch Node at all - they are git operations, Python work, Rust builds or just quick navigation. Loading the entire nvm machinery for a shell that will never call `node` is wasteful.

---

## The solution: stub functions

Instead of sourcing `nvm.sh` at startup, I define placeholder functions that share the names of every nvm command. Each stub does two things: unsets all the stubs (so nvm's own versions take over), sources the real `nvm.sh`, then calls the actual command with the original arguments.

```zsh
_nvm_load() {
    unset -f nvm node npm npx nvmuse nvmls nvminstall nvmdefault nvmls-remote
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
}

nvm()         { _nvm_load; nvm "$@"; }
node()        { _nvm_load; node "$@"; }
npm()         { _nvm_load; npm "$@"; }
npx()         { _nvm_load; npx "$@"; }
```

The first time you run `node`, `npm`, `npx` or any nvm command, `_nvm_load` fires, replaces all the stubs with the real nvm functions and then calls the real function. Every subsequent call goes directly to nvm because the stubs have been unset. The 200ms cost is paid once, at first use, not at every shell start.

---

## Why this works reliably

The key line is the `unset -f` at the top of `_nvm_load`. Without it, `node()` would call `_nvm_load`, which would source `nvm.sh` (which defines the real `node` in PATH), but then the stub `node()` would still be the active definition and would call itself recursively. The unset ensures that after `_nvm_load` runs, the name `node` resolves to the binary in PATH that nvm just set up, not to the stub function.

The stub must be a function, not an alias, because aliases are expanded before the argument list is evaluated. A function gets `"$@"` naturally.

---

## The bash version

The Linux `18-nvm.sh` version uses the same pattern, with `unset -f` and a local `_nvm_load` helper. The only difference is bash uses `unset -f` syntax identically to zsh, so the implementation is character-for-character the same.

---

## Windows and nvm-windows

On Windows, `18-nvm.ps1` does not use lazy loading. `nvm-windows` is a different tool with a completely different implementation - it is a compiled Go binary that manages Node version symlinks in `AppData`. Sourcing it does not add a startup penalty because it is not a shell script. The Windows stubs are simple PowerShell functions that call `nvm.exe` directly, so there is nothing to lazy-load.

---

## Trade-offs

The one downside of lazy loading is that `node --version` in a fresh shell takes longer than usual on the first call - you pay the 200ms cost then. If I were writing a benchmark or a script that depends on fast startup of a subshell that immediately calls node, this approach would not help. For interactive use it is invisible.

Another minor downside: tab completion for nvm subcommands does not work until after the first nvm call in a session, because `bash_completion` is not sourced until `_nvm_load` runs. I rarely tab-complete nvm commands so this has not been a problem in practice.
