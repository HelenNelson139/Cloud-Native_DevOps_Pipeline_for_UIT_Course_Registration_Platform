# Terraform Azure Infrastructure
Terraform is used to provision the Azure infrastructure for the UIT Course Registration platform.
## Resources Created
- Resource Group
- Virtual Network and subnets
- Azure Container Registry
- Azure Kubernetes Service
- AKS node autoscaling
- Azure Database for PostgreSQL Flexible Server
- Private DNS for PostgreSQL
- Role assignment for AKS to pull images from ACR
- kube-prometheus-stack Helm release for monitoring
## Prerequisites
Login to Azure:
```powershell
az login
az account show
```
Install Terraform if needed:
```powershell
winget install Hashicorp.Terraform
terraform -version
```
## Remote State Backend
Terraform state is stored in Azure Storage so it is not tied to one local machine.
Run from the Terraform folder:
```powershell
cd terraform
```
Create the backend resources once:
```powershell
$TFSTATE_RG="uit-tfstate-rg"
$TFSTATE_LOCATION="southeastasia"
$TFSTATE_STORAGE="uitdkhptfstate0001"

az group create --name $TFSTATE_RG --location $TFSTATE_LOCATION
az storage account create --name $TFSTATE_STORAGE --resource-group $TFSTATE_RG --location $TFSTATE_LOCATION --sku Standard_LRS --kind StorageV2 --allow-blob-public-access false
az storage container create --name tfstate --account-name $TFSTATE_STORAGE --auth-mode login
```
`$TFSTATE_STORAGE` must be globally unique, lowercase, and contain only letters and numbers.
Create local backend config:
```powershell
Copy-Item backend.hcl.example backend.hcl
```
Edit `backend.hcl` and set the real storage account name:
```hcl
resource_group_name  = "uit-tfstate-rg"
storage_account_name = "uitdkhptfstate0001"
container_name       = "tfstate"
key                  = "uit-course.terraform.tfstate"
```
Migrate existing local state to Azure Storage:
```powershell
terraform init -backend-config=backend.hcl -migrate-state
```
`backend.hcl` is local-only and must not be committed.

## Run Terraform
```powershell
cd terraform
terraform init -backend-config=backend.hcl
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```
When Terraform asks for confirmation, type:
```text
yes
```
Terraform will ask for:
```text
var.db_admin_password
```
This is the PostgreSQL admin password for user `pgadmin`.
Use a strong password and do not commit real passwords or `.tfvars` files.

Common values can be overridden with a local `.tfvars` file or GitHub Actions secrets/variables:

```hcl
environment                  = "dev"
acr_sku                      = "Basic"
aks_min_count                = 1
aks_max_count                = 3
enable_monitoring            = true
db_backup_retention_days     = 7
db_geo_redundant_backup_enabled = false
tags = {
  Owner = "uit-devops"
}
```

For low-cost lab runs, keep `db_geo_redundant_backup_enabled = false` and `aks_min_count = 1`. For production, review these values before enabling security gates.

In GitHub Actions, Terraform only runs `plan/apply` when repository variable `ENABLE_TERRAFORM_APPLY` is set to `true` and required secrets are configured. Otherwise, the workflow stops after fmt, Checkov, init, and validate.

## Security Scanning
GitHub Actions runs Checkov against Terraform. Lab-only cost and access tradeoffs are documented inline with `checkov:skip` comments, for example ACR Premium-only controls, private AKS API endpoint, paid AKS SLA, customer-managed disk encryption, and PostgreSQL geo-redundant backups.

Local check:
```powershell
checkov -d terraform --framework terraform --quiet --skip-path terraform/.terraform --skip-path terraform/terraform.tfstate --skip-path terraform/terraform.tfstate.backup
```

After `terraform apply`, connect `kubectl` to the created AKS cluster:
```powershell
az aks get-credentials `
  --resource-group uit-dkhp-rg `
  --name devops-aks `
  --overwrite-existing

kubectl get nodes
```

## Monitoring Helm Release
Terraform manages the `kube-prometheus-stack` Helm release through `modules/monitoring`.

The Helm provider uses the AKS kubeconfig values exported by the AKS module, so GitHub Actions does not depend on an existing `~/.kube/config` file. Set `enable_monitoring = false` if you want Terraform to provision only Azure infrastructure first.

If monitoring was already installed manually by script, import the existing Helm release before running `terraform apply`:
```powershell
terraform import module.monitoring.helm_release.kube_prometheus_stack monitoring/prometheus
```

Project-specific rules, ServiceMonitors, dashboards, and Teams webhook setup are still applied from the `monitoring/` scripts:
```powershell
.\monitoring\scripts\apply-monitoring-rules.ps1
```
```bash
bash monitoring/scripts/apply-monitoring-rules.sh
```

## Outputs
```powershell
terraform output
```
Check remote state:
```powershell
az storage blob list `
  --account-name $TFSTATE_STORAGE `
  --container-name tfstate `
  --auth-mode login `
  --output table
```

Check AKS node autoscaling:
```powershell
az aks nodepool show `
  --resource-group uit-dkhp-rg `
  --cluster-name devops-aks `
  --name default `
  --query "{enableAutoScaling:enableAutoScaling,minCount:minCount,maxCount:maxCount,count:count}"
```

## Connect To AKS
```powershell
az aks get-credentials --resource-group uit-dkhp-rg --name devops-aks --overwrite-existing
kubectl get nodes
```
## Cleanup
To delete Azure resources:
```powershell
cd terraform
terraform destroy
```
