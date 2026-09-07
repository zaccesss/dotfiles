# =============================================================================
# Cloud platform CLIs - AWS, Google Cloud and Azure
# Requires: awscli google-cloud-sdk azure-cli (install via package manager)
# =============================================================================

alias awsprofiles="aws configure list-profiles"
awsp() { export AWS_PROFILE="${1:?Usage: awsp <profile>}"; echo "AWS_PROFILE=$AWS_PROFILE"; }
alias awswho="aws sts get-caller-identity"
alias awsls="aws s3 ls"
alias awsec2="aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==\`running\`].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]' --output table"
alias awseks="aws eks list-clusters --output table"
awslogs() { aws logs tail "${1:?Usage: awslogs <log-group>}" --follow; }
alias awslambda="aws lambda list-functions --query 'Functions[].FunctionName' --output table"
awsregion() { export AWS_DEFAULT_REGION="${1:?}"; echo "Region: $AWS_DEFAULT_REGION"; }

alias gcfg="gcloud config list"
alias gcconfigs="gcloud config configurations list"
gcactivate() { gcloud config configurations activate "${1:?Usage: gcactivate <config-name>}"; }
gcproj() { gcloud config set project "${1:?Usage: gcproj <project-id>}"; }
alias gcwho="gcloud auth list"
alias gcrun="gcloud run services list"
alias gcbuild="gcloud builds list --limit 10"
alias gcvms="gcloud compute instances list"
alias gcgke="gcloud container clusters list"
gclogs() {
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=${1:?}" --limit 50 --format "value(textPayload)"
}

alias azwho="az account show"
alias azls="az account list --output table"
azsub() { az account set --subscription "${1:?}"; }
azvm() { az vm list -g "${1:?}" --output table; }
alias azweb="az webapp list --output table"
alias azgroup="az group list --output table"
alias azaks="az aks list --output table"
azlogs() { az webapp log tail --name "${1:?}" --resource-group "${2:?}"; }
