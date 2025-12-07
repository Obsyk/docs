# Managing Clusters

Learn how to add, manage, and remove clusters in Obsyk.

## Adding a Cluster

1. Navigate to **Clusters** in the sidebar
2. Click **Add Cluster**
3. Enter a descriptive name for your cluster
4. Click **Create**

Obsyk generates OAuth2 credentials for the operator:

- **Client ID** - Public identifier for authentication
- **Client Secret** - Private key (shown only once)

!!! tip "Naming Convention"
    Use descriptive names like `prod-us-east-1` or `staging-gke` to easily identify clusters.

## Cluster Status

Each cluster displays its current status:

| Status | Description |
|--------|-------------|
| **Connected** | Operator is actively sending data |
| **Disconnected** | No recent communication from operator |
| **Pending** | Cluster registered but operator not yet installed |

## Cluster Details

Click on a cluster to view:

- **Overview** - Resource counts and cluster metadata
- **Namespaces** - All namespaces with resource summaries
- **Nodes** - Worker nodes and their status

## Removing a Cluster

1. Click on the cluster to open details
2. Click **Delete Cluster**
3. Confirm the deletion

!!! warning "Data Retention"
    Deleting a cluster removes all associated data. This action cannot be undone.

Before deleting, uninstall the operator from your cluster:

```bash
helm uninstall obsyk-operator -n obsyk-system
```
