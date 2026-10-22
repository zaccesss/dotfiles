# =============================================================================
# JavaScript, Node.js and TypeScript
# Note: ni = New-Item in PowerShell so npm install uses npmi here.
# all other aliases match Mac and Linux exactly.
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

# inspect a package's real published metadata (version, deps) without installing it
function nview { npm view @args }

# list an installed package's actual resolved version, catches an override that silently failed
function nls   { npm ls @args }

# list globally installed packages
function nglobal { npm ls -g --depth=0 }

# exact, lockfile-only install - what CI actually runs, catches a lockfile drift early
function nci { npm ci }

function nout      { npm outdated }
function naudit    { npm audit }
function nauditfix { npm audit fix }

# run the project's typecheck script - most Next.js/React/Node setups define one
function ntc { npm run typecheck }

# TypeScript watch mode - recompiles on save without a full npm run wrapper
function tsw { tsc --watch }

# full clean reinstall - deletes node_modules and the lockfile, for when an override or a
# dependency change isn't taking effect and a normal install isn't enough
function nreset {
    Remove-Item -Recurse -Force node_modules, package-lock.json -ErrorAction SilentlyContinue
    npm install
}
