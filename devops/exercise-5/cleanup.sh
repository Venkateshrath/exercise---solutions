#!/usr/bin/env bash
# Cleanup Exercise 5 resources
echo "Cleaning up Exercise 5 containers..."
docker rm -f flask-apparmor-demo &> /dev/null || true

# If AppArmor profile is loaded, unload it (Linux/WSL)
if command -v apparmor_parser &> /dev/null; then
    if [ -f /etc/apparmor.d/my-apparmor-profile ]; then
        echo "Removing AppArmor profile from kernel..."
        sudo apparmor_parser -R /etc/apparmor.d/my-apparmor-profile 2>/dev/null || true
        sudo rm -f /etc/apparmor.d/my-apparmor-profile 2>/dev/null || true
    fi
fi

echo "Cleanup completed."
