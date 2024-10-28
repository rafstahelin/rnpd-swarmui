# RAF RunPod PyTorch Template

A custom Docker image template for RunPod.io featuring PyTorch 2.4.0 and CUDA 12.4.

## Features

- Base image: `runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04`
- PyTorch 2.4.0 with CUDA 12.4 support
- Python 3.11
- JupyterLab
- SSH access
- Rclone
- Weights & Biases integration
- HuggingFace Hub integration

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
docker pull rafrafraf/rnpd-pytorch240:v0.2
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
```

### Services Test

```bash
# GPU info
nvidia-smi

# Rclone version
rclone version

# SSH version
ssh -V
```

## Environment Variables

The following environment variables can be set:

- `HF_TOKEN`: HuggingFace access token
- `WANDB_API_KEY`: Weights & Biases API key
- `RCLONE_CONFIG`: Rclone configuration data

## Ports

- `8888`: JupyterLab
- `22`: SSH

## Building Locally

```bash
git clone https://github.com/rafstahelin/rnpd-pytorch240.git
cd rnpd-pytorch240
docker build -t rafrafraf/rnpd-pytorch240:v0.2 .
```

## License

MIT

## Author

RAF (rafstahelin)