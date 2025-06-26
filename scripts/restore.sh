#!/bin/bash

# User Profile Restore Script
# This script provides granular restoration options for complete Mac rebuild

set -e

# Check for help flag
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "User Profile Restore Script"
    echo "Provides granular restoration options for complete Mac rebuild"
    echo ""
    echo "Usage: $0 [backup_directory_or_archive] [--all] [--category]"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Interactive mode (if run from archive directory)"
    echo "  $0 --all                             # Restore all (if run from archive directory)"
    echo "  $0 backup_20241225_120000            # Interactive mode with directory"
    echo "  $0 backup_20241225_120000.tar.gz     # Interactive mode with archive"
    echo "  $0 backup.encrypted.tar.gz           # Interactive mode with encrypted archive"
    echo "  $0 backup_20241225_120000 --all      # Restore all with directory"
    echo ""
    echo "Granular Categories:"
    echo "  1. Shell Configuration (zsh, oh-my-zsh, themes, aliases)"
    echo "  2. Homebrew Packages (formulae, casks, services, taps)"
    echo "  3. Development Tools (Git, asdf, language versions, IDEs)"
    echo "  4. SSH Configuration (config, known hosts, public keys)"
    echo "  5. Application Configurations (AWS, Docker, VS Code, etc.) - Individual selection"
    echo "  6. System Preferences (Dock, Finder, keyboard, trackpad)"
    echo "  7. Fonts (user-installed custom fonts)"
    echo "  8. Browser Data (bookmarks, preferences)"
    echo "  9. Launch Agents (custom startup services) - Individual selection"
    echo "  10. Network Settings (WiFi networks, VPN configs)"
    echo ""
    echo "Features:"
    echo "  • Application Configurations: Choose specific apps (AWS, Docker, VS Code, etc.)"
    echo "  • Launch Agents: Select individual startup services with loading guidance"
    echo "  • Comprehensive Validation: Verify all backup components before restoration"
    echo "  • Post-Restore Guidance: Step-by-step next actions"
    echo "  • Password Protection: Support for encrypted backup archives"
    echo ""
    echo "Options:"
    echo "  --all         Restore everything without interactive selection"
    echo "  --help        Show this help message"
    echo "  --validate    Validate backup contents without restoring"
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
        echo "Run with --help for detailed usage information"
        exit 1
    fi
else
    BACKUP_INPUT="$1"
fi

# Check for flags
RESTORE_ALL_FLAG=false
VALIDATE_ONLY=false

for arg in "$@"; do
    case $arg in
        --all)
            RESTORE_ALL_FLAG=true
            ;;
        --validate)
            VALIDATE_ONLY=true
            ;;
    esac
done

BACKUP_DIR=""
CLEANUP_EXTRACTED=false

