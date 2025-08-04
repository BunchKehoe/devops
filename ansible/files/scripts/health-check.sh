#!/bin/bash
# Deployment validation script

echo "=== DevOps Infrastructure Health Check ==="
echo "Date: $(date)"
echo "Host: $(hostname)"
echo

# Function to check service
check_service() {
    local service_name=$1
    local port=$2
    local expected_code=${3:-200}
    
    echo -n "Checking $service_name (port $port)... "
    
    if curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://localhost:$port" | grep -q "$expected_code"; then
        echo "✓ OK"
        return 0
    else
        echo "✗ FAILED"
        return 1
    fi
}

# Function to check HTTPS service
check_https_service() {
    local service_name=$1
    local port=$2
    
    echo -n "Checking $service_name (HTTPS port $port)... "
    
    if curl -k -s -o /dev/null -w "%{http_code}" --max-time 10 "https://localhost:$port" | grep -q "200"; then
        echo "✓ OK"
        return 0
    else
        echo "✗ FAILED"
        return 1
    fi
}

# Check Docker
echo "=== Docker Status ==="
if systemctl is-active --quiet docker; then
    echo "✓ Docker service is running"
    echo "Docker version: $(docker --version)"
    echo "Active containers: $(docker ps --format 'table {{.Names}}\t{{.Status}}' | tail -n +2 | wc -l)"
else
    echo "✗ Docker service is not running"
fi
echo

# Check Docker Swarm
echo "=== Docker Swarm Status ==="
if docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null | grep -q "active"; then
    echo "✓ Docker Swarm is active"
    echo "Swarm nodes: $(docker node ls --format '{{.Hostname}}\t{{.Status}}\t{{.Availability}}' 2>/dev/null | wc -l)"
else
    echo "✗ Docker Swarm is not active"
fi
echo

# Check services
echo "=== Service Health Checks ==="
check_service "Nginx" "80"
check_service "Elasticsearch" "9200"
check_service "Kibana" "5601"
check_service "Airflow" "8080"
check_service "Portainer" "9000"
check_https_service "Nifi" "8443"
echo

# Check disk space
echo "=== System Resources ==="
echo "Disk usage:"
df -h / | tail -1 | awk '{print "  Root filesystem: " $5 " used (" $3 "/" $2 ")"}'

echo "Memory usage:"
free -h | grep "Mem:" | awk '{print "  Memory: " $3 "/" $2 " (" int($3/$2*100) "% used)"}'

echo "CPU load average:"
uptime | awk -F'load average:' '{print "  Load:" $2}'
echo

# Check log ingestion
echo "=== Log Ingestion ==="
if curl -s "http://localhost:9200/_cat/indices?v" | grep -q "docker\|system\|application"; then
    echo "✓ Log indices found in Elasticsearch"
    echo "Recent indices:"
    curl -s "http://localhost:9200/_cat/indices?v" | grep -E "(docker|system|application)" | head -5
else
    echo "✗ No log indices found"
fi
echo

# Check Docker stack status
echo "=== Docker Stack Status ==="
if command -v docker >/dev/null 2>&1; then
    echo "Active stacks:"
    docker stack ls 2>/dev/null || echo "No stacks found or Docker Swarm not initialized"
    echo
    echo "Service status:"
    docker service ls --format 'table {{.Name}}\t{{.Replicas}}\t{{.Image}}' 2>/dev/null || echo "No services found"
fi
echo

# Summary
echo "=== Summary ==="
echo "Infrastructure health check completed at $(date)"
echo "Review any failed checks above and consult the documentation for troubleshooting."