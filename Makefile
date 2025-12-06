.PHONY: help build up down restart logs clean rebuild shell vnc

# Variables
IMAGE_NAME := act-macos
CONTAINER_NAME := act-macos
VNC_PORT := 5900
WEB_PORT := 8006

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the Docker image
	@echo "Building $(IMAGE_NAME) image..."
	./build.sh

up: ## Start the container
	@echo "Starting $(CONTAINER_NAME)..."
	docker compose up -d
	@echo ""
	@echo "Container started!"
	@echo "  Web viewer: http://localhost:$(WEB_PORT)"
	@echo "  VNC: localhost:$(VNC_PORT)"

down: ## Stop the container
	@echo "Stopping $(CONTAINER_NAME)..."
	docker compose down

restart: ## Restart the container
	@echo "Restarting $(CONTAINER_NAME)..."
	docker compose restart

logs: ## Show container logs
	docker compose logs -f

status: ## Show container status
	@docker compose ps

clean: ## Remove containers, volumes, and storage
	@echo "Cleaning up..."
	docker compose down -v
	@read -p "Remove storage directory? This will delete the macOS disk! (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		rm -rf storage/; \
		echo "Storage removed."; \
	else \
		echo "Storage kept."; \
	fi

rebuild: clean build up ## Clean, rebuild, and start fresh

shell: ## Open a shell in the running container
	docker exec -it $(CONTAINER_NAME) /bin/bash

vnc: ## Show VNC connection info
	@echo "VNC Connection Information:"
	@echo "  Host: localhost"
	@echo "  Port: $(VNC_PORT)"
	@echo "  URL:  vnc://localhost:$(VNC_PORT)"
	@echo ""
	@echo "Web Viewer:"
	@echo "  URL:  http://localhost:$(WEB_PORT)"

info: ## Show system information
	@echo "System Information:"
	@echo "  KVM available: $$([ -e /dev/kvm ] && echo 'Yes' || echo 'No')"
	@echo "  Docker version: $$(docker --version)"
	@echo "  Docker Compose version: $$(docker compose version)"
	@echo ""
	@echo "Container Status:"
	@docker ps -a --filter "name=$(CONTAINER_NAME)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

prune: ## Remove unused Docker resources
	@echo "Pruning Docker system..."
	docker system prune -f

install-deps: ## Install system dependencies (Linux only)
	@echo "Installing dependencies..."
	@if [ "$$(uname)" = "Linux" ]; then \
		sudo apt-get update && \
		sudo apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils; \
		sudo usermod -aG kvm,libvirt $$USER; \
		echo "Dependencies installed. Please log out and log back in."; \
	else \
		echo "This target is for Linux only."; \
	fi
