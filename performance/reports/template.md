# Benchmark Report Template

Run label:
Date:
Cluster:
Commit SHA:
Public URL:

## Workload

| Field | Value |
| --- | --- |
| Tool | k6 |
| Script | `performance/k6/registration-readonly.js` |
| Virtual users |  |
| Duration |  |
| Think time |  |
| Data mutation | No |

## Results

| Metric | Baseline | Optimized | Change |
| --- | ---: | ---: | ---: |
| Total HTTP requests |  |  |  |
| Avg RPS |  |  |  |
| HTTP failure rate |  |  |  |
| P95 latency |  |  |  |
| P99 latency |  |  |  |
| Login P95 |  |  |  |
| Courses P95 |  |  |  |
| Registration read P95 |  |  |  |
| Max API Gateway replicas |  |  |  |
| Max auth replicas |  |  |  |
| Max course replicas |  |  |  |
| Max registration replicas |  |  |  |
| Max notification replicas |  |  |  |

## Evidence Files

- Baseline k6 summary:
- Optimized k6 summary:
- Baseline cluster snapshot before:
- Baseline cluster snapshot after:
- Optimized cluster snapshot before:
- Optimized cluster snapshot after:
- Grafana dashboard screenshots:

## Interpretation

Write only claims directly supported by the table above.

Example:

> Under the same read-only registration workload, HPA increased the course
> service from 2 to N replicas and reduced P95 latency from X ms to Y ms while
> keeping HTTP errors below Z%.