# Check if input is an archive or directory
if [[ "$BACKUP_INPUT" == *.tar.gz ]]; then
    if [[ ! -f "$BACKUP_INPUT" ]]; then
        echo "Error: Archive file '$BACKUP_INPUT' not found"
        exit 1
    fi
    
    # Check if it's an encrypted archive
    if [[ "$BACKUP_INPUT" == *.encrypted.tar.gz ]]; then
        echo "🔒 Encrypted backup detected"
        
        # Check OpenSSL availability
        if ! command -v openssl &> /dev/null; then
            echo "❌ Error: OpenSSL not found"
            echo "OpenSSL is required to decrypt this backup but is not available."
            echo "Please install OpenSSL to restore encrypted backups."
            exit 1
        fi
        
        echo "Decrypting archive: $BACKUP_INPUT"
        
        # Prompt for password with retry logic
        MAX_ATTEMPTS=3
        ATTEMPT=1
        
        while [[ $ATTEMPT -le $MAX_ATTEMPTS ]]; do
            echo "Enter password for backup decryption (attempt $ATTEMPT of $MAX_ATTEMPTS):"
            read -s DECRYPT_PASSWORD
            
            if [[ -z "$DECRYPT_PASSWORD" ]]; then
                echo "❌ Error: Password cannot be empty"
                ((ATTEMPT++))
                continue
            fi
            
            # Create temporary decrypted file
            TEMP_ARCHIVE="${BACKUP_INPUT%.encrypted.tar.gz}.temp.tar.gz"
            
            echo "🔐 Decrypting backup (this may take a moment)..."
            openssl enc -aes-256-cbc -d -salt -pbkdf2 -iter 100000 -in "$BACKUP_INPUT" -out "$TEMP_ARCHIVE" -pass pass:"$DECRYPT_PASSWORD" 2>/dev/null
            
            if [[ $? -eq 0 && -f "$TEMP_ARCHIVE" ]]; then
                # Verify the decrypted file is a valid tar.gz
                if tar -tzf "$TEMP_ARCHIVE" >/dev/null 2>&1; then
                    echo "✅ Backup successfully decrypted"
                    break
                else
                    echo "❌ Error: Decrypted file is not a valid archive"
                    rm -f "$TEMP_ARCHIVE"
                    ((ATTEMPT++))
                fi
            else
                echo "❌ Error: Failed to decrypt backup. Check your password."
                rm -f "$TEMP_ARCHIVE"
                ((ATTEMPT++))
            fi
            
            if [[ $ATTEMPT -le $MAX_ATTEMPTS ]]; then
                echo ""
            fi
        done
        
        if [[ $ATTEMPT -gt $MAX_ATTEMPTS ]]; then
            echo ""
            echo "❌ Failed to decrypt backup after $MAX_ATTEMPTS attempts."
            echo "Please verify:"
            echo "- You're using the correct password"
            echo "- The backup file is not corrupted"
            echo "- You have sufficient disk space"
            exit 1
        fi
        
        # Clear password from memory
        unset DECRYPT_PASSWORD
        
        # Use the decrypted archive
        BACKUP_INPUT="$TEMP_ARCHIVE"
        CLEANUP_DECRYPTED=true
    fi
    
    echo "Extracting archive: $BACKUP_INPUT"
    EXTRACT_DIR="$(dirname "$BACKUP_INPUT")"
    tar -xzf "$BACKUP_INPUT" -C "$EXTRACT_DIR"
    
    # Find the extracted directory
    BACKUP_DIR="$EXTRACT_DIR/$(basename "$BACKUP_INPUT" .tar.gz)"
    CLEANUP_EXTRACTED=true
    echo "Extracted to: $BACKUP_DIR"
    
    # Clean up temporary decrypted file if it exists
    if [[ "${CLEANUP_DECRYPTED:-false}" == true ]]; then
        rm -f "$TEMP_ARCHIVE"
    fi
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

