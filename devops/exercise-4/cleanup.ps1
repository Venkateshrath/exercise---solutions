<#
.SYNOPSIS
    Cleanup script for Exercise 4: Docker Multi-Container Network
#>
Write-Host "Cleaning up Exercise 4 containers..." -ForegroundColor Yellow
docker stop mysql redis flask 2>$null | Out-Null
docker rm -f mysql redis flask 2>$null | Out-Null

Write-Host "Removing user-defined bridge network 'my-bridge-net'..." -ForegroundColor Yellow
docker network rm my-bridge-net 2>$null | Out-Null

Write-Host "Cleanup completed." -ForegroundColor Green
