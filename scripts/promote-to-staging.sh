#!/bin/bash

# Promote image from DEV to STAGING

set -e

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source-tag> <version>"
    echo "Example: $0 main-a3f2b1c 1.2.3"
    exit 1
fi

SOURCE_TAG=$1
VERSION=$2
RC_TAG="v${VERSION}-rc.1"

REPO="mfarajpour/flask-gitops-app"  # تغییر بده!
REGISTRY="ghcr.io"
IMAGE="${REGISTRY}/${REPO}"

echo "🚀 Promoting image to STAGING"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Source:  ${IMAGE}:${SOURCE_TAG}"
echo "Target:  ${IMAGE}:${RC_TAG}"
echo ""

# Pull source image
echo "📥 Pulling source image..."
docker pull ${IMAGE}:${SOURCE_TAG}

# Re-tag
echo "🏷️  Re-tagging..."
docker tag ${IMAGE}:${SOURCE_TAG} ${IMAGE}:${RC_TAG}

# Push
echo "📤 Pushing new tag..."
docker push ${IMAGE}:${RC_TAG}

# Update manifest
echo "📝 Updating staging manifest..."

mkdir -p k8s/overlays/staging/patches

cat > k8s/overlays/staging/patches/image-patch.yaml << YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  template:
    spec:
      containers:
      - name: flask-app
        image: ${IMAGE}:${RC_TAG}
YAML

# Add to kustomization if not exists
if ! grep -q "image-patch.yaml" k8s/overlays/staging/kustomization.yaml; then
    cat >> k8s/overlays/staging/kustomization.yaml << YAML

patches:
  - path: patches/image-patch.yaml
YAML
fi

# Git commit
echo "💾 Committing changes..."
git add k8s/overlays/staging/
git commit -m "release: promote ${RC_TAG} to staging

Source: ${SOURCE_TAG}
Image: ${IMAGE}:${RC_TAG}"

# Create git tag
git tag -a "${RC_TAG}" -m "Release Candidate ${RC_TAG}"

echo ""
echo "✅ Done! Now run:"
echo "   git push origin main"
echo "   git push origin ${RC_TAG}"
echo ""
echo "🔍 Monitor deployment:"
echo "   kubectl get pods -n flask-app-staging -w"
echo "   argocd app sync flask-app-staging"
