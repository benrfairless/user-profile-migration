# Complete Mac Migration Guide

Step-by-step guide for using the enhanced migration scripts to rebuild your Mac from scratch.

## 🎯 Overview

This guide walks you through the complete process of backing up your current Mac and restoring it on a fresh system. Perfect for:
- Clean macOS reinstalls
- New Mac setup
- System troubleshooting
- Development environment replication

## 📋 Pre-Migration Checklist

### Before You Start
- [ ] **Backup critical data** separately (Documents, Photos, etc.)
- [ ] **Note manual configurations** you've made to system settings
- [ ] **Document installed software** not managed by Homebrew
- [ ] **Export browser bookmarks** as additional backup
- [ ] **Save license keys** for paid software
- [ ] **Test scripts** with dry run first

### System Requirements
- [ ] macOS 10.15+ (Catalina or later)
- [ ] Sufficient disk space (backup typically 1-5GB compressed)
- [ ] Admin privileges on both source and target systems
- [ ] Internet connection for software downloads during restore

## 🔄 Migration Process

### Phase 1: Preparation and Backup

#### Step 1: Download and Prepare Scripts
```bash
# Navigate to your scripts directory
cd /path/to/user-profile-migration/scripts

# Make scripts executable (if not already)
chmod +x enhanced-*.sh

# Verify scripts are ready
ls -la enhanced-*.sh
```

#### Step 2: Review What Will Be Backed Up
```bash
# Run dry run to see what would be captured
./enhanced-dry-run.sh
```

**Review the output carefully:**
- Check estimated backup size
- Verify important configurations are included
- Note any missing items you need to handle manually

#### Step 3: Create Comprehensive Backup
```bash
# Create the backup (this may take several minutes)
./enhanced-backup.sh
```

**What happens:**
- Creates timestamped backup directory
- Captures all system information and configurations
- Compresses into portable archive
- Includes restoration scripts

**Output:** `user_profile_backup_YYYYMMDD_HHMMSS.tar.gz`

#### Step 4: Secure Your Backup
```bash
# Copy to multiple locations
cp user_profile_backup_*.tar.gz ~/Desktop/
cp user_profile_backup_*.tar.gz /path/to/external/drive/
# Upload to cloud storage (iCloud, Dropbox, etc.)
```

### Phase 2: Fresh System Setup

#### Step 5: Clean macOS Installation
1. **Create macOS installer** (if needed)
2. **Backup any remaining data** not in your profile backup
3. **Perform clean install** or setup new Mac
4. **Complete initial macOS setup**
   - Create user account (can use same username)
   - Sign into Apple ID
   - Configure basic settings

#### Step 6: Install Prerequisites
```bash
# Install Xcode Command Line Tools (required for Homebrew)
xcode-select --install

# Verify installation
xcode-select -p
```

### Phase 3: Restoration

#### Step 7: Transfer and Extract Backup
```bash
# Download/copy your backup archive to the new system
# Extract the backup
tar -xzf user_profile_backup_YYYYMMDD_HHMMSS.tar.gz

# Navigate to extracted directory
cd user_profile_backup_YYYYMMDD_HHMMSS
```

#### Step 8: Validate Backup
```bash
# Verify backup integrity before restoring
./enhanced-restore.sh . --validate
```

#### Step 9: Interactive Restoration
```bash
# Start interactive restoration process
./enhanced-restore.sh .
```

**Follow the interactive prompts:**

1. **Select restoration categories** (recommended order):
   ```
   [1] Shell Configuration          ← Start here
   [2] Homebrew Packages           ← Essential tools
   [3] Development Tools           ← Git, asdf, etc.
   [4] SSH Configuration           ← Access keys
   [5] Application Configurations  ← Choose specific apps
   [6] System Preferences          ← Manual review needed
   [7] Custom Fonts               ← If you use custom fonts
   [8] Browser Data               ← Bookmarks, etc.
   [9] Launch Agents              ← Choose specific services
   [10] Network Settings          ← Manual configuration
   ```

2. **For Application Configurations**, select specific apps:
   ```
   Available application configurations:
   [1] AWS CLI (.aws)              ← If you use AWS
   [2] Docker (.docker)            ← If you use Docker
   [3] VS Code (.vscode)           ← Editor settings
   [4] iTerm2 (.iterm2)           ← Terminal preferences
   [5] GnuPG (.gnupg)             ← If you use GPG
   ... (choose what you need)
   ```

3. **For Launch Agents**, review each service:
   ```
   Available launch agents:
   [1] com.example.myservice.plist ← Custom service
   [2] homebrew.mxcl.redis.plist  ← Redis service
   ... (select carefully)
   ```

### Phase 4: Post-Restoration

#### Step 10: Verify Core Functionality
```bash
# Test shell configuration
source ~/.zshrc

# Verify Homebrew
brew --version
brew list

# Check development tools
git --version
asdf --version  # if you use asdf

# Test SSH
ssh-add -l
```

