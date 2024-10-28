# Changelog

All notable changes to this project will be documented in this file.

## [v0.1-dev1] - 2024-10-28

### Added
- Initial development version
- SwarmUI integration with path awareness
- Jupyter Lab integration
- NVIDIA CUDA 12.4.1 support
- Automatic .NET SDK installation
- Proper workspace permissions (755)
- Integrated cron service
- Port exposure configuration
- Basic logging setup

### Technical Details
- Based on nvidia/cuda:12.4.1-runtime-ubuntu22.04
- SwarmUI runs on port 7801
- Jupyter Lab runs on port 7888
- ComfyUI instances use ports 7821-7828
- SSH available on port 22

### Development Notes
- Initial release focusing on core functionality
- Permission structure optimized for workspace access
- Added explicit host binding for better port access
  