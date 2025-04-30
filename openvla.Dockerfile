FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-devel

# Set up SSH server
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    curl \
    tmux \
    git \
    wget \
    python3-pip \
    python3-dev \
    build-essential \
    ninja-build \
    ffmpeg \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgl1-mesa-glx

# SSH configuration
ARG PORT=65142
RUN echo "Port ${PORT}" >> /etc/ssh/sshd_config
RUN mkdir -p /run/sshd
RUN ssh-keygen -A
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Set CUDA_HOME environment variable
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}

# Python dependencies
RUN pip install --upgrade pip

# Core dependencies for OpenVLA
RUN pip install \
    timm==0.9.10 \
    tokenizers==0.19.1 \
    torchvision==0.17.0 \
    torchaudio==2.2.0 \
    transformers==4.40.1 \
    accelerate>=0.25.0 \
    draccus==0.8.0 \
    einops \
    huggingface_hub \
    json-numpy \
    jsonlines \
    matplotlib \
    peft==0.11.1 \
    protobuf \
    rich \
    sentencepiece==0.1.99 \
    wandb \
    tensorflow==2.15.0 \
    tensorflow_datasets==4.9.3 \
    tensorflow_graphics==2021.12.3

# Install Flash Attention (important for OpenVLA)
RUN pip install packaging ninja
RUN pip install "flash-attn==2.5.5" --no-build-isolation

# LIBERO specific dependencies
RUN pip install \
    imageio[ffmpeg] \
    robosuite==1.4.1 \
    bddl \
    easydict \
    cloudpickle \
    gym

# Install dlimp for OpenVLA
RUN pip install --no-deps git+https://github.com/moojink/dlimp_openvla

# Create a working directory for the codebase
WORKDIR /openvla

# Expose the SSH port
EXPOSE ${PORT}

# Start SSH server
CMD ["/usr/sbin/sshd", "-D", "-e"]
