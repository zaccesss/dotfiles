# =============================================================================
# Network tools - Windows PowerShell
# =============================================================================

function myip    { (Invoke-RestMethod -Uri "https://ifconfig.me").Trim() }
function localip { (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" } | Select-Object -First 1).IPAddress }

function headers {
    param([string]$Url)
    (Invoke-WebRequest -Uri $Url -Method Head).Headers
}

function scan {
    param([string]$Subnet = "192.168.1.0/24")
    if (Get-Command nmap -ErrorAction SilentlyContinue) {
        nmap -sn $Subnet
    } else {
        Write-Host "nmap not found - install via: winget install Insecure.Nmap"
    }
}

function portscan {
    # named HostName, not Host - $Host is PowerShell's automatic host-info variable and
    # a param of the same name would shadow it inside this function's scope
    param([string]$HostName)
    if (Get-Command nmap -ErrorAction SilentlyContinue) {
        nmap -sV --open $HostName
    } else {
        Write-Host "nmap not found - install via: winget install Insecure.Nmap"
    }
}

function openports { netstat -an | Select-String "LISTENING" }

function dns {
    param([string]$Domain)
    Resolve-DnsName -Name $Domain -Type ANY
}

function portcheck {
    param([string]$HostName, [int]$Port)
    $tcp = New-Object System.Net.Sockets.TcpClient
    try {
        $tcp.Connect($HostName, $Port)
        Write-Host "$HostName`:$Port is open" -ForegroundColor Green
    } catch {
        Write-Host "$HostName`:$Port is closed or unreachable" -ForegroundColor Red
    } finally {
        $tcp.Close()
    }
}

function ping4 { param([string]$HostName) ping -n 4 $HostName }

# gateway: show the default gateway - useful when a node's IP config looks wrong
function gateway { (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1).NextHop }

# nginx shortcuts (if nginx is installed on Windows)
function nginx-test    { nginx -t }
function nginx-reload  { nginx -s reload }
# nginx-restart: nginx on Windows doesn't handle POSIX signals, so this is stop-then-start
function nginx-restart { nginx -s stop; Start-Sleep -Milliseconds 500; Start-Process nginx }
function nginx-log     { Get-Content "C:\nginx\logs\error.log" -Wait -Tail 20 }
function nginx-access  { Get-Content "C:\nginx\logs\access.log" -Wait -Tail 20 }
