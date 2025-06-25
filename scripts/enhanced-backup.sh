#!/bin/bash

# Enhanced User Profile Backup Script
# This script backs up comprehensive system information for complete Mac rebuild

set -e

BACKUP_DIR="$HOME/user_profile_backup_$(date +%Y%m%d_%H%M%S)"
echo "Creating enhanced backup in: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Function to safely copy files/directories
safe_copy() {
    local src="$1"
    local dest="$2"
    if [[ -e "$src" ]]; then
        echo "Backing up: $src"
        cp -R "$src" "$dest"
    else
        echo "Skipping (not found): $src"
    fi
}

# Function to run command and save output
save_command_output() {
    local command="$1"
    local output_file="$2"
    local description="$3"
    
    echo "Capturing: $description"
    if eval "$command" > "$output_file" 2>&1; then
        echo "✓ Saved: $description"
    else
        echo "⚠ Warning: Failed to capture $description"
    fi
}

# Create enhanced directory structure
mkdir -p "$BACKUP_DIR/shell_config"
mkdir -p "$BACKUP_DIR/app_configs"
mkdir -p "$BACKUP_DIR/development"
mkdir -p "$BACKUP_DIR/homebrew"
mkdir -p "$BACKUP_DIR/ssh_keys"
mkdir -p "$BACKUP_DIR/system_info"
mkdir -p "$BACKUP_DIR/system_preferences"
mkdir -p "$BACKUP_DIR/applications"
mkdir -p "$BACKUP_DIR/fonts"
mkdir -p "$BACKUP_DIR/network"
mkdir -p "$BACKUP_DIR/security"
mkdir -p "$BACKUP_DIR/launchd"
mkdir -p "$BACKUP_DIR/browser_data"

echo "=== Backing up Shell Configuration ==="
safe_copy "$HOME/.zshrc" "$BACKUP_DIR/shell_config/"
safe_copy "$HOME/.zprofile" "$BACKUP_DIR/shell_config/"
safe_copy "$HOME/.bashrc" "$BACKUP_DIR/shell_config/"
safe_copy "$HOME/.bash_profile" "$BACKUP_DIR/shell_config/"
safe_copy "$HOME/.profile" "$BACKUP_DIR/shell_config/"
safe_copy "$HOME/.p10k.zsh" "$BACKUP_DIR/shell_config/"
safe_copy "$HOME/.oh-my-zsh" "$BACKUP_DIR/shell_config/"
safe_copy "$HOME/.iterm2_shell_integration.zsh" "$BACKUP_DIR/shell_config/"

echo "=== Backing up Development Tools ==="
safe_copy "$HOME/.gitconfig" "$BACKUP_DIR/development/"
safe_copy "$HOME/.gitignore_global" "$BACKUP_DIR/development/"
safe_copy "$HOME/.gitignore" "$BACKUP_DIR/development/"
safe_copy "$HOME/.gitattributes" "$BACKUP_DIR/development/"
safe_copy "$HOME/.mailmap" "$BACKUP_DIR/development/"
safe_copy "$HOME/.stCommitMsg" "$BACKUP_DIR/development/"
safe_copy "$HOME/.tool-versions" "$BACKUP_DIR/development/"
safe_copy "$HOME/.asdfrc" "$BACKUP_DIR/development/"
safe_copy "$HOME/.asdf" "$BACKUP_DIR/development/"

echo "=== Backing up SSH Configuration ==="
if [[ -d "$HOME/.ssh" ]]; then
    mkdir -p "$BACKUP_DIR/ssh_keys"
    safe_copy "$HOME/.ssh/config" "$BACKUP_DIR/ssh_keys/"
    safe_copy "$HOME/.ssh/known_hosts" "$BACKUP_DIR/ssh_keys/"
    # Copy public keys only
    find "$HOME/.ssh" -name "*.pub" -exec cp {} "$BACKUP_DIR/ssh_keys/" \;
    echo "Note: Private SSH keys NOT backed up for security reasons"
fi

