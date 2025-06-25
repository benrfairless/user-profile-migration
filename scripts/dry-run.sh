#!/bin/bash

# Dry Run of User Profile Backup Script
# This shows what the backup script would do without actually doing it

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
dry_run_copy "$HOME/.cache" "app_configs/"

echo ""
echo "=== Other Important Files ==="
dry_run_copy "$HOME/.nanorc" "app_configs/"
dry_run_copy "$HOME/.viminfo" "app_configs/"
dry_run_copy "$HOME/.wget-hsts" "app_configs/"
dry_run_copy "$HOME/.z" "app_configs/"

echo ""
echo "=== Script Copying ==="
echo "✓ Would copy backup script to archive"

# Check for restore script
RESTORE_SCRIPT_PATH=""
if [[ -f "$(dirname "$0")/user_profile_restore.sh" ]]; then
    RESTORE_SCRIPT_PATH="$(dirname "$0")/user_profile_restore.sh"
elif [[ -f "$HOME/user_profile_restore.sh" ]]; then
    RESTORE_SCRIPT_PATH="$HOME/user_profile_restore.sh"
elif [[ -f "./user_profile_restore.sh" ]]; then
    RESTORE_SCRIPT_PATH="./user_profile_restore.sh"
fi

if [[ -n "$RESTORE_SCRIPT_PATH" ]]; then
    echo "✓ Would copy restore script: $RESTORE_SCRIPT_PATH"
else
    echo "⚠ Warning: Restore script not found"
fi

# Check for migration guide
GUIDE_PATH=""
if [[ -f "$(dirname "$0")/user_profile_migration_guide.md" ]]; then
    GUIDE_PATH="$(dirname "$0")/user_profile_migration_guide.md"
elif [[ -f "$HOME/user_profile_migration_guide.md" ]]; then
    GUIDE_PATH="$HOME/user_profile_migration_guide.md"
elif [[ -f "./user_profile_migration_guide.md" ]]; then
    GUIDE_PATH="./user_profile_migration_guide.md"
fi

if [[ -n "$GUIDE_PATH" ]]; then
    echo "✓ Would copy migration guide: $GUIDE_PATH"
else
    echo "⚠ Note: Migration guide not found"
fi

echo ""
echo "=== Archive Creation ==="
ARCHIVE_NAME="${BACKUP_DIR}.tar.gz"
echo "✓ Would create compressed archive: $ARCHIVE_NAME"

# Estimate total size
echo ""
echo "=== Size Estimation ==="
TOTAL_SIZE=0
for item in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.oh-my-zsh" "$HOME/.asdf" "$HOME/.config" "$HOME/.docker" "$HOME/.orbstack" "$HOME/.vscode" "$HOME/.iterm2" "$HOME/.gnupg" "$HOME/.cache"; do
    if [[ -e "$item" ]]; then
        SIZE=$(du -sk "$item" 2>/dev/null | cut -f1 || echo "0")
        TOTAL_SIZE=$((TOTAL_SIZE + SIZE))
    fi
done

echo "Estimated total size: $((TOTAL_SIZE / 1024))MB (before compression)"
echo "Expected compressed size: ~$((TOTAL_SIZE / 1024 / 3))MB (estimated 3:1 compression ratio)"

echo ""
echo "=== Summary ==="
echo "The backup would include:"
echo "- Shell configurations and themes"
echo "- Development tool settings (Git, asdf, etc.)"
echo "- SSH configuration (public keys only)"
echo "- Fresh Homebrew package list"
echo "- Application configurations"
echo "- All necessary scripts for restoration"
echo ""
echo "Ready to run the actual backup? (This was just a dry run)"
