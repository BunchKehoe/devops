#!/bin/bash

# Minimal Docker Deployment Script
# This script deploys just the essential Docker functionality for testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "ansible-local.cfg" ]; then
    print_error "Please run this script from the ansible directory"
    exit 1
fi

print_status "Starting minimal Docker deployment..."

# Set the ansible config to use local configuration
export ANSIBLE_CONFIG="$(pwd)/ansible-local.cfg"

# Check connectivity
print_status "Checking local connectivity..."
if ansible all -i inventory/local.yml -m ping; then
    print_success "Local connectivity verified"
else
    print_error "Cannot connect to localhost"
    exit 1
fi

# Deploy minimal Docker setup
print_status "Deploying minimal Docker setup..."
if ansible-playbook playbooks/docker-setup-minimal.yml -i inventory/local.yml; then
    print_success "Minimal Docker setup completed successfully!"
else
    print_error "Docker setup failed"
    exit 1
fi

# Test the deployment
print_status "Testing Docker deployment..."
echo "Docker networks:"
docker network ls | grep -E "(overlay|swarm)" || echo "No overlay networks found"
echo
echo "Docker volumes:"
docker volume ls
echo
echo "Docker nodes:"
docker node ls
echo

print_success "Minimal Docker deployment completed!"
echo
print_status "Test commands you can run:"
echo "  docker service create --name test-nginx --network test_network --publish 8080:80 nginx:alpine"
echo "  docker service ls"
echo "  docker service logs test-nginx"
echo "  docker service rm test-nginx"