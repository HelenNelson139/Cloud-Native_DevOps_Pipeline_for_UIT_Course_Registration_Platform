# HPA-Enabled Benchmark Run

Date: 2026-06-27
Cluster context: `devops-aks`
Public URL: `http://20.44.237.162`
Script: `performance/scripts/read-only-load.js`
Mode: read-only, no enroll/cancel mutation

## Workload

| Field | Value |
| --- | ---: |
| Virtual users | 10 |
| Duration | 120s |
| Think time | 500ms |
| Endpoints per iteration | 5 |
| Data mutation | No |

Endpoints:

- `POST /api/auth/login`
- `GET /api/courses`
- `GET /api/courses/stats`
- `GET /api/registrations/available-classes`
- `GET /api/registrations/my-classes`

## Result

| Metric | Value |
| --- | ---: |
| Total HTTP requests | 760 |
| Failed requests | 1 |
| Request failure rate | 0.13% |
| Checks pass rate | 99.87% |
| Average RPS | 6.333 |
| P50 latency | 1458.74 ms |
| P95 latency | 4248.95 ms |
| P99 latency | 5667.31 ms |
| Max latency | 7216.89 ms |

## Endpoint Breakdown

| Endpoint | Requests | Failed | P50 | P95 | P99 | Max |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| login | 152 | 0 | 129.19 ms | 822.47 ms | 1343.54 ms | 1439.82 ms |
| courses | 152 | 1 | 3579.74 ms | 5667.31 ms | 6881.55 ms | 7216.89 ms |
| course_stats | 152 | 0 | 1789.84 ms | 2866.34 ms | 3781.67 ms | 4243.80 ms |
| available_classes | 152 | 0 | 1703.55 ms | 2646.61 ms | 3171.65 ms | 3315.83 ms |
| my_classes | 152 | 0 | 39.53 ms | 62.42 ms | 108.60 ms | 218.70 ms |

## HPA State After Run

| HPA | CPU target | Replicas |
| --- | --- | ---: |
| api-gateway-hpa | 13%/70% | 2 |
| auth-service-hpa | 35%/70% | 2 |
| course-service-hpa | 30%/70% | 10 |
| notification-service-hpa | 2%/70% | 2 |
| registration-service-hpa | 43%/70% | 2 |

## Evidence Files

- `performance/reports/node-hpa-enabled-10vu-2m-summary.json`
- Cluster snapshots were collected with `performance/scripts/collect-snapshot.ps1`
  during the run and are ignored as generated run artifacts.

## Interpretation

This run proves the application can serve the read-only registration workload at
10 virtual users with a 0.13% request failure rate and 99.87% checks pass rate.

It does not prove an HPA improvement percentage yet because no fixed-replica
baseline was run under the same conditions. The next step is to run the same
script in a controlled baseline window with HPA disabled or fixed replicas.
