# Introduction

Obsyk provides observability and security for AI workloads running on Kubernetes.

## Overview

As organizations deploy more AI and ML workloads to Kubernetes, maintaining visibility becomes critical. Obsyk helps you:

- **Inventory Management** - See all resources across your clusters in one place
- **Real-time Monitoring** - Track changes as they happen
- **Security Visibility** - Understand what's running in your clusters
- **Multi-cluster Support** - Manage multiple clusters from a single dashboard

## Architecture

Obsyk consists of two main components:

### Obsyk Operator

A lightweight Kubernetes operator that runs in your cluster. It:

- Watches for resource changes using the Kubernetes API
- Sends inventory data to the Obsyk platform
- Requires minimal permissions and resources

### Obsyk Platform

The central platform that:

- Receives and stores cluster data
- Provides the web dashboard
- Offers REST APIs for integration

## Next Steps

- [Installation](installation.md) - Set up your Obsyk account
- [Quick Start](quickstart.md) - Connect your first cluster
