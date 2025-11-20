#!/bin/bash

echo "Current Deployment Status"
echo ""

for env in dev staging prod; do
    namespace="flask-app-${env}"
    if [ "$env" = "prod" ]; then
        namespace="flask-app-prod"
    fi

    echo "$env Environment ($namespace)"

    if kubectl get deployment -n $namespace >/dev/null 2>&1; then
        IMAGE=$(kubectl get deployment -n $namespace -o jsonpath='{.items[0].spec.template.spec.containers[0].image}' 2>/dev/null || echo "Not deployed")
        echo "  Image: $IMAGE"

        DESIRED=$(kubectl get deployment -n $namespace -o jsonpath='{.items[0].spec.replicas}' 2>/dev/null || echo "0")
        READY=$(kubectl get deployment -n $namespace -o jsonpath='{.items[0].status.readyReplicas}' 2>/dev/null || echo "0")
        echo "  Replicas: ${READY}/${DESIRED}"

        AGE=$(kubectl get deployment -n $namespace -o jsonpath='{.items[0].metadata.creationTimestamp}' 2>/dev/null || echo "Unknown")
        echo "  Age: $AGE"
    else
        echo "  Status: Not deployed"
    fi

    echo ""
done

echo "ArgoCD Applications:"
kubectl get applications -n argocd | grep flask-app || echo "No ArgoCD apps found"
