#!/bin/bash

# User Profile Backup Script
# This script backs up important user configuration files and data

set -e

BACKUP_DIR="$HOME/user_profile_backup_$(date +%Y%m%d_%H%M%S)"
echo "Creating backup in: $BACKUP_DIR"
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

# Create directory structure
mkdir -p "$BACKUP_DIR/shell_config"
mkdir -p "$BACKUP_DIR/app_configs"
mkdir -p "$BACKUP_DIR/development"
mkdir -p "$BACKUP_DIR/homebrew"
mkdir -p "$BACKUP_DIR/ssh_keys"
mkdir -p "$BACKUP_DIR/vscode"

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
# Only backup public keys and config, not private keys for security
if [[ -d "$HOME/.ssh" ]]; then
    mkdir -p "$BACKUP_DIR/ssh_keys"
    safe_copy "$HOME/.ssh/config" "$BACKUP_DIR/ssh_keys/"
    safe_copy "$HOME/.ssh/known_hosts" "$BACKUP_DIR/ssh_keys/"
    # Copy public keys only
    find "$HOME/.ssh" -name "*.pub" -exec cp {} "$BACKUP_DIR/ssh_keys/" \;
    echo "Note: Private SSH keys NOT backed up for security reasons"
fi

echo "=== Backing up Homebrew Configuration ==="
# Always generate a fresh Brewfile from current installations
if command -v brew &> /dev/null; then
    echo "Generating fresh Brewfile from current installations..."
    brew bundle dump --file="$BACKUP_DIR/homebrew/Brewfile_current" --force
    echo "Fresh Brewfile created: $BACKUP_DIR/homebrew/Brewfile_current"
else
    echo "Warning: Homebrew not found, cannot generate Brewfile"
fi

# Also backup the existing .Brewfile if it exists (for reference)
if [[ -f "$HOME/.Brewfile" ]]; then
    echo "Backing up existing .Brewfile for reference..."
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
safe_copy "$HOME/.cache" "$BACKUP_DIR/app_configs/"

echo "=== Backing up Other Important Files ==="
safe_copy "$HOME/.nanorc" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.viminfo" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.wget-hsts" "$BACKUP_DIR/app_configs/"
safe_copy "$HOME/.z" "$BACKUP_DIR/app_configs/"

echo "=== Creating System Information ==="
cat > "$BACKUP_DIR/system_info.txt" << EOF
Backup created: $(date)
System: $(uname -a)
macOS Version: $(sw_vers)
Homebrew Version: $(brew --version 2>/dev/null || echo "Not installed")
Shell: $SHELL
User: $(whoami)
Home: $HOME
EOF

# List installed applications
echo "=== Listing Installed Applications ==="
ls /Applications > "$BACKUP_DIR/installed_applications.txt"
ls "$HOME/Applications" >> "$BACKUP_DIR/installed_applications.txt" 2>/dev/null || true

# Create a manifest of what was backed up
echo "=== Creating Backup Manifest ==="
find "$BACKUP_DIR" -type f > "$BACKUP_DIR/backup_manifest.txt"

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
cp "$0" "$BACKUP_DIR/user_profile_backup.sh"

# Find and copy the restore script
RESTORE_SCRIPT_PATH=""
if [[ -f "$(dirname "$0")/restore.sh" ]]; then
    RESTORE_SCRIPT_PATH="$(dirname "$0")/restore.sh"
elif [[ -f "$(dirname "$0")/user_profile_restore.sh" ]]; then
    RESTORE_SCRIPT_PATH="$(dirname "$0")/user_profile_restore.sh"
elif [[ -f "$HOME/user_profile_restore.sh" ]]; then
    RESTORE_SCRIPT_PATH="$HOME/user_profile_restore.sh"
elif [[ -f "./user_profile_restore.sh" ]]; then
    RESTORE_SCRIPT_PATH="./user_profile_restore.sh"
fi

if [[ -n "$RESTORE_SCRIPT_PATH" ]]; then
    echo "Found restore script: $RESTORE_SCRIPT_PATH"
    cp "$RESTORE_SCRIPT_PATH" "$BACKUP_DIR/user_profile_restore.sh"
    chmod +x "$BACKUP_DIR/user_profile_restore.sh"
    echo "Restore script copied and made executable"
else
    echo "Warning: Restore script not found. You'll need to copy it manually."
fi

# Copy migration guide if available
GUIDE_PATH=""
if [[ -f "$(dirname "$0")/../docs/migration-guide.md" ]]; then
    GUIDE_PATH="$(dirname "$0")/../docs/migration-guide.md"
elif [[ -f "$(dirname "$0")/user_profile_migration_guide.md" ]]; then
    GUIDE_PATH="$(dirname "$0")/user_profile_migration_guide.md"
elif [[ -f "$HOME/user_profile_migration_guide.md" ]]; then
    GUIDE_PATH="$HOME/user_profile_migration_guide.md"
elif [[ -f "./user_profile_migration_guide.md" ]]; then
    GUIDE_PATH="./user_profile_migration_guide.md"
fi

if [[ -n "$GUIDE_PATH" ]]; then
    echo "Found migration guide: $GUIDE_PATH"
    cp "$GUIDE_PATH" "$BACKUP_DIR/user_profile_migration_guide.md"
    echo "Migration guide copied"
else
    echo "Note: Migration guide not found"
fi

# Update the archive with the scripts
echo "Creating final compressed archive with all scripts included..."
tar -czf "$ARCHIVE_NAME" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"

echo ""
echo "=== Backup Complete ==="
echo "Backup archive: $ARCHIVE_NAME"
echo "Compressed size: $COMPRESSED_SIZE (was $ORIGINAL_SIZE)"
echo ""
echo "iCloud Drive Instructions:"
echo "1. Copy $ARCHIVE_NAME to your iCloud Drive"
echo "2. On your new user account, download from iCloud Drive"
echo "3. Extract: tar -xzf $(basename "$ARCHIVE_NAME")"
echo "4. Run: ./$(basename "$BACKUP_DIR")/user_profile_restore.sh ./$(basename "$BACKUP_DIR")"
echo ""
echo "Cleaning up uncompressed backup directory..."
rm -rf "$BACKUP_DIR"
echo "Cleanup complete. Only the compressed archive remains."
echo ""
