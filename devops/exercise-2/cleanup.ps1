<#
.SYNOPSIS
    Cleanup script for Exercise 2: Flask App on Minikube
#>
Write-Host "Cleaning up Exercise 2 resources..." -ForegroundColor Yellow
kubectl delete -f flask-deployment.yaml --ignore-not-found=true
Write-Host "Cleanup completed." -ForegroundColor Green
