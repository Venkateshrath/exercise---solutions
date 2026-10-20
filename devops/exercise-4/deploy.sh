#!/usr/bin/env bash
# ==============================================================================
# Exercise 4: Docker Networking with Multiple Containers
# Automated Setup & Verification Script
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Deploying Exercise 4: Docker Multi-Container Network     "
echo "=========================================================="

# 1. Verify Docker is running
if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running. Please start Docker."
    exit 1
fi

# 2. Task 1: Create Bridge Network if not already existing
echo "[Task 1/6] Creating user-defined bridge network 'my-bridge-net'..."
if docker network inspect my-bridge-net &> /dev/null; then
    echo "Network 'my-bridge-net' already exists."
else
    docker network create --driver bridge my-bridge-net
fi

# 3. Task 2: Verify Network List
echo "[Task 2/6] Verifying network list..."
docker network ls | grep my-bridge-net

# 4. Task 3: Inspect Network
echo "[Task 3/6] Inspecting network configuration..."
docker network inspect my-bridge-net --format '{{json .IPAM.Config}}'

# 5. Task 4: Build Flask image
echo "[Task 4a/6] Building Flask image 'flask-api'..."
docker build -t flask-api .

# Clean up any leftover containers with these names
docker rm -f mysql redis flask &> /dev/null || true

# Launch MySQL, Redis, and Flask on my-bridge-net
echo "[Task 4b/6] Starting MySQL container..."
docker run -d --name mysql --net=my-bridge-net -e MYSQL_ROOT_PASSWORD=my-secret-pw mysql:latest

echo "[Task 4c/6] Starting Redis container..."
docker run -d --name redis --net=my-bridge-net redis:latest

echo "[Task 4d/6] Starting Flask API container on port 5001..."
docker run -d --name flask --net=my-bridge-net -p 5001:5001 flask-api

# Wait for containers to initialize
echo "Waiting for containers to become ready..."
sleep 5

# 6. Task 5: Test DNS & Connectivity
echo "[Task 5/6] Testing DNS resolution and inter-container connectivity..."
echo "Pinging MySQL from Flask container:"
docker exec flask ping -c 3 mysql

echo "Pinging Redis from Flask container:"
docker exec flask ping -c 3 redis

echo "Testing Flask endpoint from host:"
curl -s http://127.0.0.1:5001/about | jq . || curl -s http://127.0.0.1:5001/about

echo "----------------------------------------------------------"
echo "Exercise 4 deployed and verified successfully!"
echo "To clean up later run: ./cleanup.sh"
echo "=========================================================="
