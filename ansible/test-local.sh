#!/bin/bash

# Test script for local deployment configuration
# This script verifies that the local deployment setup is working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_status "Testing Local DevOps Infrastructure Configuration"
echo

# Check if we're in the right directory
if [ ! -f "ansible-local.cfg" ]; then
    print_error "Please run this script from the ansible directory"
    exit 1
fi

# Test 1: Check if ansible is installed
print_status "Checking Ansible installation..."
if command -v ansible-playbook &> /dev/null; then
    ANSIBLE_VERSION=$(ansible --version | head -1)
    print_success "Ansible is installed: $ANSIBLE_VERSION"
else
    print_error "Ansible is not installed"
    exit 1
fi

# Test 2: Test local connectivity
print_status "Testing local connectivity..."
export ANSIBLE_CONFIG="$(pwd)/ansible-local.cfg"
if ansible all -i inventory/local.yml -m ping > /dev/null 2>&1; then
    print_success "Local connectivity works"
else
    print_error "Local connectivity failed"
    exit 1
fi

# Test 3: Test fact gathering
print_status "Testing fact gathering..."
if ansible all -i inventory/local.yml -m setup > /dev/null 2>&1; then
    print_success "Fact gathering works"
else
    print_error "Fact gathering failed"
    exit 1
fi

# Test 4: Test sudo access
print_status "Testing sudo access..."
if sudo -n echo "test" > /dev/null 2>&1; then
    print_success "Sudo access available (passwordless)"
else
    print_error "Sudo access requires password prompt (this is normal)"
fi

# Test 5: Check playbook syntax
print_status "Checking playbook syntax..."
PLAYBOOKS=("basic-setup-local.yml" "users.yml" "git.yml" "docker-setup.yml" "nginx.yml")
SYNTAX_OK=true

for playbook in "${PLAYBOOKS[@]}"; do
    if [ -f "playbooks/$playbook" ]; then
        if ansible-playbook "playbooks/$playbook" -i inventory/local.yml --syntax-check > /dev/null 2>&1; then
            echo "  ✓ $playbook syntax OK"
        else
            echo "  ✗ $playbook syntax error"
            SYNTAX_OK=false
        fi
    else
        echo "  ? $playbook not found"
    fi
done

if [ "$SYNTAX_OK" = true ]; then
    print_success "All playbook syntax checks passed"
else
    print_error "Some playbooks have syntax errors"
fi

# Test 6: Verify local configuration files
print_status "Checking configuration files..."
FILES=("ansible-local.cfg" "inventory/local.yml" "inventory/group_vars/local.yml" "deploy-local.sh")
CONFIG_OK=true

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file exists"
    else
        echo "  ✗ $file missing"
        CONFIG_OK=false
    fi
done

if [ "$CONFIG_OK" = true ]; then
    print_success "All configuration files present"
else
    print_error "Some configuration files are missing"
fi

echo
print_success "Local deployment configuration test completed!"
echo
print_status "To deploy the infrastructure locally, run:"
echo "  ./deploy-local.sh"
echo
print_status "To deploy specific components, run:"
echo "  ./deploy-local.sh basic docker nginx"
echo
print_status "For more information, see LOCAL_DEPLOYMENT.md"