# Enhanced validation function
validate_backup() {
    echo "=== Validating Backup Contents ==="
    
    local validation_passed=true
    local warnings=0
    
    # Check for all expected directories from enhanced backup
    local all_dirs=("shell_config" "development" "homebrew" "system_info" "app_configs" "ssh_keys" "system_preferences" "applications" "fonts" "network" "security" "launchd" "browser_data")
    local essential_dirs=("shell_config" "development" "homebrew" "system_info")
    
    echo "Checking backup directory structure..."
    for dir in "${all_dirs[@]}"; do
        if [[ -d "$BACKUP_DIR/$dir" ]]; then
            echo "✓ Found: $dir"
        else
            if [[ " ${essential_dirs[@]} " =~ " ${dir} " ]]; then
                echo "❌ Missing essential: $dir"
                validation_passed=false
            else
                echo "⚠ Missing optional: $dir"
                ((warnings++))
            fi
        fi
    done
    
    echo ""
    echo "Checking key backup files..."
    
    # Check for system info
    if [[ -f "$BACKUP_DIR/system_info/backup_summary.txt" ]]; then
        echo "✓ Found: System information"
        echo "  Backup details:"
        head -5 "$BACKUP_DIR/system_info/backup_summary.txt" | sed 's/^/    /'
    else
        echo "❌ Missing: System information"
        validation_passed=false
    fi
    
    # Check for Homebrew data
    if [[ -f "$BACKUP_DIR/homebrew/Brewfile_current" ]]; then
        local formula_count=$(grep -c "^brew " "$BACKUP_DIR/homebrew/Brewfile_current" 2>/dev/null || echo "0")
        local cask_count=$(grep -c "^cask " "$BACKUP_DIR/homebrew/Brewfile_current" 2>/dev/null || echo "0")
        echo "✓ Found: Homebrew data ($formula_count formulae, $cask_count casks)"
    else
        echo "⚠ Missing: Homebrew data"
        ((warnings++))
    fi
    
    # Check for applications list
    if [[ -f "$BACKUP_DIR/applications/all_applications.txt" ]]; then
        local app_count=$(wc -l < "$BACKUP_DIR/applications/all_applications.txt" 2>/dev/null || echo "0")
        echo "✓ Found: Applications list ($app_count entries)"
    else
        echo "⚠ Missing: Applications list"
        ((warnings++))
    fi
    
    # Check for detailed manifest (new feature)
    if [[ -f "$BACKUP_DIR/detailed_manifest.txt" ]]; then
        local file_count=$(grep -c "^-" "$BACKUP_DIR/detailed_manifest.txt" 2>/dev/null || echo "0")
        echo "✓ Found: Detailed manifest ($file_count files cataloged)"
    else
        echo "⚠ Missing: Detailed manifest (older backup format)"
        ((warnings++))
    fi
    
    # Check for app configs
    if [[ -d "$BACKUP_DIR/app_configs" ]]; then
        local config_count=$(find "$BACKUP_DIR/app_configs" -maxdepth 1 -type d -o -type f | wc -l | tr -d ' ')
        echo "✓ Found: Application configurations ($((config_count - 1)) items)"
    else
        echo "⚠ Missing: Application configurations"
        ((warnings++))
    fi
    
    # Check for fonts
    if [[ -d "$BACKUP_DIR/fonts/user_fonts_backup" ]]; then
        local font_count=$(find "$BACKUP_DIR/fonts/user_fonts_backup" -type f 2>/dev/null | wc -l | tr -d ' ')
        echo "✓ Found: Custom fonts ($font_count files)"
    else
        echo "⚠ Missing: Custom fonts backup"
        ((warnings++))
    fi
    
    # Check for launch agents
    if [[ -d "$BACKUP_DIR/launchd/user_launch_agents_backup" ]]; then
        local agent_count=$(find "$BACKUP_DIR/launchd/user_launch_agents_backup" -name "*.plist" 2>/dev/null | wc -l | tr -d ' ')
        echo "✓ Found: Launch agents ($agent_count agents)"
    else
        echo "⚠ Missing: Launch agents backup"
        ((warnings++))
    fi
    
    echo ""
    echo "Validation Summary:"
    if [[ "$validation_passed" == true ]]; then
        if [[ $warnings -eq 0 ]]; then
            echo "✅ Backup validation passed - Complete backup detected"
        else
            echo "✅ Backup validation passed with $warnings warnings - Functional backup"
            echo "   Some optional components are missing but core functionality is intact"
        fi
        return 0
    else
        echo "❌ Backup validation failed - Essential components are missing"
        echo "   This backup may not restore properly"
        return 1
    fi
}

# Run validation
validate_backup

if [[ "$VALIDATE_ONLY" == true ]]; then
    echo "Validation complete. Exiting (--validate flag specified)."
    exit 0
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

# Function to restore system preferences
restore_system_preferences() {
    echo "=== Restoring System Preferences ==="
    
    if [[ -f "$BACKUP_DIR/system_preferences/dock.plist" ]]; then
        echo "Restoring Dock preferences..."
        # Note: This is a simplified approach - in practice, you'd want to selectively restore specific keys
        echo "⚠ Manual step required: Review and manually apply Dock settings from backup"
        echo "  Backup file: $BACKUP_DIR/system_preferences/dock.plist"
    fi
    
    if [[ -f "$BACKUP_DIR/system_preferences/finder.plist" ]]; then
        echo "⚠ Manual step required: Review and manually apply Finder settings from backup"
        echo "  Backup file: $BACKUP_DIR/system_preferences/finder.plist"
    fi
    
    echo "Note: System preferences restoration requires manual review for security reasons"
}

