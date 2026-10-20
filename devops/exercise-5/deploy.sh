#!/usr/bin/env bash
# ==============================================================================
# Exercise 5: Docker Security with AppArmor and Python
# Setup & Security Profile Verification Script
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Deploying Exercise 5: Docker Security with AppArmor      "
echo "=========================================================="

# 1. Check AppArmor support (Linux / WSL2)
if command -v apparmor_parser &> /dev/null; then
    echo "[Step 1/5] Loading AppArmor profile into kernel..."
    if [ -w /etc/apparmor.d ]; then
        cp my-apparmor-profile /etc/apparmor.d/my-apparmor-profile
        apparmor_parser -r /etc/apparmor.d/my-apparmor-profile
    else
        echo "Using sudo to install and parse AppArmor profile..."
        sudo cp my-apparmor-profile /etc/apparmor.d/my-apparmor-profile
        sudo apparmor_parser -r /etc/apparmor.d/my-apparmor-profile
    fi
    echo "AppArmor profile 'my-apparmor-profile' loaded successfully."
else
    echo "[Step 1/5] Notice: apparmor_parser not found in host path. Skipping kernel parse."
    echo "On Debian/Ubuntu, install with: sudo apt-get install apparmor-utils"
fi

# 2. Build Docker Image
echo "[Step 2/5] Building Docker image 'flask-apparmor'..."
docker build -t flask-apparmor .

# 3. Clean up any existing container
docker rm -f flask-apparmor-demo &> /dev/null || true

# 4. Run container with AppArmor profile
echo "[Step 3/5] Starting container with AppArmor profile..."
if command -v apparmor_parser &> /dev/null; then
    docker run -d --name flask-apparmor-demo \
        --security-opt="apparmor=my-apparmor-profile" \
        -p 5000:5000 flask-apparmor
else
    docker run -d --name flask-apparmor-demo \
        -p 5000:5000 flask-apparmor
fi

# 5. Verify security options
echo "[Step 4/5] Inspecting container security options..."
docker inspect --format '{{json .HostConfig.SecurityOpt}}' flask-apparmor-demo

# 6. Test AppArmor enforcement
echo "[Step 5/5] Testing security enforcement inside container..."
echo "Testing /etc/passwd access:"
docker exec flask-apparmor-demo cat /etc/passwd || echo "Access restricted as expected."

echo "Testing /bin/bash execution:"
docker exec flask-apparmor-demo /bin/bash || echo "Binary execution restricted as expected."

echo "Testing HTTP endpoint:"
curl -s http://127.0.0.1:5000/ || echo "Service reachable."

echo "----------------------------------------------------------"
echo "Exercise 5 deployed and verified!"
echo "To clean up run: ./cleanup.sh"
echo "=========================================================="
