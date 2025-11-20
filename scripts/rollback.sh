#!/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <environment> <image-tag>"
    echo "Example: $0 staging v1.2.2-rc.1"
    echo "Example: $0 prod v1.2.1"
    exit 1
fi

ENV=$1
TAG=$2

REPO="mfarajpour/flask-gitops-app"
REGISTRY="ghcr.io"
IMAGE="${REGISTRY}/${REPO}"

command -v kustomize >/dev/null 2>&1 || {
    echo "Error: kustomize is not installed"
    echo "Install: curl -s https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh | bash"
    exit 1
}

case $ENV in
    staging)
        OVERLAY_PATH="k8s/overlays/staging"
        NAMESPACE="flask-app-staging"
        ;;
    prod|production)
        OVERLAY_PATH="k8s/overlays/production"
        NAMESPACE="flask-app-prod"
        ENV="production"
        ;;
    *)
        echo "Invalid environment. Use: staging, prod"
        exit 1
        ;;
esac

echo "Rolling back ${ENV} to ${TAG}"
echo "Image: ${IMAGE}:${TAG}"
echo ""

read -p "Confirm rollback? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo "Pulling image..."
docker pull ${IMAGE}:${TAG}

echo "Updating manifest..."
cd ${OVERLAY_PATH}
kustomize edit set image ${IMAGE}:${TAG}
cd ../../..

echo "Updated kustomization.yaml:"
grep -A 2 "images:" ${OVERLAY_PATH}/kustomization.yaml

echo "Committing rollback..."
git add ${OVERLAY_PATH}/kustomization.yaml
git commit -m "rollback: revert ${ENV} to ${TAG}"

echo ""
echo "Rollback ready! Now run:"
echo "  git push origin main"

if [ "$ENV" = "production" ]; then
    echo ""
    echo "Then sync ArgoCD:"
    echo "  argocd app sync flask-app-prod"
else
    echo ""
    echo "ArgoCD will auto-sync staging"
fi
