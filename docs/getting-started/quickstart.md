# Quick Start

Get Obsyk running in under 5 minutes.

## 1. Register Your Cluster

In the Obsyk dashboard:

```
Clusters → Add Cluster → Enter name → Copy credentials
```

## 2. Install the Operator

```bash
# Add the Obsyk Helm repository
helm repo add obsyk https://charts.obsyk.ai
helm repo update

# Install the operator
helm install obsyk-operator obsyk/obsyk-operator \
  --namespace obsyk-system \
  --create-namespace \
  --set clientId=YOUR_CLIENT_ID \
  --set clientSecret=YOUR_CLIENT_SECRET \
  --set platformUrl=https://api.obsyk.ai
```

## 3. Verify Installation

```bash
# Check operator is running
kubectl get pods -n obsyk-system

# Check operator logs
kubectl logs -n obsyk-system -l app=obsyk-operator
```

## 4. View Your Cluster

Return to the Obsyk dashboard. Your cluster should now appear with:

- **Status**: Connected
- **Namespaces**: List of discovered namespaces
- **Resources**: Pods, deployments, services, and more

## What's Next?

- [Explore the Inventory](../user-guide/inventory.md) - Navigate your cluster resources
- [Operator Configuration](../operator/configuration.md) - Customize what gets monitored
- [API Reference](https://developers.obsyk.ai) - Integrate with your tools
