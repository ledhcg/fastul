#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Icons for better visibility
ICON_INFO="ℹ️ "
ICON_SUCCESS="✅ "
ICON_WARNING="⚠️ "
ICON_ERROR="❌ "
ICON_INSTALL="📦 "
ICON_CONFIG="⚙️ "

# Function to print messages
print_message() {
    echo -e "${GREEN}${ICON_INFO}${NC} $1"
}

print_success() {
    echo -e "${GREEN}${ICON_SUCCESS}${NC} $1"
}

print_error() {
    echo -e "${RED}${ICON_ERROR}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${ICON_WARNING}${NC} $1"
}

print_install() {
    echo -e "${GREEN}${ICON_INSTALL}${NC} $1"
}

print_config() {
    echo -e "${GREEN}${ICON_CONFIG}${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get latest nvm version from GitHub
get_latest_nvm_version() {
    if command_exists curl; then
        curl --silent "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/'
    elif command_exists wget; then
        wget -qO- "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/'
    else
        print_error "Neither curl nor wget is installed. Please install one of them first."
        exit 1
    fi
}

install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        print_warning "NVM is already installed. Checking for updates..."
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        return 0
    fi

    print_install "Starting NVM installation..."
    
    NVM_VERSION=$(get_latest_nvm_version)
    print_message "Latest NVM version from GitHub: $NVM_VERSION"
    if [ -z "$NVM_VERSION" ]; then
        print_error "Failed to get latest NVM version"
        return 1
    fi
    
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
    
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    if ! command_exists nvm; then
        print_error "NVM installation failed"
        return 1
    fi
    
    print_success "NVM installed successfully!"
    return 0
}

install_node_lts() {
    print_install "Installing Node.js LTS..."
    nvm install --lts
    
    if [ $? -eq 0 ]; then
        nvm use --lts
        print_success "Node.js LTS installed successfully!"
        print_message "Node.js version: $(node -v)"
        print_message "npm version: $(npm -v)"
        return 0
    else
        print_error "Node.js LTS installation failed"
        return 1
    fi
}

install_yarn() {
    print_install "Installing Yarn package manager..."
    npm install -g yarn
    
    if [ $? -eq 0 ]; then
        print_success "Yarn installed successfully! Version: $(yarn --version)"
        return 0
    else
        print_error "Yarn installation failed"
        return 1
    fi
}

install_pm2() {
    print_install "Installing PM2 process manager..."
    npm install -g pm2
    
    if [ $? -eq 0 ]; then
        print_success "PM2 installed successfully! Version: $(pm2 --version)"
        configure_pm2_startup
        return 0
    else
        print_error "PM2 installation failed"
        return 1
    fi
}

configure_pm2_startup() {
    print_config "Configuring PM2 startup..."
    if [ "$EUID" -eq 0 ]; then
        pm2 startup
    else
        startup_command=$(pm2 startup | grep "sudo env")
        if [ ! -z "$startup_command" ]; then
            print_warning "Please run the following command with sudo to enable PM2 startup:"
            echo "$startup_command"
        else
            print_error "Failed to generate PM2 startup command"
        fi
    fi
    print_success "PM2 configuration completed!"
}

install_nginx() {
    print_install "Installing Nginx web server..."
    
    if command_exists nginx; then
        print_warning "Nginx is already installed. Version: $(nginx -v 2>&1)"
        return 0
    fi
    
    if [ "$EUID" -ne 0 ]; then
        print_warning "Please run the following commands with sudo to install Nginx:"
        echo "sudo apt update"
        echo "sudo apt install -y nginx"
        echo "sudo systemctl enable nginx"
        echo "sudo systemctl start nginx"
        return 0
    else
        apt update
        apt install -y nginx
        systemctl enable nginx
        systemctl start nginx
        
        if [ $? -eq 0 ]; then
            print_success "Nginx installed and started successfully!"
            print_message "Nginx version: $(nginx -v 2>&1)"
            return 0
        else
            print_error "Nginx installation failed"
            return 1
        fi
    fi
}

# Main installation process
main() {
    echo "=== STARTING SETUP UBUNTU ==="
    echo -e "\nStep 1: Installing NVM (Node Version Manager)"
    install_nvm || exit 1
    
    echo -e "\nStep 2: Installing Node.js LTS"
    install_node_lts || exit 1
    
    echo -e "\nStep 3: Installing Yarn Package Manager"
    install_yarn || exit 1
    
    echo -e "\nStep 4: Installing and Configuring PM2 Process Manager"
    install_pm2 || exit 1
    
    echo -e "\nStep 5: Installing Nginx Web Server"
    install_nginx || exit 1
    
    echo -e "\n=== SETUP UBUNTU COMPLETED ==="
    print_success "Ubuntu environment has been successfully set up!"
}

# Check if curl or wget is installed
if ! command_exists curl && ! command_exists wget; then
    print_error "Neither curl nor wget is installed. Please install one of them first."
    exit 1
fi

# Run main installation
main 