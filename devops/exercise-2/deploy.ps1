<#
.SYNOPSIS
    Automated deployment script for Exercise 2: Deploy Flask App on Minikube
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Deploying Exercise 2: Flask App on Kubernetes    " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Check Minikube
Write-Host "[1/6] Checking Minikube status..." -ForegroundColor Yellow
if (-not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    Write-Error "minikube is not installed or not in PATH."
    exit 1
}

# 2. Configure Minikube Docker environment in PowerShell
Write-Host "[2/6] Configuring Minikube Docker environment..." -ForegroundColor Yellow
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# 3. Build Docker image
Write-Host "[3/6] Building Docker image 'flask-app:latest' in Minikube..." -ForegroundColor Yellow
docker build -t flask-app:latest .

# 4. Apply Kubernetes Deployment and Service
Write-Host "[4/6] Applying Kubernetes manifests..." -ForegroundColor Yellow
kubectl apply -f flask-deployment.yaml

# 5. Wait for rollout
Write-Host "[5/6] Waiting for rollout to complete..." -ForegroundColor Yellow
kubectl rollout status deployment/flask-app --timeout=90s

# 6. Verify and output service URL
Write-Host "[6/6] Verifying deployment..." -ForegroundColor Yellow
kubectl get deployments -l app=flask-app
kubectl get pods -l app=flask-app
kubectl get svc flask-app-service

Write-Host "--------------------------------------------------" -ForegroundColor Green
Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "Run the following command to get the service URL:" -ForegroundColor Cyan
Write-Host "  minikube service flask-app-service --url" -ForegroundColor White
Write-Host "==================================================" -ForegroundColor Cyan
