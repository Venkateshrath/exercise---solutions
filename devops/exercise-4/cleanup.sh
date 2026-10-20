#!/usr/bin/env bash
# Tear down Exercise 4 containers and network
echo "Cleaning up Exercise 4 containers..."
docker stop mysql redis flask &> /dev/null || true
docker rm -f mysql redis flask &> /dev/null || true

echo "Removing user-defined bridge network..."
docker network rm my-bridge-net &> /dev/null || true

echo "Cleanup completed."
