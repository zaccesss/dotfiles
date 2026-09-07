# =============================================================================
# Kubernetes
# I use kubectl for cluster management and deployments. All aliases use the
# 'k' prefix so they're easy to distinguish from Docker commands.
# =============================================================================

alias kc="kubectl"
alias kg="kubectl get"
alias ka="kubectl apply -f"
alias kd="kubectl describe"
alias klogs="kubectl logs -f"
alias klogsp="kubectl logs --previous" # last run of a crashed/restarted container
alias kns="kubectl get namespaces"
alias kctx="kubectl config get-contexts"
alias kpods="kubectl get pods -A"

# Get resources by type
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias kgd="kubectl get deployments"
alias kgn="kubectl get nodes"
alias kgall="kubectl get all"
alias king="kubectl get ingress"
alias ksec="kubectl get secrets"
alias kcm="kubectl get configmaps"
alias kevents="kubectl get events --sort-by=.lastTimestamp"

# Delete
alias kdel="kubectl delete"
alias kdelf="kubectl delete -f"

# Introspection
alias kapi="kubectl api-resources"
alias kexplain="kubectl explain"
alias ktop="kubectl top pods"
alias ktopn="kubectl top nodes"
alias krollout="kubectl rollout status"

# Context / config
alias kcur="kubectl config current-context"
kuse() {
    kubectl config use-context "${1:?Usage: kuse <context>}"
}

# Exec into a pod, defaulting to sh since not every image ships bash
kexec() {
    local pod="$1"; shift
    kubectl exec -it "$pod" -- "${@:-sh}"
}

# Forward a local port to a pod or service - same syntax as kubectl itself
kpf() {
    kubectl port-forward "${1:?Usage: kpf <pod-or-svc> <local>:<remote>}" "${2:?Usage: kpf <pod-or-svc> <local>:<remote>}"
}

# Roll a deployment - forces new pods without changing the manifest, my go-to for "pick up the new secret/config"
krestart() {
    kubectl rollout restart deployment "${1:?Usage: krestart <deployment>}"
}

kscale() {
    kubectl scale deployment "${1:?Usage: kscale <deployment> <replicas>}" --replicas="${2:?Usage: kscale <deployment> <replicas>}"
}

# Node maintenance - cordon stops new pods scheduling, drain evicts what's already there
kdrain() {
    kubectl drain "${1:?Usage: kdrain <node>}" --ignore-daemonsets --delete-emptydir-data
}
kcordon() {
    kubectl cordon "${1:?Usage: kcordon <node>}"
}
kuncordon() {
    kubectl uncordon "${1:?Usage: kuncordon <node>}"
}
