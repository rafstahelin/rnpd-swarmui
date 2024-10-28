#!/bin/bash
set -e

# Configure logging
MAIN_LOG="/workspace/logs/swarmui.log"
JUPYTER_LOG="/workspace/logs/jupyter.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $MAIN_LOG
}

# Function to check if port is available
check_port() {
    local port=$1
    local service=$2
    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if netstat -tuln | grep ":$port " > /dev/null; then
            log_message "✓ $service started successfully on port $port"
            return 0
        fi
        log_message "Waiting for $service to start (attempt $attempt/$max_attempts)..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    log_message "✗ Failed to verify $service on port $port after $max_attempts attempts"
    return 1
}

# Start services
start_services() {
    log_message "Starting services..."
    service nginx start
    service ssh start
    service cron start
}

# Setup .NET SDK
setup_dotnet() {
    log_message "Setting up .NET SDK..."
    if [ ! -f "/root/.dotnet/dotnet" ]; then
        wget -q https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
        chmod +x dotnet-install.sh
        ./dotnet-install.sh --channel 8.0 --install-dir /root/.dotnet
        rm dotnet-install.sh
    fi
}

# Start Jupyter
start_jupyter() {
    log_message "Starting Jupyter Lab..."
    cd /workspace
    jupyter lab --allow-root --no-browser --port=7888 --ip=0.0.0.0 \
        --ServerApp.token='' --ServerApp.password='' \
        --ServerApp.allow_origin='*' > "$JUPYTER_LOG" 2>&1 &
    
    check_port 7888 "Jupyter Lab"
}

# Setup and start SwarmUI
setup_swarmui() {
    cd /workspace
    
    if [ -d "SwarmUI" ]; then
        log_message "Found existing SwarmUI installation, updating..."
        cd SwarmUI
        git pull
        chmod -R 755 .
    else
        log_message "Installing SwarmUI..."
        git clone https://github.com/mcmonkeyprojects/SwarmUI
        cd SwarmUI
        chmod -R 755 .
    fi

    # Build SwarmUI
    log_message "Building SwarmUI..."
    cd src
    dotnet build -c Release
    cd ..

    # Handle ComfyUI backend if present
    if [ -f "dlbackend/ComfyUI/requirements.txt" ]; then
        log_message "Installing ComfyUI requirements..."
        cd dlbackend/ComfyUI
        pip install -r requirements.txt
        cd ../..
    fi

    # Launch SwarmUI with debug output
    log_message "Launching SwarmUI..."
    chmod +x launch-linux.sh
    ./launch-linux.sh --launch_mode none --no-browser --port 7801 --host 0.0.0.0 --debug 2>&1 | tee -a "$MAIN_LOG" &
    
    # Wait for SwarmUI to start
    check_port 7801 "SwarmUI"
}

# Trap SIGTERM and SIGINT
trap 'kill $(jobs -p)' SIGTERM SIGINT

# Main execution
log_message "Starting initialization..."
start_services
setup_dotnet
start_jupyter
setup_swarmui

log_message "Setup complete, tailing logs..."
tail -f "$MAIN_LOG" "$JUPYTER_LOG"