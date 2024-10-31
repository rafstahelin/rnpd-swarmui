#!/bin/bash
# RAF RunPod PyTorch Template
# Version: v0.4
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

# Function to setup rclone with validation
setup_rclone() {
    log_message "Setting up rclone..."
    
    # Check current version
    CURRENT_VERSION=$(rclone --version | head -n1)
    log_message "Current rclone version: $CURRENT_VERSION"
    
    # Always attempt upgrade
    log_message "Starting rclone upgrade process..."
    
    # Create temp directory and work there
    mkdir -p /tmp/rclone_update
    cd /tmp/rclone_update
    
    # Download and install rclone 1.65
    log_message "Downloading rclone 1.65..."
    wget https://downloads.rclone.org/v1.65.0/rclone-v1.65.0-linux-amd64.zip
    unzip -o rclone-v1.65.0-linux-amd64.zip
    
    # Stop any running rclone processes
    log_message "Stopping any running rclone processes..."
    pkill rclone || true
    
    # Force replace the binary
    log_message "Installing new rclone binary..."
    cp -f rclone-v1.65.0-linux-amd64/rclone /usr/bin/
    chmod 755 /usr/bin/rclone
    
    # Cleanup
    cd /workspace
    rm -rf /tmp/rclone_update
    
    # Verify new version
    NEW_VERSION=$(rclone --version | head -n1)
    log_message "Rclone version after update attempt: $NEW_VERSION"
    
    # Continue with
    # First check if config already exists in workspace
    if [ ! -f "/workspace/rclone.conf" ]; then
        log_message "No existing rclone.conf found in workspace, attempting to download..."
        
        if [[ -n "${RCLONE_CONF_URL:-}" ]]; then
            log_message "Downloading rclone.conf from Dropbox..."
            curl -L -f -S "${RCLONE_CONF_URL}" -o /workspace/rclone.conf || {
                log_message "Failed to download rclone.conf"
                return 1
            }
            
            # Verify file was downloaded and is not empty
            if [ -s /workspace/rclone.conf ]; then
                log_message "Successfully downloaded rclone.conf"
                chmod 600 /workspace/rclone.conf
            else
                log_message "Downloaded file is empty or missing"
                return 1
            fi
        fi
    else
        log_message "Existing rclone.conf found in workspace"
    fi

    # Proceed with configuration if file exists
    if [ -f "/workspace/rclone.conf" ]; then
        log_message "Copying rclone config to ~/.config/rclone/"
        mkdir -p ~/.config/rclone
        cp /workspace/rclone.conf "$RCLONE_CONFIG_PATH"
        chmod 600 "$RCLONE_CONFIG_PATH"

        if rclone config show &>/dev/null; then
            log_message "Rclone configuration validated successfully"
            # Test Dropbox connection
            if rclone lsd dbx: &>/dev/null; then
                log_message "Successfully connected to Dropbox"
            else
                log_message "Warning: Could not connect to Dropbox"
            fi
        else
            log_message "Warning: Invalid rclone configuration"
            return 1
        fi
    else
        log_message "No rclone configuration available"
    fi
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
verify_service "Cron" "service cron start"

# Setup tokens with proper cleaning
if [[ -n "${HF_TOKEN:-}" ]]; then
    log_message "Setting up HuggingFace token..."
    cleaned_token=$(echo "$HF_TOKEN" | sed 's/^=//g' | tr -d '[:space:]')
    echo "$cleaned_token" > /root/.huggingface/token
    export HF_TOKEN="$cleaned_token"
fi

if [[ -n "${WANDB_API_KEY:-}" ]]; then
    log_message "Setting up Weights & Biases token..."
    # Remove any leading '=' and trim whitespace
    cleaned_key=$(echo "$WANDB_API_KEY" | sed 's/^=//g' | tr -d '[:space:]')
    export WANDB_API_KEY="$cleaned_key"
fi

# Setup rclone
setup_rclone

# Print system information
log_message "=== System Information ==="
log_message "CPU: $(nproc) cores"
log_message "Memory: $(free -h | awk '/Mem:/ {print $2}')"
log_message "GPU: $(nvidia-smi --query-gpu=gpu_name --format=csv,noheader 2>/dev/null || echo 'No GPU found')"
log_message "Python: $(python --version)"
log_message "PyTorch: $(python -c 'import torch; print(torch.__version__)')"
log_message "CUDA: $(nvidia-smi | grep "CUDA Version:" | awk '{print $9}' 2>/dev/null || echo 'No CUDA found')"

# Start Jupyter Lab with improved configuration
log_message "Starting Jupyter Lab..."
cd /workspace

# Create Jupyter config if it doesn't exist
jupyter lab --generate-config

# Configure Jupyter with token authentication
cat << EOF >> /root/.jupyter/jupyter_lab_config.py
c.ServerApp.allow_root = True
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.token = '${JUPYTER_TOKEN:-runpod}'
c.ServerApp.password = ''
c.ServerApp.allow_origin = '*'
c.ServerApp.root_dir = '/workspace'
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}
EOF

# Start Jupyter Lab
jupyter lab >> /workspace/jupyter.log 2>&1 &

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
log_message "Jupyter Lab running with token: ${JUPYTER_TOKEN:-runpod}"
tail -f /workspace/jupyter.log
