#!/usr/bin/env bash
# Cleanup Exercise 7 Jenkins container
echo "Stopping and removing Jenkins container..."
docker rm -f jenkins &> /dev/null || true
echo "Cleanup completed. Note: The 'jenkins_home' Docker volume was preserved."
echo "To also remove data: docker volume rm jenkins_home"
