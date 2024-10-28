FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

LABEL maintainer="RAF"
LABEL version="v0.1-dev1"
LABEL description="RunPod SwarmUI Template - Development Version"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/root/.local/bin:/root/.dotnet:$PATH
ENV DOTNET_ROOT=/root/.dotnet
ENV SWARM_NO_VENV=true

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    nginx \
    openssh-server \
    python3 \
    python3-pip \
    net-tools \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --no-cache-dir \
    jupyter \
    jupyterlab \
    ipywidgets

# Create workspace with basic permissions
RUN mkdir -p /workspace && \
    chmod 755 /workspace && \
    chown root:root /workspace

# Create additional directories
RUN mkdir -p /workspace/logs && \
    mkdir -p /var/log/cron && \
    chmod -R 755 /workspace/logs

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose ports
EXPOSE 7801 7821-7828 7888 22

WORKDIR /workspace
ENTRYPOINT ["/start.sh"]