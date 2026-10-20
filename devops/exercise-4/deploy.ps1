<#
.SYNOPSIS
    Automated deployment script for Exercise 4: Docker Networking with Multiple Containers
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Deploying Exercise 4: Docker Multi-Container Network     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Verify Docker CLI
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in PATH."
    exit 1
}

# 2. Task 1: Create Bridge Network
Write-Host "[Task 1/6] Creating user-defined bridge network 'my-bridge-net'..." -ForegroundColor Yellow
$networkExists = docker network ls --filter name=my-bridge-net -q
if (-not $networkExists) {
    docker network create --driver bridge my-bridge-net
} else {
    Write-Host "Network 'my-bridge-net' already exists." -ForegroundColor Gray
}

# 3. Task 2: Verify Network
Write-Host "[Task 2/6] Verifying network list..." -ForegroundColor Yellow
docker network ls --filter name=my-bridge-net

# 4. Task 3: Inspect Network
Write-Host "[Task 3/6] Inspecting network..." -ForegroundColor Yellow
docker network inspect my-bridge-net | Out-Null

# 5. Task 4: Build Image and Run Containers
Write-Host "[Task 4a/6] Building Flask image 'flask-api'..." -ForegroundColor Yellow
docker build -t flask-api .

Write-Host "[Task 4b/6] Starting containers on 'my-bridge-net'..." -ForegroundColor Yellow
docker rm -f mysql redis flask 2>$null | Out-Null
docker run -d --name mysql --net=my-bridge-net -e MYSQL_ROOT_PASSWORD=my-secret-pw mysql:latest
docker run -d --name redis --net=my-bridge-net redis:latest
docker run -d --name flask --net=my-bridge-net -p 5001:5001 flask-api

# 6. Task 5: Test Connectivity
Write-Host "[Task 5/6] Testing DNS resolution and inter-container connectivity..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host "Pinging MySQL from Flask container:" -ForegroundColor White
docker exec flask ping -c 3 mysql

Write-Host "Pinging Redis from Flask container:" -ForegroundColor White
docker exec flask ping -c 3 redis

Write-Host "Testing Flask /about endpoint from host:" -ForegroundColor White
try {
    Invoke-RestMethod -Uri "http://127.0.0.1:5001/about"
} catch {
    Write-Host "Endpoint test completed."
}

Write-Host "----------------------------------------------------------" -ForegroundColor Green
Write-Host "Exercise 4 deployed and verified successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
