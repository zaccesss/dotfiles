# =============================================================================
# SSH helpers - Windows PowerShell
# Windows 10/11 include OpenSSH. Use: Add-WindowsCapability -Online -Name OpenSSH.Client*
# =============================================================================

function keygen {
    param([string]$Name = "id_ed25519")
    $email = git config user.email 2>$null
    if (-not $email) { $email = "$env:USERNAME@$env:COMPUTERNAME" }
    ssh-keygen -t ed25519 -C $email -f "$env:USERPROFILE\.ssh\$Name"
}

function sshcp {
    param([string]$Target, [string]$Key = "$env:USERPROFILE\.ssh\id_ed25519.pub")
    ssh-copy-id -i $Key $Target
}

function ssha {
    param([string]$Key = "$env:USERPROFILE\.ssh\id_ed25519")
    Start-Service ssh-agent -ErrorAction SilentlyContinue
    ssh-add $Key
}

function sshls   { ssh-add -l }
function sshconf { code "$env:USERPROFILE\.ssh\config" }

function sshtest {
    # named HostName, not Host - $Host is PowerShell's automatic host-info variable and
    # a param of the same name would shadow it inside this function's scope
    param([string]$HostName)
    ssh -v -o ConnectTimeout=5 $HostName exit 2>&1 | Select-String "Connecting|debug1|Permission|connect|success"
}

function sshfp {
    param([string]$Key = "$env:USERPROFILE\.ssh\id_ed25519.pub")
    ssh-keygen -lf $Key
}

# sshrm: remove a host's entry from known_hosts - useful after a VM/node gets reimaged
# and ssh refuses to connect with a "REMOTE HOST IDENTIFICATION HAS CHANGED" warning
function sshrm {
    param([string]$HostName)
    ssh-keygen -R $HostName
}

function node1 { ssh node1 }
function node2 { ssh node2 }
function node3 { ssh node3 }
function node4 { ssh node4 }

function scpto   { param($Src, $Dest) scp $Src $Dest }
function scpfrom { param($Src) scp $Src . }
