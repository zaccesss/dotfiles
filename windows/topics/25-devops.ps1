# =============================================================================
# DevOps and infrastructure - Terraform, Ansible (via WSL), Helm, Vagrant
# Install: winget install Hashicorp.Terraform Kubernetes.Helm
# =============================================================================

function tfi    { terraform init }
function tfp    { terraform plan }
function tfa    { terraform apply }
function tfaa   { terraform apply -auto-approve }
function tfd    { terraform destroy }
function tfda   { terraform destroy -auto-approve }
function tfv    { terraform validate }
function tff    { terraform fmt -recursive }
function tfr    { terraform refresh }
function tfo    { terraform output }
function tfs    { terraform show }
function tfst   { terraform state list }
function tfw    { terraform workspace list }
function tfwn   { param($Name) terraform workspace new $Name }
function tfwsel { param($Name) terraform workspace select $Name }

# tfimport: bring an existing resource under Terraform management
function tfimport {
    param([string]$Address, [string]$Id)
    terraform import $Address $Id
}

# tfunlock: force-release a stuck state lock, only when you're sure no one else is applying
function tfunlock {
    param([string]$LockId)
    terraform force-unlock $LockId
}

# Ansible runs best under WSL on Windows
function ap       { param($Playbook) wsl ansible-playbook $Playbook @args }
function apcheck  { param($Playbook) wsl ansible-playbook --check $Playbook }
function ai       { wsl ansible-inventory --list }
function aping    { wsl ansible all -m ping }
function afacts   { wsl ansible all -m setup }
function av       { wsl ansible-vault @args }

function hls      { helm list }
function hlsa     { helm list --all-namespaces }
function hinst    { helm install @args }
function hup      { helm upgrade @args }
function hupi     { helm upgrade --install @args }
function hrm      { helm uninstall @args }
function hrepo    { helm repo list }
function hrepoadd { helm repo add @args }
function hrepoup  { helm repo update }
function hsearch  { helm search repo @args }
function hvals    { helm show values @args }
function hdiff    { helm diff upgrade @args } # requires helm-diff plugin
function hstatus  { helm status @args }
function hrollback { helm rollback @args }
function htest    { helm test @args }

function vup      { vagrant up }
function vhalt    { vagrant halt }
function vreload  { vagrant reload }
function vssh     { vagrant ssh }
function vdestroy { vagrant destroy }
function vstatus  { vagrant status }
function vsnap    { vagrant snapshot }
function vprovision { vagrant provision }
function vbox     { vagrant box list }
