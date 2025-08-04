# Minimal Docker Deployment Guide

## Overview

This guide provides a **minimal viable Docker deployment** that focuses only on core Docker Swarm functionality. This simplified approach helps isolate issues and provides a solid foundation for building more complex infrastructure.

## What This Includes

✅ **Docker Engine Installation** - Core Docker functionality  
✅ **Docker Swarm Initialization** - Single-node swarm cluster  
✅ **Docker SDK for Python** - Required for Ansible Docker modules  
✅ **Basic Overlay Network** - Test network for service communication  
✅ **Basic Volume** - Test volume for data persistence  
✅ **Service Deployment Testing** - Verify everything works  

## What This Excludes

❌ **Docker Compose** - Causes Python package conflicts  
❌ **Portainer** - Complex monitoring/management UI  
❌ **Firewall Configuration** - Simplified for local testing  
❌ **ELK Stack Integration** - Complex logging infrastructure  
❌ **SSL/TLS Configuration** - Simplified for testing  
❌ **Complex Networking** - Only basic overlay networks  

## Quick Start

### 1. Deploy Minimal Docker Setup

```bash
cd ansible
./deploy-minimal.sh
```

### 2. Verify Installation

```bash
# Check Docker nodes
docker node ls

# Check networks (should show overlay networks)
docker network ls | grep overlay

# Check volumes
docker volume ls
```

### 3. Test Service Deployment

```bash
# Deploy a test service
docker service create --name test-nginx --network test_network --publish 8080:80 nginx:alpine

# Check service status
docker service ls

# Access the service (if ports are accessible)
curl http://localhost:8080

# Clean up
docker service rm test-nginx
```

## Results

This minimal setup successfully demonstrates that:

1. **Docker SDK Installation Works** ✅
2. **Docker Swarm Initialization Works** ✅  
3. **Overlay Network Creation Works** ✅
4. **Volume Creation Works** ✅
5. **Service Deployment Works** ✅

## Root Cause Analysis

The original deployment failure was **NOT** due to Docker network creation issues. The networks were being created successfully. The failure occurred in later steps when trying to install additional complex components like:

- `docker-compose` (Python package conflicts with PyYAML/Cython)
- Portainer monitoring stack
- Complex firewall configurations
- Extensive logging and monitoring setup

## Next Steps

Once this minimal setup works reliably, you can gradually add back components:

1. **Add Docker Compose** - Use native `docker stack deploy` instead of `pip install docker-compose`
2. **Add Basic Monitoring** - Simple health checks without Portainer
3. **Add Networking** - Additional overlay networks as needed
4. **Add Services** - One service at a time with testing
5. **Add Security** - Firewall rules and SSL when everything else works

## Files

- `playbooks/docker-setup-minimal.yml` - Minimal Docker setup playbook
- `deploy-minimal.sh` - Simplified deployment script
- `MINIMAL_DOCKER_GUIDE.md` - This documentation

## Troubleshooting

If the minimal setup fails:

1. Check Docker installation: `docker --version`
2. Check Python Docker SDK: `python3 -c "import docker; print(docker.__version__)"`
3. Check Ansible Docker modules: `ansible-doc community.docker.docker_swarm`
4. Run with verbose output: `ansible-playbook -vvv playbooks/docker-setup-minimal.yml -i inventory/local.yml`