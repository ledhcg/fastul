# Nginx SSL Setup Script

This script automates the process of setting up Nginx with SSL certificates for your domain. There are two versions available:

- `nginx-ssl.sh` - For Ubuntu/Debian-based systems using Certbot
- `nginx-ssl-mac.sh` - For macOS systems using Homebrew and mkcert

## Prerequisites

### For Linux (nginx-ssl.sh)

- Ubuntu/Debian-based system
- Root or sudo access
- Nginx installed
- Domain name pointing to your server's IP address
- Port available for your application

### For macOS (nginx-ssl-mac.sh)

- macOS system
- Sudo access
- Port available for your application

## Installation & Usage

### For Linux (nginx-ssl.sh)

#### Method 1: Run directly from URL

```bash
curl -s https://raw.githubusercontent.com/ledhcg/fastul/master/nginx/nginx-ssl.sh | sudo bash -s example.com 8080 admin@example.com
```

Replace:
- `example.com` with your domain
- `8080` with your application port
- `admin@example.com` with your email (optional)

#### Method 2: Download and run locally

Download the script:

```bash
curl -O https://raw.githubusercontent.com/ledhcg/fastul/master/nginx/nginx-ssl.sh
chmod +x nginx-ssl.sh
```

Then run it:

```bash
./nginx-ssl.sh <domain> <port> [email]
```

### For macOS (nginx-ssl-mac.sh)

Download the script:

```bash
curl -O https://raw.githubusercontent.com/ledhcg/fastul/master/nginx/nginx-ssl-mac.sh
chmod +x nginx-ssl-mac.sh
```

Then run it:

```bash
./nginx-ssl-mac.sh <domain> <port> [email]
```

## Usage

### For Linux (nginx-ssl.sh)

Run the script with the following command:

```bash
./nginx-ssl.sh <domain> <port> [email]
```

#### Parameters:

- `domain`: Your domain name (e.g., example.com)
- `port`: The port your application is running on (e.g., 8080)
- `email`: (Optional) Email for SSL certificate notifications. Defaults to mail@ledinhcuong.com

#### Example:

```bash
./nginx-ssl.sh example.com 8080 admin@example.com
```

### For macOS (nginx-ssl-mac.sh)

Run the script with the following command:

```bash
./nginx-ssl-mac.sh <domain> <port> [email]
```

#### Parameters:

- `domain`: Your domain name (e.g., example.com or local.test)
- `port`: The port your application is running on (e.g., 8080)
- `email`: (Optional) Email for reference. Defaults to mail@ledinhcuong.com

#### Example:

```bash
./nginx-ssl-mac.sh myapp.local 3000 admin@example.com
```

## What the Script Does

### Linux Version (nginx-ssl.sh)

1. Creates Nginx configuration for your domain
2. Sets up reverse proxy to your application
3. Installs Certbot if not already installed
4. Obtains and configures SSL certificate
5. Sets up automatic SSL renewal
6. Enables and starts Nginx service

### macOS Version (nginx-ssl-mac.sh)

1. Installs or updates Nginx using Homebrew if needed
2. Installs mkcert for local SSL certificate generation
3. Creates Nginx configuration for your domain
4. Sets up reverse proxy to your application
5. Generates and configures local SSL certificates
6. Adds your domain to /etc/hosts if needed
7. Starts Nginx service via Homebrew services
8. Creates a certificate renewal script

## Features

### Common Features (Both Versions)

- Automatic HTTPS redirect
- WebSocket support
- Proper proxy headers configuration
- UTF-8 character encoding
- Access and error logs configuration
- Maximum upload size set to 20MB

### Linux Version (nginx-ssl.sh)

- Let's Encrypt SSL certificates for public domains
- Automatic SSL renewal via Certbot

### macOS Version (nginx-ssl-mac.sh)

- Local development environment setup
- Locally-trusted SSL certificates via mkcert
- Integration with Homebrew for package management
- Custom certificate renewal script

## Notes

### For Linux (nginx-ssl.sh)

- Make sure your domain's DNS is properly configured before running the script
- The script requires sudo privileges
- The script will remove the default Nginx configuration
- SSL certificates will auto-renew before expiration

### For macOS (nginx-ssl-mac.sh)

- This script is designed for local development environments
- The script requires sudo privileges for modifying /etc/hosts
- Local domains (like myapp.local) will be added to your /etc/hosts file
- You'll need to manually run the renewal script when needed
- Since mkcert creates locally-trusted certificates, clients need the root CA installed to trust the certificates

## Support

If you encounter any issues, please open an issue in the GitHub repository.

## License

This script is open-source and available under the MIT License. 