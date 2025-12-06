#!/bin/bash
# Script to install Docker Desktop and act inside macOS VM
# This should be run inside the macOS guest after it boots

set -e

echo "======================================"
echo "Installing Docker Desktop for Mac..."
echo "======================================"

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Install Docker Desktop
echo "Installing Docker via Homebrew..."
brew install --cask docker

# Start Docker Desktop
echo "Starting Docker Desktop..."
open -a Docker

# Wait for Docker to start
echo "Waiting for Docker daemon to start..."
while ! docker info &> /dev/null; do
    echo "Waiting for Docker..."
    sleep 5
done

echo "Docker is ready!"

# Install act
echo "======================================"
echo "Installing act (GitHub Actions tool)..."
echo "======================================"
brew install act

# Configure act
echo "Configuring act..."
mkdir -p ~/.actrc

# Verify installations
echo "======================================"
echo "Installation complete!"
echo "======================================"
echo "Docker version:"
docker --version

echo ""
echo "act version:"
act --version

echo ""
echo "======================================"
echo "Setup Instructions:"
echo "======================================"
echo "1. Configure act with your preferred settings:"
echo "   act --list"
echo ""
echo "2. Run GitHub Actions locally:"
echo "   act -j <job-name>"
echo ""
echo "3. For large runners, you may want to configure:"
echo "   act -P ubuntu-latest=catthehacker/ubuntu:full-latest"
echo "======================================"
