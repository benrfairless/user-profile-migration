#!/bin/bash

# User Profile Restore Script
# This script restores user configuration files and data from backup
# Run this script from your NEW user account

set -e

# Check for help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "User Profile Restore Script"
    echo "Restores user configuration files and data from backup"
    echo ""
    echo "Usage: $0 [backup_directory_or_archive] [--all]"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Interactive mode (if run from archive directory)"
    echo "  $0 --all                             # Restore all (if run from archive directory)"
    echo "  $0 backup_20241225_120000            # Interactive mode with directory"
    echo "  $0 backup_20241225_120000.tar.gz     # Interactive mode with archive"
    echo "  $0 backup_20241225_120000 --all      # Restore all with directory"
    echo "  $0 backup_20241225_120000.tar.gz --all # Restore all with archive"
    echo ""
    echo "Options:"
    echo "  --all    Restore everything without interactive selection"
    echo "  --help   Show this help message"
    echo ""
    echo "Interactive Categories:"
    echo "  1. Shell Configuration (zsh, oh-my-zsh, themes)"
    echo "  2. Homebrew Packages (formulae, casks, extensions)"
    echo "  3. Development Tools (Git, asdf, language versions)"
    echo "  4. SSH Configuration (config, known hosts, public keys)"
    echo "  5. Application Configurations (AWS, Docker, VS Code, etc.)"
    exit 0
fi

# Detect if we're running from an expanded archive
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
RUNNING_FROM_ARCHIVE=false

# Check if we're in a backup directory structure
if [[ "$(basename "$SCRIPT_DIR")" =~ ^user_profile_backup_ ]]; then
    RUNNING_FROM_ARCHIVE=true
    echo "Detected: Running from expanded archive directory"
    echo "Archive location: $SCRIPT_DIR"
fi

