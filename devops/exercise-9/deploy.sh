#!/usr/bin/env bash
# ==============================================================================
# Exercise 9: Jenkins Multi-Stage Pipeline Simulation Script
# Simulates: Build -> Test -> Deploy -> Run -> Test Application -> Teardown
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Executing Exercise 9: Multi-Stage Pipeline Simulation   "
echo "=========================================================="

# Stage 1: Build
echo "[Stage 1/5: Build] Checking & installing dependencies..."
pip install -r requirements.txt || pip3 install -r requirements.txt

# Stage 2: Test
echo "[Stage 2/5: Test] Running unit tests..."
python3 -m unittest discover -s .

# Stage 3: Deploy
echo "[Stage 3/5: Deploy] Copying application to mock deployment directory..."
DEPLOY_DIR="./mock-python-app-deploy"
mkdir -p "$DEPLOY_DIR"
cp app.py "$DEPLOY_DIR/"
echo "Application successfully copied to $DEPLOY_DIR"

# Stage 4: Run Application
echo "[Stage 4/5: Run Application] Launching application in background..."
python3 "$DEPLOY_DIR/app.py" > "$DEPLOY_DIR/app.log" 2>&1 &
APP_PID=$!
echo "$APP_PID" > "$DEPLOY_DIR/app.pid"
sleep 2

# Stage 5: Test Application
echo "[Stage 5/5: Test Application] Validating running application..."
python3 test_app.py

# Cleanup
echo "Cleaning up background process (PID: $APP_PID)..."
kill "$APP_PID" 2>/dev/null || true
rm -rf "$DEPLOY_DIR"

echo "----------------------------------------------------------"
echo "Multi-Stage Pipeline simulation completed successfully!"
echo "=========================================================="
