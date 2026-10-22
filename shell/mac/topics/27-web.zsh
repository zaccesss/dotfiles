# =============================================================================
# JavaScript, Node.js and TypeScript
# Used daily across Next.js, React and Node.js projects. All aliases
# use the 'n' prefix so they don't conflict with system commands.
# =============================================================================

# package management
alias ni="npm install"
alias nid="npm install --save-dev"

# script runners - used dozens of times a day in any JS/TS project
alias nr="npm run"
alias nd="npm run dev"
alias nb="npm run build"
alias ns="npm start"
alias nt="npm test"
alias ntw="npm test -- --watch"
alias nlint="npm run lint"
alias nfmt="npm run format"

# inspect a package's real published metadata (version, deps) without installing it
alias nview="npm view"

# list an installed package's actual resolved version, catches an override that silently failed
alias nls="npm ls"

# list globally installed packages
alias nglobal="npm ls -g --depth=0"

# exact, lockfile-only install - what CI actually runs, catches a lockfile drift early
alias nci="npm ci"

alias nout="npm outdated"
alias naudit="npm audit"
alias nauditfix="npm audit fix"

# run the project's typecheck script - most Next.js/React/Node setups define one
alias ntc="npm run typecheck"

# TypeScript watch mode - recompiles on save without a full npm run wrapper
alias tsw="tsc --watch"

# full clean reinstall - deletes node_modules and the lockfile, for when an override or a
# dependency change isn't taking effect and a normal install isn't enough
nreset() {
    rm -rf node_modules package-lock.json && npm install
}
