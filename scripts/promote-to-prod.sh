#!/bin/bash

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <rc-tag>"
    echo "Example: $0 v1.2.3-rc.1"
    exit 1
fi

RC_TAG=$1
RELEASE_TAG=$(echo "$RC_TAG" | sed 's/-rc\..*//')

REPO="mfarajpour/flask-gitops-app"
REGISTRY="ghcr.io"
IMAGE="${REGISTRY}/${REPO}"

command -v kustomize >/dev/null 2>&1 || {
    echo "Error: kustomize is not installed"
    exit 1
}

echo "Promoting to PRODUCTION"
echo "Source:  ${IMAGE}:${RC_TAG}"
echo "Release: ${IMAGE}:${RELEASE_TAG}"
echo ""

read -p "Deploy to PRODUCTION? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo "Pulling RC image..."
docker pull ${IMAGE}:${RC_TAG}

echo "Re-tagging for production..."
docker tag ${IMAGE}:${RC_TAG} ${IMAGE}:${RELEASE_TAG}
docker tag ${IMAGE}:${RC_TAG} ${IMAGE}:stable

echo "Pushing production tags..."
docker push ${IMAGE}:${RELEASE_TAG}
docker push ${IMAGE}:stable

echo "Updating production manifest..."
cd k8s/overlays/production
kustomize edit set image ${IMAGE}:${RELEASE_TAG}
cd ../../..

echo "Committing changes..."
git add k8s/overlays/production/kustomization.yaml
git commit -m "release: deploy ${RELEASE_TAG} to production

Promoted from: ${RC_TAG}
Image: ${IMAGE}:${RELEASE_TAG}"

git tag -a "${RELEASE_TAG}" -m "Release ${RELEASE_TAG}"

echo "Pushing to remote..."
git push origin main
git push origin ${RELEASE_TAG}

echo ""
echo "Done! Now manually sync ArgoCD:"
echo "  argocd app sync flask-app-prod"
