# Current AKS State Snapshot

Date: 2026-06-27
Context: `devops-aks`
Ingress IP: `20.44.237.162`

This is a read-only observation before adding benchmark runs.

## HPA State

| HPA | Target | Min | Max | Current replicas | CPU target |
| --- | --- | ---: | ---: | ---: | --- |
| api-gateway-hpa | Rollout/api-gateway-rollout | 2 | 10 | 2 | 1%/70% |
| auth-service-hpa | Deployment/auth-service | 2 | 10 | 2 | 1%/70% |
| course-service-hpa | Deployment/course-service | 2 | 10 | 10 | 22%/70% |
| notification-service-hpa | Deployment/notification-service | 2 | 5 | 2 | 2%/70% |
| registration-service-hpa | Deployment/registration-service | 2 | 10 | 2 | 1%/70% |

## Interpretation

The current cluster already shows HPA behavior: `course-service` is at its max
replica count of 10 while the other services remain at their minimum of 2.

This observation alone is not a controlled benchmark. It is useful evidence that
HPA is active, but before/after performance claims still require a k6 run and
matching Prometheus/Grafana evidence.

