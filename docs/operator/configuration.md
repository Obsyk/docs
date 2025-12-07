# Operator Configuration

Customize the Obsyk operator behavior for your environment.

## Helm Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `platformUrl` | Obsyk platform API URL | `https://api.obsyk.ai` |
| `existingSecret` | Name of secret with credentials | `""` |
| `clientId` | OAuth2 client ID (if not using secret) | `""` |
| `clientSecret` | OAuth2 client secret (if not using secret) | `""` |
| `logLevel` | Logging verbosity (debug, info, warn, error) | `info` |
| `syncInterval` | Full sync interval | `5m` |
| `heartbeatInterval` | Heartbeat frequency | `30s` |

## Resource Limits

Configure resource allocation:

```yaml
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

## Namespace Filtering

By default, the operator watches all namespaces. To limit scope:

```yaml
# Watch only specific namespaces
namespaceSelector:
  matchLabels:
    obsyk.io/monitor: "true"

# Or exclude namespaces
excludeNamespaces:
  - kube-system
  - kube-public
```

## Resource Type Filtering

Disable monitoring for specific resource types:

```yaml
resources:
  pods: true
  deployments: true
  secrets: false  # Don't monitor secrets
  configmaps: false
```

## Network Configuration

For clusters behind proxies:

```yaml
env:
  - name: HTTPS_PROXY
    value: "http://proxy.example.com:8080"
  - name: NO_PROXY
    value: "kubernetes.default.svc"
```

## High Availability

For production clusters, consider:

```yaml
replicaCount: 2

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app: obsyk-operator
          topologyKey: kubernetes.io/hostname
```

## Troubleshooting Configuration

Enable debug logging:

```bash
helm upgrade obsyk-operator obsyk/obsyk-operator \
  --namespace obsyk-system \
  --set logLevel=debug
```

Check current configuration:

```bash
kubectl get cm -n obsyk-system obsyk-operator-config -o yaml
```
