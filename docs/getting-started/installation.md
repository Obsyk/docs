# Installation

This guide covers setting up your Obsyk account and preparing to connect clusters.

## Prerequisites

- A Kubernetes cluster (v1.24 or later)
- `kubectl` configured with cluster access
- `helm` v3.x installed

## Create an Account

1. Visit [app.obsyk.ai](https://app.obsyk.ai)
2. Sign up with your email or SSO provider
3. Create your organization

## Generate Cluster Credentials

Before installing the operator, you need to register your cluster:

1. Navigate to **Clusters** in the dashboard
2. Click **Add Cluster**
3. Enter a name for your cluster
4. Copy the generated `Client ID` and `Client Secret`

!!! warning "Save Your Credentials"
    The client secret is only shown once. Save it securely before closing the dialog.

## Install the Operator

See the [Operator Installation Guide](../operator/installation.md) for detailed instructions.

## Verify Connection

After installing the operator:

1. Return to the Obsyk dashboard
2. Navigate to **Clusters**
3. Your cluster should show as **Connected**

If the cluster doesn't connect within a few minutes, check the [Troubleshooting Guide](../reference/troubleshooting.md).
