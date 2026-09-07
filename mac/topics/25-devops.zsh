# =============================================================================
# DevOps and infrastructure tools
# Terraform/Ansible/Helm/Vagrant shortcuts. I prefix terraform with tf,
# ansible with an; helm with h and vagrant with v to keep things short.
# Requires: brew install terraform ansible helm vagrant
# =============================================================================

# ─── Terraform ───────────────────────────────────────────────────────────────

alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfaa="terraform apply -auto-approve"      # skip interactive confirmation
alias tfd="terraform destroy"
alias tfda="terraform destroy -auto-approve"
alias tfv="terraform validate"
alias tff="terraform fmt -recursive"
alias tfr="terraform refresh"
alias tfo="terraform output"
alias tfs="terraform show"
alias tfst="terraform state list"               # list resources in state
alias tfw="terraform workspace list"
alias tfwn="terraform workspace new"
alias tfwsel="terraform workspace select"

# tfplan-save: save a plan file to review before applying
tfplan-save() {
    terraform plan -out="${1:-tfplan}"
    echo "Plan saved. Apply with: terraform apply ${1:-tfplan}"
}

# tfimport: bring an existing resource under Terraform management
tfimport() {
    terraform import "${1:?Usage: tfimport <address> <id>}" "${2:?Usage: tfimport <address> <id>}"
}

# tfunlock: force-release a stuck state lock, only when you're sure no one else is applying
tfunlock() {
    terraform force-unlock "${1:?Usage: tfunlock <lock-id>}"
}

# ─── Ansible ─────────────────────────────────────────────────────────────────

# ap: run a playbook
ap() { ansible-playbook "${1:?Usage: ap <playbook.yml>}" "${@:2}"; }

# apcheck: dry-run a playbook without making changes
apcheck() { ansible-playbook --check "${1:?}" "${@:2}"; }

# ai: show the inventory
alias ai="ansible-inventory --list"

# aping: ping all hosts in the inventory
alias aping="ansible all -m ping"

# afacts: gather and dump facts from every host - my first move when a playbook behaves oddly
alias afacts="ansible all -m setup"

# av: encrypt/decrypt/edit vault-protected files
alias av="ansible-vault"

# ─── Helm ────────────────────────────────────────────────────────────────────

alias hls="helm list"
alias hlsa="helm list --all-namespaces"
alias hinst="helm install"
alias hup="helm upgrade"
alias hupi="helm upgrade --install"             # install or upgrade in one command
alias hrm="helm uninstall"
alias hrepo="helm repo list"
alias hrepoadd="helm repo add"
alias hrepoup="helm repo update"
alias hsearch="helm search repo"
alias hvals="helm show values"
alias hdiff="helm diff upgrade"                 # requires helm-diff plugin
alias hstatus="helm status"
alias hrollback="helm rollback"
alias htest="helm test"

# ─── Vagrant ─────────────────────────────────────────────────────────────────

alias vup="vagrant up"
alias vhalt="vagrant halt"
alias vreload="vagrant reload"
alias vssh="vagrant ssh"
alias vdestroy="vagrant destroy"
alias vstatus="vagrant status"
alias vsnap="vagrant snapshot"
alias vprovision="vagrant provision"
alias vbox="vagrant box list"
