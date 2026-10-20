<#
.SYNOPSIS
    Cleanup script for Exercise 6: ZAPPTTO Monitoring Stack
#>
Write-Host "Cleaning up Exercise 6 monitoring stack..." -ForegroundColor Yellow
docker rm -f delivery_metrics prometheus grafana 2>$null | Out-Null
Write-Host "Cleanup completed." -ForegroundColor Green
