# Changelog

All notable changes to the Mac User Profile Migration Scripts will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive backup script with system information capture
- Granular restore script with selective restoration options
- Password protection by default using AES-256-CBC encryption
- Individual application configuration selection
- Individual launch agent selection
- Comprehensive backup validation
- Support for encrypted backup archives
- Detailed backup manifest generation
- System information collection
- Browser data backup (bookmarks, preferences, extensions)
- Custom fonts backup and restoration
- Network configuration capture
- Security settings documentation
- Launch agents management with guided loading
- Post-restore verification and guidance

### Features
- Complete directory structure with 12 organized categories
- Robust error handling and validation
- User-friendly interactive menus
- Comprehensive help documentation
- Backward compatibility with older backup formats

### Security
- Password protection enabled by default
- Strong key derivation with PBKDF2 (100,000 iterations)
- Automatic encryption detection and handling
- Secure password handling with memory cleanup
- Private keys excluded from backups for security

---

*This project provides a comprehensive solution for Mac user profile migration and system backup.*
