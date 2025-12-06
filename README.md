# act-macos

A macOS Docker container optimized for running [act](https://github.com/nektos/act) (GitHub Actions locally) with docker-in-docker support. Based on [dockur/macos](https://github.com/dockur/macos).

## Overview

This project provides a containerized macOS environment that can run GitHub Actions locally using the act tool. It combines the power of macOS virtualization with the convenience of Docker containers.

### Features

- macOS 15 (Sequoia) running in Docker
- KVM/QEMU virtualization for performance
- VNC and web-based access
- Docker-in-Docker support for act
- Persistent storage
- Easy deployment with Docker Compose

### Use Cases

- Test GitHub Actions workflows locally on macOS
- Run macOS builds in CI/CD pipelines
- Develop and test macOS applications in isolated environments
- Run macOS-specific tools and scripts in containers

## Prerequisites

### System Requirements

- **CPU**: x86_64 processor with virtualization support (Intel VT-x or AMD-V)
- **RAM**: Minimum 8GB available (16GB+ recommended)
- **Disk**: At least 150GB free space
- **OS**: Linux with KVM support or Windows 11 with Docker Desktop

### Software Requirements

- Docker Engine 20.10+ or Docker Desktop
- Docker Compose 2.0+
- KVM support (Linux) - check with: `kvm-ok` or `ls -l /dev/kvm`

### Enable Virtualization

**Linux:**
```bash
# Check if KVM is available
ls -l /dev/kvm

# If not available, enable virtualization in BIOS
# Then load KVM modules
sudo modprobe kvm
sudo modprobe kvm_intel  # For Intel CPUs
# or
sudo modprobe kvm_amd    # For AMD CPUs
```

**macOS/Windows:**
- Docker Desktop includes necessary virtualization support
- Ensure virtualization is enabled in your system BIOS/UEFI

## Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd act-macos
```

### 2. Build the Image

Using the build script:
```bash
./build.sh
```

Or using Docker Compose:
```bash
docker compose build
```

Or using Docker directly:
```bash
docker build -t act-macos:latest .
```

### 3. Run the Container

Using Docker Compose (recommended):
```bash
docker compose up -d
```

Or using Docker directly:
```bash
docker run -d \
  --name act-macos \
  --device=/dev/kvm \
  --device=/dev/net/tun \
  --cap-add NET_ADMIN \
  -p 5900:5900 \
  -p 8006:8006 \
  -v $(pwd)/storage:/storage \
  -v $(pwd)/shared:/shared \
  act-macos:latest
```

### 4. Access macOS

**Web Browser** (Recommended):
- Open http://localhost:8006
- No additional software required

**VNC Client:**
- Connect to `localhost:5900`
- Use any VNC client (TightVNC, RealVNC, etc.)

### 5. Install Docker and act Inside macOS

Once macOS is booted and you're logged in:

1. Open Terminal in macOS
2. Copy the install script to the VM via the shared folder (see below)
3. Run the installation script:

```bash
# If you mounted the shared folder
bash /Volumes/Shared/scripts/install-docker.sh

# Or download and run directly
curl -fsSL https://raw.githubusercontent.com/<your-repo>/main/scripts/install-docker.sh | bash
```

This will install:
- Homebrew
- Docker Desktop for Mac
- act CLI tool

## Configuration

### Environment Variables

Configure in `compose.yml` or pass to `docker run`:

| Variable | Default | Description |
|----------|---------|-------------|
| `VERSION` | `15` | macOS version (11-15) |
| `DISK_SIZE` | `128G` | Virtual disk size |
| `RAM_SIZE` | `8G` | RAM allocation |
| `CPU_CORES` | `4` | Number of CPU cores |
| `DHCP` | `Y` | Enable DHCP networking |

### Customizing Resources

Edit `compose.yml`:

```yaml
environment:
  VERSION: "15"
  DISK_SIZE: "256G"    # Increase disk space
  RAM_SIZE: "16G"      # Increase RAM
  CPU_CORES: "8"       # More CPU cores
```

### Sharing Files Between Host and Container

Files placed in the `./shared` directory on your host will be accessible inside the container:

```bash
# On your host
echo "Hello from host" > ./shared/test.txt

# Inside the container
cat /shared/test.txt
```

To access from macOS guest, you'll need to set up file sharing through the container or use network shares.

## Using act Inside macOS

Once Docker and act are installed inside the macOS VM:

### 1. Navigate to Your Project

```bash
cd /path/to/your/github/project
```

### 2. List Available Workflows

```bash
act -l
```

### 3. Run a Workflow

```bash
# Run default workflow
act

# Run specific job
act -j test

# Run on specific event
act push
act pull_request
```

### 4. Configure Platform Images

For better compatibility with GitHub Actions:

```bash
# Use full Ubuntu image for ubuntu-latest
act -P ubuntu-latest=catthehacker/ubuntu:full-latest

# Create .actrc file for persistent configuration
cat > ~/.actrc << EOF
-P ubuntu-latest=catthehacker/ubuntu:full-latest
-P ubuntu-22.04=catthehacker/ubuntu:full-22.04
-P ubuntu-20.04=catthehacker/ubuntu:full-20.04
EOF
```

## Troubleshooting

### Container Won't Start

**Error: `/dev/kvm not found`**
```bash
# Check if KVM module is loaded
lsmod | grep kvm

# Load KVM module
sudo modprobe kvm_intel  # or kvm_amd
```

**Error: `permission denied accessing /dev/kvm`**
```bash
# Add your user to the kvm group
sudo usermod -aG kvm $USER

# Log out and log back in, then check
groups | grep kvm
```

### macOS Won't Boot

- Ensure you have allocated enough resources (8GB RAM minimum)
- Check if virtualization is enabled in BIOS
- Wait longer - first boot can take 10-15 minutes
- Check logs: `docker logs act-macos`

### Docker Desktop Won't Install in macOS VM

- Ensure macOS has internet connectivity
- Try rebooting the VM
- Manually download Docker Desktop from https://www.docker.com/products/docker-desktop

### Performance Issues

- Increase RAM and CPU allocation in `compose.yml`
- Ensure KVM acceleration is working
- Use SSD storage for better I/O performance
- Close unnecessary applications on host

### act Fails to Run Workflows

- Ensure Docker Desktop is running in macOS VM
- Check Docker daemon: `docker ps`
- Verify act installation: `act --version`
- Try with `-v` flag for verbose output: `act -v`

## Advanced Usage

### Building for Different Platforms

```bash
./build.sh --platform linux/amd64
```

### Using Custom macOS Version

```yaml
environment:
  VERSION: "14"  # Use macOS Sonoma instead
```

### Port Forwarding

To access services running inside macOS from your host:

1. Add port mappings to `compose.yml`:
```yaml
ports:
  - "5900:5900"
  - "8006:8006"
  - "8080:8080"  # Add custom ports
```

2. Configure port forwarding in macOS network settings if needed

### Persistent Storage

All data in `/storage` is persistent across container restarts:
- macOS disk image
- User data
- Applications

To reset:
```bash
docker compose down
rm -rf storage/
docker compose up -d
```

## Development

### Project Structure

```
act-macos/
├── Dockerfile              # Main container definition
├── compose.yml             # Compose configuration
├── build.sh                # Build helper script
├── scripts/                # Setup scripts
│   └── install-docker.sh   # Install Docker and act in macOS
├── storage/                # Persistent macOS data (created on first run)
├── shared/                 # Shared files between host and container
└── README.md               # This file
```

### Modifying the Build

1. Edit `Dockerfile` for container-level changes
2. Edit `scripts/install-docker.sh` for macOS-level setup
3. Edit `compose.yml` for runtime configuration
4. Rebuild: `docker compose build`

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Resources

- [act - Run GitHub Actions Locally](https://github.com/nektos/act)
- [dockur/macos](https://github.com/dockur/macos)
- [QEMU Documentation](https://www.qemu.org/documentation/)
- [Docker Documentation](https://docs.docker.com/)

## License

This project inherits the license from [dockur/macos](https://github.com/dockur/macos). Please refer to their repository for license details.

## Acknowledgments

- [dockur/macos](https://github.com/dockur/macos) - Base macOS container
- [nektos/act](https://github.com/nektos/act) - GitHub Actions local runner
- [OSX-KVM](https://github.com/kholia/OSX-KVM) - macOS virtualization project

## Support

For issues and questions:
- Check the [Troubleshooting](#troubleshooting) section
- Review [dockur/macos issues](https://github.com/dockur/macos/issues)
- Review [act issues](https://github.com/nektos/act/issues)
- Create an issue in this repository
