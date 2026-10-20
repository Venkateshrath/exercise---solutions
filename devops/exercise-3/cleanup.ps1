<#
.SYNOPSIS
    Cleanup script for Exercise 3: Flash Sale ReplicaSet
#>
Write-Host "Cleaning up Exercise 3 resources..." -ForegroundColor Yellow
kubectl delete -f flashsale-replicaset.yaml --ignore-not-found=true
kubectl delete deployment flashsale-deployment --ignore-not-found=true
Write-Host "Cleanup completed." -ForegroundColor Green
