# User Profile Migration Tools

A comprehensive set of scripts for backing up and selectively restoring macOS user profiles, perfect for migrating to new user accounts or machines while maintaining full control over what gets restored.

## 🚀 Features

- **Complete Backup**: Backs up shell configs, development tools, applications, and more
- **Selective Restore**: Choose exactly what to restore with an interactive menu
- **Compressed Archives**: Creates space-efficient .tar.gz files perfect for cloud storage
- **Security Focused**: Private SSH keys and sensitive data are handled safely
- **Fresh Package Lists**: Always generates current Homebrew package lists
- **Self-Contained**: Archives include all necessary scripts and documentation

## 📋 What Gets Backed Up

### Shell Configuration
- Zsh, Bash configurations (`.zshrc`, `.zprofile`, `.bashrc`, etc.)
- Oh My Zsh installation and themes
- PowerLevel10K configuration
- iTerm2 shell integration

### Development Tools  
- Git configuration and global settings
- asdf version manager with all installed tools
- Development environment configurations

### SSH Configuration
- SSH config files and known hosts
- Public keys (private keys excluded for security)

### Applications
- AWS, Azure, Docker configurations
- VS Code settings and extensions
- iTerm2, 1Password, and other app configs
- Homebrew package lists (formulae, casks, extensions)

### System Information
- Installed applications list
- System details and versions
- Backup manifest for verification

## 🛠 Usage

### Creating a Backup

```bash
# Run the backup script
./scripts/backup.sh

# Creates a compressed archive like:
# user_profile_backup_20241225_120000.tar.gz (typically ~800MB)
```

### Restoring (Interactive Mode)

```bash
# Extract and run interactive restore
tar -xzf user_profile_backup_20241225_120000.tar.gz
cd user_profile_backup_20241225_120000
./user_profile_restore.sh

# Choose what to restore:
# [1] Shell Configuration ○
# [2] Homebrew Packages ○  
# [3] Development Tools ○
# [4] SSH Configuration ○
# [5] Application Configurations ○
# [A] Select All | [C] Continue | [Q] Quit
```

### Restoring (All Components)

```bash
# Restore everything without prompts
./user_profile_restore.sh --all
```

### Testing Before Backup

```bash
# See what would be backed up without creating a backup
./scripts/dry-run.sh
```

## 📁 Repository Structure

```
user-profile-migration/
├── README.md                 # This file
├── scripts/
│   ├── backup.sh            # Main backup script
│   ├── restore.sh           # Selective restore script
│   └── dry-run.sh           # Test what would be backed up
├── docs/
│   └── migration-guide.md   # Detailed migration instructions
└── examples/
    └── sample-usage.md      # Usage examples and scenarios
```

## 🔒 Security Considerations

### ✅ Safe Practices
- Private SSH keys are **never** backed up
- Scripts contain no personal data
- Backup archives should **never** be committed to version control
- Public keys only are included in SSH backups

### ⚠️ Important Warnings
- **Never upload backup archives to public repositories**
- **Review restored configurations** for hardcoded personal paths
- **Re-authenticate with services** after restoration
- **Regenerate SSH keys** if needed for new environments

## 🎯 Common Use Cases

### New Machine Setup
Select shell configuration and development tools for a clean, productive environment.

### Work vs Personal Separation  
Restore different components for different contexts and requirements.

### Testing Configurations
Restore individual components to test compatibility and troubleshoot issues.

### Minimal Installations
Choose only essential tools for lightweight setups or containers.

### Gradual Migration
Restore components incrementally to ensure everything works correctly.

## 📖 Documentation

- **[Migration Guide](docs/migration-guide.md)** - Complete step-by-step migration instructions
- **[Sample Usage](examples/sample-usage.md)** - Common scenarios and examples
- **Script Help** - Run any script with `--help` for detailed usage information

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request

### Development Guidelines
- Keep scripts generic and avoid hardcoded personal information
- Test on clean systems when possible
- Update documentation for new features
- Follow existing code style and patterns

## ⚠️ Disclaimer

These scripts modify system configurations and install software. Always:
- **Test in a safe environment first**
- **Review scripts before running**
- **Keep backups of important data**
- **Understand what each script does**

Use at your own risk. The authors are not responsible for any data loss or system issues.

## 📄 License

MIT License - see LICENSE file for details.

## 🙏 Acknowledgments

Built for the macOS development community to make user profile migrations safer, more flexible, and more reliable.
