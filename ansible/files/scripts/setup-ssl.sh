#!/bin/bash
# SSL Certificate setup helper script

set -e

CERT_DIR="/etc/ssl/devops"
NGINX_CERT_PATH="/etc/ssl/certs/nginx.crt"
NGINX_KEY_PATH="/etc/ssl/private/nginx.key"

echo "=== SSL Certificate Setup Helper ==="
echo

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Create certificate directory
mkdir -p "$CERT_DIR"
mkdir -p "$(dirname "$NGINX_CERT_PATH")"
mkdir -p "$(dirname "$NGINX_KEY_PATH")"

echo "Choose certificate setup method:"
echo "1) Generate self-signed certificate (for testing)"
echo "2) Use existing certificate files"
echo "3) Generate Let's Encrypt certificate (requires domain)"
echo -n "Enter choice [1-3]: "
read -r choice

case $choice in
    1)
        echo "Generating self-signed certificate..."
        
        echo -n "Enter hostname/domain name: "
        read -r hostname
        
        # Generate self-signed certificate
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$NGINX_KEY_PATH" \
            -out "$NGINX_CERT_PATH" \
            -subj "/C=US/ST=State/L=City/O=Organization/OU=IT/CN=$hostname"
        
        echo "✓ Self-signed certificate generated"
        ;;
        
    2)
        echo "Using existing certificate files..."
        
        echo -n "Enter path to certificate file: "
        read -r cert_path
        echo -n "Enter path to private key file: "
        read -r key_path
        
        if [[ ! -f "$cert_path" ]]; then
            echo "Error: Certificate file not found: $cert_path"
            exit 1
        fi
        
        if [[ ! -f "$key_path" ]]; then
            echo "Error: Private key file not found: $key_path"
            exit 1
        fi
        
        # Copy files
        cp "$cert_path" "$NGINX_CERT_PATH"
        cp "$key_path" "$NGINX_KEY_PATH"
        
        echo "✓ Certificate files copied"
        ;;
        
    3)
        echo "Setting up Let's Encrypt certificate..."
        
        # Check if certbot is installed
        if ! command -v certbot >/dev/null 2>&1; then
            echo "Installing certbot..."
            apt-get update
            apt-get install -y certbot python3-certbot-nginx
        fi
        
        echo -n "Enter domain name: "
        read -r domain
        echo -n "Enter email address: "
        read -r email
        
        # Generate Let's Encrypt certificate
        certbot --nginx -d "$domain" --email "$email" --agree-tos --non-interactive
        
        # Link to expected paths
        ln -sf "/etc/letsencrypt/live/$domain/fullchain.pem" "$NGINX_CERT_PATH"
        ln -sf "/etc/letsencrypt/live/$domain/privkey.pem" "$NGINX_KEY_PATH"
        
        echo "✓ Let's Encrypt certificate generated"
        echo "Note: Auto-renewal is configured via systemd timer"
        ;;
        
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

# Set proper permissions
chmod 644 "$NGINX_CERT_PATH"
chmod 600 "$NGINX_KEY_PATH"
chown root:root "$NGINX_CERT_PATH" "$NGINX_KEY_PATH"

echo
echo "=== Certificate Information ==="
echo "Certificate: $NGINX_CERT_PATH"
echo "Private Key: $NGINX_KEY_PATH"
echo

# Display certificate details
if [[ -f "$NGINX_CERT_PATH" ]]; then
    echo "Certificate details:"
    openssl x509 -in "$NGINX_CERT_PATH" -text -noout | grep -E "(Subject:|Issuer:|Not Before:|Not After:)"
fi

echo
echo "=== Next Steps ==="
echo "1. Update inventory/group_vars/all.yml:"
echo "   nginx_ssl_enabled: true"
echo "   nginx_ssl_cert_path: $NGINX_CERT_PATH"
echo "   nginx_ssl_key_path: $NGINX_KEY_PATH"
echo
echo "2. Re-run the nginx playbook:"
echo "   ansible-playbook playbooks/nginx.yml"
echo
echo "3. Verify SSL configuration:"
echo "   curl -I https://your-server/"
echo
echo "SSL certificate setup completed!"