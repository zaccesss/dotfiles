# =============================================================================
# winget - Windows Package Manager
# The Windows equivalent of brew. Comes built into Windows 11 and can be
# installed on Windows 10 via the Microsoft Store (App Installer).
# =============================================================================

# wgup: upgrade all installed packages
function wgup { winget upgrade --all }

# wgins: install a package
function wgins {
    param([string]$Package)
    winget install --exact --id $Package
}

# wgrm: uninstall a package
function wgrm {
    param([string]$Package)
    winget uninstall --exact --id $Package
}

# wgsearch: search for a package
function wgsearch {
    param([string]$Query)
    winget search $Query
}

# wgls: list all installed packages
function wgls { winget list }

# wginfo: show info about a package
function wginfo {
    param([string]$Package)
    winget show $Package
}

# wgimport: install from a winget export file
function wgimport {
    param([string]$File)
    winget import --import-file $File
}

# wgexport: export installed packages to a file
function wgexport {
    param([string]$File = "winget-packages.json")
    winget export --output $File
    Write-Host "Exported to $File" -ForegroundColor Green
}

# wgpin: pin a package to prevent it being upgraded
function wgpin {
    param([string]$Package)
    winget pin add --exact --id $Package
}

# wgunpin: unpin a package
function wgunpin {
    param([string]$Package)
    winget pin remove --exact --id $Package
}

# No winget equivalent for brew's `buses` (reverse-dependency lookup) or `bservices`
# (managing a formula's background service) - winget installs packages, it doesn't
# track dependents or run services the way Homebrew does

# Chocolatey shortcuts (alternative package manager)
function chocoins  { param($Pkg) choco install $Pkg -y }
function chocolist { choco list --local-only }
function chocoup   { choco upgrade all -y }
function chocoinfo { param($Pkg) choco info $Pkg }
