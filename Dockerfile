FROM dockurr/macos:latest

# Metadata
LABEL maintainer="act-macos"
LABEL description="macOS Docker container optimized for act (GitHub Actions locally) with docker-in-docker support"

# Install essential development tools for GitHub Actions compatibility
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    bash \
    jq \
    unzip \
    zip \
    tar \
    gzip \
    sudo \
    openssh-client \
    gnupg \
    nodejs \
    npm \
    python3 \
    python3-pip \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub Actions runner dependencies
RUN npm install -g yarn

# Environment variables for macOS configuration
ENV VERSION="15" \
    DISK_SIZE="128G" \
    RAM_SIZE="8G" \
    CPU_CORES="4" \
    DHCP="Y"

# Additional environment variables for act support
ENV ACT_VERSION="0.2.68" \
    HOMEBREW_NO_AUTO_UPDATE="1" \
    HOMEBREW_NO_INSTALL_CLEANUP="1"

# Copy additional setup scripts
COPY scripts/ /opt/scripts/

# Volume for persistent storage (including Docker data)
VOLUME ["/storage"]

# Expose ports
# 5900: VNC
# 8006: Web viewer
# 2375: Docker daemon (for act)
EXPOSE 5900 8006 2375

# Use the parent entrypoint
ENTRYPOINT ["/usr/bin/tini", "-s", "/run/entry.sh"]
