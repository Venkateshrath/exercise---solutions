<#
.SYNOPSIS
    Cleanup script for Exercise 1: Hello Pod
#>
Write-Host "Cleaning up Exercise 1 resources..." -ForegroundColor Yellow
kubectl delete service hello-k8s --ignore-not-found=true
kubectl delete pod hello-k8s --ignore-not-found=true
Write-Host "Cleanup completed." -ForegroundColor Green
