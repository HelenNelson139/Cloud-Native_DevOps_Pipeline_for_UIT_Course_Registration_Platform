# Prometheus Queries

Use these queries for before/after comparison. Adjust the time range in Grafana
or Prometheus to match the k6 run window.

## API Gateway RPS

```promql
sum(rate(api_gateway_http_requests_total{namespace="default",service=~"api-gateway-stable|api-gateway-canary"}[5m]))
```

## API Gateway 5xx Rate

```promql
sum(rate(api_gateway_http_requests_total{namespace="default",service=~"api-gateway-stable|api-gateway-canary",status_code=~"5.."}[5m]))
/
clamp_min(sum(rate(api_gateway_http_requests_total{namespace="default",service=~"api-gateway-stable|api-gateway-canary"}[5m])), 0.001)
```

## API Gateway P95 Latency

```promql
histogram_quantile(
  0.95,
  sum by (le) (
    rate(api_gateway_http_request_duration_seconds_bucket{namespace="default",service=~"api-gateway-stable|api-gateway-canary"}[5m])
  )
)
```

## Service RPS

```promql
sum by (service) (rate(uit_course_http_requests_total{namespace="default"}[5m]))
```

## Service 5xx Rate

```promql
sum by (service) (rate(uit_course_http_requests_total{namespace="default",status_code=~"5.."}[5m]))
/
clamp_min(sum by (service) (rate(uit_course_http_requests_total{namespace="default"}[5m])), 0.001)
```

## Service P95 Latency

```promql
histogram_quantile(
  0.95,
  sum by (service, le) (
    rate(uit_course_http_request_duration_seconds_bucket{namespace="default"}[5m])
  )
)
```

## HPA Current Replicas

```promql
kube_horizontalpodautoscaler_status_current_replicas{namespace="default"}
```

## HPA Max Replicas

```promql
kube_horizontalpodautoscaler_spec_max_replicas{namespace="default"}
```

## Container CPU Usage

```promql
sum by (pod) (
  rate(container_cpu_usage_seconds_total{namespace="default",container!="",container!="POD"}[5m])
)
```

## Container Memory Working Set

```promql
sum by (pod) (
  container_memory_working_set_bytes{namespace="default",container!="",container!="POD"}
)
```