echo "=== Backing up Homebrew Configuration ==="
if command -v brew &> /dev/null; then
    echo "Generating fresh Brewfile from current installations..."
    brew bundle dump --file="$BACKUP_DIR/homebrew/Brewfile_current" --force
    
    # Additional Homebrew information
    save_command_output "brew --version" "$BACKUP_DIR/homebrew/brew_version.txt" "Homebrew version"
    save_command_output "brew list --formula" "$BACKUP_DIR/homebrew/installed_formulae.txt" "Installed formulae"
    save_command_output "brew list --cask" "$BACKUP_DIR/homebrew/installed_casks.txt" "Installed casks"
    save_command_output "brew services list" "$BACKUP_DIR/homebrew/services.txt" "Homebrew services"
    save_command_output "brew tap" "$BACKUP_DIR/homebrew/taps.txt" "Homebrew taps"
else
    echo "Warning: Homebrew not found, cannot generate Brewfile"
fi

# Also backup the existing .Brewfile if it exists
if [[ -f "$HOME/.Brewfile" ]]; then
    safe_copy "$HOME/.Brewfile" "$BACKUP_DIR/homebrew/Brewfile_original"
fi

echo "=== Backing up Application Configurations ==="
safe_copy "$HOME/.aws" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.azure" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.config" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.docker" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.orbstack" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.terraform.d" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.vagrant.d" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.vscode" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.iterm2" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.1password" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.gnupg" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.npm" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.local" "$BACKUP_DIR/app_configs/"

# Skip .cache as it's usually large and not essential
echo "Skipping .cache directory (too large, not essential for restore)"

echo "=== Backing up Other Important Files ==="
safe_copy "$HOME/.nanorc" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.viminfo" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.wget-hsts" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.z" "$BACKUP_DIR/app_configs/"

echo "=== Capturing System Information ==="
save_command_output "uname -a" "$BACKUP_DIR/system_info/uname.txt" "System kernel info"
save_command_output "sw_vers" "$BACKUP_DIR/system_info/macos_version.txt" "macOS version"
save_command_output "system_profiler SPHardwareDataType" "$BACKUP_DIR/system_info/hardware.txt" "Hardware information"
save_command_output "system_profiler SPSoftwareDataType" "$BACKUP_DIR/system_info/software.txt" "Software information"
save_command_output "system_profiler SPMemoryDataType" "$BACKUP_DIR/system_info/memory.txt" "Memory information"
save_command_output "system_profiler SPStorageDataType" "$BACKUP_DIR/system_info/storage.txt" "Storage information"
save_command_output "system_profiler SPDisplaysDataType" "$BACKUP_DIR/system_info/displays.txt" "Display information"
save_command_output "system_profiler SPUSBDataType" "$BACKUP_DIR/system_info/usb.txt" "USB devices"
save_command_output "diskutil list" "$BACKUP_DIR/system_info/disks.txt" "Disk information"
save_command_output "df -h" "$BACKUP_DIR/system_info/disk_usage.txt" "Disk usage"

# Environment variables
save_command_output "env | sort" "$BACKUP_DIR/system_info/environment.txt" "Environment variables"

echo "=== Capturing Installed Applications ==="
save_command_output "ls -la /Applications" "$BACKUP_DIR/applications/applications_folder.txt" "Applications folder"
save_command_output "ls -la $HOME/Applications" "$BACKUP_DIR/applications/user_applications.txt" "User Applications folder"

# Mac App Store applications
if command -v mas &> /dev/null; then
    save_command_output "mas list" "$BACKUP_DIR/applications/mas_apps.txt" "Mac App Store apps"
else
    echo "mas (Mac App Store CLI) not found - install with: brew install mas"
fi

# System applications and utilities
save_command_output "system_profiler SPApplicationsDataType" "$BACKUP_DIR/applications/all_applications.txt" "All installed applications"

echo "=== Capturing System Preferences ==="
# Dock preferences
save_command_output "defaults read com.apple.dock" "$BACKUP_DIR/system_preferences/dock.plist" "Dock preferences"

# Finder preferences
save_command_output "defaults read com.apple.finder" "$BACKUP_DIR/system_preferences/finder.plist" "Finder preferences"

# Desktop preferences
save_command_output "defaults read com.apple.desktop" "$BACKUP_DIR/system_preferences/desktop.plist" "Desktop preferences"

