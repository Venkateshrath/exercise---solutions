<#
.SYNOPSIS
    Pipeline simulation script for Exercise 9: Jenkins Multi-Stage Pipeline
#>

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Executing Exercise 9: Multi-Stage Pipeline Simulation   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Stage 1: Build
Write-Host "[Stage 1/5: Build] Checking dependencies..." -ForegroundColor Yellow
python -m pip install -r requirements.txt --quiet

# Stage 2: Test
Write-Host "[Stage 2/5: Test] Running unit tests..." -ForegroundColor Yellow
python -m unittest discover -s .

# Stage 3: Deploy
Write-Host "[Stage 3/5: Deploy] Deploying to mock directory..." -ForegroundColor Yellow
$deployDir = Join-Path (Get-Location) "mock-python-app-deploy"
if (-not (Test-Path $deployDir)) {
    New-Item -ItemType Directory -Path $deployDir | Out-Null
}
Copy-Item "app.py" -Destination $deployDir -Force

# Stage 4: Run Application
Write-Host "[Stage 4/5: Run Application] Launching Flask in background..." -ForegroundColor Yellow
$proc = Start-Process -FilePath "python" -ArgumentList "$deployDir\app.py" -PassThru
Start-Sleep -Seconds 2

# Stage 5: Test Application
Write-Host "[Stage 5/5: Test Application] Validating test client..." -ForegroundColor Yellow
try {
    python test_app.py
} finally {
    if ($proc -and -not $proc.HasExited) {
        Stop-Process -Id $proc.Id -Force
    }
    Remove-Item $deployDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "----------------------------------------------------------" -ForegroundColor Green
Write-Host "Multi-Stage Pipeline completed successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
