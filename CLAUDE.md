# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

User documentation for the Obsyk platform, hosted at docs.obsyk.ai. Built with MkDocs Material theme.

## Tech Stack

- **Framework**: MkDocs with Material theme
- **Styling**: Material theme customization
- **Diagrams**: Mermaid.js
- **Hosting**: Kubernetes + Cloudflare Tunnel
- **CI/CD**: GitHub Actions → GHCR → ArgoCD

## Repository Structure

```
/
├── docs/                    # Documentation source files
│   ├── index.md            # Home page
│   ├── getting-started/    # Getting started guides
│   ├── user-guide/         # Platform usage guides
│   ├── operator/           # Operator documentation
│   │   ├── overview.md
│   │   ├── installation.md
│   │   ├── configuration.md
│   │   └── security.md     # Security architecture (for CISOs)
│   └── reference/          # Reference documentation
│       ├── architecture.md
│       └── troubleshooting.md
├── mkdocs.yml              # MkDocs configuration
├── requirements.txt        # Python dependencies
├── Dockerfile              # Production container
└── .github/workflows/
    └── release.yml         # Build and deploy workflow
```

## Build Commands

```bash
# Install dependencies
pip install -r requirements.txt

# Start dev server (localhost:8000)
mkdocs serve

# Build static site
mkdocs build

# Build with strict mode (catches warnings)
mkdocs build --strict
```

## URLs

| Environment | URL |
|-------------|-----|
| Production | https://docs.obsyk.ai |
| Staging | https://staging-docs.obsyk.ai |

## MkDocs Configuration

Key extensions enabled in `mkdocs.yml`:

- **admonition** - Note/warning/tip blocks
- **attr_list** + **md_in_html** - Grid cards
- **pymdownx.superfences** - Code blocks with Mermaid support
- **pymdownx.tabbed** - Tabbed content
- **pymdownx.emoji** - Material icons (:material-icon-name:)

### Adding Mermaid Diagrams

```markdown
\`\`\`mermaid
graph LR
    A[Start] --> B[End]
\`\`\`
```

### Adding Grid Cards

```markdown
<div class="grid cards" markdown>

-   :material-icon: __[Title](link.md)__

    ---

    Description text.

</div>
```

### Adding Admonitions

```markdown
!!! note "Title"
    Content here.

!!! warning
    Warning content.
```

## Deployment

### Automatic (on merge to main)
1. GitHub Actions builds MkDocs site
2. Docker image pushed to `ghcr.io/obsyk/docs:<sha>`
3. Platform repo staging kustomization updated
4. ArgoCD syncs staging deployment

### Production Promotion
- Nightly promotion workflow copies staging → production
- Or manual promotion via workflow dispatch

## Writing Guidelines

- Use clear, concise language
- Include code examples where applicable
- Add diagrams for complex concepts
- Keep pages focused on one topic
- Link to related documentation
- Update navigation in `mkdocs.yml` when adding pages

## Support Links

Documentation references these support channels:
- **Community Q&A**: https://github.com/obsyk/docs/discussions
- **Bug Reports**: https://github.com/obsyk/obsyk-operator/issues
- **Email**: support@obsyk.ai
- **Security**: security@obsyk.ai

## License

Proprietary. All files should include copyright header where applicable:

```
<!-- Copyright (c) Obsyk. All rights reserved. -->
<!-- Proprietary and confidential. -->
```
