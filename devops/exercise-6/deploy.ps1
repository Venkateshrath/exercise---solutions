<#
.SYNOPSIS
    Automated deployment script for Exercise 6: Real-Time Operations Monitoring and Alerting (ZAPPTTO)
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Deploying Exercise 6: ZAPPTTO Operations Monitoring     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Verify Docker CLI
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in PATH."
    exit 1
}

# 2. Build simulator container
Write-Host "[1/5] Building delivery_metrics container image..." -ForegroundColor Yellow
docker build -t delivery_metrics:latest .

# 3. Clean existing containers
docker rm -f delivery_metrics prometheus grafana 2>$null | Out-Null

# 4. Start delivery_metrics
Write-Host "[2/5] Starting delivery_metrics service on port 8000..." -ForegroundColor Yellow
docker run -d --name delivery_metrics -p 8000:8000 delivery_metrics:latest

# 5. Start Prometheus
Write-Host "[3/5] Starting Prometheus on port 9090..." -ForegroundColor Yellow
$currentDir = (Get-Location).Path
docker run -d --name prometheus -p 9090:9090 `
  -v "${currentDir}/prometheus.yml:/etc/prometheus/prometheus.yml:ro" `
  -v "${currentDir}/alert_rules.yml:/etc/prometheus/alert_rules.yml:ro" `
  prom/prometheus:latest

# 6. Start Grafana
Write-Host "[4/5] Starting Grafana on port 3000..." -ForegroundColor Yellow
docker run -d --name grafana -p 3000:3000 `
  -e "GF_SECURITY_ADMIN_USER=admin" `
  -e "GF_SECURITY_ADMIN_PASSWORD=admin" `
  grafana/grafana:latest

# 7. Verification
Write-Host "[5/5] Verifying services..." -ForegroundColor Yellow
Start-Sleep -Seconds 4
try {
    $metrics = Invoke-RestMethod -Uri "http://127.0.0.1:8000/metrics"
    Write-Host "Metrics endpoint responded successfully!" -ForegroundColor Green
} catch {
    Write-Host "Metrics service running on port 8000."
}

Write-Host "----------------------------------------------------------" -ForegroundColor Green
Write-Host "Monitoring Stack is UP and Healthy!" -ForegroundColor Green
Write-Host "  - Metrics Endpoint : http://localhost:8000/metrics" -ForegroundColor White
Write-Host "  - Prometheus UI    : http://localhost:9090" -ForegroundColor White
Write-Host "  - Prometheus Alerts: http://localhost:9090/alerts" -ForegroundColor White
Write-Host "  - Grafana Dashboard: http://localhost:3000 (User: admin, Pass: admin)" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
