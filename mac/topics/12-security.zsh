# =============================================================================
# Security tools
# Shortcuts for authorised testing, CTF work, cert management and key ops.
# All offensive tools here are for authorised testing only - never use against
# systems you do not own or have explicit written permission to test.
# =============================================================================

# openssl shortcuts - I use these constantly for cert inspection and API testing

# ssl-check: inspect a remote certificate (expiry, issuer, SANs)
ssl-check() {
    echo | openssl s_client -connect "${1:?Usage: ssl-check host:port}" -servername "${1%%:*}" 2>/dev/null \
        | openssl x509 -noout -subject -issuer -dates -ext subjectAltName
}

# ssl-expiry: show just the expiry date of a remote cert - useful in cron checks
ssl-expiry() {
    echo | openssl s_client -connect "${1:?Usage: ssl-expiry host:443}" -servername "${1%%:*}" 2>/dev/null \
        | openssl x509 -noout -enddate
}

# ssl-gen: generate a self-signed cert for local dev
# Usage: ssl-gen myapp.local
ssl-gen() {
    local name="${1:-localhost}"
    openssl req -x509 -newkey rsa:4096 -keyout "$name.key" -out "$name.crt" \
        -days 365 -nodes -subj "/CN=$name"
    echo "Generated $name.key and $name.crt"
}

# ssl-view: inspect a local .crt or .pem file
ssl-view() {
    openssl x509 -in "${1:?Usage: ssl-view file.crt}" -text -noout
}

# hash shortcuts
alias md5="md5sum 2>/dev/null || md5"
alias sha1="shasum -a 1"
alias sha256="shasum -a 256"
alias sha512="shasum -a 512"

# GPG shortcuts - key management and signing
alias gpgls="gpg --list-keys"
alias gpglss="gpg --list-secret-keys"
alias gpgenc="gpg --encrypt --armor"
alias gpgdec="gpg --decrypt"
alias gpgsign="gpg --detach-sign --armor"
alias gpgverify="gpg --verify"
alias gpgexport="gpg --export --armor"
alias gpgimport="gpg --import"

# nmap quick-scan (requires nmap)
# nmapq: fast SYN scan of a host
nmapq() { nmap -sS -T4 "${1:?Usage: nmapq <host>}"; }

# nikto: basic web server scan (requires nikto)
alias nikto="nikto -host"

# gobuster: directory/file brute-force (requires gobuster)
# Usage: gobust http://target.local /path/to/wordlist.txt
gobust() {
    gobuster dir -u "${1:?Usage: gobust <url> <wordlist>}" -w "${2:-/usr/share/wordlists/common.txt}"
}

# hashcat: quick hash crack shortcut (requires hashcat)
# Usage: hashcrack hash.txt /path/to/wordlist.txt
hashcrack() {
    hashcat -a 0 "${1:?Usage: hashcrack <hashfile> <wordlist>}" "${2:-/usr/share/wordlists/rockyou.txt}"
}

# whois shortcut
alias wh="whois"

# genpass: generate a random strong password
# Usage: genpass [length, default 20]
genpass() {
    openssl rand -base64 "${1:-20}" | tr -d '\n'
    echo
}
