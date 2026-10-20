#!/usr/bin/env bash
# Cleanup Exercise 3 resources
echo "Cleaning up Exercise 3 resources..."
kubectl delete -f flashsale-replicaset.yaml --ignore-not-found=true
kubectl delete deployment flashsale-deployment --ignore-not-found=true
echo "Cleanup completed."
