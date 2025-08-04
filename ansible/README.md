# DevOps Ansible Playbooks

This directory contains comprehensive Ansible playbooks for setting up a complete Linux environment with containerized applications and monitoring.

## Features

- **Basic Package Installation**: Essential tools (vim, curl, wget, python3-pip)
- **User Management**: User provisioning with optional Microsoft LDAP/Entra integration
- **Git Setup**: Local Git installation with configuration
- **Docker Swarm**: Industry-standard Docker Swarm deployment
- **Nginx Proxy**: Reverse proxy for Docker Swarm services
- **ELK Stack**: Logging infrastructure (Fluentd + Elasticsearch + Kibana)
- **Apache Nifi**: Data integration platform
- **Apache Airflow**: Workflow orchestration platform

## Quick Start

1. **Configure Inventory**: Edit `inventory/hosts.yml` with your target hosts
2. **Set Variables**: Customize variables in `inventory/group_vars/`
3. **Run Playbook**: Execute the main playbook

```bash
# Install all components
ansible-playbook -i inventory/hosts.yml playbooks/site.yml

# Install specific components
ansible-playbook -i inventory/hosts.yml playbooks/basic-setup.yml
ansible-playbook -i inventory/hosts.yml playbooks/docker-setup.yml
```

## Directory Structure

```
ansible/
├── inventory/           # Host inventories and variables
├── playbooks/          # Main playbooks
├── roles/              # Reusable roles for complex components
├── templates/          # Jinja2 templates
├── files/              # Static files
└── README.md           # This file
```

## Prerequisites

- Ansible installed on control machine
- SSH access to target hosts
- Sudo privileges on target hosts
- Python 3 on target hosts

## Configuration

### SSL Configuration (for future use)

The Nginx proxy is configured without SSL but can be easily extended. To enable SSL:

1. Obtain SSL certificates
2. Update `inventory/group_vars/all.yml` with certificate paths
3. Set `nginx_ssl_enabled: true`
4. Re-run the nginx playbook

### LDAP/Entra Integration

To enable Microsoft LDAP/Entra integration:

1. Configure LDAP settings in `inventory/group_vars/all.yml`
2. Set `ldap_enabled: true`
3. Provide LDAP server details and credentials

## Security Considerations

- All secrets should be stored in Ansible Vault
- Default configurations use non-privileged users where possible
- Network security is configured with appropriate firewall rules
- SSL/TLS encryption should be enabled in production

## Monitoring and Logging

- All applications are configured to send logs to the ELK stack
- Logs from external networks are supported
- Default retention policies are applied but can be customized

## Support

For issues or questions, please refer to the individual playbook documentation or create an issue in the repository.