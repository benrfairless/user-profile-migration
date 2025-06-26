#!/bin/bash

# Dry Run of User Profile Backup Script
# This shows what the backup script would capture without actually doing it

echo "=== DRY RUN MODE - No files will be copied ==="
echo ""

BACKUP_DIR="$HOME/user_profile_backup_$(date +%Y%m%d_%H%M%S)"
echo "Would create backup in: $BACKUP_DIR"

# Function to simulate copying files/directories
dry_run_copy() {
    local src="$1"
    local dest="$2"
    if [[ -e "$src" ]]; then
        echo "✓ Would backup: $src"
        if [[ -d "$src" ]]; then
            echo "  └─ Directory size: $(du -sh "$src" 2>/dev/null | cut -f1 || echo "unknown")"
        else
            echo "  └─ File size: $(ls -lh "$src" 2>/dev/null | awk '{print $5}' || echo "unknown")"
        fi
    else
        echo "✗ Would skip (not found): $src"
    fi
}

# Function to simulate command output capture
dry_run_command() {
    local command="$1"
    local description="$2"
    echo "✓ Would capture: $description"
    echo "  └─ Command: $command"
}

echo ""
echo "=== Shell Configuration Files ==="
dry_run_copy "$HOME/.zshrc" "shell_config/"
dry_run_copy "$HOME/.zprofile" "shell_config/"
dry_run_copy "$HOME/.bashrc" "shell_config/"
dry_run_copy "$HOME/.bash_profile" "shell_config/"
dry_run_copy "$HOME/.profile" "shell_config/"
dry_run_copy "$HOME/.p10k.zsh" "shell_config/"
dry_run_copy "$HOME/.oh-my-zsh" "shell_config/"
dry_run_copy "$HOME/.iterm2_shell_integration.zsh" "shell_config/"

echo ""
echo "=== Development Tools ==="
dry_run_copy "$HOME/.gitconfig" "development/"
dry_run_copy "$HOME/.gitignore_global" "development/"
dry_run_copy "$HOME/.gitignore" "development/"
dry_run_copy "$HOME/.gitattributes" "development/"
dry_run_copy "$HOME/.mailmap" "development/"
dry_run_copy "$HOME/.stCommitMsg" "development/"
dry_run_copy "$HOME/.tool-versions" "development/"
dry_run_copy "$HOME/.asdfrc" "development/"
dry_run_copy "$HOME/.asdf" "development/"

echo ""
echo "=== SSH Configuration ==="
dry_run_copy "$HOME/.ssh/config" "ssh_keys/"
dry_run_copy "$HOME/.ssh/known_hosts" "ssh_keys/"
if [[ -d "$HOME/.ssh" ]]; then
    echo "✓ Would backup SSH public keys:"
    find "$HOME/.ssh" -name "*.pub" -exec echo "  └─ {}" \; 2>/dev/null || echo "  └─ No public keys found"
fi

echo ""
echo "=== Homebrew Configuration ==="
if command -v brew &> /dev/null; then
    echo "✓ Would generate fresh Brewfile from current installations"
    echo "  └─ Current packages: $(brew list --formula | wc -l | tr -d ' ') formulae, $(brew list --cask | wc -l | tr -d ' ') casks"
    dry_run_command "brew --version" "Homebrew version"
    dry_run_command "brew list --formula" "Installed formulae list"
    dry_run_command "brew list --cask" "Installed casks list"
    dry_run_command "brew services list" "Homebrew services"
    dry_run_command "brew tap" "Homebrew taps"
else
    echo "✗ Homebrew not found"
fi

dry_run_copy "$HOME/.Brewfile" "homebrew/"

echo ""
echo "=== Application Configurations ==="
dry_run_copy "$HOME/.aws" "app_configs/"
dry_run_copy "$HOME/.azure" "app_configs/"
dry_run_copy "$HOME/.config" "app_configs/"
dry_run_copy "$HOME/.docker" "app_configs/"
dry_run_copy "$HOME/.orbstack" "app_configs/"
dry_run_copy "$HOME/.terraform.d" "app_configs/"
dry_run_copy "$HOME/.vagrant.d" "app_configs/"
dry_run_copy "$HOME/.vscode" "app_configs/"
dry_run_copy "$HOME/.iterm2" "app_configs/"
dry_run_copy "$HOME/.1password" "app_configs/"
dry_run_copy "$HOME/.gnupg" "app_configs/"
dry_run_copy "$HOME/.npm" "app_configs/"
dry_run_copy "$HOME/.local" "app_configs/"

echo ""
echo "=== System Information Capture ==="
dry_run_command "uname -a" "System kernel info"
dry_run_command "sw_vers" "macOS version"
dry_run_command "system_profiler SPHardwareDataType" "Hardware information"
dry_run_command "system_profiler SPSoftwareDataType" "Software information"
dry_run_command "system_profiler SPMemoryDataType" "Memory information"
dry_run_command "system_profiler SPStorageDataType" "Storage information"
dry_run_command "system_profiler SPDisplaysDataType" "Display information"
dry_run_command "system_profiler SPUSBDataType" "USB devices"
dry_run_command "diskutil list" "Disk information"
dry_run_command "df -h" "Disk usage"
dry_run_command "env | sort" "Environment variables"

echo ""
echo "=== Installed Applications ==="
dry_run_command "ls -la /Applications" "Applications folder listing"
dry_run_command "ls -la $HOME/Applications" "User Applications folder"
if command -v mas &> /dev/null; then
    dry_run_command "mas list" "Mac App Store apps"
else
    echo "✗ mas (Mac App Store CLI) not found"
    if command -v brew &> /dev/null; then
        echo "  → Will attempt to install mas via Homebrew during backup"
        echo "  → If successful, Mac App Store apps will be captured"
    else
        echo "  → Homebrew not available - Mac App Store apps will be skipped"
        echo "  → Install Homebrew and mas to capture Mac App Store apps"
    fi
