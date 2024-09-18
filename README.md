# Ubuntu Development Environment Setup

This repository contains a script to set up a development environment on Ubuntu. The script installs and configures various tools and applications commonly used by software developers.

## Overview

The `setup.sh` script automates the installation and configuration of:

- Basic system updates and utilities
- Terminal emulator (Alacritty)
- Development tools (VSCode, DBeaver-CE)
- Productivity applications (NordPass, Remmina, Slack)
- Twingate VPN client
- Nix package manager
- Home Manager
- Docker
- Homebrew
- Zsh shell

## Prerequisites

- A fresh installation of Ubuntu (tested on Ubuntu 24.04 LTS)
- Sudo privileges on your account

## Usage

### Recommended Approach

The recommended way to use this script is to run it line by line. This allows you to understand each step and make any necessary adjustments for your specific setup.

1. Clone this repository or copy it manually to your ~/.config/home-manager/ (if you want home-manager to install your git):
   ```
   git clone https://github.com/pedro-pscunha/nix.git ~/.config/home-manager/
   ```

2. Open the `setup.sh` script in a text editor and review each command.

3. Open a terminal and execute each command manually, ensuring it completes successfully before moving to the next.

### Alternative: Running the Entire Script

If you're confident in the script and understand all its operations, you can run it in its entirety:

1. Make the script executable:
   ```
   chmod +x setup.sh
   ```

2. Run the script:
   ```
   ./setup.sh
   ```

## Important Notes

- **Read Each Step**: Even if running the entire script, it's crucial to read and understand each step.
- **Manual Steps**: Some steps require manual intervention, such as copying configuration files or setting up secrets.
- **Customization**: Feel free to modify the script to suit your specific needs before running it.
- **Nix and Home Manager**: This script sets up Nix and Home Manager, which are powerful tools for managing your development environment. Familiarize yourself with these tools for best results.
- **Docker Setup**: The script adds your user to the Docker group. You may need to log out and back in for this to take effect.
- **Zsh Configuration**: The script changes your default shell to Zsh. You'll need to log out and back in for this change to take effect.

## Post-Installation

After running the script:

1. Review the installed applications and configurations.
2. Set up your secrets in `~/.config/home-manager/.exports.*`
3. Customize your Zsh configuration as needed.
4. Log out and log back in to ensure all changes take effect.

## Troubleshooting

If you encounter any issues:

1. Check the terminal output for error messages.
2. Ensure all prerequisites are met.
3. Try running the problematic command manually to see more detailed error output.
4. Check the official documentation of the tool causing issues.

## Contributing

Contributions to improve the script or documentation are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## Disclaimer

This script is provided as-is, without warranties of any kind. Always review scripts before running them on your system, especially those that make system-wide changes.
