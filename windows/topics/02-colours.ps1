# =============================================================================
# Colour and separator variables
# PowerShell uses -ForegroundColor on Write-Host rather than ANSI escape codes.
# I define the separator string here so refresh() and the welcome banner both
# use the same width.
# =============================================================================

$sep = "---------------------------------------------"

# =============================================================================
# Prompt
# Uses ANSI escape codes via `e (PowerShell 7+). user@host in cyan,
# path in yellow, > in green.
# =============================================================================

function prompt {
    "`e[36m$env:USERNAME@$env:COMPUTERNAME`e[0m `e[33m$(Get-Location)`e[0m `e[32m>`e[0m "
}

# =============================================================================
# PSReadLine syntax highlighting (PS7+)
# Commands green, strings yellow, errors red, keywords magenta, parameters cyan.
# Consistent with RED=errors GREEN=success CYAN=info YELLOW=warnings MAGENTA=headers.
# =============================================================================

if (Get-Module -ListAvailable -Name PSReadLine -ErrorAction SilentlyContinue) {
    Set-PSReadLineOption -Colors @{
        Command   = "`e[32m"
        Parameter = "`e[36m"
        String    = "`e[33m"
        Error     = "`e[31m"
        Comment   = "`e[90m"
        Keyword   = "`e[35m"
        Number    = "`e[33m"
        Variable  = "`e[36m"
        Operator  = "`e[37m"
    }
}
