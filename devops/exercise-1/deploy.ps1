<#
.SYNOPSIS
    Automated deployment script for Exercise 1: Hello Pod (Zepto Storefront simulation)
.DESCRIPTION
    Deploys an Nginx Pod and exposes it via a NodePort Service on a Kubernetes cluster (Minikube / Docker Desktop).
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Deploying Exercise 1: Hello Pod (Zepto) " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Verify kubectl exists
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Error "kubectl is not installed or not available in PATH."
    exit 1
}

# 2. Check cluster status
Write-Host "[1/5] Checking Kubernetes cluster connectivity..." -ForegroundColor Yellow
try {
    kubectl cluster-info | Out-Null
} catch {
    Write-Warning "Kubernetes cluster is not responding. Please make sure Minikube or Docker Desktop Kubernetes is running (e.g., 'minikube start')."
    exit 1
}

# 3. Deploy Pod
Write-Host "[2/5] Creating Pod 'hello-k8s'..." -ForegroundColor Yellow
kubectl apply -f pod.yaml

# 4. Wait for Pod ready
Write-Host "[3/5] Waiting for Pod 'hello-k8s' to be Ready..." -ForegroundColor Yellow
kubectl wait --for=condition=Ready pod/hello-k8s --timeout=60s

# 5. Expose as NodePort Service
Write-Host "[4/5] Creating Service 'hello-k8s'..." -ForegroundColor Yellow
kubectl apply -f service.yaml

# 6. Summary
Write-Host "[5/5] Verifying Deployment..." -ForegroundColor Yellow
kubectl get pods -l app=hello-k8s -o wide
kubectl get svc hello-k8s

Write-Host "-----------------------------------------" -ForegroundColor Green
Write-Host "Deployment completed successfully!" -ForegroundColor Green
if (Get-Command minikube -ErrorAction SilentlyContinue) {
    Write-Host "Run the following command to open the storefront app in your browser:" -ForegroundColor Cyan
    Write-Host "  minikube service hello-k8s" -ForegroundColor White
} else {
    $nodePort = kubectl get svc hello-k8s -o jsonpath='{.spec.ports[0].nodePort}'
    Write-Host "Access the application on NodePort: $nodePort" -ForegroundColor Cyan
}
Write-Host "=========================================" -ForegroundColor Cyan
