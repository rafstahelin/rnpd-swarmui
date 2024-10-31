#!/bin/bash
# RAF RunPod PyTorch Template
# Version: v0.4

# Enable error handling
set -euo pipefail
trap 'echo "Error on line $LINENO"' ERR

# Function to log messages
log_message() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Start services
log_message "Starting SSH..."
service ssh start
log_message "SSH started successfully"

log_message "Starting Nginx..."
service nginx start
log_message "Nginx started successfully"

log_message "Starting Cron..."
service cron start
log_message "Cron started successfully"

# Setup tokens
if [[ -n "${HF_TOKEN:-}" ]]; then
    log_message "Setting up HuggingFace token..."
    echo "${HF_TOKEN}" > /root/.huggingface/token
fi

if [[ -n "${WANDB_API_KEY:-}" ]]; then
    log_message "Setting up Weights & Biases token..."
    export WANDB_API_KEY="${WANDB_API_KEY}"
fi

# Setup rclone
log_message "Setting up rclone..."
if [ ! -f "/workspace/rclone.conf" ] && [ -n "${RCLONE_CONF_URL:-}" ]; then
    log_message "Downloading rclone.conf..."
    curl -L -f -S "${RCLONE_CONF_URL}" -o /workspace/rclone.conf
    chmod 600 /workspace/rclone.conf
fi

if [ -f "/workspace/rclone.conf" ]; then
    log_message "Copying rclone config..."
    cp /workspace/rclone.conf "${RCLONE_CONFIG_PATH}"
    chmod 600 "${RCLONE_CONFIG_PATH}"
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

# Generate default config
jupyter lab --generate-config

# Create hashed password and configure Jupyter
python -c "from jupyter_server.auth import passwd; print(passwd('${JUPYTER_PASSWORD}'))" > /tmp/jupyter_pass

cat << EOF >> /root/.jupyter/jupyter_lab_config.py
c.ServerApp.allow_root = True
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.password = '$(cat /tmp/jupyter_pass)'
c.ServerApp.allow_origin = '*'
c.ServerApp.root_dir = '/workspace'
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}
EOF

rm /tmp/jupyter_pass

# Start Jupyter Lab
jupyter lab >> /workspace/jupyter.log 2>&1 &

# Wait for Jupyter to be ready
timeout=30
while ! curl -s http://localhost:8888/api >/dev/null; do
    if ((timeout-- <= 0)); then
        log_message "Error: Jupyter failed to start"
        exit 1
    fi
    sleep 1
done

log_message "Pod ready to use."
log_message "Jupyter Lab running with password from environment"
tail -f /workspace/jupyter.log
