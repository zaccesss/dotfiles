# =============================================================================
# Docker and Docker Compose
# =============================================================================

alias dps="docker ps"
alias dpa="docker ps -a"
alias dex="docker exec -it"
alias dlogs="docker logs -f"
alias dstart="docker start"
alias dstop="docker stop"
alias drm="docker rm"
alias drmf="docker rm -f"
alias dimg="docker images"
alias dprune="docker system prune -f"
alias dprunea="docker system prune -af --volumes" # aggressive - also drops unused images and volumes
alias dstats="docker stats"
alias dinspect="docker inspect"
alias dnet="docker network ls"
alias dvol="docker volume ls"
alias dpull="docker pull"
alias dpush="docker push"

alias dcu="docker compose up"
alias dcud="docker compose up -d"
alias dcd="docker compose down"
alias dcb="docker compose build"
alias dcl="docker compose logs -f"
alias dcps="docker compose ps"
alias dcr="docker compose restart"

# Spin up a throwaway named container that stays alive for N seconds (default 900), for real
# cross-platform verification work, not just docker compose services
dtest() {
    local name="${1:?Usage: dtest <name> <image> [seconds]}"
    local image="${2:?Usage: dtest <name> <image> [seconds]}"
    local seconds="${3:-900}"
    docker run --rm -d --name "$name" "$image" sleep "$seconds"
}

alias dcp="docker cp"

# Exec a command in a running container without -it, for a scripted/non-interactive call
dexec() {
    local name="$1"; shift
    docker exec "$name" "$@"
}

# Build an image from the current directory and tag it in one step
dbuild() {
    docker build -t "${1:?Usage: dbuild <tag>}" .
}

# Run a throwaway interactive container - drops in and cleans up itself on exit
drun() {
    docker run --rm -it "$@"
}

# Exec into a compose service, defaulting to sh since not every image ships bash
dcex() {
    local service="$1"; shift
    docker compose exec "$service" "${@:-sh}"
}
