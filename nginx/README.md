# Nginx SSL Setup Script

This script automates the process of setting up Nginx with SSL certificates using Certbot for your domain.

## Prerequisites

- Ubuntu/Debian-based system
- Root or sudo access
- Nginx installed
- Domain name pointing to your server's IP address
- Port available for your application

## Installation & Usage

There are two ways to use this script:

### Method 1: Run directly from URL

```bash
curl -s https://raw.githubusercontent.com/ledhcg/fastul/main/nginx/nginx-ssl.sh | sudo bash -s example.com 8080 admin@example.com
```

Replace:
- `example.com` with your domain
- `8080` with your application port
- `admin@example.com` with your email (optional)

### Method 2: Download and run locally

Download the script:

```bash
curl -O https://raw.githubusercontent.com/ledhcg/fastul/main/nginx/nginx-ssl.sh
chmod +x nginx-ssl.sh
```

Then run it:

```bash
./nginx-ssl.sh <domain> <port> [email]
```

## Usage

Run the script with the following command:

```bash
./nginx-ssl.sh <domain> <port> [email]
```

### Parameters:

- `domain`: Your domain name (e.g., example.com)
- `port`: The port your application is running on (e.g., 8080)
- `email`: (Optional) Email for SSL certificate notifications. Defaults to mail@ledinhcuong.com

### Example:

```bash
./nginx-ssl.sh example.com 8080 admin@example.com
```

## What the Script Does

1. Creates Nginx configuration for your domain
2. Sets up reverse proxy to your application
3. Installs Certbot if not already installed
4. Obtains and configures SSL certificate
5. Sets up automatic SSL renewal
6. Enables and starts Nginx service

## Features

- Automatic HTTPS redirect
- WebSocket support
- Proper proxy headers configuration
- Automatic SSL renewal
- UTF-8 character encoding
- Access and error logs configuration
- Maximum upload size set to 20MB

## Notes

- Make sure your domain's DNS is properly configured before running the script
- The script requires sudo privileges
- The script will remove the default Nginx configuration
- SSL certificates will auto-renew before expiration

## Support

If you encounter any issues, please open an issue in the GitHub repository.

## License

This script is open-source and available under the MIT License. 