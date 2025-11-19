#!/bin/bash

# Promote image from STAGING to PRODUCTION

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <rc-tag>"
    echo "Example: $0 v1.2.3-rc.1"
    exit 1
fi

RC_TAG=$1
RELEASE_TAG=$(echo "$RC_TAG" | sed 's/-rc\..*//')

REPO="mfarajpour/flask-gitops-app"  # تغییر بده!
REGISTRY="ghcr.io"
IMAGE="${REGISTRY}/${REPO}"

echo "🚀 Promoting to PRODUCTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Source:  ${IMAGE}:${RC_TAG}"
echo "Release: ${IMAGE}:${RELEASE_TAG}"
echo ""

read -p "⚠️  Deploy to PRODUCTION? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

# Pull RC image
echo "📥 Pulling RC image..."
docker pull ${IMAGE}:${RC_TAG}

# Re-tag for production
echo "🏷️  Re-tagging for production..."
docker tag ${IMAGE}:${RC_TAG} ${IMAGE}:${RELEASE_TAG}
docker tag ${IMAGE}:${RC_TAG} ${IMAGE}:stable

# Push
echo "📤 Pushing production tags..."
docker push ${IMAGE}:${RELEASE_TAG}
docker push ${IMAGE}:stable

# Update manifest
echo "📝 Updating production manifest..."

mkdir -p k8s/overlays/production/patches

cat > k8s/overlays/production/patches/image-patch.yaml << YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  template:
    spec:
      containers:
      - name: flask-app
        image: ${IMAGE}:${RELEASE_TAG}
YAML

# Add to kustomization if not exists
if ! grep -q "image-patch.yaml" k8s/overlays/production/kustomization.yaml; then
    cat >> k8s/overlays/production/kustomization.yaml << YAML

patches:
  - path: patches/image-patch.yaml
YAML
fi

# Git commit
echo "💾 Committing changes..."
git add k8s/overlays/production/
git commit -m "release: deploy ${RELEASE_TAG} to production

Promoted from: ${RC_TAG}
Image: ${IMAGE}:${RELEASE_TAG}"

# Create release tag
git tag -a "${RELEASE_TAG}" -m "Release ${RELEASE_TAG}"

echo ""
echo "🎉 Ready for production! Now run:"
echo "   git push origin main"
echo "   git push origin ${RELEASE_TAG}"
echo ""
echo "🔍 Deploy to production:"
echo "   argocd app sync flask-app-prod"
