#!/usr/bin/env bash
# Test script simulating Jenkins build execution
set -euo pipefail

echo "=========================================================="
echo " Testing Exercise 8: Hello World Execution                "
echo "=========================================================="

echo "[1/2] Making hello-world.sh executable..."
chmod +x hello-world.sh

echo "[2/2] Executing hello-world.sh..."
OUTPUT=$(./hello-world.sh)
echo "Output: $OUTPUT"

if [ "$OUTPUT" = "Hello, Jenkins!" ]; then
    echo "SUCCESS: Output matches expected value ('Hello, Jenkins!')."
else
    echo "FAILURE: Unexpected output."
    exit 1
fi
echo "=========================================================="
