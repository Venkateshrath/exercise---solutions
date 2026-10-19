#!/usr/bin/env bash
# ==============================================================================
# Exercise 1: Hello Pod - Automated Deployment Script
# Simulates deploying Zepto's storefront & delivery status web app on Kubernetes
# ==============================================================================

set -euo pipefail

echo "========================================="
echo " Deploying Exercise 1: Hello Pod (Zepto) "
echo "========================================="

# 1. Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH."
    exit 1
fi

# 2. Check cluster accessibility
echo "[Step 1/5] Checking Kubernetes cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    echo "Warning: Kubernetes cluster is not responding."
    echo "Ensure minikube or Docker Desktop Kubernetes is running:"
    echo "  minikube start"
    exit 1
fi

# 3. Create Pod
echo "[Step 2/5] Deploying Pod 'hello-k8s' (Nginx image)..."
if kubectl get pod hello-k8s &> /dev/null; then
    echo "Pod 'hello-k8s' already exists."
else
    # Declarative or imperative approach:
    # Imperative: kubectl run hello-k8s --image=nginx --port=80
    kubectl apply -f pod.yaml
fi

# 4. Wait for Pod to become Ready
echo "[Step 3/5] Waiting for Pod 'hello-k8s' to be in Running state..."
kubectl wait --for=condition=Ready pod/hello-k8s --timeout=60s

# 5. Expose Pod as NodePort Service
echo "[Step 4/5] Exposing Pod via NodePort Service..."
if kubectl get svc hello-k8s &> /dev/null; then
    echo "Service 'hello-k8s' already exists."
else
    # Imperative alternative: kubectl expose pod hello-k8s --type=NodePort --port=80
    kubectl apply -f service.yaml
fi

# 6. Verify and output service details
echo "[Step 5/5] Verifying Deployment..."
kubectl get pods -l app=hello-k8s -o wide
kubectl get svc hello-k8s

echo "-----------------------------------------"
echo "Deployment successful!"
if command -v minikube &> /dev/null; then
    echo "To access the service via Minikube run:"
    echo "  minikube service hello-k8s"
else
    NODE_PORT=$(kubectl get svc hello-k8s -o jsonpath='{.spec.ports[0].nodePort}')
    echo "Access the application on NodePort: $NODE_PORT"
fi
echo "========================================="
