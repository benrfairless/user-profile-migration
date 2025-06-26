# Mac User Profile Migration Scripts

Complete solution for backing up and restoring your Mac configuration for clean rebuilds or migrations.

## 🚀 Quick Start

```bash
# Test what would be backed up
./scripts/dry-run.sh

# Create password-protected backup (default)
./scripts/backup.sh

# Create unencrypted backup (not recommended)
./scripts/backup.sh --no-password

# Restore with granular control
./scripts/restore.sh backup.encrypted.tar.gz
```

## 📋 Overview

These enhanced scripts provide comprehensive Mac system backup and restoration with granular control over what gets restored. Perfect for:

- **Clean Mac rebuilds** - Capture everything, restore selectively
- **New Mac setup** - Transfer your exact configuration
- **System migrations** - Move between different Mac models
- **Development environment setup** - Restore just your dev tools

## 🆕 Enhanced Features

### 🔒 Security First
- **Password Protection by Default**: All backups encrypted with AES-256-CBC encryption
- **Strong Key Derivation**: PBKDF2 with 100,000 iterations for enhanced security
- **Automatic Encryption Detection**: Seamless handling of encrypted backup archives
- **Secure Password Handling**: Passwords cleared from memory after use
- **Opt-out Option**: Use `--no-password` flag for unencrypted backups (with warning)

### Comprehensive System Capture
- **System Information**: Hardware specs, macOS version, installed software
- **Application Inventory**: All apps including Mac App Store purchases
- **System Preferences**: Dock, Finder, trackpad, keyboard settings
- **Custom Fonts**: User-installed fonts from `~/Library/Fonts`
- **Network Configuration**: WiFi networks, hardware ports
- **Security Settings**: Firewall, Gatekeeper, System Integrity Protection
- **Browser Data**: Bookmarks, preferences, extensions list

### Granular Restoration Control
- **10 Main Categories** with selective restoration
- **Application-Specific Selection** - Choose individual app configs
- **Launch Agent Selection** - Pick specific startup services
- **Backup Validation** - Verify backup integrity before restore
- **Post-Restore Verification** - Guided next steps

## 📁 Scripts

| Script | Purpose |
|--------|---------|
| `backup.sh` | Creates comprehensive system backup |
| `restore.sh` | Restores with granular selection options |
| `dry-run.sh` | Shows what would be backed up (no changes) |

## 🔧 Detailed Usage

### Creating a Backup

```bash
# See what would be backed up (recommended first step)
./scripts/dry-run.sh

# Create full backup
./scripts/backup.sh
```

**Output**: Creates `user_profile_backup_YYYYMMDD_HHMMSS.tar.gz` containing:
- All configuration files and settings
- Complete system information
- Application inventory
- Restoration scripts

### Restoring from Backup

```bash
# Interactive restoration (recommended)
./scripts/restore.sh backup_archive.tar.gz

# Restore everything without prompts
./scripts/restore.sh backup_archive.tar.gz --all

# Validate backup without restoring
./scripts/restore.sh backup_archive.tar.gz --validate

# Get help
./scripts/restore.sh --help
```

## 📊 Restoration Categories

### 1. Shell Configuration
- Zsh/Bash profiles and configurations
- Oh My Zsh themes and plugins
- Shell aliases and functions
- Terminal integration scripts

### 2. Homebrew Packages
- All installed formulae and casks
- Homebrew services configuration
- Custom taps and repositories
- Service startup configurations

### 3. Development Tools
- Git configuration and global settings
- asdf version manager and tool versions
- Language-specific configurations
- IDE and editor settings

### 4. SSH Configuration
- SSH client configuration
- Known hosts
- Public keys (private keys never backed up)
- SSH agent settings

### 5. Application Configurations ⭐ *Enhanced*
**Now with individual app selection:**
- AWS CLI credentials and config
- Azure CLI settings
- Docker configuration
- VS Code settings and extensions
- iTerm2 preferences
- 1Password CLI settings
- GnuPG configuration
- NPM settings
- And more...

**Interactive Selection**: Choose exactly which application configurations to restore.

### 6. System Preferences
- Dock configuration and positioning
- Finder preferences and sidebar
- Trackpad and mouse settings
- Keyboard shortcuts and input
- Desktop and screensaver settings

### 7. Custom Fonts
- User-installed fonts from `~/Library/Fonts`
- Automatic font cache refresh
- Font availability verification

### 8. Browser Data
- Chrome bookmarks and preferences
- Safari bookmarks
- Browser extension lists
- Search engine preferences

### 9. Launch Agents ⭐ *Enhanced*
**Now with individual agent selection:**
- Custom startup services
- User-defined automation scripts
- Background task configurations
- Service management guidance

**Interactive Selection**: Choose specific launch agents to restore with guided loading instructions.

### 10. Network Settings
- WiFi network preferences
- Network hardware configuration
- VPN settings documentation
- Network service priorities

## 🔒 Security Features

