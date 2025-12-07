# User Guide Overview

This guide covers how to use the Obsyk platform to monitor and manage your Kubernetes clusters.

## Dashboard Navigation

The Obsyk dashboard provides several key areas:

| Section | Description |
|---------|-------------|
| **Overview** | Summary of all connected clusters |
| **Inventory** | Hierarchical view of cluster resources |
| **Clusters** | Cluster management and connection status |
| **Users** | Team member management |
| **Settings** | Organization and API key configuration |

## Key Concepts

### Clusters

A cluster represents a Kubernetes cluster connected via the Obsyk operator. Each cluster:

- Has a unique identifier
- Reports resources in real-time
- Shows connection status and health

### Namespaces

Namespaces within each cluster are organized by resource type:

- **Workloads** - Pods, Deployments, StatefulSets, DaemonSets, Jobs
- **Services** - Services, Ingresses, Endpoints
- **Config** - ConfigMaps, Secrets
- **RBAC** - ServiceAccounts, Roles, RoleBindings

### Resources

Resources are the Kubernetes objects monitored by Obsyk:

- Real-time status and health
- Configuration details
- Relationship mapping

## Getting Help

- Use the **Help** section in the dashboard for FAQs
- Check [Troubleshooting](../reference/troubleshooting.md) for common issues
- Contact support via the dashboard
