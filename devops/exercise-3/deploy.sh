#!/usr/bin/env bash
# ==============================================================================
# Exercise 3: Scaling Flask App on Single Node using ReplicaSets
# E-Commerce Flash Sale Simulation
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Deploying Exercise 3: Flash Sale ReplicaSet Simulation   "
echo "=========================================================="

# 1. Check Minikube
echo "[1/7] Checking Minikube status..."
if ! minikube status &> /dev/null; then
    echo "Starting Minikube with single node..."
    minikube start --nodes=1
fi

# 2. Point Docker CLI to Minikube
echo "[2/7] Configuring Docker environment for Minikube..."
eval $(minikube docker-env)

# 3. Build Docker image inside Minikube
echo "[3/7] Building Docker image 'flashsale:1.0'..."
docker build -t flashsale:1.0 .

# 4. Apply ReplicaSet and Service
echo "[4/7] Applying ReplicaSet and Service manifests..."
kubectl apply -f flashsale-replicaset.yaml

# 5. Verify ReplicaSet and Pods
echo "[5/7] Verifying running Pods and ReplicaSet..."
kubectl get rs flashsale-rs
kubectl get pods -l app=flashsale -o wide

# 6. Scale out to 5 replicas (simulate flash sale traffic spike)
echo "[6/7] Scaling ReplicaSet out to 5 replicas..."
kubectl scale rs flashsale-rs --replicas=5

# 7. Verify scaled status
echo "[7/7] Verifying scaled Pod distribution..."
kubectl rollout status rs/flashsale-rs || true
kubectl get rs flashsale-rs
kubectl get pods -l app=flashsale -o wide

echo "----------------------------------------------------------"
echo "Exercise 3 deployed and scaled successfully!"
echo "To test checkout endpoints across pods:"
echo "  kubectl port-forward svc/flashsale-svc 8080:80 &"
echo "  curl http://127.0.0.1:8080/buy"
echo "=========================================================="
