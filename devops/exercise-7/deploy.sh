#!/usr/bin/env bash
# ==============================================================================
# Exercise 7: Introduction to CI and Jenkins Installation
# Automated Jenkins Deployment & Admin Password Retrieval Script
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo " Deploying Exercise 7: Jenkins Automation Server          "
echo "=========================================================="

# 1. Verify Docker
if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running. Please start Docker."
    exit 1
fi

# 2. Clean up any previous Jenkins container
docker rm -f jenkins &> /dev/null || true

# 3. Start Jenkins container
echo "[1/3] Starting Jenkins LTS container on ports 8080 & 50000..."
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# 4. Wait for Jenkins to generate the initialAdminPassword
echo "[2/3] Waiting for Jenkins initialization and initialAdminPassword generation..."
max_attempts=30
attempt=0
password=""

while [ $attempt -lt $max_attempts ]; do
    if docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
        password=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || true)
        if [ -n "$password" ]; then
            break
        fi
    fi
    attempt=$((attempt + 1))
    echo "Waiting for password file ($attempt/$max_attempts)..."
    sleep 3
done

# 5. Output Results
echo "[3/3] Jenkins is ready!"
echo "----------------------------------------------------------"
echo "Jenkins Web Interface : http://localhost:8080"
if [ -n "$password" ]; then
    echo "Initial Admin Password: $password"
else
    echo "To retrieve the admin password manually, run:"
    echo "  docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
fi
echo "----------------------------------------------------------"
echo "To clean up later run: ./cleanup.sh"
echo "=========================================================="
