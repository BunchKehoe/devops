# DevOps Infrastructure Automation

Comprehensive Ansible playbooks for automated deployment of containerized applications, monitoring, and logging infrastructure with cross-platform support for Debian/Ubuntu and RHEL/AlmaLinux distributions.

## 🚀 Features

- **Docker Swarm**: Industry-standard containerized application platform using CLI commands
- **Cross-Platform**: Full support for Debian/Ubuntu and RHEL/AlmaLinux distributions  
- **ELK Stack**: Complete logging solution (Fluentd + Elasticsearch + Kibana)
- **Apache Nifi**: Data integration and processing platform
- **Apache Airflow**: Workflow orchestration and scheduling
- **Nginx Reverse Proxy**: Load balancing and SSL-ready configuration
- **Security**: Fail2ban, firewall, SSH hardening, and SSL preparation
- **User Management**: Local users with optional Microsoft LDAP/Entra integration

## 📁 Repository Structure

```
devops/
├── ansible/                    # Main Ansible directory
│   ├── inventory/             # Host inventories and variables
│   │   ├── hosts.yml         # Remote server hosts
│   │   ├── local.yml         # Local deployment hosts
│   │   └── group_vars/       # Global configuration variables
│   ├── playbooks/            # Individual component playbooks
│   │   ├── site.yml          # Main deployment playbook
│   │   ├── basic-setup.yml   # Basic packages and system setup
│   │   ├── docker-setup.yml  # Full Docker Swarm deployment
│   │   ├── docker-setup-minimal.yml # Minimal Docker setup
│   │   ├── users.yml         # User management and LDAP integration
│   │   ├── nginx.yml         # Nginx reverse proxy setup
│   │   ├── elk-stack.yml     # ELK stack deployment
│   │   ├── nifi.yml          # Apache Nifi deployment
│   │   └── airflow.yml       # Apache Airflow deployment
│   ├── templates/            # Jinja2 configuration templates
│   ├── files/                # Static files and scripts
│   ├── deploy-local.sh       # Local deployment script
│   ├── deploy-minimal.sh     # Minimal Docker deployment script
│   ├── test-cross-platform.sh # Cross-platform testing script
│   └── DEPLOYMENT_GUIDE.md   # Comprehensive deployment guide
└── README.md                 # This file
```

## ⚡ Quick Start

### Option 1: Local Development Deployment (Recommended)

Deploy the complete infrastructure on your local machine:

```bash
git clone <repository-url>
cd devops/ansible
./deploy-local.sh
```

**Selective deployment**:
```bash
# Deploy specific components
./deploy-local.sh basic docker elk nginx

# Available components: basic, users, git, docker, elk, nginx, nifi, airflow
```

### Option 2: Minimal Docker Testing

For testing Docker functionality with minimal dependencies:

```bash
cd devops/ansible
./deploy-minimal.sh
```

### Option 3: Remote Server Deployment

1. **Configure inventory**: Edit `inventory/hosts.yml` with your server details
2. **Customize variables**: Edit `inventory/group_vars/all.yml` 
3. **Deploy**: `ansible-playbook playbooks/site.yml`

## 🌐 Service Access

After deployment, services are available at:

| Service | Local URL | Description |
|---------|-----------|-------------|
| **Dashboard** | http://localhost | Main landing page with service links |
| **Kibana** | http://localhost:5601 | Log analysis and visualization |
| **Nifi** | https://localhost:8443/nifi | Data integration platform |
| **Airflow** | http://localhost:8080 | Workflow orchestration |
| **Portainer** | http://localhost:9000 | Docker management |
| **Elasticsearch** | http://localhost:9200 | Search and analytics API |

### Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| **Nifi** | admin | nifipassword |
| **Airflow** | admin | admin |
| **Portainer** | admin | (set on first login) |

## 🔧 Scripts Explained

### Deployment Scripts

- **`deploy-local.sh`**: Complete local infrastructure deployment
  - Sets up local inventory targeting localhost
  - Configures services for development with relaxed security
  - Supports selective component deployment
  - Creates comprehensive logging and monitoring stack

