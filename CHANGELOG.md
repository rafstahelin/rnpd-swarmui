# Changelog

All notable changes to this project will be documented in this file.

## [v0.1-dev3] - 2024-10-28

### Added
- Successful SwarmUI integration with auto-build process
- Working Jupyter Lab integration
- Confirmed NVIDIA CUDA support with RTX 4090
- Proper service initialization and port configuration
- Enhanced logging and error handling
- Integrated build system for SwarmUI
- Automatic .NET SDK installation (v8.0.403)

### Fixed
- Fixed SwarmUI startup issues
- Corrected build process handling
- Proper port exposures and bindings

### Technical Details
- Based on nvidia/cuda:12.4.1-runtime-ubuntu22.04
- SwarmUI v0.9.3.1 running on port 7801
- Jupyter Lab running on port 7888
- ComfyUI instances using ports 7821-7828
- SSH available on port 22

### Development Notes
- Confirmed working on both local Docker and WSL2
- Added better error logging and status checks
- Improved startup script reliability