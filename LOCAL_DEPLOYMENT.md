# Local DevOps Infrastructure Deployment

This directory contains configuration and scripts for deploying the complete DevOps infrastructure stack on your local machine instead of remote servers.

## 🚀 Quick Start (Local Deployment)

### Prerequisites

- **Operating System**: Linux (Ubuntu 18.04+, CentOS 7+) or macOS
- **Ansible**: 2.9+ installed on your local machine
- **Sudo Access**: Required for system-level configuration
- **Resources**: Minimum 8GB RAM, 4 CPUs, 50GB disk space
- **Ports**: Ensure ports 80, 443, 5601, 8080, 8443, 9000, 9200 are available

### Installation

1. **Install Ansible** (if not already installed):
   ```bash
   # Ubuntu/Debian
   sudo apt update && sudo apt install ansible
   
   # macOS
   brew install ansible
   
   # Via pip
   pip install ansible
   ```

2. **Clone and navigate to the repository**:
   ```bash
   git clone <repository-url>
   cd devops/ansible
   ```

3. **Deploy the complete infrastructure**:
   ```bash
   ./deploy-local.sh
   ```

### Selective Deployment

You can deploy individual components instead of the full stack:

```bash
# Deploy specific components
./deploy-local.sh basic docker elk nginx

# Available components:
# - basic (or basics): Basic system setup
# - users: User management
# - git: Git configuration
# - docker: Docker and Docker Swarm
# - elk (or logging): ELK Stack
# - nginx (or proxy): Nginx reverse proxy
# - nifi: Apache Nifi
# - airflow: Apache Airflow
```

## 🌐 Accessing Services

After successful deployment, services will be available at:

| Service | URL | Description |
|---------|-----|-------------|
| **Main Dashboard** | http://localhost | Nginx reverse proxy landing page |
| **Kibana** | http://localhost:5601 | Log analysis and visualization |
| **Elasticsearch** | http://localhost:9200 | Search and analytics API |
| **Apache Nifi** | https://localhost:8443/nifi | Data integration platform |
| **Apache Airflow** | http://localhost:8080 | Workflow orchestration |
| **Portainer** | http://localhost:9000 | Docker container management |

## 🔐 Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| **Nifi** | admin | nifipassword |
| **Airflow** | admin | admin |
| **Portainer** | admin | (set on first login) |

## 🔧 Configuration Files

### Local-Specific Files

- `inventory/local.yml` - Local host inventory (targets localhost)
- `inventory/group_vars/local.yml` - Local deployment variables
- `ansible-local.cfg` - Ansible configuration for local deployment
- `deploy-local.sh` - Automated deployment script

### Customization

1. **Resource Allocation**: Edit `inventory/group_vars/local.yml` to adjust:
   - Elasticsearch heap size (`elasticsearch_heap_size`)
   - Log retention days (`log_retention_days`)
   - Service ports and configurations

2. **Git Configuration**: Set your preferred Git settings:
   ```yaml
   git_user_name: "Your Name"
   git_user_email: "your.email@example.com"
   ```

3. **Security Settings**: For development, security features are relaxed:
   - Firewall disabled (`firewall_enabled: false`)
   - SSL disabled (`nginx_ssl_enabled: false`)
   - fail2ban disabled (`fail2ban_enabled: false`)

## 🔍 Monitoring and Management

### Check Service Status
```bash
# Docker services
docker service ls

# Container status
docker ps

# Service logs
docker service logs <service-name>

# Deployment logs
tail -f ansible-local.log
```

### Common Management Tasks
```bash
# Restart all services
docker service update --force <service-name>

# Scale a service
docker service scale <service-name>=<replicas>

# Remove all services
docker service rm $(docker service ls -q)

# Clean up Docker system
docker system prune -f
```

## 🛠️ Troubleshooting

### Common Issues

1. **Port Conflicts**: If services fail to start, check for port conflicts:
   ```bash
   sudo netstat -tulpn | grep :<port>
   sudo lsof -i :<port>
   ```

2. **Insufficient Resources**: Monitor system resources:
   ```bash
   free -h  # Memory usage
   df -h    # Disk usage
   htop     # CPU and process monitoring
   ```

3. **Permission Issues**: Ensure your user is in the docker group:
   ```bash
   sudo usermod -aG docker $USER
   # Logout and login again
   ```

4. **Service Health**: Check individual service health:
   ```bash
   curl http://localhost:5601  # Kibana
   curl http://localhost:9200  # Elasticsearch
   curl http://localhost:8080  # Airflow
   ```

### Reset and Cleanup

To completely reset the local deployment:

```bash
# Stop all services
docker service rm $(docker service ls -q)

# Remove all containers, networks, and volumes
docker system prune -a --volumes -f

# Re-run deployment
./deploy-local.sh
```

## 🔄 Differences from Remote Deployment

### Optimizations for Local Development

1. **Resource Usage**: Reduced memory allocation for services
2. **Security**: Relaxed security settings for development ease
3. **SSL**: Disabled by default (can be enabled if needed)
4. **Networking**: Uses localhost/127.0.0.1 instead of external IPs
5. **Clustering**: Single-node configurations for most services
6. **Logging**: Shorter retention periods to save disk space

### Development Features

- No SSH configuration required
- Simplified user management
- Local file system access
- Faster deployment and iteration
- Easy service restart and debugging

## 📞 Support

For local deployment issues:

1. Check the troubleshooting section above
2. Review `ansible-local.log` for detailed error messages
3. Verify system requirements and available resources
4. Ensure all prerequisite ports are available
5. Check Docker service status and logs

## 🔒 Security Note

This local deployment configuration is optimized for development and testing. For production use:

1. Enable SSL/TLS encryption
2. Configure proper authentication
3. Enable firewall and security features
4. Use strong passwords and secrets
5. Implement proper backup strategies

---

**Note**: This configuration is designed for local development and testing. The infrastructure runs entirely on your local machine without requiring external servers or complex networking setup.