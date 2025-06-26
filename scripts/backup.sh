#!/bin/bash

# User Profile Backup Script
# This script backs up comprehensive system information for complete Mac rebuild

set -e

# Check for help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "User Profile Backup Script"
    echo "Creates comprehensive system backup for Mac rebuild"
    echo ""
    echo "Usage: $0 [--no-password] [--help]"
    echo ""
    echo "Options:"
    echo "  --no-password    Create unencrypted backup (NOT recommended)"
    echo "  --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Create password-protected backup (default)"
    echo "  $0 --no-password     # Create unencrypted backup"
    echo ""
    echo "Features:"
    echo "  • Comprehensive system information capture"
    echo "  • Application inventory and configurations"
    echo "  • System preferences and custom fonts"
    echo "  • Network and security settings"
    echo "  • Self-contained backup with restoration scripts"
    echo "  • Password protection by default for security"
    echo ""
    echo "Security Note:"
    echo "  Password protection is enabled by default to secure your personal"
    echo "  configuration data. Use --no-password only if you're certain the"
    echo "  backup will be stored securely."
    exit 0
fi

# Check for no-password flag
USE_PASSWORD=true
BACKUP_PASSWORD=""

if [[ "$1" == "--no-password" ]]; then
    USE_PASSWORD=false
    echo "⚠️  WARNING: Password protection disabled"
    echo "   Your backup will contain personal configuration data unencrypted"
    echo ""
    read -p "Are you sure you want to proceed without encryption? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Backup cancelled. Run without --no-password for encrypted backup."
        exit 0
    fi
    echo ""
else
    echo "🔒 Password protection enabled (default)"
    echo ""
fi

BACKUP_DIR="$HOME/user_profile_backup_$(date +%Y%m%d_%H%M%S)"
echo "Creating enhanced backup in: $BACKUP_DIR"

# Check prerequisites
echo "=== Checking Prerequisites ==="

# Check OpenSSL availability (required for encryption)
if ! command -v openssl &> /dev/null; then
    echo "❌ Error: OpenSSL not found"
    echo "OpenSSL is required for password protection but is not available."
    echo "Please install OpenSSL or use --no-password flag."
    exit 1
fi

# Check available disk space
echo "Checking available disk space..."
AVAILABLE_SPACE=$(df -k "$HOME" | tail -1 | awk '{print $4}')
AVAILABLE_GB=$((AVAILABLE_SPACE / 1024 / 1024))

if [[ $AVAILABLE_GB -lt 5 ]]; then
    echo "⚠️  Warning: Low disk space available (${AVAILABLE_GB}GB)"
    echo "Backup may require 1-3GB of space. Continue anyway?"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Backup cancelled due to insufficient disk space."
        exit 0
    fi
else
    echo "✅ Sufficient disk space available (${AVAILABLE_GB}GB)"
fi

