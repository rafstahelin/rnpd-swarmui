#!/bin/bash
# RAF RunPod PyTorch Template
# Version: v0.2
# Date: 2024-10-28

# Enable error handling
set -euo pipefail
trap 'echo "Error on line $LINENO"' ERR

# Function to log messages
log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to verify service
verify_service() {
    local service_name="$1"
    local command="$2"
    local max_retries=3
    local retry_count=0

    log_message "Starting $service_name..."
    while ! $command && ((retry_count < max_retries)); do
        log_message "Warning: $service_name failed to start, retry $((retry_count + 1))/$max_retries"
        sleep 2
        ((retry_count++))
    done

    if ((retry_count >= max_retries)); then
        log_message "Error: $service_name failed to start after $max_retries retries"
        return 1
    fi

    log_message "$service_name started successfully"
    return 0
}

# Ensure required directories exist
mkdir -p /var/run/sshd
mkdir -p /root/.ssh
mkdir -p /root/.config/rclone
chmod 700 /root/.ssh

# Generate SSH host keys if missing
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    log_message "Generating SSH host keys..."
    ssh-keygen -A
fi

# Start services with retry
verify_service "SSH" "service ssh start"
verify_service "Nginx" "service nginx start"

# Setup tokens with proper permissions
if [[ -n "${HF_TOKEN:-}" ]]; then
    log_message "Setting up HuggingFace token..."
    mkdir -p /root/.huggingface
    echo "$HF_TOKEN" > /root/.huggingface/token
    chmod 600 /root/.huggingface/token
    export HUGGINGFACE_TOKEN=$HF_TOKEN
fi

if [[ -n "${WANDB_API_KEY:-}" ]]; then
    log_message "Setting up Weights & Biases token..."
    export WANDB_API_KEY=$WANDB_API_KEY
fi

# Setup rclone
if [[ -n "${RCLONE_CONFIG:-}" ]]; then
    log_message "Setting up rclone..."
    echo "$RCLONE_CONFIG" > "$RCLONE_CONFIG_PATH"
    chmod 600 "$RCLONE_CONFIG_PATH"
fi

# Print system information
log_message "=== System Information ==="
log_message "CPU: $(nproc) cores"
log_message "Memory: $(free -h | awk '/Mem:/ {print $2}')"
log_message "GPU: $(nvidia-smi --query-gpu=gpu_name --format=csv,noheader 2>/dev/null || echo 'No GPU found')"
log_message "Python: $(python --version)"
log_message "PyTorch: $(python -c 'import torch; print(torch.__version__)')"
log_message "CUDA: $(nvidia-smi | grep "CUDA Version:" | awk '{print $9}' 2>/dev/null || echo 'No CUDA found')"

# Start Jupyter Lab
log_message "Starting Jupyter Lab..."
cd /workspace
jupyter lab --allow-root --no-browser --port=8888 --ip=0.0.0.0 \
    --ServerApp.token='' \
    --ServerApp.password='' \
    --ServerApp.allow_origin=* \
    --ServerApp.root_dir=/workspace \
    --ServerApp.terminado_settings='{"shell_command": ["/bin/bash"]}' \
    >> /workspace/jupyter.log 2>&1 &

# Verify Jupyter is running
timeout=30
while ! curl -s http://localhost:8888/api >/dev/null; do
    if ((timeout-- <= 0)); then
        log_message "Error: Jupyter failed to start"
        exit 1
    fi
    sleep 1
done

log_message "Pod ready to use."
tail -f /workspace/jupyter.log