# Check if backup directory or archive is provided
if [[ $# -eq 0 ]]; then
    if [[ "$RUNNING_FROM_ARCHIVE" == true ]]; then
        echo "Auto-detected backup directory: $SCRIPT_DIR"
        BACKUP_INPUT="$SCRIPT_DIR"
    else
        echo "Usage: $0 <backup_directory_path_or_archive> [--all]"
        echo "Examples:"
        echo "  $0 /Users/newuser/user_profile_backup_20241225_120000"
        echo "  $0 /Users/newuser/user_profile_backup_20241225_120000.tar.gz"
        echo "  $0 /Users/newuser/user_profile_backup_20241225_120000 --all"
        echo ""
        echo "Options:"
        echo "  --all    Restore everything without interactive selection"
        echo ""
        echo "Or run this script from within an expanded backup directory (no arguments needed)"
        exit 1
    fi
else
    BACKUP_INPUT="$1"
fi

# Check for --all flag
RESTORE_ALL_FLAG=false
if [[ "$2" == "--all" ]] || [[ "$1" == "--all" && "$RUNNING_FROM_ARCHIVE" == true ]]; then
    RESTORE_ALL_FLAG=true
fi

BACKUP_DIR=""
CLEANUP_EXTRACTED=false

# Check if input is an archive or directory
if [[ "$BACKUP_INPUT" == *.tar.gz ]]; then
    if [[ ! -f "$BACKUP_INPUT" ]]; then
        echo "Error: Archive file '$BACKUP_INPUT' not found"
        exit 1
    fi
    
    echo "Extracting archive: $BACKUP_INPUT"
    EXTRACT_DIR="$(dirname "$BACKUP_INPUT")"
    tar -xzf "$BACKUP_INPUT" -C "$EXTRACT_DIR"
    
    # Find the extracted directory
    BACKUP_DIR="$EXTRACT_DIR/$(basename "$BACKUP_INPUT" .tar.gz)"
    CLEANUP_EXTRACTED=true
    echo "Extracted to: $BACKUP_DIR"
elif [[ -d "$BACKUP_INPUT" ]]; then
    BACKUP_DIR="$BACKUP_INPUT"
else
    echo "Error: '$BACKUP_INPUT' is neither a valid directory nor a .tar.gz archive"
    exit 1
fi

if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Error: Backup directory '$BACKUP_DIR' not found after extraction"
    exit 1
fi

echo "Restoring from backup: $BACKUP_DIR"
echo "Target user: $(whoami)"
echo "Target home: $HOME"
echo ""

# Function to safely restore files/directories
safe_restore() {
    local src="$1"
    local dest="$2"
    local backup_existing="$3"
    
    if [[ -e "$src" ]]; then
        # Backup existing file if it exists and backup_existing is true
        if [[ "$backup_existing" == "true" && -e "$dest" ]]; then
            echo "Backing up existing: $dest -> ${dest}.backup-$(date +%Y%m%d-%H%M%S)"
            mv "$dest" "${dest}.backup-$(date +%Y%m%d-%H%M%S)"
        fi
        
        echo "Restoring: $src -> $dest"
        cp -R "$src" "$dest"
    else
        echo "Skipping (not in backup): $src"
    fi
}

# Interactive selection menu (skip if --all flag is used)
if [[ "$RESTORE_ALL_FLAG" == true ]]; then
    echo "=== Restoring All Components (--all flag specified) ==="
    RESTORE_SHELL=true
    RESTORE_HOMEBREW=true
    RESTORE_DEV_TOOLS=true
    RESTORE_SSH=true
    RESTORE_APPS=true
    RESTORE_ALL=true
else
    echo "=== Selective Restore Options ==="
    echo "Choose what you want to restore (you can select multiple options):"
    echo ""

    # Initialize selection variables
    RESTORE_SHELL=false
    RESTORE_HOMEBREW=false
    RESTORE_DEV_TOOLS=false
    RESTORE_SSH=false
    RESTORE_APPS=false
    RESTORE_ALL=false

    while true; do
        echo "Current selections:"
        echo "  [1] Shell Configuration (zsh, oh-my-zsh, themes) - $([ "$RESTORE_SHELL" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [2] Homebrew Packages - $([ "$RESTORE_HOMEBREW" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [3] Development Tools (Git, asdf, etc.) - $([ "$RESTORE_DEV_TOOLS" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [4] SSH Configuration - $([ "$RESTORE_SSH" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [5] Application Configurations (AWS, Docker, VS Code, etc.) - $([ "$RESTORE_APPS" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo ""
        echo "  [A] Select All"
        echo "  [C] Continue with current selections"
        echo "  [Q] Quit without restoring"
        echo ""
        read -p "Enter your choice (1-5, A, C, or Q): " choice
        
        case $choice in
            1|1*)
                RESTORE_SHELL=$([ "$RESTORE_SHELL" = true ] && echo false || echo true)
                ;;
            2|2*)
                RESTORE_HOMEBREW=$([ "$RESTORE_HOMEBREW" = true ] && echo false || echo true)
                ;;
            3|3*)
                RESTORE_DEV_TOOLS=$([ "$RESTORE_DEV_TOOLS" = true ] && echo false || echo true)
                ;;
            4|4*)
                RESTORE_SSH=$([ "$RESTORE_SSH" = true ] && echo false || echo true)
                ;;
            5|5*)
                RESTORE_APPS=$([ "$RESTORE_APPS" = true ] && echo false || echo true)
                ;;
            [Aa]|[Aa]*)
                RESTORE_SHELL=true
                RESTORE_HOMEBREW=true
                RESTORE_DEV_TOOLS=true
                RESTORE_SSH=true
                RESTORE_APPS=true
                RESTORE_ALL=true
                ;;
            [Cc]|[Cc]*)
                break
                ;;
            [Qq]|[Qq]*)
                echo "Restore cancelled."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
        echo ""
    done

    # Check if at least one option is selected
    if [[ "$RESTORE_SHELL" = false && "$RESTORE_HOMEBREW" = false && "$RESTORE_DEV_TOOLS" = false && "$RESTORE_SSH" = false && "$RESTORE_APPS" = false ]]; then
        echo "No options selected. Exiting."
        exit 0
    fi
fi

echo ""
echo "=== Selected for restoration ==="
[ "$RESTORE_SHELL" = true ] && echo "✓ Shell Configuration"
[ "$RESTORE_HOMEBREW" = true ] && echo "✓ Homebrew Packages"
[ "$RESTORE_DEV_TOOLS" = true ] && echo "✓ Development Tools"
[ "$RESTORE_SSH" = true ] && echo "✓ SSH Configuration"
[ "$RESTORE_APPS" = true ] && echo "✓ Application Configurations"
echo ""

# Final confirmation (skip if --all flag is used)
if [[ "$RESTORE_ALL_FLAG" != true ]]; then
    read -p "Proceed with restoration? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Restore cancelled."
        exit 0
    fi
fi

if [[ "$RESTORE_HOMEBREW" = true ]]; then
    echo "=== Installing Homebrew (if not present) ==="
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for this session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "Homebrew already installed"
    fi
else
    echo "=== Skipping Homebrew Installation ==="
fi

