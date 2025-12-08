# Security Architecture

This document provides a comprehensive overview of the security controls, practices, and certifications implemented in the Obsyk Operator. It is designed to address the requirements of enterprise security teams, compliance officers, and CISOs evaluating Obsyk for deployment in regulated environments.

## Executive Summary

The Obsyk Operator is designed with a security-first architecture that adheres to industry best practices and compliance frameworks. Key security highlights include:

| Security Control | Implementation |
|------------------|----------------|
| **Authentication** | OAuth2 JWT Bearer with keyless ECDSA P-256 (no static credentials) |
| **Image Signing** | Sigstore Cosign with keyless OIDC signing |
| **Provenance** | SLSA Level 3 attestations via GitHub Actions |
| **SBOM** | Generated in SPDX and CycloneDX formats for every release |
| **Vulnerability Scanning** | Trivy scans blocking on CRITICAL/HIGH CVEs |
| **Container Runtime** | Distroless base image, non-root user (UID 65532) |
| **RBAC** | Read-only cluster access, principle of least privilege |
| **Network Security** | TLS 1.3 for all external communication, optional NetworkPolicy |
| **Secret Handling** | Metadata only - never collects secret values |

---

## Supply Chain Security

### Container Image Signing (Sigstore Cosign)

All Obsyk Operator container images are cryptographically signed using [Sigstore Cosign](https://www.sigstore.dev/) with keyless OIDC signing. This provides:

- **Tamper-proof verification** - Images cannot be modified after signing
- **Keyless operation** - No long-lived signing keys to manage or rotate
- **OIDC identity binding** - Signatures are tied to GitHub Actions workflow identity
- **Transparency log** - All signatures recorded in Rekor for auditability

#### Verifying Image Signatures

```bash
# Install cosign
brew install cosign  # macOS
# or: go install github.com/sigstore/cosign/v2/cmd/cosign@latest

# Verify image signature
cosign verify ghcr.io/obsyk/obsyk-operator:v1.0.0 \
  --certificate-identity-regexp="https://github.com/obsyk/obsyk-operator/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```

Expected output confirms the image was signed by our official release workflow:

```
Verification for ghcr.io/obsyk/obsyk-operator:v1.0.0 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified
  - The code-signing certificate was verified using trusted certificate authority certificates
```

### SLSA Provenance Attestations

Every release includes [SLSA (Supply-chain Levels for Software Artifacts)](https://slsa.dev/) provenance attestations at **Level 3**, providing:

- **Build integrity** - Cryptographic proof the image was built from the claimed source
- **Source verification** - Links image to exact Git commit and repository
- **Builder verification** - Confirms image was built on GitHub Actions infrastructure
- **Non-forgeable** - Attestations cannot be created outside the official CI/CD pipeline

#### Verifying SLSA Provenance

```bash
# Verify provenance attestation
gh attestation verify ghcr.io/obsyk/obsyk-operator:v1.0.0 \
  --owner obsyk

# Or using cosign
cosign verify-attestation ghcr.io/obsyk/obsyk-operator:v1.0.0 \
  --type slsaprovenance \
  --certificate-identity-regexp="https://github.com/obsyk/obsyk-operator/.github/workflows/release.yml@refs/tags/v.*" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com"
```

### Software Bill of Materials (SBOM)

Every release includes SBOMs in two industry-standard formats:

| Format | Use Case | Specification |
|--------|----------|---------------|
| **SPDX** | License compliance, government requirements | [SPDX 2.3](https://spdx.dev/) |
| **CycloneDX** | Vulnerability management, DevSecOps | [CycloneDX 1.5](https://cyclonedx.org/) |

SBOMs are:

- Generated using [Anchore Syft](https://github.com/anchore/syft)
- Attached to every GitHub Release
- Include all Go dependencies and system packages
- Enable vulnerability tracking across your software inventory

#### Downloading SBOMs

```bash
# Download from GitHub Release
gh release download v1.0.0 --repo obsyk/obsyk-operator --pattern "sbom-*.json"

# Files: sbom-spdx.json, sbom-cyclonedx.json
```

### Vulnerability Scanning (Trivy)

All container images are scanned using [Aqua Trivy](https://trivy.dev/) before release:

- **Automated scanning** - Every image scanned in CI/CD pipeline
- **Blocking policy** - Releases blocked on CRITICAL or HIGH severity CVEs
- **SARIF reporting** - Results uploaded to GitHub Security tab
- **Continuous monitoring** - Images re-scanned on schedule

#### Scan Results

Trivy scan results are available:

1. **GitHub Security tab** - Repository → Security → Code scanning alerts
2. **SARIF artifact** - Attached to each CI workflow run
3. **GitHub Release notes** - Summary included in release description

### Base Image Security

The operator uses a minimal, hardened base image:

```dockerfile
# Runtime: Google Distroless (static, nonroot variant)
FROM gcr.io/distroless/static:nonroot@sha256:2b7c93f6d6648c11f0e80a48558c8f77885eb0445213b8e69a6a0d7c89fc6ae4
```

**Distroless benefits:**

- **Minimal attack surface** - No shell, package manager, or unnecessary utilities
- **Immutable** - No way to install additional software at runtime
- **Non-root by default** - Runs as UID 65532 (nonroot user)
- **Pinned digest** - Exact image hash, not mutable tag

**Image composition:**

| Layer | Contents |
|-------|----------|
| Base | Distroless static (glibc, ca-certificates, tzdata) |
| Application | Single statically-compiled Go binary |
| User | nonroot (65532:65532) |

---

## Authentication & Authorization

### OAuth2 JWT Bearer Authentication

The operator authenticates to the Obsyk platform using **OAuth2 JWT Bearer Assertion** (RFC 7523), a standards-based approach that eliminates static credentials:

```
┌─────────────────────────────────────────────────────────────────┐
│                    Customer Environment                          │
│  ┌─────────────────┐    ┌────────────────────────────────────┐  │
│  │ Customer generates   │         Obsyk Operator             │  │
│  │ ECDSA P-256 keypair  │  1. Creates JWT assertion          │  │
│  │ (private stays local)│  2. Signs with private key         │  │
│  └─────────────────┘    │  3. Exchanges for access token     │  │
│          │              │  4. Uses token for API calls       │  │
│          │              └──────────────────┬─────────────────┘  │
│          │                                 │                     │
│          │ Upload public key               │ HTTPS/TLS 1.3      │
│          ▼                                 ▼                     │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                   Obsyk Platform                         │    │
│  │  - Stores public key only                                │    │
│  │  - Verifies JWT signatures                               │    │
│  │  - Issues short-lived access tokens (1 hour)             │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

**Security properties:**

| Property | Benefit |
|----------|---------|
| **No static credentials** | Private key never leaves customer environment |
| **Short-lived tokens** | Access tokens expire in 1 hour, auto-refreshed |
| **Asymmetric cryptography** | Platform stores only public key |
| **Non-exportable** | Private key stored in Kubernetes Secret |
| **Revocable** | Delete client registration to revoke access |

### Key Generation

Customers generate their own ECDSA P-256 keypair:

```bash
# Generate private key (keep secure, never share)
openssl ecparam -genkey -name prime256v1 -noout -out private.pem

# Extract public key (upload to Obsyk platform)
openssl ec -in private.pem -pubout -out public.pem
```

**Key security requirements:**

- Private key stored only in Kubernetes Secret
- Never transmitted over the network
- Never logged or exposed in operator output
- Supports PKCS#1 and PKCS#8 PEM formats

### Credential Storage

Credentials are stored in a Kubernetes Secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: obsyk-credentials
  namespace: obsyk-system
type: Opaque
data:
  client_id: <base64-encoded>      # OAuth2 client ID from platform
  private_key: <base64-encoded>    # PEM-encoded ECDSA P-256 private key
```

**Protection recommendations:**

- Enable encryption at rest for etcd
- Use RBAC to restrict Secret access
- Enable audit logging for Secret access
- Consider external secret management (Vault, AWS Secrets Manager)

---

## Kubernetes Security Controls

### Pod Security Standards

The operator deployment enforces strict Pod Security Standards:

```yaml
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 65532
  runAsGroup: 65532
  fsGroup: 65532
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  privileged: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 65532
  runAsGroup: 65532
```

| Control | Setting | Purpose |
|---------|---------|---------|
| `runAsNonRoot` | `true` | Prevents running as root |
| `runAsUser` | `65532` | Runs as nonroot user |
| `allowPrivilegeEscalation` | `false` | Prevents privilege escalation attacks |
| `privileged` | `false` | No privileged container access |
| `capabilities.drop` | `ALL` | Drops all Linux capabilities |
| `readOnlyRootFilesystem` | `true` | Prevents filesystem modifications |
| `seccompProfile` | `RuntimeDefault` | Enables seccomp syscall filtering |

### Host Isolation

The operator explicitly disables host-level access:

```yaml
spec:
  hostNetwork: false   # No access to host network namespace
  hostPID: false       # No access to host PID namespace
  hostIPC: false       # No access to host IPC namespace
```

### RBAC - Principle of Least Privilege

The operator uses **read-only** access to cluster resources:

```yaml
# Core resources - READ ONLY (list, watch)
- apiGroups: [""]
  resources: [namespaces, pods, services, nodes, configmaps,
              secrets, persistentvolumeclaims, serviceaccounts]
  verbs: [list, watch]

# Apps resources - READ ONLY
- apiGroups: [apps]
  resources: [deployments, statefulsets, daemonsets]
  verbs: [list, watch]

# Batch resources - READ ONLY
- apiGroups: [batch]
  resources: [jobs, cronjobs]
  verbs: [list, watch]

# Networking resources - READ ONLY
- apiGroups: [networking.k8s.io]
  resources: [ingresses, networkpolicies]
  verbs: [list, watch]

# RBAC resources - READ ONLY
- apiGroups: [rbac.authorization.k8s.io]
  resources: [roles, clusterroles, rolebindings, clusterrolebindings]
  verbs: [list, watch]
```

**The operator CANNOT:**

- Create, update, or delete any workloads
- Modify any configurations
- Access shell or exec into pods
- Read secret values (metadata only)

### NetworkPolicy Support

For environments requiring strict network segmentation, enable the built-in NetworkPolicy:

```yaml
# values.yaml
networkPolicy:
  enabled: true
  kubeAPIServerCIDR: "10.0.0.1/32"  # Optional: restrict API server access
  metrics:
    namespaceSelector:
      matchLabels:
        name: monitoring  # Only allow Prometheus scraping
```

**Egress rules (all other traffic blocked):**

- DNS resolution (UDP/TCP 53)
- Kubernetes API server (TCP 443/6443)
- Obsyk platform (TCP 443)

**Ingress rules (all other traffic blocked):**

- Prometheus metrics scraping (configurable)
- Health probe endpoints

---

## Data Security

### Secret Handling - Metadata Only

!!! warning "Critical Security Design"
    The Obsyk Operator **never** collects or transmits secret values. Only metadata is collected.

**What IS collected:**

- Secret name and namespace
- Labels and annotations
- Creation timestamp
- Secret type (e.g., `kubernetes.io/tls`, `Opaque`)
- **Data key names only** (e.g., `password`, `api-key`)

**What is NEVER collected:**

- Secret values
- Encoded or decoded data
- Certificate contents
- Any sensitive payloads

**Code enforcement** (from `secret_ingester.go`):

```go
// SecretInfo contains only metadata - NEVER secret values
type SecretInfo struct {
    UID         string
    Name        string
    Namespace   string
    Labels      map[string]string
    Annotations map[string]string
    Type        string
    DataKeys    []string  // Key names only, NEVER values
    CreatedAt   time.Time
}
```

### ConfigMap Handling

Similar to Secrets, ConfigMaps are collected with metadata only:

- ConfigMap name, namespace, labels
- **Data key names only**
- No data values transmitted

### Data in Transit

All communication uses TLS 1.3:

| Connection | Protocol | Verification |
|------------|----------|--------------|
| Operator → Obsyk Platform | HTTPS/TLS 1.3 | Platform certificate validated |
| Operator → Kubernetes API | HTTPS/TLS | In-cluster service account |

---

## Compliance Considerations

### SOC 2 Type II

The operator's security controls align with SOC 2 Trust Service Criteria:

| Criteria | Control |
|----------|---------|
| **CC6.1** Access Control | OAuth2 JWT Bearer, no static credentials |
| **CC6.6** System Boundaries | NetworkPolicy, TLS encryption |
| **CC6.7** Data Confidentiality | Secret metadata only, TLS in transit |
| **CC7.1** Vulnerability Management | Trivy scanning, SBOM generation |
| **CC8.1** Change Management | SLSA provenance, image signing |

### NIST 800-53

| Control Family | Implementation |
|----------------|----------------|
| **AC** Access Control | RBAC, least privilege, OAuth2 |
| **AU** Audit | Kubernetes audit logs, operator logs |
| **CM** Configuration Management | Helm values, GitOps deployment |
| **IA** Identification & Authentication | ECDSA P-256, JWT Bearer |
| **SC** System & Communications | TLS 1.3, NetworkPolicy |
| **SI** System & Information Integrity | Image signing, Trivy, SLSA |

### CIS Kubernetes Benchmark

The operator deployment passes CIS Kubernetes Benchmark controls:

- ✅ 5.2.1 - Minimize admission of privileged containers
- ✅ 5.2.2 - Minimize admission of containers with privilege escalation
- ✅ 5.2.3 - Minimize admission of root containers
- ✅ 5.2.4 - Minimize admission of containers with NET_RAW
- ✅ 5.2.5 - Minimize admission of containers with capabilities
- ✅ 5.2.6 - Minimize admission of containers with HostPID
- ✅ 5.2.7 - Minimize admission of containers with HostIPC
- ✅ 5.2.8 - Minimize admission of containers with HostNetwork

---

## Deployment Checklist for Security Teams

### Pre-Deployment

- [ ] Verify image signature using Cosign
- [ ] Verify SLSA provenance attestation
- [ ] Review SBOM for known vulnerabilities
- [ ] Generate ECDSA P-256 keypair in secure environment
- [ ] Upload public key to Obsyk platform

### Deployment Configuration

- [ ] Deploy to dedicated namespace (`obsyk-system`)
- [ ] Enable NetworkPolicy if required
- [ ] Configure resource limits
- [ ] Enable PodDisruptionBudget for HA

### Post-Deployment

- [ ] Verify operator logs show successful authentication
- [ ] Confirm read-only access (no write operations in audit log)
- [ ] Enable Kubernetes audit logging for `obsyk-system` namespace
- [ ] Monitor Prometheus metrics for anomalies

### Ongoing Operations

- [ ] Subscribe to [security advisories](https://github.com/obsyk/obsyk-operator/security/advisories)
- [ ] Update operator promptly when new versions released
- [ ] Rotate credentials periodically (generate new keypair)
- [ ] Review audit logs for unauthorized access attempts

---

## Security Contacts

- **Security Advisories**: [github.com/obsyk/obsyk-operator/security](https://github.com/obsyk/obsyk-operator/security)
- **Responsible Disclosure**: security@obsyk.ai
- **Security Documentation**: [docs.obsyk.ai/operator/security](https://docs.obsyk.ai/operator/security)
