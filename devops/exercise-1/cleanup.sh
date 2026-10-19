#!/usr/bin/env bash
# Tear down Exercise 1 resources
echo "Cleaning up Exercise 1 resources..."
kubectl delete service hello-k8s --ignore-not-found=true
kubectl delete pod hello-k8s --ignore-not-found=true
echo "Cleanup completed."
