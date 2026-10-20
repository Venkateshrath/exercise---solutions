#!/usr/bin/env bash
# ==============================================================================
# Exercise 6: Real-Time Operations Monitoring and Alerting (ZAPPTTO)
# Automated Stack Deployment & Health Check Script
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Deploying Exercise 6: ZAPPTTO Operations Monitoring     "
echo "=========================================================="

# 1. Verify Docker
if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running. Please start Docker."
    exit 1
fi

# 2. Build Python metrics simulator container
echo "[1/5] Building delivery_metrics simulator image..."
docker build -t delivery_metrics:latest .

# 3. Clean up any existing containers
docker rm -f delivery_metrics prometheus grafana &> /dev/null || true

# 4. Start delivery_metrics service
echo "[2/5] Starting delivery_metrics service on port 8000..."
docker run -d --name delivery_metrics -p 8000:8000 delivery_metrics:latest

# 5. Start Prometheus with mounted configurations
echo "[3/5] Starting Prometheus on port 9090..."
docker run -d --name prometheus -p 9090:9090 \
  -v "$(pwd)/prometheus.yml:/etc/prometheus/prometheus.yml:ro" \
  -v "$(pwd)/alert_rules.yml:/etc/prometheus/alert_rules.yml:ro" \
  prom/prometheus:latest

# 6. Start Grafana
echo "[4/5] Starting Grafana on port 3000..."
docker run -d --name grafana -p 3000:3000 \
  -e "GF_SECURITY_ADMIN_USER=admin" \
  -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
  grafana/grafana:latest

# 7. Verification
echo "[5/5] Waiting for services to initialize..."
sleep 4

echo "Verifying /metrics endpoint:"
curl -s http://127.0.0.1:8000/metrics | grep -E "(total_deliveries|pending_deliveries|on_the_way_deliveries)" | head -n 6

echo "----------------------------------------------------------"
echo "Monitoring Stack is UP and Healthy!"
echo "  - Metrics Endpoint : http://localhost:8000/metrics"
echo "  - Prometheus UI    : http://localhost:9090"
echo "  - Prometheus Alerts: http://localhost:9090/alerts"
echo "  - Grafana Dashboard: http://localhost:3000 (User: admin, Pass: admin)"
echo "To clean up later run: ./cleanup.sh"
echo "=========================================================="