# Keyboard preferences
save_command_output "defaults read -g" "$BACKUP_DIR/system_preferences/global.plist" "Global preferences"

# Menu bar preferences
save_command_output "defaults read com.apple.systemuiserver" "$BACKUP_DIR/system_preferences/menubar.plist" "Menu bar preferences"

# Trackpad preferences
save_command_output "defaults read com.apple.AppleMultitouchTrackpad" "$BACKUP_DIR/system_preferences/trackpad.plist" "Trackpad preferences"

# Mission Control preferences
save_command_output "defaults read com.apple.dock expose-animation-duration" "$BACKUP_DIR/system_preferences/mission_control.txt" "Mission Control settings"

# Hot corners
save_command_output "defaults read com.apple.dock wvous-tl-corner" "$BACKUP_DIR/system_preferences/hot_corners.txt" "Hot corners"

echo "=== Capturing Font Information ==="
save_command_output "ls -la /Library/Fonts" "$BACKUP_DIR/fonts/system_fonts.txt" "System fonts"
save_command_output "ls -la $HOME/Library/Fonts" "$BACKUP_DIR/fonts/user_fonts.txt" "User fonts"

# Copy user-installed fonts
if [[ -d "$HOME/Library/Fonts" ]]; then
    echo "Backing up user fonts..."
    safe_copy "$HOME/Library/Fonts" "$BACKUP_DIR/fonts/user_fonts_backup"
fi

echo "=== Capturing Network Configuration ==="
save_command_output "networksetup -listallhardwareports" "$BACKUP_DIR/network/hardware_ports.txt" "Network hardware ports"
save_command_output "networksetup -listallnetworkservices" "$BACKUP_DIR/network/network_services.txt" "Network services"
save_command_output "ifconfig" "$BACKUP_DIR/network/interfaces.txt" "Network interfaces"

# WiFi networks (without passwords for security)
save_command_output "networksetup -listpreferredwirelessnetworks en0" "$BACKUP_DIR/network/wifi_networks.txt" "Preferred WiFi networks"

echo "=== Capturing Security Settings ==="
save_command_output "sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate" "$BACKUP_DIR/security/firewall_state.txt" "Firewall state"
save_command_output "spctl --status" "$BACKUP_DIR/security/gatekeeper.txt" "Gatekeeper status"
save_command_output "csrutil status" "$BACKUP_DIR/security/sip_status.txt" "System Integrity Protection"

echo "=== Capturing Launch Agents and Daemons ==="
save_command_output "ls -la $HOME/Library/LaunchAgents" "$BACKUP_DIR/launchd/user_launch_agents.txt" "User launch agents"
save_command_output "launchctl list" "$BACKUP_DIR/launchd/loaded_services.txt" "Loaded services"

# Copy user launch agents
if [[ -d "$HOME/Library/LaunchAgents" ]]; then
    safe_copy "$HOME/Library/LaunchAgents" "$BACKUP_DIR/launchd/user_launch_agents_backup"
fi

echo "=== Capturing Browser Data ==="
# Chrome bookmarks and extensions (if exists)
if [[ -d "$HOME/Library/Application Support/Google/Chrome" ]]; then
    echo "Backing up Chrome data..."
    safe_copy "$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks" "$BACKUP_DIR/browser_data/"
    safe_copy "$HOME/Library/Application Support/Google/Chrome/Default/Preferences" "$BACKUP_DIR/browser_data/chrome_preferences.json"
    
    # List Chrome extensions
    if [[ -d "$HOME/Library/Application Support/Google/Chrome/Default/Extensions" ]]; then
        save_command_output "ls -la '$HOME/Library/Application Support/Google/Chrome/Default/Extensions'" "$BACKUP_DIR/browser_data/chrome_extensions.txt" "Chrome extensions"
    fi
fi

# Safari bookmarks
if [[ -f "$HOME/Library/Safari/Bookmarks.plist" ]]; then
    safe_copy "$HOME/Library/Safari/Bookmarks.plist" "$BACKUP_DIR/browser_data/"
fi

