# Operations
Operational commands for checking the AKS deployment and controlling Azure cost.
## Useful Checks
```powershell
kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get ingress
kubectl get rollout
kubectl get hpa
kubectl get applications -n argocd
```
Check API Gateway metrics through the stable service:
```powershell
kubectl port-forward -n default svc/api-gateway-stable 8088:80
Invoke-WebRequest -UseBasicParsing http://localhost:8088/metrics
```

## Pause And Resume Azure Resources
To reduce Azure cost when the project is not in use, stop the main paid resources.
### Stop Resources
Stop AKS:
```powershell
az aks stop `
  --resource-group uit-dkhp-rg `
  --name devops-aks
```
Stop Azure PostgreSQL:
```powershell
az postgres flexible-server stop `
  --resource-group uit-dkhp-rg `
  --name uit-dkhp-pg-server
```
Check status:
```powershell
az aks show `
  --resource-group uit-dkhp-rg `
  --name devops-aks `
  --query powerState.code `
  -o tsv
az postgres flexible-server show `
  --resource-group uit-dkhp-rg `
  --name uit-dkhp-pg-server `
  --query state `
  -o tsv
```
### Start Resources Again

Start Azure PostgreSQL first:
```powershell
az postgres flexible-server start `
  --resource-group uit-dkhp-rg `
  --name uit-dkhp-pg-server
```
Start AKS:
```powershell
az aks start `
  --resource-group uit-dkhp-rg `
  --name devops-aks
```
Get AKS credentials:
```powershell
az aks get-credentials `
  --resource-group uit-dkhp-rg `
  --name devops-aks `
  --overwrite-existing
```
Check after starting:
```powershell
kubectl get nodes
kubectl get pods
kubectl get applications -n argocd
kubectl get ingress
kubectl get rollout
kubectl get hpa
```
