#!/bin/bash
# Build script for act-macos image

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
IMAGE_NAME="act-macos"
IMAGE_TAG="latest"
PLATFORM=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        --platform)
            PLATFORM="--platform $2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -n, --name NAME       Image name (default: act-macos)"
            echo "  -t, --tag TAG         Image tag (default: latest)"
            echo "  --platform PLATFORM   Target platform (e.g., linux/amd64)"
            echo "  -h, --help            Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                           # Build with defaults"
            echo "  $0 -t v1.0.0                # Build with custom tag"
            echo "  $0 --platform linux/amd64   # Build for specific platform"
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            exit 1
            ;;
    esac
done

FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"

echo -e "${GREEN}======================================"
echo "Building act-macos Docker Image"
echo -e "======================================${NC}"
echo -e "Image: ${YELLOW}${FULL_IMAGE_NAME}${NC}"
echo -e "Platform: ${YELLOW}${PLATFORM:-default}${NC}"
echo ""

# Check prerequisites
echo -e "${GREEN}Checking prerequisites...${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

# Check if KVM is available (Linux only)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ ! -e /dev/kvm ]; then
        echo -e "${YELLOW}Warning: /dev/kvm not found. KVM acceleration may not be available.${NC}"
        echo -e "${YELLOW}Make sure virtualization is enabled in your BIOS.${NC}"
    else
        echo -e "${GREEN}KVM device found: /dev/kvm${NC}"
    fi
fi

# Create required directories
echo -e "${GREEN}Creating required directories...${NC}"
mkdir -p storage shared

# Build the image
echo ""
echo -e "${GREEN}Building Docker image...${NC}"
docker build ${PLATFORM} -t "${FULL_IMAGE_NAME}" .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}======================================"
    echo "Build successful!"
    echo -e "======================================${NC}"
    echo -e "Image: ${YELLOW}${FULL_IMAGE_NAME}${NC}"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "1. Run with Docker Compose:"
    echo -e "   ${YELLOW}docker-compose up -d${NC}"
    echo ""
    echo "2. Or run manually:"
    echo -e "   ${YELLOW}docker run -d --name act-macos \\${NC}"
    echo -e "   ${YELLOW}  --device=/dev/kvm \\${NC}"
    echo -e "   ${YELLOW}  --cap-add NET_ADMIN \\${NC}"
    echo -e "   ${YELLOW}  -p 5900:5900 -p 8006:8006 \\${NC}"
    echo -e "   ${YELLOW}  -v \$(pwd)/storage:/storage \\${NC}"
    echo -e "   ${YELLOW}  ${FULL_IMAGE_NAME}${NC}"
    echo ""
    echo "3. Access via VNC on port 5900 or web browser at http://localhost:8006"
else
    echo ""
    echo -e "${RED}======================================"
    echo "Build failed!"
    echo -e "======================================${NC}"
    exit 1
fi
