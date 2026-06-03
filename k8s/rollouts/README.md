# Argo Rollouts Canary Release
This folder contains the manifests for AI-assisted canary release on AKS.
## Files
- `canary-ai-agent.yaml`: deploys the AI decision service.
- `analysis-template.yaml`: lets Argo Rollouts call the AI agent.
- `api-gateway-rollout.yaml`: defines canary rollout for `api-gateway`.
## Install Argo Rollouts
```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```
Check:
```bash
kubectl get pods -n argo-rollouts
```
## Build AI Agent Image Manually

In the normal GitOps flow, GitHub Actions builds and pushes the AI Agent image. Use this only for a manual test:
```powershell
az acr login --name uitdkhpacr2026
docker build -t uitdkhpacr2026.azurecr.io/canary-ai-agent:latest .\ai-agent
docker push uitdkhpacr2026.azurecr.io/canary-ai-agent:latest
```
## Apply
```powershell
kubectl apply -f k8s/rollouts/canary-ai-agent.yaml
kubectl apply -f k8s/rollouts/analysis-template.yaml
kubectl apply -f k8s/rollouts/api-gateway-rollout.yaml
```
## Check
```powershell
kubectl get pods -l app=canary-ai-agent
kubectl logs deploy/canary-ai-agent --tail=50
kubectl get rollout
kubectl describe rollout api-gateway-rollout
kubectl get analysisrun
```
Watch a rollout:
```powershell
kubectl get rollout api-gateway-rollout -n default -w
```

Retry an aborted rollout:
```powershell
.\kubectl-argo-rollouts.exe retry rollout api-gateway-rollout -n default
```

Check the AI Agent service:
```powershell
kubectl port-forward -n default svc/canary-ai-agent-svc 8085:80
Invoke-RestMethod http://localhost:8085/health
Invoke-RestMethod http://localhost:8085/model
```
## Prometheus Metric Checks
The AI agent needs Prometheus data for the rollout pods and for stable/canary traffic.
Check that the pod selector used by `analysis-template.yaml` matches real rollout pods:
```powershell
kubectl get pods -n default -l app=api-gateway
kubectl logs deploy/canary-ai-agent -n default | Select-String "history_build"
```
If `metrics_raw` is all zero, verify the Prometheus queries used by the agent. The rollout pod metrics should match:
```promql
container_cpu_usage_seconds_total{namespace="default",pod=~"api-gateway-rollout-.*"}
container_memory_working_set_bytes{namespace="default",pod=~"api-gateway-rollout-.*"}
```
HTTP traffic metrics must also exist for the stable and canary services, or the agent will return `Running` with `reason="insufficient_data"`:
```promql
api_gateway_http_requests_total{namespace="default",service=~"api-gateway-canary|api-gateway-stable"}
api_gateway_http_request_duration_seconds_bucket{namespace="default",service=~"api-gateway-canary|api-gateway-stable"}
```
