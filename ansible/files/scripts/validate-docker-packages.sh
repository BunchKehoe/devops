#!/bin/bash
# Docker Installation Validation Script
# This script validates that Docker packages are available after the fix

echo "=== Docker Package Availability Validation ==="

# Detect package manager
if command -v dnf >/dev/null 2>&1; then
    PKG_MGR="dnf"
    echo "Checking if Docker packages are available in dnf..."
elif command -v yum >/dev/null 2>&1; then
    PKG_MGR="yum"
    echo "Checking if Docker packages are available in yum..."
elif command -v apt-cache >/dev/null 2>&1; then
    PKG_MGR="apt"
    echo "Checking if Docker packages are available in apt..."
else
    echo "❌ ERROR: No supported package manager found (dnf, yum, or apt)"
    exit 1
fi

echo

# Check each package individually
packages=("docker-ce" "docker-ce-cli" "containerd.io" "docker-compose-plugin")

all_available=true

for package in "${packages[@]}"; do
    echo -n "Checking $package... "
    case $PKG_MGR in
        "dnf"|"yum")
            if $PKG_MGR info $package >/dev/null 2>&1; then
                echo "✅ Available"
            else
                echo "❌ Not available"
                all_available=false
            fi
            ;;
        "apt")
            if apt-cache show $package >/dev/null 2>&1; then
                echo "✅ Available"
            else
                echo "❌ Not available"
                all_available=false
            fi
            ;;
    esac
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