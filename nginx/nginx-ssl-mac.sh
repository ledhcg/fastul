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

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Install or update Nginx using Homebrew
if brew list nginx &> /dev/null; then
    echo "Nginx is already installed. Updating..."
    brew upgrade nginx
else
    echo "Installing Nginx..."
    brew install nginx
fi

# Install mkcert for local SSL certificates
if ! command -v mkcert &> /dev/null; then
    echo "Installing mkcert for SSL certificates..."
    brew install mkcert
    mkcert -install
fi

# Create directories for nginx configs
echo "Setting up Nginx directories..."
NGINX_CONF_DIR=$(brew --prefix)/etc/nginx
SITES_DIR="$NGINX_CONF_DIR/servers"
SSL_DIR="$NGINX_CONF_DIR/ssl"

mkdir -p "$SITES_DIR"
mkdir -p "$SSL_DIR"

# Generate SSL certificates using mkcert
echo "Generating SSL certificates for $MAIN_DOMAIN..."
mkcert -cert-file "$SSL_DIR/$MAIN_DOMAIN.crt" -key-file "$SSL_DIR/$MAIN_DOMAIN.key" "$MAIN_DOMAIN" "*.$MAIN_DOMAIN" localhost 127.0.0.1 ::1

# Create temp directory for nginx configs
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

# Create nginx configuration
echo "Creating nginx configuration..."
NGINX_CONFIG="$TEMP_DIR/$MAIN_DOMAIN.conf"
cat > "$NGINX_CONFIG" << EOL
server {
    listen 80;
    server_name $MAIN_DOMAIN;
    
    # Redirect HTTP to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $MAIN_DOMAIN;

    charset utf-8;

    # SSL Configuration
    ssl_certificate $SSL_DIR/$MAIN_DOMAIN.crt;
    ssl_certificate_key $SSL_DIR/$MAIN_DOMAIN.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    
    access_log $(brew --prefix)/var/log/nginx/$MAIN_DOMAIN.access.log;
    error_log $(brew --prefix)/var/log/nginx/$MAIN_DOMAIN.error.log;
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
cp "$NGINX_CONFIG" "$SITES_DIR/$MAIN_DOMAIN.conf"

# Update main nginx.conf to include our server configs
NGINX_MAIN_CONF="$NGINX_CONF_DIR/nginx.conf"
if ! grep -q "include servers/\*.conf" "$NGINX_MAIN_CONF"; then
    # Backup original config
    cp "$NGINX_MAIN_CONF" "$NGINX_MAIN_CONF.bak"
    
    # Add the include directive inside the http block if it doesn't exist
    sed -i '' 's/http {/http {\n    include servers\/*.conf;/g' "$NGINX_MAIN_CONF"
fi

# Verify Nginx configuration
echo "Verifying Nginx configuration..."
nginx -t

# Set up localhost entry in /etc/hosts if needed
if ! grep -q "$MAIN_DOMAIN" /etc/hosts; then
    echo "Adding $MAIN_DOMAIN to /etc/hosts..."
    echo "127.0.0.1 $MAIN_DOMAIN" | sudo tee -a /etc/hosts
fi

# Start or restart Nginx service
echo "Starting Nginx service..."
if brew services list | grep -q "nginx"; then
    echo "Restarting Nginx..."
    brew services restart nginx
else
    echo "Starting Nginx as a service..."
    brew services start nginx
fi

# Create a command to renew certificates
RENEW_SCRIPT="$HOME/renew-$MAIN_DOMAIN-cert.sh"
cat > "$RENEW_SCRIPT" << EOL
#!/bin/bash
# Renew certificate for $MAIN_DOMAIN
mkcert -cert-file "$SSL_DIR/$MAIN_DOMAIN.crt" -key-file "$SSL_DIR/$MAIN_DOMAIN.key" "$MAIN_DOMAIN" "*.$MAIN_DOMAIN" localhost 127.0.0.1 ::1
brew services restart nginx
EOL
chmod +x "$RENEW_SCRIPT"

echo "Setup completed successfully!"
echo "Your site should now be accessible at: https://$MAIN_DOMAIN"
echo "To renew certificates in the future, run: $RENEW_SCRIPT"
echo ""
echo "Note: Since this uses mkcert, you'll need to install the generated root CA on any"
echo "devices that need to trust this certificate. For more information visit:"
echo "https://github.com/FiloSottile/mkcert"
