#!/usr/bin/env bash
# Cleanup Exercise 6 resources
echo "Cleaning up Exercise 6 monitoring stack..."
docker rm -f delivery_metrics prometheus grafana &> /dev/null || true
echo "Cleanup completed."
