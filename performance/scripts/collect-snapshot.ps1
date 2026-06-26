param(
  [string]$Label = "snapshot",
  [string]$Namespace = "default",
  [string]$OutDir = "performance/reports"
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$safeLabel = $Label -replace "[^A-Za-z0-9_.-]", "-"
$outFile = Join-Path $OutDir "$timestamp-$safeLabel-cluster-snapshot.txt"

function Write-Section {
  param([string]$Title)
  Add-Content -Path $outFile -Value ""
  Add-Content -Path $outFile -Value "==== $Title ===="
}

"timestamp=$(Get-Date -Format o)" | Set-Content -Path $outFile
"context=$(kubectl config current-context)" | Add-Content -Path $outFile
"namespace=$Namespace" | Add-Content -Path $outFile

Write-Section "nodes"
kubectl get nodes -o wide | Add-Content -Path $outFile

Write-Section "pods"
kubectl get pods -n $Namespace -o wide | Add-Content -Path $outFile

Write-Section "services"
kubectl get svc -n $Namespace -o wide | Add-Content -Path $outFile

Write-Section "ingress"
kubectl get ingress -n $Namespace -o wide | Add-Content -Path $outFile

Write-Section "deployments"
kubectl get deploy -n $Namespace -o wide | Add-Content -Path $outFile

Write-Section "hpa"
kubectl get hpa -n $Namespace -o wide | Add-Content -Path $outFile

Write-Section "rollouts"
kubectl get rollout -n $Namespace -o wide | Add-Content -Path $outFile

Write-Section "top pods"
kubectl top pods -n $Namespace 2>&1 | Add-Content -Path $outFile

Write-Section "top nodes"
kubectl top nodes 2>&1 | Add-Content -Path $outFile

Write-Output $outFile

