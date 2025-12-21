# GitOps Deployment

Deploy and manage the Obsyk operator using GitOps tools for automated, declarative cluster management.

## Why GitOps?

- **Declarative**: Define your desired state in Git
- **Auditable**: Full history of all changes
- **Automated**: Continuous reconciliation
- **Rollback**: Easy recovery from failed deployments

## Flux CD

Flux CD supports automatic version upgrades using semver ranges.

### Prerequisites

- Flux CD v2 installed ([installation guide](https://fluxcd.io/docs/installation/))
- kubectl configured for your cluster
- Obsyk credentials (Client ID and Private Key)

### Create a HelmRepository

Create `obsyk-helmrepository.yaml`:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: obsyk
  namespace: flux-system
spec:
  interval: 1h
  url: https://obsyk.github.io/obsyk-operator
```

Apply:

```bash
kubectl apply -f obsyk-helmrepository.yaml
```

### Create a Credentials Secret

```bash
kubectl create namespace obsyk-system

kubectl create secret generic obsyk-credentials \
  --namespace obsyk-system \
  --from-literal=clientId=YOUR_CLIENT_ID \
  --from-file=privateKey=private-key.pem
```

### Create a HelmRelease

Create `obsyk-helmrelease.yaml`:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: obsyk-operator
  namespace: obsyk-system
spec:
  interval: 15m
  chart:
    spec:
      chart: obsyk-operator
      version: ">=0.3.0"
      sourceRef:
        kind: HelmRepository
        name: obsyk
        namespace: flux-system
      interval: 5m
  install:
    createNamespace: true
  values:
    agent:
      clusterName: "my-cluster"
      platformURL: "https://api.obsyk.ai"
      credentialsSecretRef:
        name: obsyk-credentials
```

Apply:

```bash
kubectl apply -f obsyk-helmrelease.yaml
```

### Automatic Upgrades

The `version: ">=0.3.0"` field enables automatic upgrades. Flux checks for new versions every 5 minutes and upgrades automatically.

| Pattern | Behavior |
|---------|----------|
| `>=0.3.0` | Any version 0.3.0 or higher |
| `0.3.x` | Any 0.3.x patch version |
| `>=0.3.0 <1.0.0` | 0.x versions only |

!!! tip "Production Recommendation"
    Use `>=0.3.0 <1.0.0` to auto-upgrade patches and minors while avoiding breaking major version changes.

### Verify Installation

```bash
# Check HelmRelease status
flux get helmrelease obsyk-operator -n obsyk-system

# View operator pods
kubectl get pods -n obsyk-system
```

### Troubleshooting

Force reconciliation:

```bash
flux reconcile helmrelease obsyk-operator -n obsyk-system
```

View logs:

```bash
flux logs --kind=HelmRelease --name=obsyk-operator
```

---

## ArgoCD

ArgoCD provides declarative GitOps with a web UI for visibility.

### Prerequisites

- ArgoCD installed ([installation guide](https://argo-cd.readthedocs.io/en/stable/getting_started/))
- kubectl configured for your cluster
- Obsyk credentials (Client ID and Private Key)

### Create a Credentials Secret

```bash
kubectl create namespace obsyk-system

kubectl create secret generic obsyk-credentials \
  --namespace obsyk-system \
  --from-literal=clientId=YOUR_CLIENT_ID \
  --from-file=privateKey=private-key.pem
```

### Create an Application

Create `obsyk-application.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: obsyk-operator
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://obsyk.github.io/obsyk-operator
    chart: obsyk-operator
    targetRevision: "0.3.5"
    helm:
      values: |
        agent:
          clusterName: "my-cluster"
          platformURL: "https://api.obsyk.ai"
          credentialsSecretRef:
            name: obsyk-credentials
  destination:
    server: https://kubernetes.default.svc
    namespace: obsyk-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

Apply:

```bash
kubectl apply -f obsyk-application.yaml
```

### Upgrading

To upgrade, update `targetRevision` to the new version and commit to Git:

```yaml
targetRevision: "0.4.0"
```

!!! tip "Automate Version Updates"
    Use [Renovate](https://docs.renovatebot.com/modules/manager/argocd/) to automatically create PRs when new versions are available.

### Verify Installation

Via ArgoCD UI:

1. Open ArgoCD web interface
2. Find `obsyk-operator` application
3. Check sync status shows "Synced" and "Healthy"

Via CLI:

```bash
argocd app get obsyk-operator
kubectl get pods -n obsyk-system
```

### Troubleshooting

Force sync:

```bash
argocd app sync obsyk-operator --force
```

View diff:

```bash
argocd app diff obsyk-operator
```

---

## Comparison

| Feature | Flux CD | ArgoCD |
|---------|---------|--------|
| **Auto-upgrade** | :material-check: Native semver ranges | :material-close: Manual (use Renovate) |
| **Web UI** | :material-close: CLI only | :material-check: Rich dashboard |
| **Best for** | Platform teams, automation | Application teams, visibility |

---

## Next Steps

- [Operator Configuration](configuration.md) - Customize operator settings
- [Security](security.md) - Review security best practices