# Collect backup password early if encryption is enabled
if [[ "$USE_PASSWORD" == true ]]; then
    echo ""
    echo "=== Setting Up Backup Encryption ==="
    echo "Your backup will contain personal configuration data and will be encrypted."
    echo "Please set a password for your backup archive."
    echo ""
    
    # Prompt for password
    while true; do
        echo "Enter password for backup encryption:"
        read -s BACKUP_PASSWORD
        echo "Confirm password:"
        read -s PASSWORD_CONFIRM
        
        if [[ -z "$BACKUP_PASSWORD" ]]; then
            echo "❌ Error: Password cannot be empty"
            echo ""
            continue
        fi
        
        if [[ "$BACKUP_PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
            echo "❌ Error: Passwords do not match"
            echo ""
            continue
        fi
        
        # Check password strength (enhanced validation)
        if [[ ${#BACKUP_PASSWORD} -lt 8 ]]; then
            echo "⚠️  Warning: Password is less than 8 characters"
            read -p "Continue with this password? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo ""
                continue
            fi
        elif [[ ${#BACKUP_PASSWORD} -lt 12 ]]; then
            echo "💡 Tip: Passwords 12+ characters are more secure"
        fi
        
        # Check for common weak passwords
        if [[ "$BACKUP_PASSWORD" =~ ^[0-9]+$ ]]; then
            echo "⚠️  Warning: Password contains only numbers"
            read -p "Continue with this password? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo ""
                continue
            fi
        fi
        
        break
    done
    
    # Clear confirmation password from memory
    unset PASSWORD_CONFIRM
    echo "✅ Backup password set successfully"
    echo ""
fi

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
    echo "Found mas CLI, capturing Mac App Store apps..."
    save_command_output "mas list" "$BACKUP_DIR/applications/mas_apps.txt" "Mac App Store apps"
else
    echo "mas (Mac App Store CLI) not found"
    
    # Try to install mas if Homebrew is available
    if command -v brew &> /dev/null; then
        echo "Installing mas via Homebrew..."
        if brew install mas; then
            echo "✅ mas installed successfully"
            echo "Capturing Mac App Store apps..."
            save_command_output "mas list" "$BACKUP_DIR/applications/mas_apps.txt" "Mac App Store apps"
        else
            echo "❌ Failed to install mas via Homebrew"
            echo "Mac App Store apps will not be captured in this backup"
            echo "You can manually install mas later with: brew install mas"
        fi
    else
        echo "Homebrew not available - cannot install mas automatically"
        echo "Mac App Store apps will not be captured in this backup"
        echo "To capture Mac App Store apps in future backups:"
        echo "  1. Install Homebrew: https://brew.sh"
        echo "  2. Install mas: brew install mas"
    fi
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

# Safari bookmarks - Skipped due to macOS System Integrity Protection
# Note: Safari bookmarks are protected by SIP and cannot be backed up programmatically
# Users should manually export bookmarks via Safari > File > Export Bookmarks
echo "Note: Safari bookmarks skipped (protected by System Integrity Protection)"
echo "      To backup Safari bookmarks manually: Safari > File > Export Bookmarks"

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
cp "$0" "$BACKUP_DIR/backup.sh"

# Find and copy the restore script
RESTORE_SCRIPT_PATH=""
if [[ -f "$(dirname "$0")/restore.sh" ]]; then
    RESTORE_SCRIPT_PATH="$(dirname "$0")/restore.sh"
fi

if [[ -n "$RESTORE_SCRIPT_PATH" ]]; then
    echo "Found restore script: $RESTORE_SCRIPT_PATH"
    cp "$RESTORE_SCRIPT_PATH" "$BACKUP_DIR/restore.sh"
    chmod +x "$BACKUP_DIR/restore.sh"
    echo "Restore script copied and made executable"
else
    echo "Warning: Restore script not found."
fi

# Update the archive with the scripts
echo "Creating final compressed archive with all scripts included..."
tar -czf "$ARCHIVE_NAME" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"

# Password protection (using pre-collected password)
if [[ "$USE_PASSWORD" == true ]]; then
    echo ""
    echo "=== Encrypting Backup Archive ==="
    echo "🔒 Encrypting your backup with the password you provided..."
    
    # Create encrypted version using the password collected earlier
    ENCRYPTED_ARCHIVE="${ARCHIVE_NAME%.tar.gz}.encrypted.tar.gz"
    echo "Creating encrypted archive: $(basename "$ENCRYPTED_ARCHIVE")"
    
    # Use AES-256-CBC encryption with stronger key derivation
    echo "🔐 Encrypting with AES-256-CBC (this may take a moment)..."
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$ARCHIVE_NAME" -out "$ENCRYPTED_ARCHIVE" -pass pass:"$BACKUP_PASSWORD"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Backup successfully encrypted with AES-256-CBC"
        
        # Verify the encrypted file was created and has reasonable size
        if [[ -f "$ENCRYPTED_ARCHIVE" ]]; then
            ENCRYPTED_SIZE=$(stat -f%z "$ENCRYPTED_ARCHIVE" 2>/dev/null || echo "0")
            ORIGINAL_SIZE_BYTES=$(stat -f%z "$ARCHIVE_NAME" 2>/dev/null || echo "0")
            
            # Encrypted file should be roughly the same size (within 10% variance)
            MIN_SIZE=$((ORIGINAL_SIZE_BYTES * 90 / 100))
            MAX_SIZE=$((ORIGINAL_SIZE_BYTES * 110 / 100))
            
            if [[ $ENCRYPTED_SIZE -lt $MIN_SIZE || $ENCRYPTED_SIZE -gt $MAX_SIZE ]]; then
                echo "⚠️  Warning: Encrypted file size seems unusual"
                echo "   Original: $(du -sh "$ARCHIVE_NAME" | cut -f1)"
                echo "   Encrypted: $(du -sh "$ENCRYPTED_ARCHIVE" | cut -f1)"
                echo "   This might indicate an encryption issue."
                read -p "Continue anyway? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    echo "Backup cancelled. Keeping unencrypted version."
                    exit 1
                fi
            fi
        else
            echo "❌ Error: Encrypted file was not created"
            echo "Keeping unencrypted backup: $ARCHIVE_NAME"
            exit 1
        fi
        
        # Remove unencrypted version for security
        rm "$ARCHIVE_NAME"
        ARCHIVE_NAME="$ENCRYPTED_ARCHIVE"
        
        # Update size information
        COMPRESSED_SIZE=$(du -sh "$ARCHIVE_NAME" | cut -f1)
        
        echo "🔒 Encrypted backup: $(basename "$ARCHIVE_NAME")"
        echo "🔒 Final size: $COMPRESSED_SIZE"
    else
        echo "❌ Error: Failed to encrypt backup"
        echo "OpenSSL returned error code: $?"
        echo "Unencrypted backup available: $ARCHIVE_NAME"
        echo ""
        echo "Possible causes:"
        echo "- Insufficient disk space"
        echo "- OpenSSL version compatibility issue"
        echo "- File permissions problem"
        exit 1
    fi
    
    # Clear password from memory
    unset BACKUP_PASSWORD
fi

echo ""
echo "=== Backup Complete ==="
echo "Backup archive: $(basename "$ARCHIVE_NAME")"
echo "Final size: $COMPRESSED_SIZE (was $ORIGINAL_SIZE)"

if [[ "$USE_PASSWORD" == true ]]; then
    echo "🔒 Backup is password-protected with AES-256-CBC encryption"
    echo ""
    echo "To restore this encrypted backup:"
    echo "1. Transfer $(basename "$ARCHIVE_NAME") to your new Mac"
    echo "2. Run: ./restore.sh $(basename "$ARCHIVE_NAME")"
    echo "3. Enter your password when prompted"
    echo ""
    echo "⚠️  Important: Keep your password safe! Without it, your backup cannot be restored."
else
    echo "⚠️  Backup is NOT encrypted"
    echo ""
    echo "Transfer Instructions:"
    echo "1. Copy $(basename "$ARCHIVE_NAME") to your backup location"
    echo "2. On your new Mac, extract: tar -xzf $(basename "$ARCHIVE_NAME")"
    echo "3. Run: ./$(basename "$BACKUP_DIR")/restore.sh ./$(basename "$BACKUP_DIR")"
fi
echo ""
echo "This backup includes:"
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
echo "3. Run: ./$(basename "$BACKUP_DIR")/restore.sh ./$(basename "$BACKUP_DIR")"
echo ""
echo "Cleaning up uncompressed backup directory..."
rm -rf "$BACKUP_DIR"
echo "Cleanup complete. Only the compressed archive remains."
echo ""
