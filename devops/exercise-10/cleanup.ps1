# ==============================================================================
# cleanup.ps1 - Teardown and Cleanup Script for Exercise 10 (PowerShell)
# ==============================================================================

$ProfileName = "devops-multinode"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Cleaning up Exercise 10 Resources" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

Write-Host "Deleting Kubernetes Services and Deployments..." -ForegroundColor Yellow
kubectl delete -f shopping_cart_service.yaml --ignore-not-found=true
kubectl delete -f product_catalog_service.yaml --ignore-not-found=true
kubectl delete -f shopping_cart_deployment.yaml --ignore-not-found=true
kubectl delete -f product_catalog_deployment.yaml --ignore-not-found=true

Write-Host "`nTo stop and delete the Minikube multi-node cluster, run:" -ForegroundColor Magenta
Write-Host "  minikube stop -p $ProfileName" -ForegroundColor White
Write-Host "  minikube delete -p $ProfileName" -ForegroundColor White
Write-Host "`nCleanup completed successfully." -ForegroundColor Green