- **`deploy-minimal.sh`**: Minimal Docker deployment for testing
  - Uses Docker CLI commands instead of Ansible modules
  - Eliminates Python Docker SDK dependencies
  - Creates basic Docker Swarm, networks, and volumes
  - Ideal for troubleshooting Docker connectivity issues

- **`test-cross-platform.sh`**: Cross-platform compatibility testing
  - Validates Ansible syntax across all playbooks
  - Tests both Debian/Ubuntu and RHEL/AlmaLinux configurations
  - Checks package availability and service configurations

- **`test-local.sh`**: Local deployment validation
  - Verifies all services are running correctly
  - Checks service connectivity and health
  - Validates log ingestion and monitoring

### Utility Scripts (in `files/scripts/`)

- **`health-check.sh`**: Service health monitoring
  - Automated health checks for all deployed services
  - Generates alerts for service failures
  - Used by monitoring cron jobs

- **`deploy.sh`**: Production deployment helper
  - Enhanced deployment script for production environments
  - Includes backup and rollback capabilities
  - SSL certificate management

- **`setup-ssl.sh`**: SSL/TLS configuration
  - Automated SSL certificate installation
  - Configures Nginx for HTTPS
  - Supports Let's Encrypt and custom certificates

- **`validate-docker-packages.sh`**: Docker dependency validation
  - Validates Docker installation and dependencies
  - Checks Python Docker SDK availability
  - Used for troubleshooting Docker module issues

## 🔍 Cross-Platform Support

Supports all major Linux distributions:

| Distribution Family | Supported Versions | Package Manager | Firewall |
|-------------------|-------------------|-----------------|----------|
| **Debian/Ubuntu** | Ubuntu 20.04+, Debian 11+ | `apt` | `ufw` |
| **RHEL/AlmaLinux** | RHEL 8+, AlmaLinux 8+, Rocky 8+ | `dnf` | `firewalld` |

**Key platform differences automatically handled**:
- Time sync: `ntp` (Debian) vs `chrony` (RHEL)
- SSH service: `ssh` vs `sshd`
- LDAP packages: `ldap-utils` vs `openldap-clients`
- Log ownership: `www-data:adm` vs `nginx:nginx`

## 🛠️ Prerequisites

- **Control Machine**: Ansible 2.9+ installed
- **Target Hosts**: Ubuntu 18.04+ or RHEL 8+
- **Access**: SSH key-based authentication (remote) or sudo access (local)
- **Resources**: Minimum 8GB RAM, 4 CPUs, 50GB disk space

## 🔍 Troubleshooting

### Check Service Status
```bash
# Docker services
docker service ls

# Service logs
docker service logs <service-name>

# System status
systemctl status nginx docker
```

### Common Issues

1. **Docker network creation errors**: Use minimal deployment to isolate issues
2. **Port conflicts**: Check `netstat -tulpn | grep :<port>`
3. **Resource constraints**: Monitor with `htop` and `df -h`
4. **Permission issues**: Ensure user is in docker group

### Reset Local Deployment
```bash
# Stop all services and clean up
docker service rm $(docker service ls -q)
docker system prune -a --volumes -f

# Re-deploy
./deploy-local.sh
```

## 📊 Architecture Decisions

### Docker CLI vs Ansible Modules

The deployment uses **Docker CLI commands** instead of Ansible Docker modules to eliminate Python Docker SDK dependency issues:

**Before (problematic)**:
```yaml
- name: Create network
  community.docker.docker_network:
    name: test_network
    driver: overlay
```

**After (working)**:
```yaml
- name: Create Docker network using CLI
  shell: docker network create --driver overlay --attachable test_network
  when: network_exists.rc != 0
```

This approach provides reliable Docker deployment across all environments without complex dependency management.

## 📞 Support

For detailed configuration, advanced deployment options, and troubleshooting:
1. Check the comprehensive [DEPLOYMENT_GUIDE.md](ansible/DEPLOYMENT_GUIDE.md)
2. Review service logs for specific error messages
3. Use the testing scripts to validate your environment
4. Create an issue in the repository for bug reports

## 📄 License

This project is licensed under the MIT License.

---

**Note**: This infrastructure is designed for development and staging environments. For production use, additional security hardening, monitoring, and backup strategies should be implemented.