- **Private keys never backed up** - SSH private keys excluded for security
- **Credential review required** - Manual re-authentication needed for services
- **System preferences validation** - Manual review required for security-sensitive settings
- **Launch agent inspection** - Individual review of startup services
- **Network password exclusion** - WiFi passwords not captured

## 💡 Best Practices

### Before Backup
1. **Clean up unnecessary files** - Remove caches and temporary data
2. **Update software** - Ensure latest versions are captured
3. **Document manual configurations** - Note any manual system tweaks
4. **Test dry run** - Verify what will be backed up

### During Restore
1. **Start with essentials** - Restore shell and development tools first
2. **Validate each step** - Check configurations work before proceeding
3. **Review security settings** - Manually verify system preferences
4. **Test applications** - Ensure restored configs work properly

### After Restore
1. **Re-authenticate services** - Sign back into AWS, GitHub, etc.
2. **Verify SSH keys** - Test SSH connections
3. **Check application licenses** - Re-activate software as needed
4. **Update system** - Install any pending macOS updates

## 🛠 Advanced Usage

### Backup Validation
```bash
# Validate backup contents without restoring
./scripts/enhanced-restore.sh backup.tar.gz --validate
```

### Selective Application Restore
When selecting "Application Configurations", you'll get a submenu to choose specific apps:
```
Available application configurations:
  [1] AWS CLI (.aws)
  [2] Docker (.docker)
  [3] VS Code (.vscode)
  [4] iTerm2 (.iterm2)
  ...
```

### Launch Agent Management
When selecting "Launch Agents", choose specific services:
```
Available launch agents:
  [1] com.example.myservice.plist
  [2] homebrew.mxcl.redis.plist
  ...
```

### System Information Review
```bash
# View captured system information
tar -xzf backup.tar.gz
cat user_profile_backup_*/system_info/backup_summary.txt
```

## 📋 Backup Contents

### System Information
- Hardware specifications and model
- macOS version and build number
- Installed applications inventory
- System profiler data
- Disk usage and storage info
- Environment variables

### Configuration Files
- Shell configurations (`.zshrc`, `.bashrc`, etc.)
- Development tools (`.gitconfig`, `.tool-versions`)
- Application settings directories
- SSH configuration (public keys only)
- Custom fonts and preferences

### Package Management
- Homebrew Brewfile with all packages
- Homebrew services configuration
- Custom taps and repositories
- Package version information

## 🔧 Troubleshooting

### Common Issues

**Backup too large**
- Review what's being backed up with dry run
- Exclude cache directories (already done automatically)
- Consider selective backup of large app configs

**Restore fails**
- Validate backup first: `--validate` flag
- Check disk space on target system
- Ensure proper permissions on target directories

**Applications don't work after restore**
- Re-authenticate with services
- Check application licenses
- Verify file permissions
- Restart applications

**Launch agents don't start**
- Review agent files before loading
- Use `launchctl load` manually
- Check system logs for errors

### Getting Help

```bash
# Detailed help for restore script
./scripts/enhanced-restore.sh --help

# View backup contents
tar -tzf backup_archive.tar.gz | head -20

# Check system compatibility
cat backup_directory/system_info/backup_summary.txt
```

## 🔄 Migration Workflow

### Complete Mac Rebuild
1. **Preparation**
   ```bash
   ./scripts/enhanced-dry-run.sh  # Review what will be backed up
   ./scripts/enhanced-backup.sh   # Create backup
   ```

2. **Fresh macOS Install**
   - Perform clean macOS installation
   - Complete initial setup
   - Install Xcode Command Line Tools

3. **Restoration**
   ```bash
   ./scripts/enhanced-restore.sh backup.tar.gz
   # Select categories interactively
   # Choose specific app configs and launch agents
   ```

4. **Post-Restore**
   - Re-authenticate services
   - Verify configurations
   - Install additional software as needed

### Selective Migration
For moving specific configurations to a new system:
1. Create backup on source system
2. Transfer backup archive
3. Use selective restore to choose only needed components
4. Manually configure remaining items

## 📝 Version History

### Current Version
- ✅ Granular application configuration selection
- ✅ Individual launch agent selection
- ✅ Comprehensive system information capture
- ✅ Backup validation and verification
- ✅ 10 restoration categories
- ✅ Enhanced security practices
- ✅ Password protection by default

## 🤝 Contributing

To enhance these scripts:
1. Test thoroughly on different macOS versions
2. Add support for additional applications
3. Improve error handling and validation
4. Enhance documentation with examples

## ⚠️ Important Notes

- **Test on non-production systems first**
- **Review all restored configurations**
- **Keep backups in multiple locations**
- **Update scripts for new macOS versions**
- **Never share backup archives** (contain personal data)

---

**Ready to rebuild your Mac with confidence!** 🚀

Start with `./scripts/dry-run.sh` to see what would be captured, then create your comprehensive backup with `./scripts/backup.sh`.
