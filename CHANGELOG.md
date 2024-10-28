# Changelog

## [v0.3-dev2] - 2024-10-28

### Changed
- Removed predefined workspace directories (data, models, notebooks, scripts, logs, outputs)
- Simplified workspace setup to just /workspace root directory
- Let individual repositories/applications create their own directory structures

### Fixed
- Cleaned up unnecessary directory creation in Dockerfile and start.sh
- Streamlined startup process

### Verified
- GPU/CUDA functionality with RTX 4090
- All core services (SSH, Nginx, Cron)
- Python package versions
- CUDA matrix operations
- Jupyter Lab access and configuration

## [v0.3-dev] - 2024-10-28

### Added
- Cron service support with logging
- Enhanced rclone configuration with base64 support and validation
- Proper Jupyter Lab configuration file generation
- Base64 support for rclone configuration
- Environment variable for rclone config path
- Better service verification and logging

### Changed
- Optimized Docker image size by removing non-essential packages
- Fixed workspace directory creation in start.sh
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
- Workspace directory creation and permissions
- Jupyter Lab startup and configuration issues
- SSH startup and configuration
- Service verification process
- File permissions for security
- Rclone configuration validation

[Previous entries remain unchanged...]