#### Step 11: Re-authenticate Services
- **GitHub**: `gh auth login` or setup SSH keys
- **AWS**: `aws configure` or restore credentials
- **Docker**: Sign into Docker Hub
- **Cloud services**: Re-authenticate as needed

#### Step 12: Manual Configuration Tasks

**System Preferences** (requires manual setup):
- Review and apply Dock settings
- Configure Finder preferences
- Set up trackpad and keyboard preferences
- Adjust display and energy settings

**Network Settings**:
- Connect to WiFi networks
- Configure VPN connections
- Set up network locations if needed

**Browser Setup**:
- Import bookmarks (files provided in backup)
- Reinstall extensions
- Sign into browser accounts

**Application Licenses**:
- Reactivate paid software
- Sign into subscription services
- Restore application-specific settings

#### Step 13: Install Additional Software
```bash
# Review applications that weren't installed via Homebrew
cat system_info/backup_summary.txt
cat applications/all_applications.txt

# Install Mac App Store apps (if mas is available)
# mas install [app-id]

# Install other applications manually
```

## 🔧 Advanced Scenarios

### Selective Migration
If you only want specific configurations:

```bash
# Run restore and select only what you need
./enhanced-restore.sh backup.tar.gz

# Example: Only development environment
# Select: [1] Shell, [2] Homebrew, [3] Development Tools
```

### Cross-User Migration
Moving configurations to a different username:

```bash
# Some paths may need manual adjustment
# Review and edit configuration files as needed
grep -r "/Users/oldusername" ~/.config/
```

### Multiple Mac Setup
Setting up identical configurations on multiple Macs:

```bash
# Use the same backup archive on each Mac
# Consider creating a "template" backup for team use
```

## 🚨 Troubleshooting

### Common Issues and Solutions

**Homebrew Installation Fails**
```bash
# Manually install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then run restore again
```

**SSH Keys Don't Work**
```bash
# Check key permissions
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
chmod 700 ~/.ssh

# Add keys to SSH agent
ssh-add ~/.ssh/id_rsa  # or your key name
```

**Applications Can't Find Configurations**
```bash
# Some apps may need restart after config restore
# Check file permissions
ls -la ~/.config/

# Verify app-specific config locations
```

**Launch Agents Don't Start**
```bash
# Load agents manually
launchctl load ~/Library/LaunchAgents/[agent-name].plist

# Check for errors
launchctl list | grep [agent-name]
```

**System Preferences Not Applied**
- System preferences require manual configuration for security
- Use backup files as reference: `system_preferences/`
- Apply settings through System Preferences app

### Getting Help

**Check Backup Contents**
```bash
# List all backed up files
tar -tzf backup.tar.gz | less

# View system information
cat system_info/backup_summary.txt
```

**Validate Specific Components**
```bash
# Check if specific configs exist
ls -la app_configs/
ls -la development/
```

## 📊 Migration Checklist

### Pre-Migration
- [ ] Scripts downloaded and tested
- [ ] Dry run completed and reviewed
- [ ] Backup created successfully
- [ ] Backup copied to safe locations
- [ ] Critical data backed up separately

### During Migration
- [ ] Fresh macOS installation completed
- [ ] Initial system setup finished
- [ ] Command Line Tools installed
- [ ] Backup transferred to new system
- [ ] Backup validation passed

### Post-Migration
- [ ] Core functionality verified (shell, git, etc.)
- [ ] Services re-authenticated
- [ ] System preferences configured
- [ ] Network settings applied
- [ ] Additional software installed
- [ ] Browser setup completed
- [ ] All applications tested

### Final Verification
- [ ] Development environment working
- [ ] All needed applications installed
- [ ] System preferences as desired
- [ ] Network connectivity confirmed
- [ ] Backup archive stored safely

## 💡 Pro Tips

### Before Migration
- **Document customizations**: Note any manual system tweaks
- **Clean up first**: Remove unnecessary files and applications
- **Update everything**: Ensure latest versions are captured
- **Test restore**: Try restoring to a VM or test system first

### During Migration
- **Start minimal**: Restore core components first, add more later
- **Verify each step**: Test functionality before proceeding
- **Take notes**: Document any issues or manual steps needed
- **Be patient**: Some installations take time

### After Migration
- **Keep backup**: Don't delete backup archive immediately
- **Monitor system**: Watch for issues in first few days
- **Update documentation**: Note any improvements for next time
- **Share learnings**: Help others with your experience

## 🔄 Regular Maintenance

### Periodic Backups
```bash
# Create regular backups (monthly/quarterly)
./enhanced-backup.sh

# Keep multiple backup versions
# Clean up old backups periodically
```

### Script Updates
- Check for script improvements periodically
- Test new features on non-production systems
- Contribute improvements back to the project

---

**You're now ready to confidently migrate your Mac setup!** 🚀

Remember: Start with the dry run, create your backup, and restore selectively based on your needs.
