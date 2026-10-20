<#
.SYNOPSIS
    Test script for Exercise 8: Hello World Jenkins Job
#>

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Testing Exercise 8: Hello World Execution                " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

Write-Host "Executing hello-world.ps1..." -ForegroundColor Yellow
$output = & .\hello-world.ps1
Write-Host "Output: $output" -ForegroundColor White

if ($output -eq "Hello, Jenkins!") {
    Write-Host "SUCCESS: Output matches expected value ('Hello, Jenkins!')." -ForegroundColor Green
} else {
    Write-Error "FAILURE: Unexpected output."
}
Write-Host "==========================================================" -ForegroundColor Cyan