fi
dry_run_command "system_profiler SPApplicationsDataType" "All installed applications"

echo ""
echo "=== System Preferences ==="
dry_run_command "defaults read com.apple.dock" "Dock preferences"
dry_run_command "defaults read com.apple.finder" "Finder preferences"
dry_run_command "defaults read com.apple.desktop" "Desktop preferences"
dry_run_command "defaults read -g" "Global preferences"
dry_run_command "defaults read com.apple.systemuiserver" "Menu bar preferences"
dry_run_command "defaults read com.apple.AppleMultitouchTrackpad" "Trackpad preferences"

echo ""
echo "=== Font Information ==="
dry_run_command "ls -la /Library/Fonts" "System fonts"
dry_run_command "ls -la $HOME/Library/Fonts" "User fonts"
dry_run_copy "$HOME/Library/Fonts" "fonts/user_fonts_backup"

echo ""
echo "=== Network Configuration ==="
dry_run_command "networksetup -listallhardwareports" "Network hardware ports"
dry_run_command "networksetup -listallnetworkservices" "Network services"
dry_run_command "ifconfig" "Network interfaces"
dry_run_command "networksetup -listpreferredwirelessnetworks en0" "Preferred WiFi networks"

echo ""
echo "=== Security Settings ==="
dry_run_command "sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate" "Firewall state"
dry_run_command "spctl --status" "Gatekeeper status"
dry_run_command "csrutil status" "System Integrity Protection"

echo ""
echo "=== Launch Agents and Daemons ==="
dry_run_command "ls -la $HOME/Library/LaunchAgents" "User launch agents"
dry_run_command "launchctl list" "Loaded services"
dry_run_copy "$HOME/Library/LaunchAgents" "launchd/user_launch_agents_backup"

echo ""
echo "=== Browser Data ==="
if [[ -d "$HOME/Library/Application Support/Google/Chrome" ]]; then
    echo "✓ Would backup Chrome data:"
    dry_run_copy "$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks" "browser_data/"
    dry_run_copy "$HOME/Library/Application Support/Google/Chrome/Default/Preferences" "browser_data/chrome_preferences.json"
    if [[ -d "$HOME/Library/Application Support/Google/Chrome/Default/Extensions" ]]; then
        dry_run_command "ls -la '$HOME/Library/Application Support/Google/Chrome/Default/Extensions'" "Chrome extensions"
    fi
else
    echo "✗ Chrome not found"
fi

if [[ -f "$HOME/Library/Safari/Bookmarks.plist" ]]; then
    dry_run_copy "$HOME/Library/Safari/Bookmarks.plist" "browser_data/"
else
    echo "✗ Safari bookmarks not found"
fi

echo ""
echo "=== Archive Creation ==="
ARCHIVE_NAME="${BACKUP_DIR}.tar.gz"
echo "✓ Would create compressed archive: $ARCHIVE_NAME"

echo ""
echo "=== Size Estimation ==="
TOTAL_SIZE=0

# Calculate sizes for major directories
for item in "$HOME/.oh-my-zsh" "$HOME/.asdf" "$HOME/.config" "$HOME/.docker" "$HOME/.orbstack" "$HOME/.vscode" "$HOME/.iterm2" "$HOME/.gnupg" "$HOME/Library/Fonts"; do
    if [[ -e "$item" ]]; then
        SIZE=$(du -sk "$item" 2>/dev/null | cut -f1 || echo "0")
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
    fi
done

# Add estimated size for system information (usually small)
TOTAL_SIZE=$((TOTAL_SIZE + 10240)) # Add ~10MB for system info

echo "Estimated total size: $((TOTAL_SIZE / 1024))MB (before compression)"
echo "Expected compressed size: ~$((TOTAL_SIZE / 1024 / 3))MB (estimated 3:1 compression ratio)"

echo ""
echo "=== Enhanced Backup Summary ==="
echo "The enhanced backup would include:"
echo ""
echo "📁 Original Features:"
echo "  ✓ Shell configurations and themes"
echo "  ✓ Development tool settings (Git, asdf, etc.)"
echo "  ✓ SSH configuration (public keys only)"
echo "  ✓ Fresh Homebrew package list"
echo "  ✓ Application configurations"
echo ""
echo "🆕 New Enhanced Features:"
echo "  ✓ Complete system information (hardware, software, versions)"
echo "  ✓ Detailed application inventory (including Mac App Store apps)"
echo "  ✓ System preferences (Dock, Finder, trackpad, etc.)"
echo "  ✓ Custom installed fonts"
echo "  ✓ Network configuration (WiFi networks, hardware ports)"
echo "  ✓ Security settings (firewall, gatekeeper, SIP)"
echo "  ✓ Launch agents and startup services"
echo "  ✓ Browser bookmarks and preferences"
echo "  ✓ Homebrew services and taps information"
echo "  ✓ Environment variables"
echo "  ✓ Disk and storage information"
echo ""
echo "🔧 Restore Enhancements:"
echo "  ✓ 10 granular restoration categories"
echo "  ✓ Individual application configuration selection"
echo "  ✓ Specific launch agent selection with loading guidance"
echo "  ✓ System preferences restoration guidance"
echo "  ✓ Application installation assistance"
echo "  ✓ Backup validation before restore"
echo "  ✓ Post-restore verification steps"
echo ""
echo "Ready to run the backup? This comprehensive backup will help you:"
echo "  • Rebuild your Mac exactly as it was"
echo "  • Selectively restore only what you need"
echo "  • Understand what software and settings you had"
echo "  • Maintain security best practices"
echo ""
echo "Run: ./backup.sh"
