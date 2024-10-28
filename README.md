# RAF RunPod PyTorch Template

A custom Docker image template for RunPod.io featuring PyTorch 2.4.0 and CUDA 12.4.

## Features

- Base image: `runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04`
- PyTorch 2.4.0 with CUDA 12.4 support
- Python 3.11
- JupyterLab with pre-configured setup
- SSH access with secure configuration
- Rclone with base64 configuration support
- Weights & Biases integration
- HuggingFace Hub integration
- Cron service support

## GPU Requirements

Compatible with CUDA 12.4+ capable GPUs:
- NVIDIA RTX 4090
- NVIDIA A6000
- NVIDIA L40S
- NVIDIA A100
- NVIDIA H100

## Usage

### Quick Start

```bash
docker pull rafrafraf/rnpd-pytorch240:v0.3
```

### Testing

You can verify the setup by running these tests in JupyterLab:

```python
# Python/CUDA test
import torch
print(f"PyTorch: {torch.__version__}")
print(f"CUDA: {torch.cuda.is_available()}")

# Test GPU if available
if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name(0)}")

# Test basic data science packages
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
print(f"NumPy: {np.__version__}")
print(f"Pandas: {pd.__version__}")
print(f"Matplotlib: {plt.__version__}")
```

### Services Test

```bash
# GPU info
nvidia-smi

# Rclone version
rclone version

# SSH connection (from another terminal)
ssh -p 22 root@localhost
# Password: runpod

# Cron service
service cron status
```

## Environment Variables

The following environment variables can be set:

- `HF_TOKEN`: HuggingFace access token
- `WANDB_API_KEY`: Weights & Biases API key
- `RCLONE_CONFIG`: Rclone configuration data (plain text)
- `RCLONE_CONFIG_BASE64`: Rclone configuration data (base64 encoded)

## Ports

- `8888`: JupyterLab
- `22`: SSH

## Pre-installed Python Packages

Core packages for data science and machine learning:
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

## Building Locally

```bash
git clone https://github.com/rafstahelin/rnpd-pytorch240.git
cd rnpd-pytorch240
docker build -t rafrafraf/rnpd-pytorch240:v0.3 .
```

## RunPod Template Testing

1. Create new template on RunPod:
   - Container Image: `rafrafraf/rnpd-pytorch240:v0.3`
   - Ports: 8888, 22
   - Volume: /workspace
   - Environment Variables: As needed (HF_TOKEN, WANDB_API_KEY, etc.)

2. Deploy a pod with the template:
   - Select desired GPU
   - Configure volume size
   - Deploy and test JupyterLab access

## License

MIT

## Author

RAF (rafstahelin)