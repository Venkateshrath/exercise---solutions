#!/bin/bash
# ==============================================================================
# deploy.sh - Automated Deployment Script for Exercise 10
# Multi-Node Kubernetes Cluster with Multiple Applications and ReplicaSets
# ==============================================================================

set -euo pipefail

PROFILE="devops-multinode"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================================="
echo " Starting Exercise 10 Deployment on Multi-Node Minikube"
echo " Profile: $PROFILE"
echo "=========================================================="

# Step 1: Check / Start Minikube Multi-Node Cluster
echo "[1/6] Checking Minikube cluster status..."
if ! minikube status -p "$PROFILE" >/dev/null 2>&1; then
    echo "Starting Minikube 3-node cluster: $PROFILE ..."
    minikube start --nodes 3 -p "$PROFILE" --force
else
    echo "Minikube profile '$PROFILE' is already running."
fi

# Step 2: Enable Registry Add-on
echo "[2/6] Enabling Minikube registry add-on..."
minikube -p "$PROFILE" addons enable registry

# Step 3: Build Docker Images locally
echo "[3/6] Building Docker images..."
docker build -t product-catalog:latest -f Dockerfile.product .
docker build -t shopping-cart:latest -f Dockerfile.shopping .

# Step 4: Load Images into Minikube Multi-Node Cluster
echo "[4/6] Loading Docker images into Minikube cluster..."
minikube -p "$PROFILE" image load product-catalog:latest
minikube -p "$PROFILE" image load shopping-cart:latest

# Step 5: Apply Deployments and Services
echo "[5/6] Applying Kubernetes manifests..."
kubectl apply -f product_catalog_deployment.yaml
kubectl apply -f shopping_cart_deployment.yaml
kubectl apply -f product_catalog_service.yaml
kubectl apply -f shopping_cart_service.yaml

# Step 6: Wait for rollouts and verify Pod distribution
echo "[6/6] Waiting for deployments to become ready..."
kubectl rollout status deployment/product-catalog --timeout=120s
kubectl rollout status deployment/shopping-cart --timeout=120s

echo ""
echo "=========================================================="
echo " Deployment Complete! Pod Distribution across Nodes:"
echo "=========================================================="
kubectl get pods -o wide -l "app in (product-catalog, shopping-cart)"

echo ""
echo "=========================================================="
echo " Service Endpoints:"
echo "=========================================================="
kubectl get services product-catalog-service shopping-cart-service

echo ""
echo "To tunnel services and access endpoints, run:"
echo "  minikube -p devops-multinode service product-catalog-service"
echo "  minikube -p devops-multinode service shopping-cart-service"
