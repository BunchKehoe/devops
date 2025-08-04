# DevOps Infrastructure Automation

This repository contains comprehensive Ansible playbooks for setting up a complete Linux environment with containerized applications, monitoring, and logging infrastructure.

## 🚀 Features

- **Basic System Setup**: Essential packages and system configuration
- **User Management**: Local users with optional Microsoft LDAP/Entra integration
- **Git Configuration**: Local Git installation with hooks and templates
- **Docker Swarm**: Industry-standard containerized application platform
- **Nginx Reverse Proxy**: Load balancing and SSL-ready configuration
- **ELK Stack**: Complete logging solution (Fluentd + Elasticsearch + Kibana)
- **Apache Nifi**: Data integration and processing platform
- **Apache Airflow**: Workflow orchestration and scheduling
- **Security**: Fail2ban, firewall, SSH hardening, and SSL preparation

## 📁 Repository Structure

```
devops/
├── ansible/                    # Main Ansible directory
│   ├── inventory/             # Host inventories and variables
│   │   ├── hosts.yml         # Define your target hosts here
│   │   └── group_vars/
│   │       └── all.yml       # Global configuration variables
│   ├── playbooks/            # Individual component playbooks
│   │   ├── site.yml          # Main deployment playbook
│   │   ├── basic-setup.yml   # Basic packages and system setup
│   │   ├── users.yml         # User management and LDAP integration
│   │   ├── git.yml           # Git installation and configuration
│   │   ├── docker-setup.yml  # Docker Swarm deployment
│   │   ├── nginx.yml         # Nginx reverse proxy setup
│   │   ├── elk-stack.yml     # ELK stack deployment
│   │   ├── nifi.yml          # Apache Nifi deployment
│   │   └── airflow.yml       # Apache Airflow deployment
│   ├── templates/            # Jinja2 configuration templates
│   ├── files/                # Static files
│   ├── ansible.cfg           # Ansible configuration
│   └── README.md             # Detailed Ansible documentation
└── README.md                 # This file
```

## 🔧 Prerequisites

- **Control Machine**: Ansible 2.9+ installed
- **Target Hosts**: Ubuntu 18.04+ or CentOS/RHEL 7+
- **Access**: SSH key-based authentication to target hosts
- **Privileges**: Sudo access on target hosts
- **Resources**: Minimum 4GB RAM, 2 CPUs, 20GB disk space per host

## ⚡ Quick Start

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd devops/ansible
   ```

2. **Configure your inventory**:
   ```bash
   # Edit inventory/hosts.yml with your server details
   vim inventory/hosts.yml
   ```

3. **Customize variables**:
   ```bash
   # Edit global variables
   vim inventory/group_vars/all.yml
   ```

4. **Deploy complete infrastructure**:
   ```bash
   # Deploy everything
   ansible-playbook playbooks/site.yml
   
   # Or deploy specific components
   ansible-playbook playbooks/basic-setup.yml
   ansible-playbook playbooks/docker-setup.yml
   ansible-playbook playbooks/elk-stack.yml
   ```

## 🌐 Deployed Services

After successful deployment, the following services will be available:

| Service | URL | Description |
|---------|-----|-------------|
| **Dashboard** | `http://your-server/` | Main landing page with service links |
| **Kibana** | `http://your-server/kibana/` | Log analysis and visualization |
| **Nifi** | `http://your-server/nifi/` | Data integration platform |
| **Airflow** | `http://your-server/airflow/` | Workflow orchestration |
| **Portainer** | `http://your-server/portainer/` | Docker management |
| **Elasticsearch** | `http://your-server/elasticsearch/` | Search and analytics API |

### Direct Access URLs
- **Kibana**: `http://your-server:5601`
- **Nifi**: `https://your-server:8443/nifi` (accept self-signed cert)
- **Airflow**: `http://your-server:8080`
- **Portainer**: `http://your-server:9000`
- **Elasticsearch**: `http://your-server:9200`

## 🔐 Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| **Nifi** | admin | nifipassword |
| **Airflow** | admin | admin |
| **Portainer** | admin | (set on first login) |

## 🔧 Configuration Guide

### Basic Configuration

