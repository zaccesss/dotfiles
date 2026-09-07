# =============================================================================
# Cloud platform CLIs - AWS, Google Cloud and Azure
# I use all three. Shortcuts focus on the operations I run most: checking
# running resources, tailing logs and managing deployments.
# Requires: brew install awscli google-cloud-sdk azure-cli
# =============================================================================

# ─── AWS ─────────────────────────────────────────────────────────────────────

# awsprofiles: list every profile configured locally, before picking one with awsp
alias awsprofiles="aws configure list-profiles"

# awsp: set the active AWS profile for the session
awsp() { export AWS_PROFILE="${1:?Usage: awsp <profile-name>}"; echo "AWS_PROFILE=$AWS_PROFILE"; }

# awswho: show the current caller identity (which account and role are active)
alias awswho="aws sts get-caller-identity"

# awsls: list all S3 buckets
alias awsls="aws s3 ls"

# awsec2: list running EC2 instances in the current region
alias awsec2="aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==\`running\`].[InstanceId,InstanceType,PublicIpAddress,Tags[?Key==\`Name\`].Value|[0]]' --output table"

# awseks: list EKS clusters in the current region
alias awseks="aws eks list-clusters --output table"

# awslogs: tail a CloudWatch log group
# Usage: awslogs /aws/lambda/my-function
awslogs() {
    aws logs tail "${1:?Usage: awslogs <log-group>}" --follow
}

# awslambda: list all Lambda functions in the current region
alias awslambda="aws lambda list-functions --query 'Functions[].FunctionName' --output table"

# awsregion: switch the active region for the session
awsregion() { export AWS_DEFAULT_REGION="${1:?Usage: awsregion <region>}"; echo "Region: $AWS_DEFAULT_REGION"; }

# ─── Google Cloud ─────────────────────────────────────────────────────────────

# gcfg: show the active gcloud configuration
alias gcfg="gcloud config list"

# gcconfigs: list all named gcloud configurations (separate accounts/projects)
alias gcconfigs="gcloud config configurations list"

# gcactivate: switch to a different named gcloud configuration
gcactivate() { gcloud config configurations activate "${1:?Usage: gcactivate <config-name>}"; }

# gcproj: switch to a different GCP project
gcproj() { gcloud config set project "${1:?Usage: gcproj <project-id>}"; }

# gcwho: show the active gcloud account
alias gcwho="gcloud auth list"

# gcrun: list Cloud Run services in the active project
alias gcrun="gcloud run services list"

# gcbuild: list recent Cloud Build jobs
alias gcbuild="gcloud builds list --limit 10"

# gcvms: list all Compute Engine instances
alias gcvms="gcloud compute instances list"

# gcgke: list GKE clusters in the active project
alias gcgke="gcloud container clusters list"

# gclogs: tail logs from a Cloud Run service
# Usage: gclogs my-service
gclogs() {
    gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=${1:?}" --limit 50 --format "value(textPayload)"
}

# ─── Azure ───────────────────────────────────────────────────────────────────

# azwho: show the logged-in Azure account
alias azwho="az account show"

# azls: list all subscriptions
alias azls="az account list --output table"

# azsub: switch to a different subscription
azsub() { az account set --subscription "${1:?Usage: azsub <subscription-id-or-name>}"; }

# azvm: list VMs in a resource group
# Usage: azvm my-resource-group
azvm() { az vm list -g "${1:?Usage: azvm <resource-group>}" --output table; }

# azweb: list App Service web apps
alias azweb="az webapp list --output table"

# azgroup: list all resource groups
alias azgroup="az group list --output table"

# azaks: list AKS clusters across all resource groups
alias azaks="az aks list --output table"

# azlogs: stream logs from an App Service
azlogs() { az webapp log tail --name "${1:?}" --resource-group "${2:?}"; }
