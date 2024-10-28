# Changelog

## [v0.3] - 2024-10-28

### Added
- Cron service support with logging
- Enhanced rclone configuration with base64 support and validation
- Proper Jupyter Lab configuration file generation
- Base64 support for rclone configuration
- Environment variable for rclone config path
- Better service verification and logging

### Changed
- Optimized Docker image size by removing non-essential packages
- Streamlined Python package selection to essential ones:
  - jupyterlab 4.1.*
  - notebook 7.1.*
  - ipywidgets 8.1.*
  - ipython 8.12.*
  - numpy 1.26.*
  - pandas 2.2.*
  - matplotlib 3.8.*
  - transformers 4.36.*
  - wandb 0.16.*
  - huggingface_hub 0.20.*
- Enhanced error handling in startup script
- Improved SSH service reliability
- Better log formatting and system information display
- Updated rclone to v1.65.0
- Reorganized Dockerfile structure for better maintainability

### Fixed
- Jupyter Lab startup and configuration issues
- SSH startup and configuration
- Service verification process
- File permissions for security
- Rclone configuration validation

## [v0.2] - 2024-10-28

### Added
- SSH service with secure configuration
- Environment variable support for tokens
- Service health checks
- System utilities (curl, git)
- Basic Python packages
- Initial Jupyter setup

### Changed
- Improved error handling in startup script
- Better directory structure
- Enhanced logging system
- Updated rclone setup

### Fixed
- SSH startup issues
- Directory permissions
- Service verification
- Token handling

## [v0.1] - 2024-10-28

### Added
- Initial release
- Basic Jupyter setup
- PyTorch environment
- CUDA support
- Directory structure