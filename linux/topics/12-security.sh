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
