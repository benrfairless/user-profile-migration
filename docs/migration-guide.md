# User Profile Migration Guide

## Overview
This guide helps you migrate from your current user profile to a new one while preserving all important configurations and data.

## Selective Restore Benefits

The restore script now offers **selective restoration**, giving you fine-grained control over what gets restored:

### Why Use Selective Restore?
- **Clean slate approach**: Start fresh but only restore what you need
- **Avoid conflicts**: Skip configurations that might conflict with new setup
- **Gradual migration**: Restore components one at a time to test compatibility
- **Minimal setup**: Only restore essential tools for a lighter system
- **Troubleshooting**: Isolate issues by restoring components individually

### Common Scenarios
- **New machine setup**: Restore shell + dev tools, skip heavy applications
- **Work vs Personal**: Different configurations for different environments  
- **Testing setup**: Restore only development tools to test new configurations
- **Minimal install**: Just shell configuration and essential tools
- **Conflict resolution**: Skip problematic configurations and restore manually later

## What's Been Backed Up

The backup script creates a **compressed archive (.tar.gz)** containing all your important configurations and data, making it perfect for iCloud Drive storage.

### Backup Contents

### Shell Configuration
- `.zshrc`, `.zprofile`, `.bashrc`, `.bash_profile`, `.profile`
- PowerLevel10K configuration (`.p10k.zsh`)
- Oh My Zsh installation and configuration
- iTerm2 shell integration

### Development Tools
- Git configuration (`.gitconfig`, `.gitignore_global`, etc.)
- asdf configuration and installed tools (`.tool-versions`, `.asdfrc`)
- Development tool configurations

### SSH Configuration
- SSH config file and known hosts
- Public keys (private keys NOT backed up for security)

### Application Configurations
- AWS CLI configuration
- Azure CLI configuration
- Docker configuration
- OrbStack configuration
- Terraform configuration
- Vagrant configuration
- VS Code settings and extensions
- iTerm2 preferences
- 1Password CLI configuration
- GPG configuration
- npm configuration

### Homebrew
- Current Brewfile with all installed packages
- Both formulae and casks
- VS Code extensions list

## Migration Steps

### Step 1: Create New User Account
1. Go to System Preferences > Users & Groups
2. Click the lock and authenticate
3. Click "+" to add a new user
4. Choose "Administrator" account type
5. Fill in the details for your new account
6. Log out and log into the new account

### Step 2: Upload Backup to iCloud Drive
```bash
# The backup script creates a compressed archive automatically
# Copy the .tar.gz file to iCloud Drive
cp ~/user_profile_backup_YYYYMMDD_HHMMSS.tar.gz ~/iCloud\ Drive/

# Or drag and drop the .tar.gz file to iCloud Drive in Finder
```

### Step 3: Download and Extract on New Account
```bash
# From your new account, download from iCloud Drive
# The file will be in ~/iCloud\ Drive/ or ~/Library/Mobile\ Documents/com~apple~CloudDocs/

# Extract the archive
tar -xzf ~/iCloud\ Drive/user_profile_backup_YYYYMMDD_HHMMSS.tar.gz

# Or let the restore script handle extraction automatically
```

### Step 4: Run Restore Script (with Selective Options!)
```bash
# Option 1: Interactive selection (recommended for most users)
# Extract archive and run from within - choose what to restore
tar -xzf ~/iCloud\ Drive/user_profile_backup_YYYYMMDD_HHMMSS.tar.gz
cd user_profile_backup_YYYYMMDD_HHMMSS
./user_profile_restore.sh
# Interactive menu will let you choose:
# - Shell Configuration (zsh, themes, etc.)
# - Homebrew Packages
# - Development Tools (Git, asdf, etc.)
# - SSH Configuration
# - Application Configurations

# Option 2: Restore everything (non-interactive)
./user_profile_restore.sh --all

# Option 3: Run with archive path and interactive selection
./user_profile_backup_YYYYMMDD_HHMMSS/user_profile_restore.sh ~/iCloud\ Drive/user_profile_backup_YYYYMMDD_HHMMSS.tar.gz

# Option 4: Run with archive path and restore all
./user_profile_backup_YYYYMMDD_HHMMSS/user_profile_restore.sh ~/iCloud\ Drive/user_profile_backup_YYYYMMDD_HHMMSS.tar.gz --all
```

#### Selective Restore Categories
- **Shell Configuration**: `.zshrc`, `.zprofile`, Oh My Zsh, PowerLevel10K, shell themes
- **Homebrew Packages**: All formulae, casks, and VS Code extensions from your Brewfile
- **Development Tools**: Git config, asdf with all language versions, development settings
- **SSH Configuration**: SSH config file, known hosts, public keys (private keys not included)
- **Application Configurations**: AWS, Azure, Docker, VS Code, iTerm2, and other app settings

### Step 5: Post-Migration Tasks

#### Immediate Tasks
1. Restart your terminal or run: `source ~/.zshrc`
2. Verify Git configuration: `git config --list`
3. Check SSH keys: `ls -la ~/.ssh/`
4. Verify asdf tools: `asdf list`
5. Test Homebrew: `brew list`

#### Authentication Tasks
- **GitHub**: Run `gh auth login` to re-authenticate
- **AWS**: Run `aws configure` or copy credentials from old account
- **Azure**: Run `az login` to re-authenticate
- **SSH Keys**: You may need to regenerate SSH keys and add them to services
- **1Password**: Re-authenticate with 1Password CLI

#### Manual Tasks
- **Applications**: Some applications may need to be re-downloaded from the App Store
- **Licenses**: Re-enter license keys for paid applications
- **Browser**: Sign back into your browser and sync bookmarks/passwords
- **Cloud Storage**: Re-authenticate with Dropbox, Google Drive, etc.

## Important Notes

### Security Considerations
- Private SSH keys were NOT backed up for security reasons
- You'll need to either:
  - Copy private keys manually (if safe to do so)
  - Generate new SSH key pairs
  - Use existing keys from a secure backup

### Path Updates
- Some configuration files may contain absolute paths with your old username
- Check and update these manually if needed:
  - Git configuration
  - Application-specific configs
  - Custom scripts

### What's NOT Included
- Private SSH keys
- Keychain items (passwords, certificates)
- Application data (unless in standard config locations)
- Browser data
- Desktop files and personal documents

## Troubleshooting

### If Homebrew Installation Fails
```bash
# Install Homebrew manually
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### If asdf Tools Don't Install
```bash
# Source asdf
source /opt/homebrew/opt/asdf/libexec/asdf.sh

# Install plugins manually
asdf plugin add nodejs
asdf plugin add python
asdf plugin add ruby
# ... etc for each tool

# Install versions
asdf install
```

### If Shell Theme Doesn't Load
```bash
# Reinstall PowerLevel10K
brew install powerlevel10k

# Configure
p10k configure
```

## Cleanup

After successful migration:
1. Test everything thoroughly in your new account
2. Keep the backup for a few weeks as a safety net
3. Securely delete the old user account when confident
4. Clean up the shared backup directory: `sudo rm -rf /Users/Shared/user_profile_backup_*`

## Archive Benefits
- **Compressed**: Significantly smaller than the original directory
- **Portable**: Single file easy to upload/download from iCloud Drive
- **Self-contained**: Includes all scripts and documentation
- **Automatic cleanup**: Original directory removed after compression