if [[ "$RESTORE_SHELL" = true ]]; then
    echo "=== Restoring Shell Configuration ==="
    safe_restore "$BACKUP_DIR/shell_config/.zshrc" "$HOME/.zshrc" true
    safe_restore "$BACKUP_DIR/shell_config/.zprofile" "$HOME/.zprofile" true
    safe_restore "$BACKUP_DIR/shell_config/.bashrc" "$HOME/.bashrc" true
    safe_restore "$BACKUP_DIR/shell_config/.bash_profile" "$HOME/.bash_profile" true
    safe_restore "$BACKUP_DIR/shell_config/.profile" "$HOME/.profile" true
    safe_restore "$BACKUP_DIR/shell_config/.p10k.zsh" "$HOME/.p10k.zsh" true
    safe_restore "$BACKUP_DIR/shell_config/.iterm2_shell_integration.zsh" "$HOME/.iterm2_shell_integration.zsh" true

    echo "=== Installing Oh My Zsh (if not present) ==="
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Restore Oh My Zsh configuration
    safe_restore "$BACKUP_DIR/shell_config/.oh-my-zsh" "$HOME/.oh-my-zsh" false
else
    echo "=== Skipping Shell Configuration ==="
fi

if [[ "$RESTORE_DEV_TOOLS" = true ]]; then
    echo "=== Restoring Development Tools Configuration ==="
    safe_restore "$BACKUP_DIR/development/.gitconfig" "$HOME/.gitconfig" true
    safe_restore "$BACKUP_DIR/development/.gitignore_global" "$HOME/.gitignore_global" true
    safe_restore "$BACKUP_DIR/development/.gitignore" "$HOME/.gitignore" true
    safe_restore "$BACKUP_DIR/development/.gitattributes" "$HOME/.gitattributes" true
    safe_restore "$BACKUP_DIR/development/.mailmap" "$HOME/.mailmap" true
    safe_restore "$BACKUP_DIR/development/.stCommitMsg" "$HOME/.stCommitMsg" true
    safe_restore "$BACKUP_DIR/development/.tool-versions" "$HOME/.tool-versions" true
    safe_restore "$BACKUP_DIR/development/.asdfrc" "$HOME/.asdfrc" true

    echo "=== Installing asdf (if not present) ==="
    if [[ ! -d "$HOME/.asdf" ]] && command -v brew &> /dev/null; then
        echo "Installing asdf via Homebrew..."
        brew install asdf
    fi

    # Restore asdf configuration
    safe_restore "$BACKUP_DIR/development/.asdf" "$HOME/.asdf" false
else
    echo "=== Skipping Development Tools ==="
fi

