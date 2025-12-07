# Inventory Browser

The Inventory page provides a hierarchical view of all resources across your clusters.

## Navigation Levels

The inventory uses a drill-down navigation pattern:

```
Clusters → Namespaces → Resources → Resource Details
```

### Level 1: Cluster List

View all connected clusters with:

- Cluster name and status
- Platform (EKS, GKE, AKS, etc.)
- Region
- Resource counts

### Level 2: Cluster Detail

Select a cluster to see:

- **Namespaces tab** - All namespaces with resource counts
- **Nodes tab** - Worker nodes with capacity and status

### Level 3: Namespace Detail

Select a namespace to view resources by category:

| Category | Resources |
|----------|-----------|
| **Workloads** | Pods, Deployments, StatefulSets, DaemonSets, Jobs, CronJobs |
| **Services** | Services, Ingresses, Endpoints |
| **Config** | ConfigMaps, Secrets |
| **RBAC** | ServiceAccounts, Roles, RoleBindings |

### Level 4: Resource Detail

Select a resource (e.g., a Pod) to see:

- Metadata and labels
- Status and conditions
- Related resources (containers, volumes, events)

## Using Breadcrumbs

The breadcrumb navigation at the top allows quick jumps:

- Click any segment to return to that level
- Use dropdowns to switch between siblings (e.g., different namespaces)

## Filtering and Search

- Use the search box to filter resources by name
- Status badges help identify issues at a glance
