# RAF RunPod PyTorch Template
<<<<<<< HEAD
# Version: v0.4
# Image: rafrafraf/rnpd-pytorch240:v0.4
=======
# Version: v0.3-dev3
# Image: rafrafraf/rnpd-pytorch240:v0.3-dev3
>>>>>>> 876e196910bd9f86cc0d8586dccfc99e3feaddfe
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    JUPYTER_PORT=8888 \
<<<<<<< HEAD
    JUPYTER_TOKEN=runpod \
=======
>>>>>>> 876e196910bd9f86cc0d8586dccfc99e3feaddfe
    RCLONE_CONFIG_PATH=/root/.config/rclone/rclone.conf \
    RCLONE_CONF_URL="https://www.dropbox.com/scl/fi/n369g4tty5wg7ngh3ha0r/rclone.conf?rlkey=nw39ft02zs6kokmtu3uuc4527&st=67nc2vqg&dl=1" \
    SSH_PORT=22

# System dependencies with better organization and cleanup
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssh-server \
    unzip \
    curl \
    git \
    cron \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # SSH setup
    && mkdir -p /var/run/sshd \
    && mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh \
    && echo 'root:runpod' | chpasswd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config \
    && ssh-keygen -A \
    # Directory setup
    && mkdir -p /workspace \
    && mkdir -p /root/.config/rclone \
    && mkdir -p /root/.huggingface \
    && mkdir -p /root/.jupyter \
    && mkdir -p /etc/ssh \
    && chmod 777 /workspace \
    # Cron setup
    && touch /var/log/cron.log \
    && chmod 0644 /var/log/cron.log

# Install rclone with version pinning
RUN curl -O https://downloads.rclone.org/v1.65.0/rclone-v1.65.0-linux-amd64.zip \
    && unzip rclone-v1.65.0-linux-amd64.zip \
    && cd rclone-v1.65.0-linux-amd64 \
    && cp rclone /usr/bin/ \
    && chmod 755 /usr/bin/rclone \
    && cd .. \
    && rm -rf rclone-v1.65.0-linux-amd64*

# Install minimal Python packages with version pinning
RUN pip install --no-cache-dir \
    jupyterlab==4.1.* \
    notebook==7.1.* \
    ipywidgets==8.1.* \
    ipython==8.12.* \
    numpy==1.26.* \
    pandas==2.2.* \
    matplotlib==3.8.* \
    transformers==4.36.* \
    wandb==0.16.* \
    huggingface_hub==0.20.*

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
<<<<<<< HEAD
ENTRYPOINT ["/bin/bash", "/start.sh"]
=======
ENTRYPOINT ["/bin/bash", "/start.sh"]
>>>>>>> 876e196910bd9f86cc0d8586dccfc99e3feaddfe
