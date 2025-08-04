# Comprehensive Deployment Guide

This guide provides detailed instructions for deploying the DevOps infrastructure across different environments and platforms.

## Table of Contents

1. [Installation Methods](#installation-methods)
2. [Cross-Platform Configuration](#cross-platform-configuration)
3. [Service Configuration](#service-configuration)
4. [Security Configuration](#security-configuration)
5. [Advanced Deployment Options](#advanced-deployment-options)
6. [Monitoring and Maintenance](#monitoring-and-maintenance)

## Installation Methods

### Local Development Deployment

**Purpose**: Development and testing on your local machine  
**Resources**: 8GB RAM, 4 CPUs, 50GB disk space  
**Security**: Relaxed for development ease  

#### Prerequisites
```bash
# Install Ansible
# Ubuntu/Debian
sudo apt update && sudo apt install ansible

# macOS
brew install ansible

# Via pip
pip install ansible
```

#### Full Local Deployment
```bash
git clone <repository-url>
cd devops/ansible
./deploy-local.sh
```

#### Selective Component Deployment
```bash
# Deploy specific components
./deploy-local.sh basic docker elk nginx

# Available components:
# - basic: Essential packages and system setup
# - users: User management and LDAP integration  
# - git: Git installation and configuration
# - docker: Docker Swarm and container platform
# - elk: ELK stack for logging (Fluentd + Elasticsearch + Kibana)
# - nginx: Nginx reverse proxy
# - nifi: Apache Nifi data integration platform
# - airflow: Apache Airflow workflow orchestration
```

#### Local Configuration Files
- `inventory/local.yml` - Local host inventory (targets localhost)
- `inventory/group_vars/local.yml` - Local deployment variables
- `ansible-local.cfg` - Ansible configuration for local deployment

### Minimal Docker Deployment

**Purpose**: Testing Docker functionality with minimal dependencies  
**Approach**: Uses Docker CLI commands instead of Ansible modules  
**Benefits**: Eliminates Python Docker SDK dependency issues  

```bash
cd devops/ansible
./deploy-minimal.sh
```

**What this includes**:
- ✅ Docker Engine installation
- ✅ Docker Swarm initialization (single-node)
- ✅ CLI-based network creation (overlay networks)
- ✅ CLI-based volume creation
- ✅ Service deployment testing

**What this excludes**:
- ❌ Docker Compose (causes Python package conflicts)
- ❌ Ansible Docker modules (eliminated to avoid SDK issues)
- ❌ Complex monitoring/management UI
- ❌ ELK Stack integration

#### Testing Minimal Deployment
```bash
# Verify installation
docker node ls
docker network ls | grep overlay
docker volume ls

# Test service deployment
docker service create --name test-nginx --network test_network --publish 8080:80 nginx:alpine
curl http://localhost:8080
docker service rm test-nginx
```

### Remote Server Deployment

**Purpose**: Production or staging server deployment  
**Resources**: Minimum 4GB RAM, 2 CPUs, 20GB disk space per host  
**Security**: Full security features enabled  

#### Server Prerequisites
- Ubuntu 18.04+ or RHEL 8+
- SSH key-based authentication
- Sudo privileges
- Python 3 installed

#### Configuration Steps
1. **Configure inventory** (`inventory/hosts.yml`):
   ```yaml
   all:
     hosts:
       your-server:
         ansible_host: 192.168.1.10
         ansible_user: ubuntu
         ansible_ssh_private_key_file: ~/.ssh/id_rsa
   ```

2. **Set global variables** (`inventory/group_vars/all.yml`):
   ```yaml
   # Basic configuration
   domain_name: "your-domain.com"
   timezone: "America/New_York"
   
   # User management
   users_to_create:
     - username: johndoe
       groups: [sudo, docker]
       ssh_key: "ssh-rsa AAAAB3NzaC1yc2E..."
   
   # Git configuration
   git_user_name: "Your Name"
   git_user_email: "your.email@example.com"
   ```

3. **Deploy complete infrastructure**:
   ```bash
   ansible-playbook playbooks/site.yml
   
   # Or deploy specific components
   ansible-playbook playbooks/basic-setup.yml
   ansible-playbook playbooks/docker-setup.yml
   ansible-playbook playbooks/elk-stack.yml
   ```

## Cross-Platform Configuration

### Supported Distributions

| Distribution | Versions | Package Manager | Firewall | Time Sync |
|-------------|----------|-----------------|----------|-----------|
| **Ubuntu** | 20.04, 22.04, 24.04 | `apt` | `ufw` | `ntp` |
| **Debian** | 11, 12 | `apt` | `ufw` | `ntp` |
| **RHEL** | 8, 9 | `dnf` | `firewalld` | `chrony` |
| **AlmaLinux** | 8, 9 | `dnf` | `firewalld` | `chrony` |
| **Rocky Linux** | 8, 9 | `dnf` | `firewalld` | `chrony` |
| **CentOS Stream** | 8, 9 | `dnf` | `firewalld` | `chrony` |

### Platform-Specific Packages

#### Time Synchronization
```yaml
# Debian/Ubuntu
- name: Install and configure NTP
  apt:
    name: ntp
    state: present
  when: ansible_os_family == "Debian"

# RHEL/AlmaLinux  
- name: Install and configure Chrony
  dnf:
    name: chrony
    state: present
  when: ansible_os_family == "RedHat"
```

#### Service Names
| Service | Debian/Ubuntu | RHEL/AlmaLinux |
|---------|---------------|----------------|
| SSH | `ssh` | `sshd` |
| Time Sync | `ntp` | `chronyd` |
| Firewall | `ufw` | `firewalld` |

#### LDAP Client Packages
| Distribution | Packages |
|-------------|----------|
| Debian/Ubuntu | `ldap-utils`, `libnss-ldap`, `libpam-ldap` |
| RHEL/AlmaLinux | `openldap-clients`, `nss-pam-ldapd` |

#### Log File Ownership
| Service | Debian/Ubuntu | RHEL/AlmaLinux |
|---------|---------------|----------------|
| Nginx Logs | `www-data:adm` | `nginx:nginx` |

#### Git Flow Package Names
| Distribution | Package Name |
|-------------|-------------|
| Debian/Ubuntu | `git-flow` |
| RHEL/AlmaLinux | `gitflow` |

### Cross-Platform Variables

Configure platform-specific packages in `group_vars/all.yml`:

```yaml
# Universal packages (same name across distributions)
basic_packages:
  - vim
  - curl
  - wget
  - python3-pip
  - htop
  - net-tools
  - unzip
  - git

# Debian/Ubuntu specific packages
basic_packages_debian:
  - apt-transport-https
  - ca-certificates
  - software-properties-common
  - build-essential

# RHEL/AlmaLinux specific packages
basic_packages_redhat:
  - dnf-utils
  - ca-certificates
  - epel-release
  - gcc
  - gcc-c++
```

## Service Configuration

### Docker Swarm Configuration

#### Network Setup
The deployment creates several overlay networks:
- `app_network` - Main application network
- `logging_network` - ELK stack communication
- `test_network` - Testing and development

#### Volume Management
- `elasticsearch_data` - Elasticsearch data persistence
- `nifi_data` - Nifi configuration and flow persistence
- `airflow_data` - Airflow DAGs and metadata

#### Service Resources
Default resource allocation:
```yaml
elasticsearch_heap_size: "2g"
kibana_memory: "1g"
nifi_memory: "2g"
airflow_memory: "1g"
```

### ELK Stack Configuration

#### Log Sources
- **Docker Container Logs**: Automatically collected via Fluentd
- **System Logs**: Syslog forwarding to port 5140
- **Application Logs**: Custom log forwarding
- **External Systems**: Syslog-compatible log forwarding

#### Log Retention
```yaml
log_retention_days: 30
elasticsearch_index_template:
  settings:
    number_of_shards: 1
    number_of_replicas: 0
```

#### Index Patterns
Pre-configured Kibana index patterns:
- `docker-*` - Docker container logs
- `system-*` - System and service logs
- `app-*` - Application-specific logs

### Nginx Reverse Proxy Configuration

#### Service Routing
| Path | Upstream Service | Port |
|------|------------------|------|
| `/` | Default dashboard | 80 |
| `/kibana/` | Kibana | 5601 |
| `/nifi/` | Nifi | 8443 |
| `/airflow/` | Airflow | 8080 |
| `/portainer/` | Portainer | 9000 |
| `/elasticsearch/` | Elasticsearch | 9200 |

#### Load Balancing
- Round-robin distribution
- Health check endpoints
- Fail-over to healthy nodes

## Security Configuration

### SSH Hardening

Applied security measures:
```yaml
ssh_port: 22
ssh_permit_root_login: false
ssh_password_authentication: false
ssh_challenge_response_authentication: false
ssh_pubkey_authentication: true
ssh_max_auth_tries: 3
```

### Firewall Configuration

#### Debian/Ubuntu (UFW)
```yaml
- name: Configure UFW firewall
  ufw:
    rule: allow
    port: "{{ item }}"
  loop:
    - "22"    # SSH
    - "80"    # HTTP
    - "443"   # HTTPS
    - "5140"  # Syslog
```

#### RHEL/AlmaLinux (firewalld)
```yaml
- name: Configure firewalld
  firewalld:
    service: "{{ item }}"
    permanent: true
    state: enabled
  loop:
    - ssh
    - http
    - https
```

### Fail2ban Configuration

Automated intrusion detection:
```yaml
fail2ban_services:
  - ssh
  - nginx-http-auth
  - nginx-limit-req
```

### SSL/TLS Configuration

#### SSL Certificate Setup
1. **Obtain certificates**:
   ```bash
   # Let's Encrypt
   certbot --nginx -d your-domain.com
   
   # Or place custom certificates
   /etc/ssl/certs/nginx.crt
   /etc/ssl/private/nginx.key
   ```

2. **Enable SSL**:
   ```yaml
   # In group_vars/all.yml
   nginx_ssl_enabled: true
   ssl_certificate_path: "/etc/ssl/certs/nginx.crt"
   ssl_private_key_path: "/etc/ssl/private/nginx.key"
   ```

3. **Re-deploy Nginx**:
   ```bash
   ansible-playbook playbooks/nginx.yml
   ```

### User Management and LDAP Integration

#### Local User Creation
```yaml
users_to_create:
  - username: developer
    groups: [sudo, docker]
    ssh_key: "ssh-rsa AAAAB3NzaC1yc2E..."
    shell: /bin/bash
```

#### Microsoft LDAP/Entra Integration
```yaml
ldap_enabled: true
ldap_server: "your-ldap-server.com"
ldap_port: 389
ldap_base_dn: "DC=company,DC=com"
ldap_bind_dn: "CN=bind-user,OU=Service Accounts,DC=company,DC=com"
ldap_bind_password: "{{ vault_ldap_password }}"  # Use ansible-vault
ldap_search_base: "OU=Users,DC=company,DC=com"
```

**Required LDAP Information**:
- LDAP server hostname/IP and port
- Base DN (Distinguished Name)
- Bind user credentials with read permissions
- User search base and filters
- Group membership attributes

## Advanced Deployment Options

### High Availability Setup

#### Multi-Node Docker Swarm
```bash
# On manager node
docker swarm init --advertise-addr <manager-ip>

# On worker nodes (copy token from manager)
docker swarm join --token <worker-token> <manager-ip>:2377
```

#### Load Balancer Configuration
```yaml
nginx_upstream_servers:
  - "server 192.168.1.10:5601"  # Kibana node 1
  - "server 192.168.1.11:5601"  # Kibana node 2
```

### Backup and Recovery

#### Automated Backup Script
```bash
#!/bin/bash
# Daily backup of critical data
docker run --rm -v elasticsearch_data:/backup alpine tar czf /backup/elasticsearch-$(date +%Y%m%d).tar.gz /backup
docker run --rm -v nifi_data:/backup alpine tar czf /backup/nifi-$(date +%Y%m%d).tar.gz /backup
```

#### Recovery Process
```bash
# Stop services
docker service rm $(docker service ls -q)

# Restore data
docker run --rm -v elasticsearch_data:/backup alpine tar xzf /backup/elasticsearch-20231215.tar.gz -C /

# Restart services
ansible-playbook playbooks/elk-stack.yml
```

### Custom Configuration Templates

#### Override Default Templates
1. Create custom templates in `templates/custom/`
2. Update playbook variables:
   ```yaml
   nginx_template: "custom/nginx.conf.j2"
   elasticsearch_template: "custom/elasticsearch.yml.j2"
   ```

### Environment-Specific Variables

#### Development Environment
```yaml
# inventory/group_vars/development.yml
debug_mode: true
log_level: debug
resource_limits: false
ssl_enabled: false
firewall_enabled: false
```

#### Production Environment
```yaml
# inventory/group_vars/production.yml
debug_mode: false
log_level: warning
resource_limits: true
ssl_enabled: true
firewall_enabled: true
backup_enabled: true
```

## Monitoring and Maintenance

### Health Monitoring

#### Automated Health Checks
```bash
# Service health monitoring script
./files/scripts/health-check.sh

# Manual service status check
docker service ls
docker node ls
```

#### Service Health Endpoints
- Elasticsearch: `GET http://localhost:9200/_cluster/health`
- Kibana: `GET http://localhost:5601/status`
- Nifi: `GET https://localhost:8443/nifi-api/system-diagnostics`

### Log Management

#### Log Rotation
Automated log rotation configured for:
- Nginx logs (daily rotation, 7 day retention)
- Docker logs (json-file driver with size limits)
- System logs (rsyslog standard rotation)

#### Log Analysis
```bash
# Check log ingestion rates
curl "http://localhost:9200/_cat/indices?v"

# View recent logs in Kibana
open http://localhost:5601
```

### Performance Tuning

#### Elasticsearch Optimization
```yaml
elasticsearch_heap_size: "4g"  # 50% of available RAM
elasticsearch_indices_memory: "2g"
elasticsearch_thread_pool_bulk_queue_size: 1000
```

#### Resource Monitoring
```bash
# Monitor system resources
htop
iotop
docker stats

# Monitor Docker Swarm
docker service ps <service-name>
docker node inspect <node-id>
```

### Maintenance Tasks

#### Regular Updates
```bash
# Update system packages
ansible-playbook playbooks/basic-setup.yml

# Update Docker images
docker service update --image nginx:alpine nginx_service

# Certificate renewal (Let's Encrypt)
certbot renew --nginx
```

#### Cleanup Operations
```bash
# Remove unused Docker resources
docker system prune -f

# Clean old log files
find /var/log -name "*.log" -mtime +30 -delete

# Elasticsearch index cleanup
curl -X DELETE "localhost:9200/logs-$(date -d '30 days ago' +%Y.%m.%d)*"
```

### Troubleshooting

#### Common Issues and Solutions

**Issue**: Docker network creation fails  
**Solution**: Use minimal deployment to isolate the problem:
```bash
./deploy-minimal.sh
docker network ls
```

**Issue**: Services not starting due to resource constraints  
**Solution**: Check and adjust resource allocation:
```bash
free -h
df -h
# Reduce service memory limits in group_vars/all.yml
```

**Issue**: LDAP authentication not working  
**Solution**: Test LDAP connectivity:
```bash
ldapsearch -H ldap://your-ldap-server -x -D "bind-dn" -W -b "search-base"
```

**Issue**: SSL certificate errors  
**Solution**: Verify certificate installation:
```bash
openssl x509 -in /etc/ssl/certs/nginx.crt -text -noout
nginx -t
```

#### Debug Mode
Enable debug mode for troubleshooting:
```yaml
# In group_vars/all.yml
debug_mode: true
ansible_verbose: "-vvv"
```

#### Log Analysis
Check specific log files:
```bash
# Ansible deployment logs
tail -f ansible.log

# Service-specific logs
docker service logs elasticsearch_service
docker service logs kibana_service
docker service logs nginx_service

# System logs
journalctl -f -u docker
```

This comprehensive guide covers all aspects of deploying and maintaining the DevOps infrastructure across different environments and platforms.