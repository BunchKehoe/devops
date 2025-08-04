#!/bin/bash
# Quick deployment script

set -e

ANSIBLE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ANSIBLE_DIR"

echo "=== DevOps Infrastructure Quick Deploy ==="
echo "Starting deployment at $(date)"
echo

# Validate prerequisites
echo "Checking prerequisites..."

if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "Error: ansible-playbook not found. Please install Ansible."
    exit 1
fi

if [[ ! -f "inventory/hosts.yml" ]]; then
    echo "Error: inventory/hosts.yml not found. Please configure your inventory."
    exit 1
fi

if [[ ! -f "ansible.cfg" ]]; then
    echo "Error: ansible.cfg not found. Please run from the ansible directory."
    exit 1
fi

echo "✓ Prerequisites check passed"
echo

# Test connectivity
echo "Testing connectivity to hosts..."
if ansible all -m ping; then
    echo "✓ Connectivity test passed"
else
    echo "✗ Connectivity test failed. Please check your inventory and SSH configuration."
    exit 1
fi
echo

# Parse command line arguments
COMPONENTS="all"
SKIP_TAGS=""
TAGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --components)
            COMPONENTS="$2"
            shift 2
            ;;
        --skip-tags)
            SKIP_TAGS="$2"
            shift 2
            ;;
        --tags)
            TAGS="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --components COMPONENTS    Comma-separated list of components (basic,users,git,docker,nginx,elk,nifi,airflow) or 'all'"
            echo "  --skip-tags TAGS          Skip specific tags"
            echo "  --tags TAGS               Run only specific tags"
            echo "  --help                    Show this help message"
            echo
            echo "Examples:"
            echo "  $0                        # Deploy everything"
            echo "  $0 --components basic,docker    # Deploy only basic setup and Docker"
            echo "  $0 --skip-tags ssl       # Skip SSL configuration"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Build playbook arguments
PLAYBOOK_ARGS=""
if [[ -n "$SKIP_TAGS" ]]; then
    PLAYBOOK_ARGS="$PLAYBOOK_ARGS --skip-tags $SKIP_TAGS"
fi
if [[ -n "$TAGS" ]]; then
    PLAYBOOK_ARGS="$PLAYBOOK_ARGS --tags $TAGS"
fi

# Deploy components
if [[ "$COMPONENTS" == "all" ]]; then
    echo "Deploying complete infrastructure..."
    ansible-playbook playbooks/site.yml $PLAYBOOK_ARGS
else
    echo "Deploying selected components: $COMPONENTS"
    
    IFS=',' read -ra COMPONENT_ARRAY <<< "$COMPONENTS"
    for component in "${COMPONENT_ARRAY[@]}"; do
        case $component in
            basic)
                echo "Deploying basic setup..."
                ansible-playbook playbooks/basic-setup.yml $PLAYBOOK_ARGS
                ;;
            users)
                echo "Deploying user management..."
                ansible-playbook playbooks/users.yml $PLAYBOOK_ARGS
                ;;
            git)
                echo "Deploying Git configuration..."
                ansible-playbook playbooks/git.yml $PLAYBOOK_ARGS
                ;;
            docker)
                echo "Deploying Docker Swarm..."
                ansible-playbook playbooks/docker-setup.yml $PLAYBOOK_ARGS
                ;;
            nginx)
                echo "Deploying Nginx proxy..."
                ansible-playbook playbooks/nginx.yml $PLAYBOOK_ARGS
                ;;
            elk)
                echo "Deploying ELK stack..."
                ansible-playbook playbooks/elk-stack.yml $PLAYBOOK_ARGS
                ;;
            nifi)
                echo "Deploying Apache Nifi..."
                ansible-playbook playbooks/nifi.yml $PLAYBOOK_ARGS
                ;;
            airflow)
                echo "Deploying Apache Airflow..."
                ansible-playbook playbooks/airflow.yml $PLAYBOOK_ARGS
                ;;
            *)
                echo "Unknown component: $component"
                echo "Valid components: basic, users, git, docker, nginx, elk, nifi, airflow"
                exit 1
                ;;
        esac
    done
fi

echo
echo "=== Deployment Complete ==="
echo "Finished at $(date)"
echo

# Run health check
echo "Running health check..."
if [[ -f "files/scripts/health-check.sh" ]]; then
    bash files/scripts/health-check.sh
else
    echo "Health check script not found. Manual verification recommended."
fi

echo
echo "=== Next Steps ==="
echo "1. Access the main dashboard: http://YOUR_SERVER_IP/"
echo "2. Configure SSL certificates for production use"
echo "3. Set up monitoring and alerting"
echo "4. Configure backup strategies"
echo "5. Review security settings"
echo
echo "For troubleshooting, see the README.md file."