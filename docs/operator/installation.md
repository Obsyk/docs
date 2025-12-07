# Operator Installation

Deploy the Obsyk operator to your Kubernetes cluster.

## Prerequisites

- Kubernetes cluster v1.24+
- `kubectl` with cluster admin access
- `helm` v3.x
- Obsyk account with cluster credentials

## Installation Methods

### Helm (Recommended)

```bash
# Add the Obsyk Helm repository
helm repo add obsyk https://charts.obsyk.ai
helm repo update

# Create namespace
kubectl create namespace obsyk-system

# Create secret with credentials
kubectl create secret generic obsyk-credentials \
  --namespace obsyk-system \
  --from-literal=client-id=YOUR_CLIENT_ID \
  --from-literal=client-secret=YOUR_CLIENT_SECRET

# Install the operator
helm install obsyk-operator obsyk/obsyk-operator \
  --namespace obsyk-system \
  --set existingSecret=obsyk-credentials
```

### Helm with Values File

Create `values.yaml`:

```yaml
platformUrl: https://api.obsyk.ai

existingSecret: obsyk-credentials

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

# Optional: limit watched namespaces
namespaceSelector: {}
```

Install:

```bash
helm install obsyk-operator obsyk/obsyk-operator \
  --namespace obsyk-system \
  --values values.yaml
```

## Verify Installation

```bash
# Check pod status
kubectl get pods -n obsyk-system

# Expected output:
# NAME                              READY   STATUS    RESTARTS   AGE
# obsyk-operator-7d9f8b6c4-xxxxx    1/1     Running   0          1m

# Check logs
kubectl logs -n obsyk-system -l app=obsyk-operator --tail=50
```

## Upgrading

```bash
helm repo update
helm upgrade obsyk-operator obsyk/obsyk-operator \
  --namespace obsyk-system
```

## Uninstalling

```bash
helm uninstall obsyk-operator -n obsyk-system
kubectl delete namespace obsyk-system
```

!!! note "Cluster Data"
    Uninstalling the operator stops data collection. The cluster will show as disconnected in Obsyk but historical data is retained.
