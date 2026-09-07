# =============================================================================
# JavaScript, Node.js and TypeScript
# =============================================================================

alias ni="npm install"
alias nid="npm install --save-dev"
alias nr="npm run"
alias nd="npm run dev"
alias nb="npm run build"
alias ns="npm start"
alias nt="npm test"
alias ntw="npm test -- --watch"
alias nlint="npm run lint"
alias nfmt="npm run format"

# Inspect a package's real published metadata (version, deps) without installing it
alias nview="npm view"

# List an installed package's actual resolved version, catches an override that silently failed
alias nls="npm ls"

# List globally installed packages
alias nglobal="npm ls -g --depth=0"

# Exact, lockfile-only install - what CI actually runs, catches a lockfile drift early
alias nci="npm ci"

alias nout="npm outdated"
alias naudit="npm audit"
alias nauditfix="npm audit fix"

# Run the project's typecheck script - most Next.js/React/Node setups define one
alias ntc="npm run typecheck"

# TypeScript watch mode - recompiles on save without a full npm run wrapper
alias tsw="tsc --watch"

# Full clean reinstall - deletes node_modules and the lockfile, for when an override or a
# dependency change isn't taking effect and a normal install isn't enough
nreset() {
    rm -rf node_modules package-lock.json && npm install
}
