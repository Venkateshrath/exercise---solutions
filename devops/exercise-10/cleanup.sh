#!/bin/bash
# ==============================================================================
# cleanup.sh - Teardown and Cleanup Script for Exercise 10
# ==============================================================================

set -euo pipefail

PROFILE="devops-multinode"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo " Cleaning up Exercise 10 Resources"
echo "=========================================================="

echo "Deleting Kubernetes Services and Deployments..."
kubectl delete -f shopping_cart_service.yaml --ignore-not-found=true
kubectl delete -f product_catalog_service.yaml --ignore-not-found=true
kubectl delete -f shopping_cart_deployment.yaml --ignore-not-found=true
kubectl delete -f product_catalog_deployment.yaml --ignore-not-found=true

echo ""
echo "Do you also wish to stop and delete the Minikube cluster '$PROFILE'? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Stopping and deleting Minikube profile '$PROFILE'..."
    minikube stop -p "$PROFILE" || true
    minikube delete -p "$PROFILE" || true
    echo "Minikube cluster cleaned up."
else
    echo "Minikube cluster retained."
fi

echo "Cleanup completed successfully."
