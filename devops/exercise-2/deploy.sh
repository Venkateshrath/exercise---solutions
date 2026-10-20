#!/usr/bin/env bash
# ==============================================================================
# Exercise 2: Deploy a Flask App on Minikube using kubectl and YAML
# ==============================================================================

set -euo pipefail

echo "=================================================="
echo " Deploying Exercise 2: Flask App on Kubernetes    "
echo "=================================================="

# 1. Start or check minikube
echo "[1/6] Checking Minikube status..."
if ! minikube status &> /dev/null; then
    echo "Minikube not running. Starting Minikube..."
    minikube start
fi

# 2. Point Docker CLI to Minikube's Docker daemon
echo "[2/6] Configuring Docker environment for Minikube..."
eval $(minikube docker-env)

# 3. Build Docker image directly in Minikube's Docker environment
echo "[3/6] Building Docker image 'flask-app:latest' inside Minikube..."
docker build -t flask-app:latest .

# 4. Apply Kubernetes Deployment and Service
echo "[4/6] Applying Kubernetes manifests..."
kubectl apply -f flask-deployment.yaml

# 5. Wait for deployment rollout
echo "[5/6] Waiting for deployment rollout..."
kubectl rollout status deployment/flask-app --timeout=90s

# 6. Verify and output service URL
echo "[6/6] Verifying deployment and fetching service URL..."
kubectl get deployments -l app=flask-app
kubectl get pods -l app=flask-app
kubectl get svc flask-app-service

echo "--------------------------------------------------"
echo "Deployment successful!"
echo "To obtain the service access URL, run:"
echo "  minikube service flask-app-service --url"
echo "To test the endpoint:"
echo "  curl \$(minikube service flask-app-service --url)"
echo "=================================================="
