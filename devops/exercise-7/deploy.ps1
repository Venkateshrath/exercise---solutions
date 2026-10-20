<#
.SYNOPSIS
    Automated deployment script for Exercise 7: Jenkins Installation & Password Retrieval
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Deploying Exercise 7: Jenkins Automation Server          " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Verify Docker CLI
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in PATH."
    exit 1
}

# 2. Clean existing Jenkins container
docker rm -f jenkins 2>$null | Out-Null

# 3. Launch Jenkins
Write-Host "[1/3] Starting Jenkins LTS container on ports 8080 and 50000..." -ForegroundColor Yellow
docker run -d `
  --name jenkins `
  -p 8080:8080 `
  -p 50000:50000 `
  -v jenkins_home:/var/jenkins_home `
  jenkins/jenkins:lts

# 4. Wait for initialAdminPassword
Write-Host "[2/3] Waiting for Jenkins initialization and password generation..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$password = $null

while ($attempt -lt $maxAttempts) {
    try {
        $password = docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>$null
        if ($password -and $password.Trim().Length -gt 0) {
            break
        }
    } catch { }
    $attempt++
    Write-Host "Waiting for Jenkins secret ($attempt/$maxAttempts)..." -ForegroundColor Gray
    Start-Sleep -Seconds 3
}

# 5. Output Results
Write-Host "[3/3] Jenkins is ready!" -ForegroundColor Green
Write-Host "----------------------------------------------------------" -ForegroundColor Green
Write-Host "Jenkins Web Interface : http://localhost:8080" -ForegroundColor White
if ($password) {
    Write-Host "Initial Admin Password: $($password.Trim())" -ForegroundColor Cyan
} else {
    Write-Host "Retrieve password manually once startup finishes:" -ForegroundColor Yellow
    Write-Host "  docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword" -ForegroundColor White
}
Write-Host "----------------------------------------------------------" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
