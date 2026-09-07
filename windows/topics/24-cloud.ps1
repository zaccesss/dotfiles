# =============================================================================
# Cloud platform CLIs - Windows PowerShell
# Install: winget install Amazon.AWSCLI Google.CloudSDK Microsoft.AzureCLI
# =============================================================================

function awsprofiles { aws configure list-profiles }
function awsp       { param($Profile) $env:AWS_PROFILE = $Profile; Write-Host "AWS_PROFILE=$Profile" }
function awswho     { aws sts get-caller-identity }
function awsls      { aws s3 ls }
function awsec2     { aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==`running`].[InstanceId,InstanceType,PublicIpAddress]' --output table }
function awseks     { aws eks list-clusters --output table }
function awslogs    { param($Group) aws logs tail $Group --follow }
function awslambda  { aws lambda list-functions --query 'Functions[].FunctionName' --output table }
function awsregion  { param($Region) $env:AWS_DEFAULT_REGION = $Region; Write-Host "Region: $Region" }

function gcfg       { gcloud config list }
function gcconfigs  { gcloud config configurations list }
function gcactivate { param($ConfigName) gcloud config configurations activate $ConfigName }
function gcproj     { param($ProjectId) gcloud config set project $ProjectId }
function gcwho      { gcloud auth list }
function gcrun      { gcloud run services list }
function gcbuild    { gcloud builds list --limit 10 }
function gcvms      { gcloud compute instances list }
function gcgke      { gcloud container clusters list }

function azwho      { az account show }
function azls       { az account list --output table }
function azsub      { param($Sub) az account set --subscription $Sub }
function azvm       { param($Rg) az vm list -g $Rg --output table }
function azweb      { az webapp list --output table }
function azgroup    { az group list --output table }
function azaks      { az aks list --output table }
function azlogs     { param($Name, $Rg) az webapp log tail --name $Name --resource-group $Rg }
