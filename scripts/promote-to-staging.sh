#!/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <source-tag> <version>"
    echo "Example: $0 main-a3f2b1c 1.2.3"
    exit 1
fi

SOURCE_TAG=$1
VERSION=$2
RC_TAG="v${VERSION}-rc.1"

REPO="mfarajpour/flask-gitops-app"
REGISTRY="ghcr.io"
IMAGE="${REGISTRY}/${REPO}"

command -v kustomize >/dev/null 2>&1 || {
    echo "Error: kustomize is not installed"
    echo "Install: curl -s https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash"
    exit 1
}

echo "Promoting image to STAGING"
echo "Source:  ${IMAGE}:${SOURCE_TAG}"
echo "Target:  ${IMAGE}:${RC_TAG}"
echo ""

echo "Pulling source image..."
docker pull ${IMAGE}:${SOURCE_TAG}

echo "Re-tagging..."
docker tag ${IMAGE}:${SOURCE_TAG} ${IMAGE}:${RC_TAG}

echo "Pushing new tag..."
docker push ${IMAGE}:${RC_TAG}

echo "Updating staging manifest..."
cd k8s/overlays/staging
kustomize edit set image ${IMAGE}:${RC_TAG}
cd ../../..

echo "Updated kustomization.yaml:"
grep -A 2 "images:" k8s/overlays/staging/kustomization.yaml

echo "Committing changes..."
git add k8s/overlays/staging/kustomization.yaml
git commit -m "release: promote ${RC_TAG} to staging

Source: ${SOURCE_TAG}
Image: ${IMAGE}:${RC_TAG}"

git tag -a "${RC_TAG}" -m "Release Candidate ${RC_TAG}"

echo ""
echo "Done! Now run:"
echo "  git push origin main"
echo "  git push origin ${RC_TAG}"
echo ""
echo "ArgoCD will auto-sync staging environment"
