# Quick Reference - Enhanced Mac Migration Scripts

## 🚀 Essential Commands

```bash
# See what would be backed up
./scripts/enhanced-dry-run.sh

# Create comprehensive backup
./scripts/enhanced-backup.sh

# Interactive restore (recommended)
./scripts/enhanced-restore.sh backup.tar.gz

# Restore everything without prompts
./scripts/enhanced-restore.sh backup.tar.gz --all

# Validate backup integrity
./scripts/enhanced-restore.sh backup.tar.gz --validate
```

## 📋 Restoration Categories

| # | Category | Description | Granular Selection |
|---|----------|-------------|-------------------|
| 1 | Shell Configuration | Zsh, Bash, Oh My Zsh, themes | No |
| 2 | Homebrew Packages | Formulae, casks, services | No |
| 3 | Development Tools | Git, asdf, language versions | No |
| 4 | SSH Configuration | Config, known hosts, public keys | No |
| 5 | **Application Configs** | AWS, Docker, VS Code, etc. | **✅ Yes** |
| 6 | System Preferences | Dock, Finder, trackpad | No |
| 7 | Custom Fonts | User-installed fonts | No |
| 8 | Browser Data | Bookmarks, preferences | No |
| 9 | **Launch Agents** | Startup services | **✅ Yes** |
| 10 | Network Settings | WiFi, VPN configs | No |

## 🎯 Application Configuration Selection

When you select "Application Configurations", you can choose from:

- **AWS CLI** (`.aws`) - Credentials and config
- **Azure CLI** (`.azure`) - Azure settings
- **Docker** (`.docker`) - Docker configuration
- **VS Code** (`.vscode`) - Editor settings
- **iTerm2** (`.iterm2`) - Terminal preferences
- **1Password** (`.1password`) - CLI settings
- **GnuPG** (`.gnupg`) - GPG configuration
- **NPM** (`.npm`) - Node package manager
- **Terraform** (`.terraform.d`) - Terraform settings
- **And more...**

## 🚀 Launch Agent Selection

When you select "Launch Agents", you can choose from:

- Custom startup services (`.plist` files)
- Homebrew services
- User-defined automation scripts
- Background task configurations

**Includes loading guidance:**
```bash
# Load agent
launchctl load ~/Library/LaunchAgents/[agent-name].plist

# Unload agent
launchctl unload ~/Library/LaunchAgents/[agent-name].plist
```

## 🔄 Typical Migration Workflow

### 1. Preparation
```bash
./scripts/enhanced-dry-run.sh    # Review what will be backed up
./scripts/enhanced-backup.sh     # Create backup
```

### 2. Fresh System Setup
- Clean macOS install
- Install Xcode Command Line Tools: `xcode-select --install`

### 3. Restoration (Recommended Order)
```bash
./scripts/enhanced-restore.sh backup.tar.gz
```

**Select in this order:**
1. ✅ Shell Configuration
2. ✅ Homebrew Packages  
3. ✅ Development Tools
4. ✅ SSH Configuration
5. ✅ Application Configurations (choose specific apps)
6. ⚠️ System Preferences (manual review)
7. ✅ Custom Fonts (if needed)
8. ⚠️ Browser Data (manual import)
9. ✅ Launch Agents (choose specific services)
10. ⚠️ Network Settings (manual config)

### 4. Post-Restoration
- Re-authenticate services (GitHub, AWS, etc.)
- Configure system preferences manually
- Import browser bookmarks
- Test all functionality

## 🔒 Security Notes

- **Private SSH keys**: Never backed up
- **Passwords**: Not captured (WiFi, services)
- **System preferences**: Manual review required
- **Launch agents**: Individual inspection recommended

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| Homebrew fails | Install manually first |
| SSH keys don't work | Check permissions: `chmod 600 ~/.ssh/id_*` |
| Apps can't find configs | Restart applications |
| Launch agents don't start | Load manually with `launchctl` |

## 📁 Backup Contents

```
user_profile_backup_YYYYMMDD_HHMMSS/
├── shell_config/           # Shell configurations
├── development/            # Git, asdf, etc.
├── homebrew/              # Brewfile and package info
├── ssh_keys/              # SSH config and public keys
├── app_configs/           # Application configurations
├── system_info/           # Hardware and software info
├── system_preferences/    # macOS settings
├── applications/          # Installed app inventory
├── fonts/                 # Custom fonts
├── network/               # Network configuration
├── security/              # Security settings
├── launchd/               # Launch agents
├── browser_data/          # Browser bookmarks/prefs
└── enhanced_restore.sh    # Restoration script
```

## 💡 Pro Tips

- **Always start with dry run** to see what will be backed up
- **Validate backup** before restoring: `--validate` flag
- **Restore selectively** - you don't need everything
- **Keep multiple backups** for different scenarios
- **Test on non-production** systems first

---

**Need more details?** See `README.md` and `MIGRATION-GUIDE.md` for comprehensive documentation.
