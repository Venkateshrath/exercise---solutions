# ==============================================================================
# deploy.ps1 - Automated Deployment Script for Exercise 10 (PowerShell)
# Multi-Node Kubernetes Cluster with Multiple Applications and ReplicaSets
# ==============================================================================

$ErrorActionPreference = "Stop"
$ProfileName = "devops-multinode"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Starting Exercise 10 Deployment on Multi-Node Minikube" -ForegroundColor Cyan
Write-Host " Profile: $ProfileName" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Step 1: Check / Start Minikube Multi-Node Cluster
Write-Host "`n[1/6] Checking Minikube cluster status..." -ForegroundColor Yellow
$status = minikube status -p $ProfileName 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Starting Minikube 3-node cluster: $ProfileName ..." -ForegroundColor Green
    minikube start --nodes 3 -p $ProfileName --force
} else {
    Write-Host "Minikube profile '$ProfileName' is already running." -ForegroundColor Green
}

# Step 2: Enable Registry Add-on
Write-Host "`n[2/6] Enabling Minikube registry add-on..." -ForegroundColor Yellow
minikube -p $ProfileName addons enable registry

# Step 3: Build Docker Images locally
Write-Host "`n[3/6] Building Docker images..." -ForegroundColor Yellow
docker build -t product-catalog:latest -f Dockerfile.product .
docker build -t shopping-cart:latest -f Dockerfile.shopping .

# Step 4: Load Images into Minikube Multi-Node Cluster
Write-Host "`n[4/6] Loading Docker images into Minikube cluster..." -ForegroundColor Yellow
minikube -p $ProfileName image load product-catalog:latest
minikube -p $ProfileName image load shopping-cart:latest

# Step 5: Apply Deployments and Services
Write-Host "`n[5/6] Applying Kubernetes manifests..." -ForegroundColor Yellow
kubectl apply -f product_catalog_deployment.yaml
kubectl apply -f shopping_cart_deployment.yaml
kubectl apply -f product_catalog_service.yaml
kubectl apply -f shopping_cart_service.yaml

# Step 6: Wait for rollouts and verify Pod distribution
Write-Host "`n[6/6] Waiting for deployments to become ready..." -ForegroundColor Yellow
kubectl rollout status deployment/product-catalog --timeout=120s
kubectl rollout status deployment/shopping-cart --timeout=120s

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " Deployment Complete! Pod Distribution across Nodes:" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
kubectl get pods -o wide -l "app in (product-catalog, shopping-cart)"

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " Service Endpoints:" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
kubectl get services product-catalog-service shopping-cart-service

Write-Host "`nTo tunnel services and access endpoints, run in a separate terminal:" -ForegroundColor Magenta
Write-Host "  minikube -p devops-multinode service product-catalog-service" -ForegroundColor White
Write-Host "  minikube -p devops-multinode service shopping-cart-service" -ForegroundColor White
