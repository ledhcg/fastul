# Ubuntu Development Environment Setup Script

This script automates the process of setting up a development environment on Ubuntu/Debian-based systems by installing and configuring essential development tools.

## Prerequisites

- Ubuntu/Debian-based system
- Root or sudo access
- Internet connection
- Either `curl` or `wget` installed

## Installation & Usage

There are two ways to use this script:

### Method 1: Run directly from URL

```bash
curl -s https://raw.githubusercontent.com/ledhcg/fastul/master/ubuntu/setup_ubuntu.sh | bash
```

### Method 2: Download and run locally

Download the script:

```bash
curl -O https://raw.githubusercontent.com/ledhcg/fastul/master/ubuntu/setup_ubuntu.sh
chmod +x setup_ubuntu.sh
```

Then run it:

```bash
./setup_ubuntu.sh
```

## What the Script Does

1. Installs NVM (Node Version Manager)
   - Fetches and installs the latest version of NVM
   - Sets up NVM environment variables

2. Installs Node.js LTS
   - Installs the latest LTS version of Node.js
   - Sets it as the default Node.js version

3. Installs Yarn Package Manager
   - Installs Yarn globally using npm
   - Provides an alternative to npm for package management

4. Installs and Configures PM2 Process Manager
   - Installs PM2 globally
   - Sets up PM2 startup script for process management
   - Configures automatic startup on system boot

## Features

- Colored output with informative icons
- Automatic detection of latest NVM version
- Error handling and status checks
- PM2 startup configuration
- Support for both curl and wget
- Clear progress indicators

## Script Output

The script provides clear visual feedback with:
- ℹ️ Information messages
- ✅ Success confirmations
- ⚠️ Warning notifications
- ❌ Error alerts
- 📦 Installation progress
- ⚙️ Configuration updates

## Version Information

After installation, you'll have access to:
- Latest LTS version of Node.js
- Latest version of npm
- Latest version of Yarn
- Latest version of PM2
- Latest version of NVM

## Notes

- The script requires an internet connection
- Some operations may require sudo privileges
- PM2 startup configuration may require additional manual steps
- The script will update existing installations if components are already present

## Support

If you encounter any issues, please open an issue in the GitHub repository.

## License

This script is open-source and available under the MIT License. 