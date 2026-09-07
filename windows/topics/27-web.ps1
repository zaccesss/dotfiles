# =============================================================================
# JavaScript, Node.js and TypeScript
# Note: ni = New-Item in PowerShell so npm install uses npmi here.
# All other aliases match Mac and Linux exactly.
# =============================================================================

# npmi instead of ni to avoid shadowing the New-Item cmdlet
function npmi  { npm install $args }
function nid   { npm install --save-dev $args }
function nr    { npm run $args }
function nd    { npm run dev }
function nb    { npm run build }
function ns    { npm start }
function nt    { npm test }
function ntw   { npm test -- --watch }
function nlint { npm run lint }
function nfmt  { npm run format }

# Inspect a package's real published metadata (version, deps) without installing it
function nview { npm view @args }

# List an installed package's actual resolved version, catches an override that silently failed
function nls   { npm ls @args }

# List globally installed packages
function nglobal { npm ls -g --depth=0 }

# Exact, lockfile-only install - what CI actually runs, catches a lockfile drift early
function nci { npm ci }

function nout      { npm outdated }
function naudit    { npm audit }
function nauditfix { npm audit fix }

# Run the project's typecheck script - most Next.js/React/Node setups define one
function ntc { npm run typecheck }

# TypeScript watch mode - recompiles on save without a full npm run wrapper
function tsw { tsc --watch }

# Full clean reinstall - deletes node_modules and the lockfile, for when an override or a
# dependency change isn't taking effect and a normal install isn't enough
function nreset {
    Remove-Item -Recurse -Force node_modules, package-lock.json -ErrorAction SilentlyContinue
    npm install
}
