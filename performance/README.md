# Performance Benchmark

This folder contains repeatable benchmark assets for comparing a basic deployment
against the DevOps-optimized setup in this repository.

The first benchmark target is HPA effectiveness:

- Baseline: fixed replicas, no HPA reaction.
- Optimized: Kubernetes HPA enabled with the repository settings.

The default k6 workload is read-only. It logs in, reads course data, reads
registration views, and avoids enroll/cancel mutations.

## What This Benchmark Can Prove

Use it to produce evidence for CV claims such as:

- P95/P99 latency under a fixed number of virtual users.
- HTTP error rate under load.
- RPS handled by the public ingress.
- Replica scaling behavior from HPA.
- CPU and memory behavior from Prometheus.

Do not claim throughput or latency improvements until both baseline and optimized
runs have been executed under the same workload and duration.

## Requirements

Either install k6 locally or run it through Docker.

```powershell
docker --version
kubectl config current-context
kubectl get hpa -n default
```

If neither local k6 nor Docker is available, use the dependency-free Node.js
load script:

```powershell
node performance/scripts/read-only-load.js `
  --baseUrl "http://20.44.237.162" `
  --studentId "23520718" `
  --password "password" `
  --vus 20 `
  --duration 3m `
  --out "performance/reports/node-hpa-enabled-summary.json"
```

## Run A Read-Only Benchmark

From the repository root:

```powershell
.\performance\scripts\run-k6-docker.ps1 `
  -BaseUrl "http://20.44.237.162" `
  -StudentId "23520718" `
  -Password "password" `
  -Vus 20 `
  -Duration "3m" `
  -OutFile "performance/reports/k6-hpa-enabled-summary.json"
```

For local k6:

```powershell
$env:BASE_URL="http://20.44.237.162"
$env:STUDENT_ID="23520718"
$env:PASSWORD="password"
$env:VUS="20"
$env:DURATION="3m"
k6 run --summary-export performance/reports/k6-summary.json performance/k6/registration-readonly.js
```

## Collect Cluster Snapshot

Run before and after each k6 run:

```powershell
.\performance\scripts\collect-snapshot.ps1 `
  -Label "hpa-enabled-before" `
  -OutDir "performance/reports"
```

This captures pods, services, HPA, deployments, ingress, rollout status, and
resource usage when metrics-server is available.

## Baseline Vs Optimized Procedure

1. Record the current state.
2. Run the optimized benchmark with the current HPA configuration.
3. Save the k6 summary and cluster snapshots.
4. For a true baseline, run the same workload with HPA disabled or with fixed
   replica counts in a controlled maintenance window.
5. Compare the two runs in `performance/reports/template.md`.

Cluster-mutating baseline commands are intentionally not automated here because
they change live AKS behavior. Run them only when the environment is safe to
modify.

Example baseline commands:

```powershell
kubectl get hpa -n default -o yaml > performance/reports/hpa-backup.yaml
kubectl delete hpa -n default --all
kubectl scale deployment/auth-service -n default --replicas=2
kubectl scale deployment/course-service -n default --replicas=2
kubectl scale deployment/registration-service -n default --replicas=2
kubectl scale deployment/notification-service -n default --replicas=2
kubectl argo rollouts set image api-gateway-rollout api-gateway=$(kubectl get rollout api-gateway-rollout -n default -o jsonpath='{.spec.template.spec.containers[0].image}') -n default
```

Restore HPA:

```powershell
kubectl apply -f k8s/autoscaling/hpa.yaml
```

## Metrics To Report

Use these fields from the k6 summary:

- `http_reqs`
- `http_req_failed`
- `http_req_duration` p95 and p99
- endpoint-specific duration trends
- checks pass rate

Use Prometheus queries from `performance/prometheus/queries.md` for:

- RPS
- 5xx rate
- P95 latency
- CPU
- memory
- HPA replica count
