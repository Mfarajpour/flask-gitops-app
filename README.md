

#  README.md


# Flask GitOps CI/CD Pipeline

A production-ready GitOps implementation using ArgoCD, Kubernetes, and GitHub Actions.


## Architecture

Developer Push → CI Pipeline → Docker Image → Update Manifest → ArgoCD Sync → Kubernetes


## Environments

- **DEV**: Auto-deploy on every commit
- **STAGING**: Manual promote with RC tags
- **PROD**: Manual promote with release tags

## Repository Structure

```
.
├── app/                        # Flask application
├── k8s/
│   ├── base/                   # Base Kubernetes manifests
│   └── overlays/
│       ├── dev/                # Dev environment
│       ├── staging/            # Staging environment
│       └── production/         # Production environment
├── scripts/
│   ├── list-dev-images.sh      # List available DEV images
│   ├── promote-to-staging.sh   # Promote DEV → STAGING
│   ├── promote-to-prod.sh      # Promote STAGING → PROD
│   ├── rollback.sh             # Rollback to previous version
│   └── check-deployments.sh    # Check deployment status
├── argocd/
│   └── applications/           # ArgoCD app definitions
└── .github/workflows/
    └── ci-cd.yaml                 # CI/CD pipeline
```

## Deployment Flow

### DEV Environment (Automatic)

```bash
git push origin main
```

CI automatically builds and deploys to DEV.

### STAGING Environment (Manual Promote)

```bash
./scripts/list-dev-images.sh
./scripts/promote-to-staging.sh main-abc123 1.2.3
```

Creates `v1.2.3-rc.1` tag and deploys to STAGING.

### PROD Environment (Manual Promote)

```bash
./scripts/promote-to-prod.sh v1.2.3-rc.1
argocd app sync flask-app-prod
```

Creates `v1.2.3` release tag and deploys to PROD.

## Rollback

```bash
./scripts/rollback.sh staging v1.2.2-rc.1
./scripts/rollback.sh prod v1.2.1
```

## Monitoring

```bash
./scripts/check-deployments.sh
kubectl get pods -n flask-app-dev
kubectl get pods -n flask-app-staging
kubectl get pods -n flask-app-prod
```

## Image Tagging Strategy

| Environment | Tag Format | Example |
|-------------|------------|---------|
| DEV | `main-{sha}` | `main-abc123` |
| STAGING | `v{version}-rc.{n}` | `v1.2.3-rc.1` |
| PROD | `v{version}` | `v1.2.3` |

## Prerequisites

- Kubernetes cluster
- ArgoCD installed
- GitHub Container Registry access
- Kustomize installed locally

## Quick Commands

```bash
./scripts/list-dev-images.sh
./scripts/check-deployments.sh
./scripts/promote-to-staging.sh <source-tag> <version>
./scripts/promote-to-prod.sh <rc-tag>
./scripts/rollback.sh <env> <tag>
```

## CI/CD Pipeline

GitHub Actions workflow:
1. Run tests
2. Security scan (Trivy)
3. Build Docker image
4. Push to GHCR
5. Update DEV manifest
6. ArgoCD auto-deploys

## ArgoCD Sync

- **DEV**: Auto-sync enabled (every ~3 minutes)
- **STAGING**: Auto-sync enabled (every ~3 minutes)
- **PROD**: Manual sync only


## Key Features

✅ GitOps-based deployments  
✅ Multi-environment support  
✅ Image re-tagging without rebuild  
✅ Automated testing and security scanning  
✅ Easy rollback mechanism  
✅ Kustomize for config management  

## Tech Stack

- Flask (Python)
- Docker
- Kubernetes
- ArgoCD
- Kustomize
- GitHub Actions
- GitHub Container Registry
- Trivy (Security)

## Author

Your Name
 - GitHub: [@mfarajpour](https://github.com/mfarajpour)


