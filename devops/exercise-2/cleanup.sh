#!/usr/bin/env bash
# Cleanup Exercise 2 resources
echo "Cleaning up Exercise 2 resources..."
kubectl delete -f flask-deployment.yaml --ignore-not-found=true
echo "Cleanup completed."
