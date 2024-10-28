# RunPod SwarmUI Template

A Docker template for running SwarmUI with Jupyter integration, specifically configured for RunPod deployments.

## Repository & Image

- GitHub Repository: `rnpd-swarmui`
- Docker Image: `rafrafraf/rnpd-swarmui`

## Features

- SwarmUI on port 7801
- Jupyter Lab on port 7888
- NVIDIA CUDA 12.4.1 support
- Automatic .NET SDK installation
- Integrated cron service
- Persistent workspace with proper permissions

## Ports

- 7801: SwarmUI main interface
- 7821-7828: ComfyUI instances
- 7888: Jupyter Lab
- 22: SSH

## Environment Variables

- `SWARM_NO_VENV=true`: Prevents venv creation
- `DOTNET_ROOT=/root/.dotnet`: .NET SDK location
- `PATH=/root/.local/bin:/root/.dotnet:$PATH`: Updated PATH for binaries

## Usage

1. Pull the image:
```bash
docker pull rafrafraf/rnpd-swarmui:v0.1-dev1
```

2. Run with GPU support:
```bash
docker run --gpus all -p 7801:7801 -p 7888:7888 rafrafraf/rnpd-swarmui:v0.1-dev1
```

## RunPod Deployment

1. Template Settings:
   - Container Image: `rafrafraf/rnpd-swarmui:v0.1-dev1`
   - Container Disk: 20GB (minimum)
   - Volume Disk: As needed for your models and data

2. Exposed Ports:
   - HTTP: 7801, 7888
   - TCP: 22, 7821-7828

## Development

To build the image locally:

```bash
docker build -t rafrafraf/rnpd-swarmui:v0.1-dev1 .
docker tag rafrafraf/rnpd-swarmui:v0.1-dev1 rafrafraf/rnpd-swarmui:latest
```

## Directory Structure

```
/workspace/
├── logs/
│   ├── swarmui.log
│   └── jupyter.log
└── SwarmUI/
    └── dlbackend/
        └── ComfyUI/
```

## Version History

### v0.1-dev1
- Initial development version
- Base functionality from previous template
- Updated naming convention
- Improved documentation

## License

[MIT License](LICENSE)