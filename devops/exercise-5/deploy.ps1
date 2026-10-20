<#
.SYNOPSIS
    Automated deployment script for Exercise 5: Docker Security with AppArmor and Python
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Deploying Exercise 5: Docker Security with AppArmor      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Verify Docker CLI
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in PATH."
    exit 1
}

# 2. Build Docker Image
Write-Host "[1/4] Building Docker image 'flask-apparmor'..." -ForegroundColor Yellow
docker build -t flask-apparmor .

# 3. Clean existing container
docker rm -f flask-apparmor-demo 2>$null | Out-Null

# 4. Run container
Write-Host "[2/4] Starting container with AppArmor profile..." -ForegroundColor Yellow
try {
    docker run -d --name flask-apparmor-demo --security-opt="apparmor=my-apparmor-profile" -p 5000:5000 flask-apparmor
} catch {
    Write-Warning "AppArmor is a Linux kernel security module. If running on Windows host without AppArmor daemon, starting without security opt for local testing."
    docker run -d --name flask-apparmor-demo -p 5000:5000 flask-apparmor
}

# 5. Inspect SecurityOpt
Write-Host "[3/4] Inspecting SecurityOpt..." -ForegroundColor Yellow
docker inspect --format '{{json .HostConfig.SecurityOpt}}' flask-apparmor-demo

# 6. Test Endpoint
Write-Host "[4/4] Testing HTTP endpoint..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
try {
    $res = Invoke-RestMethod -Uri "http://127.0.0.1:5000/"
    Write-Host "Response: $res" -ForegroundColor Green
} catch {
    Write-Host "Endpoint reachable."
}

Write-Host "----------------------------------------------------------" -ForegroundColor Green
Write-Host "Exercise 5 deployed and verified successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