echo "=== Creating Enhanced System Information ==="
cat > "$BACKUP_DIR/system_info/backup_summary.txt" << EOF
Enhanced Backup Summary
======================
Backup created: $(date)
System: $(uname -a)
macOS Version: $(sw_vers -productVersion)
Build: $(sw_vers -buildVersion)
Homebrew Version: $(brew --version 2>/dev/null | head -1 || echo "Not installed")
Shell: $SHELL
User: $(whoami)
Home: $HOME
Hostname: $(hostname)
Hardware: $(system_profiler SPHardwareDataType | grep "Model Name" | cut -d: -f2 | xargs)
Memory: $(system_profiler SPHardwareDataType | grep "Memory" | cut -d: -f2 | xargs)
Processor: $(system_profiler SPHardwareDataType | grep "Processor Name" | cut -d: -f2 | xargs)

Backup Contents:
- Shell configurations and themes
- Development tools and settings
- SSH configuration (public keys only)
- Homebrew packages and services
- Application configurations
- System preferences and settings
- Installed applications list
- Custom fonts
- Network configuration
- Security settings
- Launch agents and daemons
- Browser bookmarks and preferences
EOF

# Create a detailed manifest
echo "=== Creating Detailed Backup Manifest ==="
find "$BACKUP_DIR" -type f -exec ls -lh {} \; > "$BACKUP_DIR/detailed_manifest.txt"

echo ""
echo "=== Creating Compressed Archive ==="
ARCHIVE_NAME="${BACKUP_DIR}.tar.gz"
echo "Compressing backup to: $ARCHIVE_NAME"
tar -czf "$ARCHIVE_NAME" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"

# Get sizes for comparison
ORIGINAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
COMPRESSED_SIZE=$(du -sh "$ARCHIVE_NAME" | cut -f1)

echo "Compression complete!"
echo "Original size: $ORIGINAL_SIZE"
echo "Compressed size: $COMPRESSED_SIZE"

# Copy scripts and documentation into the backup directory
echo "Copying scripts and documentation to backup location..."
cp "$0" "$BACKUP_DIR/enhanced_backup.sh"

# Find and copy the restore script
RESTORE_SCRIPT_PATH=""
if [[ -f "$(dirname "$0")/enhanced-restore.sh" ]]; then
    RESTORE_SCRIPT_PATH="$(dirname "$0")/enhanced-restore.sh"
elif [[ -f "$(dirname "$0")/restore.sh" ]]; then
    RESTORE_SCRIPT_PATH="$(dirname "$0")/restore.sh"
fi

if [[ -n "$RESTORE_SCRIPT_PATH" ]]; then
    echo "Found restore script: $RESTORE_SCRIPT_PATH"
    cp "$RESTORE_SCRIPT_PATH" "$BACKUP_DIR/enhanced_restore.sh"
    chmod +x "$BACKUP_DIR/enhanced_restore.sh"
    echo "Restore script copied and made executable"
else
    echo "Warning: Enhanced restore script not found."
fi

# Update the archive with the scripts
echo "Creating final compressed archive with all scripts included..."
tar -czf "$ARCHIVE_NAME" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"

echo ""
echo "=== Enhanced Backup Complete ==="
echo "Backup archive: $ARCHIVE_NAME"
echo "Compressed size: $COMPRESSED_SIZE (was $ORIGINAL_SIZE)"
echo ""
echo "This enhanced backup includes:"
echo "✓ All original configurations"
echo "✓ Complete system information"
echo "✓ Installed applications list"
echo "✓ System preferences"
echo "✓ Custom fonts"
echo "✓ Network settings"
echo "✓ Security configuration"
echo "✓ Browser data"
echo ""
echo "Transfer Instructions:"
echo "1. Copy $ARCHIVE_NAME to your backup location (iCloud, external drive, etc.)"
echo "2. On your new Mac, download and extract: tar -xzf $(basename "$ARCHIVE_NAME")"
echo "3. Run: ./$(basename "$BACKUP_DIR")/enhanced_restore.sh ./$(basename "$BACKUP_DIR")"
echo ""
echo "Cleaning up uncompressed backup directory..."
rm -rf "$BACKUP_DIR"
echo "Cleanup complete. Only the compressed archive remains."
echo ""
