# Quick Start

Get Obsyk running in under 5 minutes.

## 1. Register Your Cluster

In the Obsyk dashboard:

```
Integrations → Add Cluster → Enter name → Generate credentials → Download private key
```

## 2. Install the Operator

```bash
# Add the Obsyk Helm repository
helm repo add obsyk https://obsyk.github.io/obsyk-operator
helm repo update

# Create namespace and credentials secret
kubectl create namespace obsyk-system
kubectl create secret generic obsyk-credentials \
  --namespace obsyk-system \
  --from-literal=client_id=YOUR_CLIENT_ID \
  --from-file=private_key=your-cluster-private-key.pem

# Install the operator
helm install obsyk-operator obsyk/obsyk-operator \
  --namespace obsyk-system \
  --set agent.clusterName="your-cluster-name" \
  --set agent.platformURL="https://app.obsyk.ai"
```

## 3. Verify Installation

```bash
# Check operator is running
kubectl get pods -n obsyk-system

# Check operator logs
kubectl logs -n obsyk-system -l app.kubernetes.io/name=obsyk-operator
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
