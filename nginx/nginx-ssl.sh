#!/bin/bash

# Exit on error
set -e

# Check if domain and port are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <domain> <port> [email]"
    echo "Example: $0 example.com 8080 admin@example.com"
    exit 1
fi

# Set variables from arguments
MAIN_DOMAIN="$1"
PORT="$2"
EMAIL="${3:-mail@ledinhcuong.com}"  # Use default email if not provided

# Create temp directory for nginx configs
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

# Create nginx configuration
echo "Creating nginx configuration..."
NGINX_CONFIG="$TEMP_DIR/$MAIN_DOMAIN"
cat > "$NGINX_CONFIG" << EOL
server {
    listen 80;
    server_name $MAIN_DOMAIN;

    charset utf-8;

    access_log /var/log/nginx/$MAIN_DOMAIN.access.log;
    error_log /var/log/nginx/$MAIN_DOMAIN.error.log;
    client_max_body_size 20M;
    
    location / {
        proxy_pass http://127.0.0.1:$PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Port \$server_port;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

# Copy Nginx configuration
echo "Configuring Nginx..."
sudo mkdir -p /etc/nginx/sites-available/
sudo cp "$NGINX_CONFIG" "/etc/nginx/sites-available/$MAIN_DOMAIN"
sudo ln -sf "/etc/nginx/sites-available/$MAIN_DOMAIN" "/etc/nginx/sites-enabled/$MAIN_DOMAIN"

sudo rm -f /etc/nginx/sites-enabled/default  # Remove default config

# Verify Nginx configuration
echo "Verifying Nginx configuration..."
sudo nginx -t

# Install Certbot and its dependencies
echo "Installing Certbot..."
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -sf /snap/bin/certbot /usr/bin/certbot

# Obtain and install SSL certificate
echo "Setting up SSL certificates..."
sudo certbot --nginx \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    --domains "$MAIN_DOMAIN" \
    --redirect \
    --expand

# Start and enable Nginx service
echo "Starting Nginx service..."
sudo systemctl restart nginx
sudo systemctl enable nginx

# Set up automatic renewal
echo "Setting up automatic renewal..."
if sudo systemctl list-timers | grep -q 'snap.certbot.renew'; then
    echo "Certbot renewal timer is active"
else
    echo "Setting up Certbot renewal timer..."
    sudo systemctl enable snap.certbot.renew.timer
    sudo systemctl start snap.certbot.renew.timer
fi

echo "Setup completed successfully!"
echo "Your site should now be accessible at: https://$MAIN_DOMAIN"
