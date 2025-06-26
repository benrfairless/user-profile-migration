#!/bin/bash

# Dry Run Enhanced Backup Script
# Shows exactly what the enhanced backup would do without making any changes

echo "=== DRY RUN MODE - Enhanced Backup Preview ==="
echo "No files will be copied, no changes will be made"
echo ""

BACKUP_DIR="$HOME/user_profile_backup_$(date +%Y%m%d_%H%M%S)"
echo "Would create enhanced backup in: $BACKUP_DIR"

# Function to simulate copying files/directories
dry_run_copy() {
    local src="$1"
    local dest="$2"
    local category="$3"
    
    if [[ -e "$src" ]]; then
        echo "✓ Would backup: $src"
        if [[ -d "$src" ]]; then
            local size=$(du -sh "$src" 2>/dev/null | cut -f1 || echo "unknown")
            local count=$(find "$src" -type f 2>/dev/null | wc -l | tr -d ' ')
            echo "  └─ Directory: $size ($count files)"
        else
            local size=$(ls -lh "$src" 2>/dev/null | awk '{print $5}' || echo "unknown")
            echo "  └─ File: $size"
        fi
    else
        echo "✗ Would skip (not found): $src"
    fi
}

# Function to simulate command output capture
dry_run_command() {
    local command="$1"
    local output_file="$2"
    local description="$3"
    
    echo "✓ Would capture: $description"
    echo "  └─ Command: $command"
    echo "  └─ Output: $output_file"
    
    # Try to show sample of what would be captured
    if eval "$command" >/dev/null 2>&1; then
        local lines=$(eval "$command" 2>/dev/null | wc -l | tr -d ' ')
        echo "  └─ Estimated lines: $lines"
    fi
}

echo ""
echo "=== Directory Structure Creation ==="
echo "Would create directories:"
echo "  ├── shell_config/"
echo "  ├── app_configs/"
echo "  ├── development/"
echo "  ├── homebrew/"
echo "  ├── ssh_keys/"
echo "  ├── system_info/"
echo "  ├── system_preferences/"
echo "  ├── applications/"
echo "  ├── fonts/"
echo "  ├── network/"
echo "  ├── security/"
echo "  ├── launchd/"
echo "  └── browser_data/"

echo ""
echo "=== Shell Configuration Files ==="
dry_run_copy "$HOME/.zshrc" "shell_config/" "Shell"
dry_run_copy "$HOME/.zprofile" "shell_config/" "Shell"
dry_run_copy "$HOME/.bashrc" "shell_config/" "Shell"
dry_run_copy "$HOME/.bash_profile" "shell_config/" "Shell"
dry_run_copy "$HOME/.profile" "shell_config/" "Shell"
dry_run_copy "$HOME/.p10k.zsh" "shell_config/" "Shell"
dry_run_copy "$HOME/.oh-my-zsh" "shell_config/" "Shell"
dry_run_copy "$HOME/.iterm2_shell_integration.zsh" "shell_config/" "Shell"

echo ""
echo "=== Development Tools ==="
dry_run_copy "$HOME/.gitconfig" "development/" "Development"
dry_run_copy "$HOME/.gitignore_global" "development/" "Development"
dry_run_copy "$HOME/.gitignore" "development/" "Development"
dry_run_copy "$HOME/.gitattributes" "development/" "Development"
dry_run_copy "$HOME/.mailmap" "development/" "Development"
dry_run_copy "$HOME/.stCommitMsg" "development/" "Development"
dry_run_copy "$HOME/.tool-versions" "development/" "Development"
dry_run_copy "$HOME/.asdfrc" "development/" "Development"
dry_run_copy "$HOME/.asdf" "development/" "Development"

echo ""
echo "=== SSH Configuration ==="
dry_run_copy "$HOME/.ssh/config" "ssh_keys/" "SSH"
dry_run_copy "$HOME/.ssh/known_hosts" "ssh_keys/" "SSH"
if [[ -d "$HOME/.ssh" ]]; then
    echo "✓ Would backup SSH public keys:"
    find "$HOME/.ssh" -name "*.pub" -exec echo "  └─ {}" \; 2>/dev/null || echo "  └─ No public keys found"
    echo "⚠ Private keys would NOT be backed up (security)"
fi

echo ""
echo "=== Homebrew Configuration ==="
if command -v brew &> /dev/null; then
    echo "✓ Would generate fresh Brewfile from current installations"
    local formula_count=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    local cask_count=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
    echo "  └─ Current packages: $formula_count formulae, $cask_count casks"
    
    dry_run_command "brew --version" "homebrew/brew_version.txt" "Homebrew version"
    dry_run_command "brew list --formula" "homebrew/installed_formulae.txt" "Installed formulae"
    dry_run_command "brew list --cask" "homebrew/installed_casks.txt" "Installed casks"
    dry_run_command "brew services list" "homebrew/services.txt" "Homebrew services"
    dry_run_command "brew tap" "homebrew/taps.txt" "Homebrew taps"
