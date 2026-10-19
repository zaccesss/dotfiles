# =============================================================================
# Network tools
# Used constantly when debugging hardware nodes, checking API servers
# and testing connectivity on the cluster. Requires nmap for scan/portscan.
# =============================================================================

# public IP - shows the IP your traffic leaves from
alias myip="curl -s ifconfig.me && echo"

# local network IP
alias localip="ipconfig getifaddr en0"

# all network interfaces and their IPs
ips() { ifconfig | grep 'inet ' | awk '{print $2}'; }

# headers: show HTTP response headers for a URL without downloading the body
headers() { curl -sI "$@"; }

# scan: quick nmap ping scan of a subnet to find live hosts.
# finds nodes on the cluster network when IPs change.
# usage: scan 192.168.1.0/24
scan() {
    nmap -sn "${1:-192.168.1.0/24}"
}

# portscan: scan open ports on a specific host
portscan() {
    nmap -sV --open "${1:?Usage: portscan <host>}"
}

# openports: show listening ports on this machine
alias openports="lsof -i -P -n | grep LISTEN"

# digga: already in community but keeping the alias here too for discoverability
# dns: quick DNS lookup with all record types
dns() {
    dig +nocmd "${1:?Usage: dns <domain>}" any +multiline +noall +answer
}

# tracepath: quick traceroute
alias tracepath="traceroute"

# speedtest: a network speed test through the installed speedtest-cli rather than a script fetched
# on every run. PYTHONWARNINGS hides a deprecation notice the tool prints on newer Python
speedtest() {
    if command -v speedtest-cli >/dev/null 2>&1; then
        PYTHONWARNINGS=ignore::DeprecationWarning speedtest-cli "$@"
    else
        echo "speedtest-cli is not installed: brew install speedtest-cli"
    fi
}

# ping shortcuts
alias ping4="ping -c 4"

# check if a port is open on a remote host
# Usage: portcheck host port
portcheck() {
    nc -zv "${1:?Usage: portcheck <host> <port>}" "${2:?}" 2>&1
}

# nginx: test config and reload (if nginx is running locally)
alias nginx-test="sudo nginx -t"
alias nginx-reload="sudo nginx -s reload"
alias nginx-restart="sudo brew services restart nginx"
alias nginx-log="tail -f /opt/homebrew/var/log/nginx/error.log"
alias nginx-access="tail -f /opt/homebrew/var/log/nginx/access.log"

# gateway: show the default gateway - useful when a node's IP config looks wrong
alias gateway="route -n get default | grep gateway"

# flushdns: clear the DNS resolver cache, the first fix when a site still resolves to a stale IP
# after a DNS change
alias flushdns="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
