<#
.SYNOPSIS
    Automated deployment script for Exercise 3: Scaling Flask App on Single Node using ReplicaSets
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Deploying Exercise 3: Flash Sale ReplicaSet Simulation   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Check Minikube
Write-Host "[1/7] Checking Minikube status..." -ForegroundColor Yellow
if (-not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    Write-Error "minikube is not installed or not available in PATH."
    exit 1
}

# 2. Configure Minikube Docker environment
Write-Host "[2/7] Configuring Docker environment for Minikube..." -ForegroundColor Yellow
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# 3. Build image
Write-Host "[3/7] Building Docker image 'flashsale:1.0'..." -ForegroundColor Yellow
docker build -t flashsale:1.0 .

# 4. Apply manifests
Write-Host "[4/7] Applying ReplicaSet and Service manifests..." -ForegroundColor Yellow
kubectl apply -f flashsale-replicaset.yaml

# 5. Verify initial 3 replicas
Write-Host "[5/7] Verifying initial ReplicaSet and Pods..." -ForegroundColor Yellow
kubectl get rs flashsale-rs
kubectl get pods -l app=flashsale -o wide

# 6. Scale out to 5 replicas
Write-Host "[6/7] Scaling ReplicaSet to 5 replicas..." -ForegroundColor Yellow
kubectl scale rs flashsale-rs --replicas=5

# 7. Verify scaled pods
Write-Host "[7/7] Verifying scaled Pod distribution across node..." -ForegroundColor Yellow
kubectl get rs flashsale-rs
kubectl get pods -l app=flashsale -o wide

Write-Host "----------------------------------------------------------" -ForegroundColor Green
Write-Host "Exercise 3 deployed and scaled successfully!" -ForegroundColor Green
Write-Host "To test load distribution across pods, run:" -ForegroundColor Cyan
Write-Host "  kubectl port-forward svc/flashsale-svc 8080:80" -ForegroundColor White
Write-Host "And test in a new terminal: curl http://127.0.0.1:8080/buy" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
