# Sample Usage Examples

## Basic Backup and Restore

### Creating a Backup
```bash
# Run the backup script
./scripts/backup.sh

# Output will show:
# - What's being backed up
# - Compression progress
# - Final archive location and size
# - iCloud Drive upload instructions
```

### Full Restore (Non-Interactive)
```bash
# Extract and restore everything
tar -xzf user_profile_backup_20241225_120000.tar.gz
cd user_profile_backup_20241225_120000
./user_profile_restore.sh --all
```

### Interactive Selective Restore
```bash
# Extract and run interactive restore
tar -xzf user_profile_backup_20241225_120000.tar.gz
cd user_profile_backup_20241225_120000
./user_profile_restore.sh

# Interactive menu will appear:
# [1] Shell Configuration - ○ Not selected
# [2] Homebrew Packages - ○ Not selected  
# [3] Development Tools - ○ Not selected
# [4] SSH Configuration - ○ Not selected
# [5] Application Configurations - ○ Not selected
# [A] Select All
# [C] Continue with current selections
# [Q] Quit without restoring
```

## Common Scenarios

### New Developer Setup
```bash
# Restore just the essentials for development
./user_profile_restore.sh
# Select: [1] Shell Configuration, [2] Homebrew Packages, [3] Development Tools
# Skip: [4] SSH Configuration, [5] Application Configurations
```

### Minimal Shell Setup
```bash
# Just get your shell environment
./user_profile_restore.sh
# Select: [1] Shell Configuration only
```

### Testing New Configuration
```bash
# Restore development tools to test compatibility
./user_profile_restore.sh
# Select: [3] Development Tools only
```

## Dry Run Testing

```bash
# Test what would be backed up without actually doing it
./scripts/dry-run.sh

# Shows:
# - What files/directories would be included
# - Estimated sizes
# - What would be skipped
# - No actual backup is created
```

## Advanced Usage

### Custom Backup Location
```bash
# Modify the backup script to use a custom location
# Edit BACKUP_DIR variable in backup.sh
BACKUP_DIR="/path/to/custom/backup_$(date +%Y%m%d_%H%M%S)"
```

### Scripted Migration
```bash
#!/bin/bash
# Automated migration script

# Download backup from cloud storage
wget "https://your-cloud-storage/backup.tar.gz"

# Extract
tar -xzf backup.tar.gz

# Restore specific components
cd user_profile_backup_*
./user_profile_restore.sh --all

# Clean up
cd ..
rm -rf user_profile_backup_* backup.tar.gz
```

### Selective Component Testing
```bash
# Test each component individually
./user_profile_restore.sh  # Select [1] Shell only
# Test shell configuration
source ~/.zshrc

./user_profile_restore.sh  # Select [3] Dev Tools only  
# Test development tools
git --version
asdf list

# Continue with other components as needed
```

## Error Handling Examples

### Missing Dependencies
```bash
# If Homebrew is missing during restore
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# If asdf is missing
brew install asdf

# If Oh My Zsh is missing
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Permission Issues
```bash
# Fix SSH permissions after restore
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 644 ~/.ssh/*.pub

# Fix GPG permissions
chmod 700 ~/.gnupg
chmod 600 ~/.gnupg/*
```

### Path Issues
```bash
# Update paths in restored configurations
# Edit ~/.gitconfig to update user paths
# Edit shell configs to update custom paths
# Update application configs with new username
```

## Integration Examples

### CI/CD Pipeline
```bash
# Use in automated testing environments
name: Test User Profile Migration
on: [push]
jobs:
  test-migration:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Test backup script
        run: ./scripts/dry-run.sh
      - name: Test restore help
        run: ./scripts/restore.sh --help
```

### Docker Development Environment
```bash
# Use selective restore in containerized development
FROM ubuntu:latest
COPY scripts/ /migration/
RUN /migration/restore.sh --help
# Restore only development tools in container
```
