<#
.SYNOPSIS
    Cleanup script for Exercise 9
#>
Write-Host "Cleaning up Exercise 9 deployment artifacts..." -ForegroundColor Yellow
Remove-Item "mock-python-app-deploy", "python-app-deploy" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "*.pid", "*.log" -Force -ErrorAction SilentlyContinue
Write-Host "Cleanup completed." -ForegroundColor Green
