# =============================================================================
# File sync and transfer - Windows uses robocopy; rclone is cross-platform
# =============================================================================

# rcopy: robust copy with progress - equivalent to rsync -avh --progress
function rcopy {
    param([string]$Src, [string]$Dest)
    robocopy $Src $Dest /E /NFL /NDL /NJH /NJS /nc /ns /np
}

# rmirror: mirror src to dest, removing files that don't exist in src
function rmirror {
    param([string]$Src, [string]$Dest)
    robocopy $Src $Dest /MIR /NFL /NDL /NJH /NJS /nc /ns /np
}

# rbackup: incremental copy - only copy changed or new files
function rbackup {
    param([string]$Src, [string]$Dest)
    robocopy $Src $Dest /E /XO /NFL /NDL
}

# rdry: dry-run a mirror - shows what would change
function rdry {
    param([string]$Src, [string]$Dest)
    robocopy $Src $Dest /MIR /L /NFL /NDL /NJH /NJS
}

# rclone shortcuts (cross-platform, requires rclone install)
function rls           { rclone ls @args }
function rclonecopy    { rclone copy --progress @args }
function rclonesync    { rclone sync --progress @args }
function rcloneremotes { rclone listremotes }
function rclonemove    { rclone move --progress @args }
function rclonesize    { rclone size @args }

# scp shortcuts via Windows' built-in OpenSSH client (no extra install needed)
function scpget {
    param([Parameter(Mandatory)][string]$Remote, [string]$Local = ".")
    scp $Remote $Local
}
function scpput {
    param([Parameter(Mandatory)][string]$Local, [Parameter(Mandatory)][string]$Remote)
    scp $Local $Remote
}
function scpgetdir {
    param([Parameter(Mandatory)][string]$Remote, [string]$Local = ".")
    scp -r $Remote $Local
}
function scpputdir {
    param([Parameter(Mandatory)][string]$Local, [Parameter(Mandatory)][string]$Remote)
    scp -r $Local $Remote
}

# WinSCP CLI (requires WinSCP installed and winscp.com on PATH)
function winscp-put {
    param([string]$Local, [string]$Remote)
    & "winscp.com" /command "put $Local $Remote" "exit"
}
function winscp-get {
    param([string]$Remote, [string]$Local = ".")
    & "winscp.com" /command "get $Remote $Local" "exit"
}