if [[ "$RESTORE_SSH" = true ]]; then
    echo "=== Restoring SSH Configuration ==="
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    safe_restore "$BACKUP_DIR/ssh_keys/config" "$HOME/.ssh/config" true
    safe_restore "$BACKUP_DIR/ssh_keys/known_hosts" "$HOME/.ssh/known_hosts" true

    # Restore public keys
    if [[ -d "$BACKUP_DIR/ssh_keys" ]]; then
        find "$BACKUP_DIR/ssh_keys" -name "*.pub" -exec cp {} "$HOME/.ssh/" \;
        chmod 644 "$HOME/.ssh"/*.pub 2>/dev/null || true
    fi
else
    echo "=== Skipping SSH Configuration ==="
fi

if [[ "$RESTORE_HOMEBREW" = true ]]; then
    echo "=== Installing Homebrew Packages ==="
    if [[ -f "$BACKUP_DIR/homebrew/Brewfile_current" ]]; then
        echo "Installing from current Brewfile (fresh snapshot)..."
        brew bundle install --file="$BACKUP_DIR/homebrew/Brewfile_current"
    elif [[ -f "$BACKUP_DIR/homebrew/Brewfile_original" ]]; then
        echo "Installing from original Brewfile..."
        brew bundle install --file="$BACKUP_DIR/homebrew/Brewfile_original"
    elif [[ -f "$BACKUP_DIR/homebrew/.Brewfile" ]]; then
        echo "Installing from legacy Brewfile..."
        brew bundle install --file="$BACKUP_DIR/homebrew/.Brewfile"
    else
        echo "No Brewfile found in backup"
        echo "You can manually install Homebrew packages later using: brew bundle install"
    fi
else
    echo "=== Skipping Homebrew Packages ==="
fi

if [[ "$RESTORE_APPS" = true ]]; then
    echo "=== Restoring Application Configurations ==="
    safe_restore "$BACKUP_DIR/app_configs/.aws" "$HOME/.aws" false
    safe_restore "$BACKUP_DIR/app_configs/.azure" "$HOME/.azure" false
    safe_restore "$BACKUP_DIR/app_configs/.config" "$HOME/.config" false
    safe_restore "$BACKUP_DIR/app_configs/.docker" "$HOME/.docker" false
    safe_restore "$BACKUP_DIR/app_configs/.orbstack" "$HOME/.orbstack" false
    safe_restore "$BACKUP_DIR/app_configs/.terraform.d" "$HOME/.terraform.d" false
    safe_restore "$BACKUP_DIR/app_configs/.vagrant.d" "$HOME/.vagrant.d" false
    safe_restore "$BACKUP_DIR/app_configs/.vscode" "$HOME/.vscode" false
    safe_restore "$BACKUP_DIR/app_configs/.iterm2" "$HOME/.iterm2" false
    safe_restore "$BACKUP_DIR/app_configs/.1password" "$HOME/.1password" false
    safe_restore "$BACKUP_DIR/app_configs/.gnupg" "$HOME/.gnupg" false
    safe_restore "$BACKUP_DIR/app_configs/.npm" "$HOME/.npm" false
    safe_restore "$BACKUP_DIR/app_configs/.local" "$HOME/.local" false
    safe_restore "$BACKUP_DIR/app_configs/.cache" "$HOME/.cache" false

    echo "=== Restoring Other Configuration Files ==="
    safe_restore "$BACKUP_DIR/app_configs/.nanorc" "$HOME/.nanorc" true
    safe_restore "$BACKUP_DIR/app_configs/.viminfo" "$HOME/.viminfo" true
    safe_restore "$BACKUP_DIR/app_configs/.wget-hsts" "$HOME/.wget-hsts" true
    safe_restore "$BACKUP_DIR/app_configs/.z" "$HOME/.z" true
else
    echo "=== Skipping Application Configurations ==="
fi

if [[ "$RESTORE_DEV_TOOLS" = true ]]; then
    echo "=== Setting up asdf tools ==="
    if command -v asdf &> /dev/null && [[ -f "$HOME/.tool-versions" ]]; then
        echo "Installing asdf plugins and tools..."
        
        # Source asdf
        if [[ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]]; then
            source /opt/homebrew/opt/asdf/libexec/asdf.sh
        elif [[ -f "$HOME/.asdf/asdf.sh" ]]; then
            source "$HOME/.asdf/asdf.sh"
        fi
        
        # Install plugins for each tool in .tool-versions
        while IFS= read -r line; do
            if [[ -n "$line" && ! "$line" =~ ^# ]]; then
                tool=$(echo "$line" | cut -d' ' -f1)
                echo "Adding asdf plugin: $tool"
                asdf plugin add "$tool" 2>/dev/null || echo "Plugin $tool already exists or failed to add"
            fi
        done < "$HOME/.tool-versions"
        
        echo "Installing asdf tools..."
        asdf install
    else
        echo "asdf not available or .tool-versions not found"
    fi
fi

echo "=== Setting Correct Permissions ==="
chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
chmod 600 "$HOME/.ssh/known_hosts" 2>/dev/null || true
chmod 700 "$HOME/.gnupg" 2>/dev/null || true
chmod 600 "$HOME/.gnupg"/* 2>/dev/null || true

echo ""
echo "=== Restore Complete ==="
echo ""
echo "Restored components:"
[ "$RESTORE_SHELL" = true ] && echo "✓ Shell Configuration"
[ "$RESTORE_HOMEBREW" = true ] && echo "✓ Homebrew Packages"
[ "$RESTORE_DEV_TOOLS" = true ] && echo "✓ Development Tools"
[ "$RESTORE_SSH" = true ] && echo "✓ SSH Configuration"
[ "$RESTORE_APPS" = true ] && echo "✓ Application Configurations"
echo ""
echo "Next steps:"
[ "$RESTORE_SHELL" = true ] && echo "1. Restart your terminal or run: source ~/.zshrc"
[ "$RESTORE_DEV_TOOLS" = true ] && echo "2. Verify Git configuration: git config --list"
[ "$RESTORE_SSH" = true ] && echo "3. Check SSH keys: ls -la ~/.ssh/"
[ "$RESTORE_DEV_TOOLS" = true ] && echo "4. Verify asdf tools: asdf list"
[ "$RESTORE_HOMEBREW" = true ] && echo "5. Test Homebrew: brew list"
echo ""
echo "Note: You may need to:"
echo "- Re-authenticate with services (GitHub, AWS, etc.)"
[ "$RESTORE_SSH" = true ] && echo "- Regenerate SSH keys if needed"
echo "- Update any absolute paths in configuration files"
echo "- Install any missing applications manually"
echo ""

# Cleanup extracted directory if we extracted an archive
# But don't cleanup if we're running from within the archive directory
if [[ "$CLEANUP_EXTRACTED" == true && "$RUNNING_FROM_ARCHIVE" == false ]]; then
    echo "Cleaning up extracted backup directory..."
    rm -rf "$BACKUP_DIR"
    echo "Cleanup complete. Archive file preserved."
elif [[ "$RUNNING_FROM_ARCHIVE" == true ]]; then
    echo "Note: Running from archive directory - no cleanup performed."
    echo "You can manually remove the expanded directory when done: rm -rf '$SCRIPT_DIR'"
fi