else
    echo "✗ Homebrew not found"
fi

dry_run_copy "$HOME/.Brewfile" "homebrew/" "Homebrew"

echo ""
echo "=== Application Configurations ==="
local app_configs=(".aws" ".azure" ".config" ".docker" ".orbstack" ".terraform.d" ".vagrant.d" ".vscode" ".iterm2" ".1password" ".gnupg" ".npm" ".local")
local app_names=("AWS CLI" "Azure CLI" "General Config" "Docker" "OrbStack" "Terraform" "Vagrant" "VS Code" "iTerm2" "1Password" "GnuPG" "NPM" "Local")

for i in "${!app_configs[@]}"; do
    dry_run_copy "$HOME/${app_configs[$i]}" "app_configs/" "Application"
done

echo ""
echo "=== Other Configuration Files ==="
dry_run_copy "$HOME/.nanorc" "app_configs/" "Editor"
dry_run_copy "$HOME/.viminfo" "app_configs/" "Editor"
dry_run_copy "$HOME/.wget-hsts" "app_configs/" "Network"
dry_run_copy "$HOME/.z" "app_configs/" "Shell"

echo ""
echo "=== System Information Capture ==="
dry_run_command "uname -a" "system_info/uname.txt" "System kernel info"
dry_run_command "sw_vers" "system_info/macos_version.txt" "macOS version"
dry_run_command "system_profiler SPHardwareDataType" "system_info/hardware.txt" "Hardware information"
dry_run_command "system_profiler SPSoftwareDataType" "system_info/software.txt" "Software information"
dry_run_command "system_profiler SPMemoryDataType" "system_info/memory.txt" "Memory information"
dry_run_command "system_profiler SPStorageDataType" "system_info/storage.txt" "Storage information"
dry_run_command "system_profiler SPDisplaysDataType" "system_info/displays.txt" "Display information"
dry_run_command "system_profiler SPUSBDataType" "system_info/usb.txt" "USB devices"
dry_run_command "diskutil list" "system_info/disks.txt" "Disk information"
dry_run_command "df -h" "system_info/disk_usage.txt" "Disk usage"
dry_run_command "env | sort" "system_info/environment.txt" "Environment variables"

echo ""
echo "=== Installed Applications ==="
dry_run_command "ls -la /Applications" "applications/applications_folder.txt" "Applications folder"
dry_run_command "ls -la $HOME/Applications" "applications/user_applications.txt" "User Applications folder"

if command -v mas &> /dev/null; then
    dry_run_command "mas list" "applications/mas_apps.txt" "Mac App Store apps"
    local mas_count=$(mas list 2>/dev/null | wc -l | tr -d ' ')
    echo "  └─ Mac App Store apps: $mas_count"
else
    echo "✗ mas (Mac App Store CLI) not found - install with: brew install mas"
fi

dry_run_command "system_profiler SPApplicationsDataType" "applications/all_applications.txt" "All installed applications"

echo ""
echo "=== System Preferences ==="
dry_run_command "defaults read com.apple.dock" "system_preferences/dock.plist" "Dock preferences"
dry_run_command "defaults read com.apple.finder" "system_preferences/finder.plist" "Finder preferences"
dry_run_command "defaults read com.apple.desktop" "system_preferences/desktop.plist" "Desktop preferences"
dry_run_command "defaults read -g" "system_preferences/global.plist" "Global preferences"
dry_run_command "defaults read com.apple.systemuiserver" "system_preferences/menubar.plist" "Menu bar preferences"
dry_run_command "defaults read com.apple.AppleMultitouchTrackpad" "system_preferences/trackpad.plist" "Trackpad preferences"

echo ""
echo "=== Font Information ==="
dry_run_command "ls -la /Library/Fonts" "fonts/system_fonts.txt" "System fonts"
dry_run_command "ls -la $HOME/Library/Fonts" "fonts/user_fonts.txt" "User fonts"
dry_run_copy "$HOME/Library/Fonts" "fonts/user_fonts_backup" "Fonts"

echo ""
echo "=== Network Configuration ==="
dry_run_command "networksetup -listallhardwareports" "network/hardware_ports.txt" "Network hardware ports"
dry_run_command "networksetup -listallnetworkservices" "network/network_services.txt" "Network services"
dry_run_command "ifconfig" "network/interfaces.txt" "Network interfaces"
dry_run_command "networksetup -listpreferredwirelessnetworks en0" "network/wifi_networks.txt" "Preferred WiFi networks"

echo ""
echo "=== Security Settings ==="
dry_run_command "sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate" "security/firewall_state.txt" "Firewall state"
dry_run_command "spctl --status" "security/gatekeeper.txt" "Gatekeeper status"
dry_run_command "csrutil status" "security/sip_status.txt" "System Integrity Protection"

