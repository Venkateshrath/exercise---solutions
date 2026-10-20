<#
.SYNOPSIS
    Cleanup script for Exercise 5: Docker Security with AppArmor and Python
#>
Write-Host "Cleaning up Exercise 5 containers..." -ForegroundColor Yellow
docker rm -f flask-apparmor-demo 2>$null | Out-Null
Write-Host "Cleanup completed." -ForegroundColor Green
