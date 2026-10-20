#!/usr/bin/env bash
# Cleanup Exercise 9 resources
echo "Cleaning up Exercise 9 deployment artifacts..."
rm -rf mock-python-app-deploy python-app-deploy *.pid *.log 2>/dev/null || true
echo "Cleanup completed."
