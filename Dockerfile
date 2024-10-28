# RAF RunPod PyTorch Template
# Version: v0.2
# Image: rafrafraf/rnpd-pytorch240:v0.2
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    JUPYTER_PORT=8888 \
    RCLONE_CONFIG_PATH=/root/.config/rclone/rclone.conf \
    SSH_PORT=22

# System dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    openssh-server \
    unzip \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir -p /var/run/sshd \
    && mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh \
    && echo 'root:runpod' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config \
    && ssh-keygen -A

# Directory setup
RUN mkdir -p /workspace/.config/rclone \
    && mkdir -p /root/.huggingface \
    && mkdir -p /root/.jupyter \
    && mkdir -p /etc/ssh \
    && touch /workspace/jupyter.log \
    && chmod 777 /workspace/jupyter.log

# Install rclone
RUN curl -O https://downloads.rclone.org/v1.65.0/rclone-v1.65.0-linux-amd64.zip \
    && unzip rclone-v1.65.0-linux-amd64.zip \
    && cd rclone-v1.65.0-linux-amd64 \
    && cp rclone /usr/bin/ \
    && chmod 755 /usr/bin/rclone \
    && cd .. \
    && rm -rf rclone-v1.65.0-linux-amd64*

# Install Python packages
RUN pip install --no-cache-dir \
    jupyterlab==4.1.* \
    wandb==0.16.* \
    huggingface_hub==0.20.* \
    notebook==7.1.* \
    ipywidgets==8.1.* \
    numpy==1.26.* \
    pandas==2.2.* \
    matplotlib==3.8.* \
    seaborn==0.13.* \
    scikit-learn==1.4.* \
    tqdm==4.66.* \
    transformers==4.36.* \
    datasets==2.16.* \
    black==24.1.* \
    pylint==3.0.* \
    ipython==8.12.*

# Create common ML directories
RUN mkdir -p /workspace/data \
    && mkdir -p /workspace/models \
    && mkdir -p /workspace/notebooks \
    && mkdir -p /workspace/scripts \
    && mkdir -p /workspace/logs \
    && mkdir -p /workspace/outputs \
    && chmod -R 777 /workspace

# Copy startup script
COPY start.sh /
RUN chmod +x /start.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8888/api || exit 1

# Ports
EXPOSE 8888 22

# Working directory
WORKDIR /workspace

# Entry point
ENTRYPOINT ["/bin/bash", "/start.sh"]