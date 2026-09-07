# =============================================================================
# Security tools - Windows PowerShell
# OpenSSL shortcuts work if OpenSSL is installed (winget install ShiningLight.OpenSSL)
# Most Linux security tools run best under WSL on Windows.
# =============================================================================

function ssl-check {
    param([string]$HostPort)
    $parts = $HostPort -split ":"
    $h = $parts[0]; $p = if ($parts[1]) { $parts[1] } else { "443" }
    "" | openssl s_client -connect "${h}:${p}" -servername $h 2>$null `
        | openssl x509 -noout -subject -issuer -dates
}

function ssl-expiry {
    param([string]$HostPort)
    $parts = $HostPort -split ":"
    $h = $parts[0]; $p = if ($parts[1]) { $parts[1] } else { "443" }
    "" | openssl s_client -connect "${h}:${p}" -servername $h 2>$null `
        | openssl x509 -noout -enddate
}

function ssl-gen {
    param([string]$Name = "localhost")
    openssl req -x509 -newkey rsa:4096 -keyout "$Name.key" -out "$Name.crt" `
        -days 365 -nodes -subj "/CN=$Name"
    Write-Host "Generated $Name.key and $Name.crt" -ForegroundColor Green
}

function ssl-view {
    param([string]$File)
    openssl x509 -in $File -text -noout
}

function sha1file   { param([string]$File) Get-FileHash $File -Algorithm SHA1 }
function sha256file { param([string]$File) Get-FileHash $File -Algorithm SHA256 }
function sha512file { param([string]$File) Get-FileHash $File -Algorithm SHA512 }
function md5file    { param([string]$File) Get-FileHash $File -Algorithm MD5 }

# GPG shortcuts (requires gpg4win or winget install GnuPG.GnuPG)
function gpgls     { gpg --list-keys }
function gpglss    { gpg --list-secret-keys }
function gpgenc    { param($File, $Recipient) gpg --encrypt --armor -r $Recipient $File }
function gpgdec    { param($File) gpg --decrypt $File }
function gpgsign   { param($File) gpg --detach-sign --armor $File }
function gpgverify { param($Sig, $File) gpg --verify $Sig $File }
function gpgexport { param($KeyID) gpg --export --armor $KeyID }
function gpgimport { param($File) gpg --import $File }

function wh { param([string]$Domain) whois $Domain }

# genpass: generate a random strong password
function genpass {
    param([int]$Length = 20)
    (openssl rand -base64 $Length).Trim()
}

# nmapq: fast SYN scan of a host (requires nmap; WSL/Npcap-backed)
function nmapq {
    param([string]$HostName)
    if (Get-Command nmap -ErrorAction SilentlyContinue) {
        nmap -sS -T4 $HostName
    } else {
        Write-Host "nmap not found - install via: winget install Insecure.Nmap"
    }
}

# nikto: basic web server scan - most reliably run from WSL (winget install nikto is unreliable)
function nikto {
    param([string]$Target)
    wsl nikto -host $Target
}

# gobust: directory/file brute-force (requires gobuster)
# Usage: gobust http://target.local /path/to/wordlist.txt
function gobust {
    param([string]$Url, [string]$Wordlist = "$env:USERPROFILE\wordlists\common.txt")
    gobuster dir -u $Url -w $Wordlist
}

# hashcrack: quick hash crack shortcut (requires hashcat)
# Usage: hashcrack hash.txt path\to\wordlist.txt
function hashcrack {
    param([string]$HashFile, [string]$Wordlist = "$env:USERPROFILE\wordlists\rockyou.txt")
    hashcat -a 0 $HashFile $Wordlist
}
