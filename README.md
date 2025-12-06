# act-macos

macOS Docker container for running [act](https://github.com/nektos/act) (GitHub Actions locally) with docker-in-docker support. Based on [dockur/macos](https://github.com/dockur/macos).

## Features

- macOS 15 (Sequoia) running in Docker
- KVM/QEMU virtualization
- VNC and web access
- Docker-in-Docker for act
- Persistent storage

## Prerequisites

- **CPU**: x86_64 (Intel/AMD) or ARM64 (Apple Silicon) with virtualization
- **RAM**: 8GB minimum (16GB+ recommended)
- **Disk**: 150GB free space
- **OS**: Linux with KVM, macOS, or Windows 11 with Docker Desktop
- **Software**: Docker Engine 20.10+ and Docker Compose 2.0+

> **Note**: Images are available for both `linux/amd64` and `linux/arm64` platforms. Docker will automatically pull the correct architecture for your system.

### Enable KVM (Linux only)

```bash
# Check KVM availability
ls -l /dev/kvm

# Load KVM modules if needed
sudo modprobe kvm_intel  # Intel
sudo modprobe kvm_amd    # AMD
```

## Quick Start

### 1. Pull and Run

```bash
docker compose up -d
```

### 2. Access macOS

- **Web**: http://localhost:8006
- **VNC**: localhost:5900

First boot takes 10-15 minutes. Subsequent boots are faster (1-2 minutes).

### 3. Install Docker and act

Once macOS boots, open Terminal and run:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker Desktop
brew install --cask docker
open -a Docker

# Install act
brew install act
```

### 4. Run GitHub Actions Locally

```bash
cd /path/to/your/project
act -l                    # List workflows
act                       # Run default workflow
act -j test              # Run specific job
```

## Configuration

Edit `compose.yml` to customize:

```yaml
environment:
  VERSION: "15"        # macOS version (11-15)
  DISK_SIZE: "128G"    # Disk size
  RAM_SIZE: "8G"       # RAM
  CPU_CORES: "4"       # CPU cores
```

## Common Commands

```bash
# Start
make up

# Stop
make down

# View logs
make logs

# Clean (removes storage)
make clean

# Rebuild
make rebuild
```

## Troubleshooting

### Container won't start

```bash
# Check KVM
lsmod | grep kvm

# Fix permissions
sudo usermod -aG kvm $USER
```

### macOS won't boot

- Ensure 8GB RAM minimum
- Enable virtualization in BIOS
- Wait 10-15 minutes on first boot
- Check logs: `docker logs act-macos`

### Performance issues

- Increase RAM/CPU in `compose.yml`
- Use SSD storage
- Ensure KVM acceleration is enabled

## Building Locally

```bash
# Build
./build.sh

# Build with registry
./build.sh -r ghcr.io/your-username

# Build specific platform
./build.sh --platform linux/amd64
```

## Resources

- [act Documentation](https://github.com/nektos/act)
- [dockur/macos](https://github.com/dockur/macos)
- [GitHub Actions Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)

## License

Inherits license from [dockur/macos](https://github.com/dockur/macos).