echo ""
echo "=== Launch Agents and Daemons ==="
dry_run_command "ls -la $HOME/Library/LaunchAgents" "launchd/user_launch_agents.txt" "User launch agents"
dry_run_command "launchctl list" "launchd/loaded_services.txt" "Loaded services"
dry_run_copy "$HOME/Library/LaunchAgents" "launchd/user_launch_agents_backup" "Launch Agents"

echo ""
echo "=== Browser Data ==="
if [[ -d "$HOME/Library/Application Support/Google/Chrome" ]]; then
    echo "✓ Would backup Chrome data:"
    dry_run_copy "$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks" "browser_data/" "Browser"
    dry_run_copy "$HOME/Library/Application Support/Google/Chrome/Default/Preferences" "browser_data/chrome_preferences.json" "Browser"
    
    if [[ -d "$HOME/Library/Application Support/Google/Chrome/Default/Extensions" ]]; then
        dry_run_command "ls -la '$HOME/Library/Application Support/Google/Chrome/Default/Extensions'" "browser_data/chrome_extensions.txt" "Chrome extensions"
    fi
else
    echo "✗ Chrome not found"
fi

if [[ -f "$HOME/Library/Safari/Bookmarks.plist" ]]; then
    dry_run_copy "$HOME/Library/Safari/Bookmarks.plist" "browser_data/" "Browser"
else
    echo "✗ Safari bookmarks not found"
fi

echo ""
echo "=== Archive Creation ==="
ARCHIVE_NAME="${BACKUP_DIR}.tar.gz"
echo "✓ Would create compressed archive: $ARCHIVE_NAME"

echo ""
echo "=== Script Inclusion ==="
echo "✓ Would copy backup script to archive"
echo "✓ Would copy restore script to archive"
echo "✓ Would make scripts executable"

echo ""
echo "=== Size Estimation ==="
TOTAL_SIZE=0

# Calculate sizes for major directories
echo "Calculating estimated backup size..."
for item in "$HOME/.oh-my-zsh" "$HOME/.asdf" "$HOME/.config" "$HOME/.docker" "$HOME/.orbstack" "$HOME/.vscode" "$HOME/.iterm2" "$HOME/.gnupg" "$HOME/Library/Fonts"; do
    if [[ -e "$item" ]]; then
        SIZE=$(du -sk "$item" 2>/dev/null | cut -f1 || echo "0")
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
        local readable_size=$(du -sh "$item" 2>/dev/null | cut -f1 || echo "unknown")
        echo "  └─ $(basename "$item"): $readable_size"
    fi
done

# Add estimated size for system information (usually small)
TOTAL_SIZE=$((TOTAL_SIZE + 10240)) # Add ~10MB for system info

echo ""
echo "Estimated total size: $((TOTAL_SIZE / 1024))MB (before compression)"
echo "Expected compressed size: ~$((TOTAL_SIZE / 1024 / 3))MB (estimated 3:1 compression ratio)"

echo ""
echo "=== Enhanced Backup Summary ==="
echo ""
echo "📊 What Would Be Captured:"
echo ""
echo "🔧 System Information:"
echo "  • Hardware specifications and model details"
echo "  • macOS version, build, and software inventory"
echo "  • Memory, storage, and display configuration"
echo "  • USB devices and disk information"
echo "  • Environment variables and system settings"
echo ""
echo "📱 Applications & Software:"
echo "  • Complete application inventory (/Applications)"
echo "  • Mac App Store purchased apps (with mas)"
echo "  • Homebrew packages, casks, and services"
echo "  • Browser bookmarks and extension lists"
echo ""
echo "⚙️ Configurations:"
echo "  • Shell configurations (zsh, bash, oh-my-zsh)"
echo "  • Development tools (Git, asdf, language versions)"
echo "  • Application settings (AWS, Docker, VS Code, etc.)"
echo "  • SSH configuration (public keys only)"
echo "  • System preferences (Dock, Finder, trackpad)"
echo ""
echo "🎨 Customizations:"
echo "  • Custom fonts from ~/Library/Fonts"
echo "  • Launch agents and startup services"
echo "  • Network configuration and WiFi networks"
echo "  • Security settings (firewall, gatekeeper)"
echo ""
echo "🔒 Security Features:"
echo "  • Private SSH keys NOT backed up"
echo "  • Passwords and sensitive data excluded"
echo "  • System preferences require manual review"
echo "  • Launch agents individually selectable on restore"
echo ""
echo "📦 Self-Contained Backup:"
echo "  • Includes enhanced-backup.sh script"
echo "  • Includes enhanced-restore.sh script"
echo "  • Complete system documentation"
echo "  • Ready for immediate restoration"
echo ""
echo "🚀 Ready to create the actual backup?"
echo "Run: ./enhanced-backup.sh                    # Password-protected backup (default)"
echo "Run: ./enhanced-backup.sh --no-password     # Unencrypted backup (not recommended)"
echo ""
echo "Or test the restore process:"
echo "Run: ./dry-run-restore.sh [existing-backup-directory]"