1. **Host Inventory** (`inventory/hosts.yml`):
   ```yaml
   all:
     hosts:
       your-server:
         ansible_host: 192.168.1.10
         ansible_user: ubuntu
         ansible_ssh_private_key_file: ~/.ssh/id_rsa
   ```

2. **Global Variables** (`inventory/group_vars/all.yml`):
   ```yaml
   # User management
   users_to_create:
     - username: johndoe
       groups: [sudo, docker]
       ssh_key: "ssh-rsa AAAAB3NzaC1yc2E..."
   
   # Git configuration
   git_user_name: "Your Name"
   git_user_email: "your.email@example.com"
   ```

### LDAP/Entra Integration

To enable Microsoft LDAP/Entra integration:

```yaml
# In inventory/group_vars/all.yml
ldap_enabled: true
ldap_server: "your-ldap-server.com"
ldap_base_dn: "DC=company,DC=com"
ldap_bind_dn: "CN=bind-user,OU=Service Accounts,DC=company,DC=com"
ldap_bind_password: "your-bind-password"  # Use ansible-vault
```

**Required Information for LDAP Setup**:
- LDAP server hostname/IP
- Base DN (Distinguished Name)
- Bind user credentials
- Search filters (optional)

### SSL Configuration

The infrastructure is prepared for SSL but deployed without it initially. To enable SSL:

1. **Obtain SSL certificates** (Let's Encrypt, commercial CA, or self-signed)
2. **Place certificates**:
   ```bash
   # Certificate files
   /etc/ssl/certs/nginx.crt
   /etc/ssl/private/nginx.key
   ```
3. **Enable SSL**:
   ```yaml
   # In inventory/group_vars/all.yml
   nginx_ssl_enabled: true
   ```
4. **Re-run Nginx playbook**:
   ```bash
   ansible-playbook playbooks/nginx.yml
   ```

**Required for SSL**:
- Valid SSL certificate file (.crt or .pem)
- Private key file (.key)
- Optional: Certificate chain/intermediate certificates

## 📊 Monitoring and Logging

### ELK Stack Features
- **Centralized Logging**: All applications send logs to Fluentd
- **External Log Support**: Configure external systems to send logs to port 5140 (syslog)
- **Retention Policy**: Configurable log retention (default: 30 days)
- **Index Patterns**: Pre-configured for Docker, system, and application logs

### Health Monitoring
- Automated health checks for all services
- System monitoring via cron jobs
- Log rotation and cleanup
- Resource usage monitoring

## 🛡️ Security Features

- **SSH Hardening**: Key-based auth, disabled root login, fail2ban
- **Firewall**: UFW configured with service-specific rules
- **User Management**: Secure user provisioning with proper permissions
- **Container Security**: Non-privileged containers, resource limits
- **SSL Ready**: Easy SSL/TLS enablement
- **Access Control**: Service-specific access controls

## 🔍 Troubleshooting

### Check Service Status
```bash
# Docker services
docker service ls

# Container status
docker ps

# Service logs
docker service logs <service-name>

# System status
systemctl status nginx
systemctl status docker
```

### Common Issues

1. **Services not starting**: Check available resources (RAM, disk space)
2. **SSL issues**: Verify certificate paths and permissions
3. **LDAP authentication**: Test LDAP connectivity and credentials
4. **Log ingestion**: Verify Fluentd is running and accessible

### Log Locations
- **Ansible logs**: `ansible.log`
- **Nginx logs**: `/var/log/nginx/`
- **Docker logs**: `docker logs <container-name>`
- **System logs**: `/var/log/syslog`

## 🔄 Maintenance

### Regular Tasks
- Update system packages: Re-run `basic-setup.yml`
- Certificate renewal: Update SSL certificates and re-run `nginx.yml`
- Log cleanup: Automated via retention policies
- Security updates: Monitor and apply security patches

### Scaling
- Add new hosts to inventory and re-run playbooks
- Join additional Docker Swarm nodes
- Configure load balancing for high availability

## 📞 Support

For issues, questions, or contributions:
1. Check the troubleshooting section
2. Review individual playbook documentation in `/ansible/README.md`
3. Create an issue in the repository
4. Consult the official documentation for individual components

## 📄 License

This project is licensed under the MIT License - see the individual files for details.

---

**Note**: This infrastructure is designed for development and staging environments. For production use, additional security hardening, monitoring, and backup strategies should be implemented.