# Function to install applications
install_applications() {
    echo "=== Installing Applications ==="
    
    # Install Mac App Store apps if mas is available
    if command -v mas &> /dev/null && [[ -f "$BACKUP_DIR/applications/mas_apps.txt" ]]; then
        echo "Installing Mac App Store applications..."
        while IFS= read -r line; do
            if [[ -n "$line" && ! "$line" =~ ^# ]]; then
                app_id=$(echo "$line" | awk '{print $1}')
                app_name=$(echo "$line" | cut -d' ' -f2-)
                echo "Installing: $app_name (ID: $app_id)"
                mas install "$app_id" || echo "Failed to install $app_name"
            fi
        done < "$BACKUP_DIR/applications/mas_apps.txt"
    else
        echo "⚠ mas not available or no Mac App Store apps to install"
        echo "  Install mas with: brew install mas"
        echo "  Then manually install apps listed in: $BACKUP_DIR/applications/mas_apps.txt"
    fi
    
    echo "⚠ Manual step required: Install non-Homebrew applications"
    echo "  Review applications list: $BACKUP_DIR/applications/all_applications.txt"
}

# Function to select specific application configurations
select_app_configs() {
    echo "=== Select Application Configurations to Restore ==="
    echo "Available application configurations:"
    
    local app_configs=()
    local app_selections=()
    
    # Check which app configs exist in backup
    local available_apps=(".aws" ".azure" ".config" ".docker" ".orbstack" ".terraform.d" ".vagrant.d" ".vscode" ".iterm2" ".1password" ".gnupg" ".npm" ".local")
    local app_names=("AWS CLI" "Azure CLI" "General Config" "Docker" "OrbStack" "Terraform" "Vagrant" "VS Code" "iTerm2" "1Password" "GnuPG" "NPM" "Local")
    
    for i in "${!available_apps[@]}"; do
        if [[ -d "$BACKUP_DIR/app_configs/${available_apps[$i]}" ]]; then
            app_configs+=("${available_apps[$i]}")
            app_selections+=(false)
            echo "  [$(( ${#app_configs[@]} ))] ${app_names[$i]} (${available_apps[$i]})"
        fi
    done
    
    # Also check for individual config files
    local config_files=(".nanorc" ".viminfo" ".wget-hsts" ".z")
    local config_names=("Nano Editor" "Vim History" "Wget HSTS" "Z Directory Jumper")
    
    for i in "${!config_files[@]}"; do
        if [[ -f "$BACKUP_DIR/app_configs/${config_files[$i]}" ]]; then
            app_configs+=("${config_files[$i]}")
            app_selections+=(false)
            echo "  [$(( ${#app_configs[@]} ))] ${config_names[$i]} (${config_files[$i]})"
        fi
    done
    
    if [[ ${#app_configs[@]} -eq 0 ]]; then
        echo "No application configurations found in backup."
        return
    fi
    
    echo ""
    echo "  [A] Select All"
    echo "  [N] Select None"
    echo "  [C] Continue with current selections"
    echo ""
    
    while true; do
        echo "Current selections:"
        for i in "${!app_configs[@]}"; do
            local status=$([ "${app_selections[$i]}" = true ] && echo "✓ Selected" || echo "○ Not selected")
            echo "  [$(( i + 1 ))] ${app_configs[$i]} - $status"
        done
        echo ""
        
        read -p "Enter your choice (1-${#app_configs[@]}, A, N, or C): " choice
        
        case $choice in
            [Aa]*) 
                for i in "${!app_selections[@]}"; do
                    app_selections[$i]=true
                done
                ;;
            [Nn]*) 
                for i in "${!app_selections[@]}"; do
                    app_selections[$i]=false
                done
                ;;
            [Cc]*) break ;;
            [0-9]*)
                if [[ $choice -ge 1 && $choice -le ${#app_configs[@]} ]]; then
                    local idx=$(( choice - 1 ))
                    app_selections[$idx]=$([ "${app_selections[$idx]}" = true ] && echo false || echo true)
                else
                    echo "Invalid choice. Please try again."
                fi
                ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
    
    # Store selected app configs globally
    SELECTED_APP_CONFIGS=()
    for i in "${!app_configs[@]}"; do
        if [[ "${app_selections[$i]}" = true ]]; then
            SELECTED_APP_CONFIGS+=("${app_configs[$i]}")
        fi
    done
}

# Function to select specific launch agents
select_launch_agents() {
    echo "=== Select Launch Agents to Restore ==="
    
    if [[ ! -d "$BACKUP_DIR/launchd/user_launch_agents_backup" ]]; then
        echo "No launch agents found in backup."
        return
    fi
    
    echo "Available launch agents:"
    
    local launch_agents=()
    local agent_selections=()
    
    # Find all .plist files in the launch agents backup
    while IFS= read -r -d '' file; do
        local basename=$(basename "$file")
        launch_agents+=("$basename")
        agent_selections+=(false)
        echo "  [${#launch_agents[@]}] $basename"
    done < <(find "$BACKUP_DIR/launchd/user_launch_agents_backup" -name "*.plist" -print0 2>/dev/null)
    
    if [[ ${#launch_agents[@]} -eq 0 ]]; then
        echo "No launch agent .plist files found in backup."
        return
    fi
    
    echo ""
    echo "  [A] Select All"
    echo "  [N] Select None"
    echo "  [C] Continue with current selections"
    echo ""
    
    while true; do
        echo "Current selections:"
        for i in "${!launch_agents[@]}"; do
            local status=$([ "${agent_selections[$i]}" = true ] && echo "✓ Selected" || echo "○ Not selected")
            echo "  [$(( i + 1 ))] ${launch_agents[$i]} - $status"
        done
        echo ""
        
        read -p "Enter your choice (1-${#launch_agents[@]}, A, N, or C): " choice
        
        case $choice in
            [Aa]*) 
                for i in "${!agent_selections[@]}"; do
                    agent_selections[$i]=true
                done
                ;;
            [Nn]*) 
                for i in "${!agent_selections[@]}"; do
                    agent_selections[$i]=false
                done
                ;;
            [Cc]*) break ;;
            [0-9]*)
                if [[ $choice -ge 1 && $choice -le ${#launch_agents[@]} ]]; then
                    local idx=$(( choice - 1 ))
                    agent_selections[$idx]=$([ "${agent_selections[$idx]}" = true ] && echo false || echo true)
                else
                    echo "Invalid choice. Please try again."
                fi
                ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
    
    # Store selected launch agents globally
    SELECTED_LAUNCH_AGENTS=()
    for i in "${!launch_agents[@]}"; do
        if [[ "${agent_selections[$i]}" = true ]]; then
            SELECTED_LAUNCH_AGENTS+=("${launch_agents[$i]}")
        fi
    done
}

# Interactive selection menu (skip if --all flag is used)
if [[ "$RESTORE_ALL_FLAG" == true ]]; then
    echo "=== Restoring All Components (--all flag specified) ==="
    RESTORE_SHELL=true
    RESTORE_HOMEBREW=true
    RESTORE_DEV_TOOLS=true
    RESTORE_SSH=true
    RESTORE_APPS=true
    RESTORE_SYSTEM_PREFS=true
    RESTORE_FONTS=true
    RESTORE_BROWSER=true
    RESTORE_LAUNCHD=true
    RESTORE_NETWORK=true
    
    # For --all flag, select all available app configs and launch agents
    SELECTED_APP_CONFIGS=()
    if [[ -d "$BACKUP_DIR/app_configs" ]]; then
        for item in "$BACKUP_DIR/app_configs"/*; do
            if [[ -e "$item" ]]; then
                SELECTED_APP_CONFIGS+=("$(basename "$item")")
            fi
        done
    fi
    
    SELECTED_LAUNCH_AGENTS=()
    if [[ -d "$BACKUP_DIR/launchd/user_launch_agents_backup" ]]; then
        while IFS= read -r -d '' file; do
            SELECTED_LAUNCH_AGENTS+=("$(basename "$file")")
        done < <(find "$BACKUP_DIR/launchd/user_launch_agents_backup" -name "*.plist" -print0 2>/dev/null)
    fi
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
    RESTORE_SYSTEM_PREFS=false
    RESTORE_FONTS=false
    RESTORE_BROWSER=false
    RESTORE_LAUNCHD=false
    RESTORE_NETWORK=false

    while true; do
        echo "Current selections:"
        echo "  [1] Shell Configuration - $([ "$RESTORE_SHELL" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [2] Homebrew Packages - $([ "$RESTORE_HOMEBREW" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [3] Development Tools - $([ "$RESTORE_DEV_TOOLS" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [4] SSH Configuration - $([ "$RESTORE_SSH" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [5] Application Configurations - $([ "$RESTORE_APPS" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [6] System Preferences - $([ "$RESTORE_SYSTEM_PREFS" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [7] Custom Fonts - $([ "$RESTORE_FONTS" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [8] Browser Data - $([ "$RESTORE_BROWSER" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [9] Launch Agents - $([ "$RESTORE_LAUNCHD" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo "  [10] Network Settings - $([ "$RESTORE_NETWORK" = true ] && echo "✓ Selected" || echo "○ Not selected")"
        echo ""
        echo "  [A] Select All"
        echo "  [C] Continue with current selections"
        echo "  [Q] Quit without restoring"
        echo ""
        read -p "Enter your choice (1-10, A, C, or Q): " choice
        
        case $choice in
            1) RESTORE_SHELL=$([ "$RESTORE_SHELL" = true ] && echo false || echo true) ;;
            2) RESTORE_HOMEBREW=$([ "$RESTORE_HOMEBREW" = true ] && echo false || echo true) ;;
            3) RESTORE_DEV_TOOLS=$([ "$RESTORE_DEV_TOOLS" = true ] && echo false || echo true) ;;
            4) RESTORE_SSH=$([ "$RESTORE_SSH" = true ] && echo false || echo true) ;;
            5) RESTORE_APPS=$([ "$RESTORE_APPS" = true ] && echo false || echo true) ;;
            6) RESTORE_SYSTEM_PREFS=$([ "$RESTORE_SYSTEM_PREFS" = true ] && echo false || echo true) ;;
            7) RESTORE_FONTS=$([ "$RESTORE_FONTS" = true ] && echo false || echo true) ;;
            8) RESTORE_BROWSER=$([ "$RESTORE_BROWSER" = true ] && echo false || echo true) ;;
            9) RESTORE_LAUNCHD=$([ "$RESTORE_LAUNCHD" = true ] && echo false || echo true) ;;
            10) RESTORE_NETWORK=$([ "$RESTORE_NETWORK" = true ] && echo false || echo true) ;;
            [Aa]*) 
                RESTORE_SHELL=true; RESTORE_HOMEBREW=true; RESTORE_DEV_TOOLS=true
                RESTORE_SSH=true; RESTORE_APPS=true; RESTORE_SYSTEM_PREFS=true
                RESTORE_FONTS=true; RESTORE_BROWSER=true; RESTORE_LAUNCHD=true
                RESTORE_NETWORK=true
                ;;
            [Cc]*) break ;;
            [Qq]*) echo "Restore cancelled."; exit 0 ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
        echo ""
    done

    # Check if at least one option is selected
    if [[ "$RESTORE_SHELL" = false && "$RESTORE_HOMEBREW" = false && "$RESTORE_DEV_TOOLS" = false && 
          "$RESTORE_SSH" = false && "$RESTORE_APPS" = false && "$RESTORE_SYSTEM_PREFS" = false &&
          "$RESTORE_FONTS" = false && "$RESTORE_BROWSER" = false && "$RESTORE_LAUNCHD" = false &&
          "$RESTORE_NETWORK" = false ]]; then
        echo "No options selected. Exiting."
        exit 0
    fi
    
    # If Application Configurations selected, let user choose specific ones
    if [[ "$RESTORE_APPS" = true ]]; then
        echo ""
        select_app_configs
    fi
    
    # If Launch Agents selected, let user choose specific ones
    if [[ "$RESTORE_LAUNCHD" = true ]]; then
        echo ""
        select_launch_agents
    fi
fi

echo ""
echo "=== Selected for restoration ==="
[ "$RESTORE_SHELL" = true ] && echo "✓ Shell Configuration"
[ "$RESTORE_HOMEBREW" = true ] && echo "✓ Homebrew Packages"
[ "$RESTORE_DEV_TOOLS" = true ] && echo "✓ Development Tools"
[ "$RESTORE_SSH" = true ] && echo "✓ SSH Configuration"
[ "$RESTORE_APPS" = true ] && echo "✓ Application Configurations"
[ "$RESTORE_SYSTEM_PREFS" = true ] && echo "✓ System Preferences"
[ "$RESTORE_FONTS" = true ] && echo "✓ Custom Fonts"
[ "$RESTORE_BROWSER" = true ] && echo "✓ Browser Data"
[ "$RESTORE_LAUNCHD" = true ] && echo "✓ Launch Agents"
[ "$RESTORE_NETWORK" = true ] && echo "✓ Network Settings"
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

# Install Homebrew first if needed
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
fi

# Restore components based on selection
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

    safe_restore "$BACKUP_DIR/shell_config/.oh-my-zsh" "$HOME/.oh-my-zsh" false
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

    safe_restore "$BACKUP_DIR/development/.asdf" "$HOME/.asdf" false
fi

if [[ "$RESTORE_SSH" = true ]]; then
    echo "=== Restoring SSH Configuration ==="
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    safe_restore "$BACKUP_DIR/ssh_keys/config" "$HOME/.ssh/config" true
    safe_restore "$BACKUP_DIR/ssh_keys/known_hosts" "$HOME/.ssh/known_hosts" true

    if [[ -d "$BACKUP_DIR/ssh_keys" ]]; then
        find "$BACKUP_DIR/ssh_keys" -name "*.pub" -exec cp {} "$HOME/.ssh/" \;
        chmod 644 "$HOME/.ssh"/*.pub 2>/dev/null || true
    fi
fi

if [[ "$RESTORE_HOMEBREW" = true ]]; then
    echo "=== Installing Homebrew Packages ==="
    if [[ -f "$BACKUP_DIR/homebrew/Brewfile_current" ]]; then
        echo "Installing from current Brewfile..."
        brew bundle install --file="$BACKUP_DIR/homebrew/Brewfile_current"
    elif [[ -f "$BACKUP_DIR/homebrew/Brewfile_original" ]]; then
        echo "Installing from original Brewfile..."
        brew bundle install --file="$BACKUP_DIR/homebrew/Brewfile_original"
    else
        echo "No Brewfile found in backup"
    fi
    
    # Restore Homebrew services
    if [[ -f "$BACKUP_DIR/homebrew/services.txt" ]]; then
        echo "Note: Review Homebrew services to restart: $BACKUP_DIR/homebrew/services.txt"
    fi
fi

if [[ "$RESTORE_APPS" = true ]]; then
    echo "=== Restoring Selected Application Configurations ==="
    
    if [[ ${#SELECTED_APP_CONFIGS[@]} -eq 0 ]]; then
        echo "No application configurations selected for restore."
    else
        echo "Restoring $(( ${#SELECTED_APP_CONFIGS[@]} )) selected application configurations:"
        
        for app_config in "${SELECTED_APP_CONFIGS[@]}"; do
            echo "Processing: $app_config"
            
            # Determine if it's a directory or file and set backup_existing accordingly
            local backup_existing=false
            case "$app_config" in
                .nanorc|.viminfo|.wget-hsts|.z)
                    backup_existing=true
                    ;;
            esac
            
            if [[ -d "$BACKUP_DIR/app_configs/$app_config" ]]; then
                safe_restore "$BACKUP_DIR/app_configs/$app_config" "$HOME/$app_config" "$backup_existing"
            elif [[ -f "$BACKUP_DIR/app_configs/$app_config" ]]; then
                safe_restore "$BACKUP_DIR/app_configs/$app_config" "$HOME/$app_config" "$backup_existing"
            else
                echo "Warning: $app_config not found in backup"
            fi
        done
    fi
fi

if [[ "$RESTORE_FONTS" = true ]]; then
    echo "=== Restoring Custom Fonts ==="
    if [[ -d "$BACKUP_DIR/fonts/user_fonts_backup" ]]; then
        mkdir -p "$HOME/Library/Fonts"
        safe_restore "$BACKUP_DIR/fonts/user_fonts_backup" "$HOME/Library/Fonts" false
        echo "Custom fonts restored. You may need to restart applications to see them."
    else
        echo "No custom fonts found in backup"
    fi
fi

if [[ "$RESTORE_BROWSER" = true ]]; then
    echo "=== Restoring Browser Data ==="
    if [[ -f "$BACKUP_DIR/browser_data/Bookmarks" ]]; then
        echo "⚠ Manual step required: Import Chrome bookmarks"
        echo "  File: $BACKUP_DIR/browser_data/Bookmarks"
    fi
    
    if [[ -f "$BACKUP_DIR/browser_data/chrome_preferences.json" ]]; then
        echo "⚠ Manual step required: Review Chrome preferences"
        echo "  File: $BACKUP_DIR/browser_data/chrome_preferences.json"
    fi
    
    if [[ -f "$BACKUP_DIR/browser_data/Bookmarks.plist" ]]; then
        echo "⚠ Manual step required: Import Safari bookmarks"
        echo "  File: $BACKUP_DIR/browser_data/Bookmarks.plist"
    fi
    
    if [[ -f "$BACKUP_DIR/browser_data/chrome_extensions.txt" ]]; then
        echo "⚠ Manual step required: Review Chrome extensions list"
        echo "  File: $BACKUP_DIR/browser_data/chrome_extensions.txt"
    fi
fi

if [[ "$RESTORE_LAUNCHD" = true ]]; then
    echo "=== Restoring Selected Launch Agents ==="
    
    if [[ ${#SELECTED_LAUNCH_AGENTS[@]} -eq 0 ]]; then
        echo "No launch agents selected for restore."
    else
        echo "Restoring $(( ${#SELECTED_LAUNCH_AGENTS[@]} )) selected launch agents:"
        mkdir -p "$HOME/Library/LaunchAgents"
        
        for agent in "${SELECTED_LAUNCH_AGENTS[@]}"; do
            echo "Processing: $agent"
            
            if [[ -f "$BACKUP_DIR/launchd/user_launch_agents_backup/$agent" ]]; then
                safe_restore "$BACKUP_DIR/launchd/user_launch_agents_backup/$agent" "$HOME/Library/LaunchAgents/$agent" true
                echo "  ⚠ Manual step: Review and load if needed: launchctl load ~/Library/LaunchAgents/$agent"
            else
                echo "Warning: $agent not found in backup"
            fi
        done
        
        echo ""
        echo "Launch Agent Management Commands:"
        echo "  Load agent:   launchctl load ~/Library/LaunchAgents/[agent-name].plist"
        echo "  Unload agent: launchctl unload ~/Library/LaunchAgents/[agent-name].plist"
        echo "  List loaded:  launchctl list | grep [pattern]"
    fi
fi

if [[ "$RESTORE_NETWORK" = true ]]; then
    echo "=== Network Settings Information ==="
    echo "⚠ Manual step required: Configure network settings"
    if [[ -f "$BACKUP_DIR/network/wifi_networks.txt" ]]; then
        echo "  WiFi networks to configure: $BACKUP_DIR/network/wifi_networks.txt"
    fi
fi

if [[ "$RESTORE_SYSTEM_PREFS" = true ]]; then
    restore_system_preferences
fi

# Install applications
install_applications

# Setup asdf tools
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
        
        # Install plugins
        while IFS= read -r line; do
            if [[ -n "$line" && ! "$line" =~ ^# ]]; then
                tool=$(echo "$line" | cut -d' ' -f1)
                echo "Adding asdf plugin: $tool"
                asdf plugin add "$tool" 2>/dev/null || echo "Plugin $tool already exists or failed to add"
            fi
        done < "$HOME/.tool-versions"
        
        echo "Installing asdf tools..."
        asdf install
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
[ "$RESTORE_SYSTEM_PREFS" = true ] && echo "✓ System Preferences (manual steps required)"
[ "$RESTORE_FONTS" = true ] && echo "✓ Custom Fonts"
[ "$RESTORE_BROWSER" = true ] && echo "✓ Browser Data (manual import required)"
[ "$RESTORE_LAUNCHD" = true ] && echo "✓ Launch Agents"
[ "$RESTORE_NETWORK" = true ] && echo "✓ Network Settings (manual configuration required)"
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: source ~/.zshrc"
echo "2. Review system information: cat $BACKUP_DIR/system_info/backup_summary.txt"
echo "3. Manually configure system preferences as needed"
echo "4. Import browser bookmarks and extensions"
echo "5. Configure network settings (WiFi, VPN)"
echo "6. Re-authenticate with services (GitHub, AWS, etc.)"
echo "7. Install any missing applications from: $BACKUP_DIR/applications/"
echo ""

# Cleanup extracted directory if we extracted an archive
if [[ "$CLEANUP_EXTRACTED" == true && "$RUNNING_FROM_ARCHIVE" == false ]]; then
    echo "Cleaning up extracted backup directory..."
    rm -rf "$BACKUP_DIR"
    echo "Cleanup complete. Archive file preserved."
elif [[ "$RUNNING_FROM_ARCHIVE" == true ]]; then
    echo "Note: Running from archive directory - no cleanup performed."
    echo "You can manually remove the expanded directory when done: rm -rf '$SCRIPT_DIR'"
fi
