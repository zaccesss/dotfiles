# =============================================================================
# Kubernetes
# =============================================================================

function kc     { kubectl $args }
function kg     { kubectl get $args }
function ka     { kubectl apply -f $args }
function kd     { kubectl describe $args }
function klogs  { kubectl logs -f $args }
function klogsp { kubectl logs --previous $args } # last run of a crashed/restarted container
function kns    { kubectl get namespaces }
function kctx   { kubectl config get-contexts }
function kpods  { kubectl get pods -A }

function kgp    { kubectl get pods $args }
function kgs    { kubectl get svc $args }
function kgd    { kubectl get deployments $args }
function kgn    { kubectl get nodes $args }
function kgall  { kubectl get all }
function king   { kubectl get ingress $args }
function ksec   { kubectl get secrets $args }
function kcm    { kubectl get configmaps $args }
function kevents { kubectl get events --sort-by=.lastTimestamp }

function kdel   { kubectl delete $args }
function kdelf  { kubectl delete -f $args }

function kapi     { kubectl api-resources }
function kexplain { kubectl explain $args }
function ktop     { kubectl top pods }
function ktopn    { kubectl top nodes }
function krollout { kubectl rollout status $args }

function kcur { kubectl config current-context }
function kuse {
    param([string]$Context)
    kubectl config use-context $Context
}

# Exec into a pod, defaulting to sh since not every image ships bash
function kexec {
    param([string]$Pod, [string]$Cmd = "sh")
    kubectl exec -it $Pod -- $Cmd
}

# Forward a local port to a pod or service - same syntax as kubectl itself
function kpf {
    param([string]$Target, [string]$Ports)
    kubectl port-forward $Target $Ports
}

# Roll a deployment - forces new pods without changing the manifest, my go-to for "pick up the new secret/config"
function krestart {
    param([string]$Deployment)
    kubectl rollout restart deployment $Deployment
}

function kscale {
    param([string]$Deployment, [int]$Replicas)
    kubectl scale deployment $Deployment --replicas=$Replicas
}

# Node maintenance - cordon stops new pods scheduling, drain evicts what's already there
function kdrain {
    param([string]$Node)
    kubectl drain $Node --ignore-daemonsets --delete-emptydir-data
}
function kcordon {
    param([string]$Node)
    kubectl cordon $Node
}
function kuncordon {
    param([string]$Node)
    kubectl uncordon $Node
}
