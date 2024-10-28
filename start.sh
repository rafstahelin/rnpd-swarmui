#!/bin/bash
set -e

# Configure logging
MAIN_LOG="/workspace/logs/swarmui.log"
JUPYTER_LOG="/workspace/logs/jupyter.log"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $MAIN_LOG
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
        --ServerApp.allow_origin=* > "$JUPYTER_LOG" 2>&1 &
    
    sleep 5
    if netstat -tuln | grep :7888 > /dev/null; then
        log_message "✓ Jupyter Lab started"
    fi
}

# Setup and start SwarmUI
setup_swarmui() {
    cd /workspace
    
    # Handle existing SwarmUI installation
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

    # Handle ComfyUI backend if present
    if [ -f "dlbackend/ComfyUI/requirements.txt" ]; then
        log_message "Installing ComfyUI requirements..."
        rm -rf dlbackend/ComfyUI/venv/
        pip install -r dlbackend/ComfyUI/requirements.txt
    fi

    # Launch SwarmUI with explicit host binding
    chmod +x launch-linux.sh
    ./launch-linux.sh --launch_mode none --no-browser --port 7801 --host 0.0.0.0 2>&1 | tee -a "$MAIN_LOG" &
    
    # Check port binding
    sleep 10
    if netstat -tuln | grep :7801 > /dev/null; then
        log_message "✓ SwarmUI started on port 7801"
        return 0
    else
        log_message "✗ ERROR: SwarmUI failed to start"
        return 1
    fi
}

# Main execution
log_message "Starting initialization..."
start_services
setup_dotnet
start_jupyter
setup_swarmui
log_message "Setup complete, tailing logs..."
tail -f "$MAIN_LOG" "$JUPYTER_LOG"