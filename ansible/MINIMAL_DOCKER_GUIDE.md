# Minimal Docker Deployment Guide

## Overview

This guide provides a **minimal viable Docker deployment** that focuses only on core Docker Swarm functionality using **Docker CLI commands** instead of Ansible Docker modules. This approach eliminates Python Docker SDK dependency issues and provides a solid foundation for building infrastructure.

## Key Approach

This deployment uses **Docker CLI commands** directly in Ansible shell tasks rather than the `community.docker` Ansible modules. This eliminates the need for the Python Docker SDK while still providing full automation.

## What This Includes

✅ **Docker Engine Installation** - Core Docker functionality  
✅ **Docker Swarm Initialization** - Single-node swarm cluster using `docker swarm init`  
✅ **CLI-Based Network Creation** - Overlay networks created via `docker network create`  
✅ **CLI-Based Volume Creation** - Volumes created via `docker volume create`  
✅ **Service Deployment Testing** - Verify everything works with `docker service create`  
✅ **No Python Docker SDK Required** - Uses Docker CLI directly  

## What This Excludes

❌ **Docker Compose** - Causes Python package conflicts  
❌ **Ansible Docker Modules** - Eliminated to avoid SDK dependency issues  
❌ **Portainer** - Complex monitoring/management UI  
❌ **Firewall Configuration** - Simplified for local testing  
❌ **ELK Stack Integration** - Complex logging infrastructure  
❌ **SSL/TLS Configuration** - Simplified for testing  

## Architecture Decision

Instead of using Ansible modules like:
```yaml
- name: Create network (problematic)
  community.docker.docker_network:
    name: test_network
    driver: overlay
```

We use direct CLI commands:
```yaml
- name: Create Docker network using CLI
  shell: docker network create --driver overlay --attachable test_network
  when: network_exists.rc != 0
```  

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

1. **Docker CLI Commands Work** ✅
2. **Docker Swarm Initialization Works** ✅ (via `docker swarm init`)  
3. **Overlay Network Creation Works** ✅ (via `docker network create`)
4. **Volume Creation Works** ✅ (via `docker volume create`)
5. **Service Deployment Works** ✅ (via `docker service create`)

## Root Cause Analysis

The original deployment failure was **NOT** due to Docker network creation issues. The issue was with:

1. **Python Docker SDK Missing** - Ansible `community.docker` modules require the Docker SDK
2. **Environment Variables** - No `$DOCKER_HOST` needed for local Docker
3. **Module Dependencies** - Complex dependency chains with docker-compose

**Solution**: Use Docker CLI commands directly instead of Ansible Docker modules.

## Next Steps

Once this minimal setup works reliably, you can gradually add back components:

1. **Add More Networks** - Additional overlay networks using same CLI approach
2. **Add Services Incrementally** - One service at a time with testing
3. **Add Docker Compose Alternative** - Use native `docker stack deploy` 
4. **Add Basic Monitoring** - Simple health checks without complex modules
5. **Add Security** - Firewall rules and SSL when everything else works

## Files

- `playbooks/docker-setup-minimal.yml` - Minimal Docker setup using CLI commands
- `deploy-minimal.sh` - Simplified deployment script
- `MINIMAL_DOCKER_GUIDE.md` - This documentation

## Troubleshooting

If the minimal setup fails:

1. **Check Docker installation**: `docker --version`
2. **Check Docker daemon**: `docker info`
3. **Check connectivity**: `docker network ls`
4. **Run with verbose output**: `ansible-playbook -vvv playbooks/docker-setup-minimal.yml -i inventory/local.yml`
5. **Check CLI commands manually**:
   - `docker swarm init --advertise-addr 127.0.0.1`
   - `docker network create --driver overlay --attachable test_network`
   - `docker volume create test_volume`

### Common Issues Resolved

❌ **"Error connecting: Error while fetching server API version"**  
✅ **Fixed by using Docker CLI commands instead of Python SDK**

❌ **"DOCKER_HOST not defined"**  
✅ **Not needed for local Docker daemon - CLI commands work directly**

❌ **"Python Docker SDK missing"**  
✅ **Eliminated by using shell commands instead of Ansible Docker modules**