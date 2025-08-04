#!/bin/bash

# Enhanced Minimal Docker Deployment Script
# This script deploys essential Docker functionality with additional features for testing

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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "ansible-local.cfg" ]; then
    print_error "Please run this script from the ansible directory"
    exit 1
fi

print_status "Starting enhanced minimal Docker deployment..."

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

# Check OS information
print_status "Detecting system information..."
OS_INFO=$(ansible all -i inventory/local.yml -m setup -a "filter=ansible_os_family,ansible_distribution*" | grep -E "(ansible_os_family|ansible_distribution)" | head -3)
echo "$OS_INFO"

# Deploy enhanced minimal Docker setup
print_status "Deploying enhanced minimal Docker setup..."
if ansible-playbook playbooks/docker-setup-minimal.yml -i inventory/local.yml; then
    print_success "Enhanced minimal Docker setup completed successfully!"
else
    print_error "Docker setup failed"
    exit 1
fi

# Wait for services to fully start
print_status "Waiting for services to fully start..."
sleep 10

# Test the deployment
print_status "Testing Docker deployment..."
echo
echo "=== Docker Swarm Status ==="
docker node ls || print_warning "Docker Swarm not initialized"
echo
echo "=== Docker Networks ==="
docker network ls | grep -E "(overlay|swarm)" || print_warning "No overlay networks found"
echo
echo "=== Docker Volumes ==="
docker volume ls
echo
echo "=== Docker Services ==="
docker service ls || print_warning "No services running"
echo

# Test service connectivity
print_status "Testing service connectivity..."
if command -v curl >/dev/null 2>&1; then
    echo "Testing Nginx service:"
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200"; then
        print_success "Nginx service is responding (HTTP 200)"
    else
        print_warning "Nginx service not yet ready (this is normal during initial startup)"
    fi
    
    echo "Testing Portainer service:"
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:9000 | grep -q "200"; then
        print_success "Portainer service is responding (HTTP 200)"
    else
        print_warning "Portainer service not yet ready (this is normal during initial startup)"
    fi
else
    print_warning "curl not available, skipping connectivity tests"
fi

print_success "Enhanced minimal Docker deployment completed!"
echo
print_status "Available services:"
echo "  🌐 Test Nginx:  http://localhost:8080"
echo "  🐳 Portainer:   http://localhost:9000"
echo "  🗄️  PostgreSQL:  localhost:5432 (testuser/testpass/testdb)"
echo
print_status "Useful management commands:"
echo "  📊 Check services: docker service ls"
echo "  📜 View logs:     docker service logs <service-name>"
echo "  📈 Scale service: docker service scale test-stack_nginx-test=2"
echo "  🗑️  Remove stack:  docker stack rm test-stack"
echo "  🧹 Clean system:  docker system prune -af --volumes"
echo
print_status "Platform verified:"
ansible all -i inventory/local.yml -m setup -a "filter=ansible_distribution*" | grep "ansible_distribution\""