#!/bin/bash
# Docker Installation Validation Script
# This script validates that Docker packages are available after the fix

echo "=== Docker Package Availability Validation ==="
echo "Checking if Docker packages are available in apt..."
echo

# Check each package individually
packages=("docker-ce" "docker-ce-cli" "containerd.io" "docker-compose-plugin")

all_available=true

for package in "${packages[@]}"; do
    echo -n "Checking $package... "
    if apt-cache show $package >/dev/null 2>&1; then
        echo "✅ Available"
    else
        echo "❌ Not available"
        all_available=false
    fi
done

echo
if $all_available; then
    echo "🎉 SUCCESS: All Docker packages are now available!"
    echo "The fix has resolved the Docker installation issue."
    exit 0
else
    echo "❌ FAILURE: Some Docker packages are still not available."
    echo "Please check the repository configuration."
    exit 1
fi