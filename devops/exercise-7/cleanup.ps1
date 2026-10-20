<#
.SYNOPSIS
    Cleanup script for Exercise 7: Jenkins Server
#>
Write-Host "Stopping and removing Jenkins container..." -ForegroundColor Yellow
docker rm -f jenkins 2>$null | Out-Null
Write-Host "Cleanup completed. Persistent volume 'jenkins_home' was preserved." -ForegroundColor Green
Write-Host "To remove persistent data: docker volume rm jenkins_home" -ForegroundColor Gray
