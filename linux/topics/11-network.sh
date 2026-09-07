# =============================================================================
# Network tools
# Linux-specific: uses ip instead of ifconfig, nmap for scanning.
# Requires: apt install nmap netcat-openbsd
# =============================================================================

alias myip="curl -s ifconfig.me && echo"
localip() { hostname -I | awk '{print $1}'; }
alias ip='ip -c'
ips() { ip -4 addr show | grep inet | awk '{print $2}'; }

headers() { curl -sI "$@"; }

scan() {
    nmap -sn "${1:-192.168.1.0/24}"
}

portscan() {
    nmap -sV --open "${1:?Usage: portscan <host>}"
}

alias openports="ss -tulnp"

dns() {
    dig +nocmd "${1:?Usage: dns <domain>}" any +multiline +noall +answer
}

alias tracepath="traceroute"
alias ping4="ping -c 4"

portcheck() {
    nc -zv "${1:?Usage: portcheck <host> <port>}" "${2:?}" 2>&1
}

# nginx shortcuts - Linux paths
alias nginx-test="sudo nginx -t"
alias nginx-reload="sudo nginx -s reload"
alias nginx-restart="sudo systemctl restart nginx"
alias nginx-log="sudo tail -f /var/log/nginx/error.log"
alias nginx-access="sudo tail -f /var/log/nginx/access.log"

# gateway: show the default gateway - useful when a node's IP config looks wrong
alias gateway="ip route | grep default"
