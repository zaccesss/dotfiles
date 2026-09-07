# =============================================================================
# Docker and Docker Compose
# =============================================================================

function dps    { docker ps }
function dpa    { docker ps -a }
function dex    { docker exec -it $args }
function dlogs  { docker logs -f $args }
function dstart { docker start $args }
function dstop  { docker stop $args }
function drm    { docker rm $args }
function drmf   { docker rm -f $args }
function dimg   { docker images }
function dprune { docker system prune -f }
# aggressive - also drops unused images and volumes
function dprunea { docker system prune -af --volumes }
function dstats  { docker stats }
function dinspect { docker inspect $args }
function dnet    { docker network ls }
function dvol    { docker volume ls }
function dpull   { docker pull $args }
function dpush   { docker push $args }

function dcu  { docker compose up $args }
function dcud { docker compose up -d }
function dcd  { docker compose down }
function dcb  { docker compose build }
function dcl  { docker compose logs -f $args }
function dcps { docker compose ps }
function dcr  { docker compose restart $args }

# Spin up a throwaway named container that stays alive for N seconds (default 900), for real
# cross-platform verification work, not just docker compose services
function dtest {
    param([string]$Name, [string]$Image, [int]$Seconds = 900)
    docker run --rm -d --name $Name $Image sleep $Seconds
}

function dcp { docker cp @args }

# Exec a command in a running container without -it, for a scripted/non-interactive call
function dexec {
    param([string]$Name)
    docker exec $Name @args
}

# Build an image from the current directory and tag it in one step
function dbuild {
    param([string]$Tag)
    docker build -t $Tag .
}

# Run a throwaway interactive container - drops in and cleans up itself on exit
function drun {
    docker run --rm -it @args
}

# Exec into a compose service, defaulting to sh since not every image ships bash
function dcex {
    param([string]$Service, [string]$Cmd = "sh")
    docker compose exec $Service $Cmd
}
