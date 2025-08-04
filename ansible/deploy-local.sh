#!/bin/bash

# Local DevOps Infrastructure Deployment Script
# This script deploys the complete infrastructure stack on the local machine

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "ansible-local.cfg" ]; then
    print_error "Please run this script from the ansible directory"
    exit 1
fi

# Check if ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    print_error "Ansible is not installed. Please install Ansible first:"
    echo "  Ubuntu/Debian: sudo apt update && sudo apt install ansible"
    echo "  macOS: brew install ansible"
    echo "  pip: pip install ansible"
    exit 1
fi

# Check if user has sudo privileges
if ! sudo -n true 2>/dev/null; then
    print_warning "This script requires sudo privileges for system configuration"
    print_status "You may be prompted for your password during deployment"
fi

print_status "Starting local DevOps infrastructure deployment..."

# Set the ansible config to use local configuration
export ANSIBLE_CONFIG="$(pwd)/ansible-local.cfg"

# Function to run ansible playbook with error handling
run_playbook() {
    local playbook=$1
    local description=$2
    
    print_status "Running: $description"
    if ansible-playbook "playbooks/$playbook" -i inventory/local.yml; then
        print_success "Completed: $description"
    else
        print_error "Failed: $description"
        exit 1
    fi
}

# Check connectivity to localhost
print_status "Checking local connectivity..."
if ansible all -i inventory/local.yml -m ping; then
    print_success "Local connectivity verified"
else
    print_error "Cannot connect to localhost"
    exit 1
fi

# Deploy components in order
print_status "Beginning infrastructure deployment..."

# Parse command line arguments for selective deployment
if [ $# -eq 0 ]; then
    # Full deployment
    run_playbook "basic-setup-local.yml" "Basic system setup and package installation"
    run_playbook "users.yml" "User management and configuration"
    run_playbook "git.yml" "Git installation and configuration"
    run_playbook "docker-setup.yml" "Docker and Docker Swarm setup"
    run_playbook "elk-stack.yml" "ELK Stack (Elasticsearch, Logstash, Kibana) deployment"
    run_playbook "nginx.yml" "Nginx reverse proxy setup"
    run_playbook "nifi.yml" "Apache Nifi deployment"
    run_playbook "airflow.yml" "Apache Airflow deployment"
else
    # Selective deployment based on arguments
    for component in "$@"; do
        case $component in
            basic|basics)
                run_playbook "basic-setup-local.yml" "Basic system setup and package installation"
                ;;
            users)
                run_playbook "users.yml" "User management and configuration"
                ;;
            git)
                run_playbook "git.yml" "Git installation and configuration"
                ;;
            docker)
                run_playbook "docker-setup.yml" "Docker and Docker Swarm setup"
                ;;
            elk|logging)
                run_playbook "elk-stack.yml" "ELK Stack deployment"
                ;;
            nginx|proxy)
                run_playbook "nginx.yml" "Nginx reverse proxy setup"
                ;;
            nifi)
                run_playbook "nifi.yml" "Apache Nifi deployment"
                ;;
            airflow)
                run_playbook "airflow.yml" "Apache Airflow deployment"
                ;;
            *)
                print_warning "Unknown component: $component"
                ;;
        esac
    done
fi

print_success "Local DevOps infrastructure deployment completed!"
echo
print_status "Services are now available at:"
echo "  • Main Dashboard: http://localhost"
echo "  • Kibana (Logs): http://localhost:5601"
echo "  • Elasticsearch: http://localhost:9200"
echo "  • Apache Nifi: https://localhost:8443/nifi"
echo "  • Apache Airflow: http://localhost:8080"
echo "  • Portainer (Docker UI): http://localhost:9000"
echo
print_status "Default credentials:"
echo "  • Nifi: admin / nifipassword"
echo "  • Airflow: admin / admin"
echo "  • Portainer: admin / (set on first login)"
echo
print_status "To check service status:"
echo "  docker service ls"
echo "  docker ps"
echo
print_status "To view logs:"
echo "  docker service logs <service-name>"
echo "  tail -f ansible-local.log"