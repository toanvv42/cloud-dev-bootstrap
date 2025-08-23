#!/usr/bin/env bash
set -euo pipefail

log() { printf '\n[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

TERRAFORM_VERSION="1.10.3"
ARCH=$(uname -m)

# Determine architecture for Terraform
case "$ARCH" in
  x86_64) TF_ARCH="amd64" ;;
  aarch64|arm64) TF_ARCH="arm64" ;;
  *) log "Unsupported architecture: $ARCH"; exit 1 ;;
esac

log "Installing Terraform and WireGuard on $ARCH architecture..."

# 1) Install prerequisites
if command -v apt-get >/dev/null 2>&1; then
  log "Updating apt and installing prerequisites..."
  sudo apt-get update -y
  sudo apt-get install -y --no-install-recommends curl unzip
else
  log "Non-apt system detected. Please install curl and unzip manually."
  exit 1
fi

# 2) Install Terraform
if command -v terraform >/dev/null 2>&1; then
  log "Terraform already installed: $(terraform version | head -1)"
else
  log "Installing Terraform v${TERRAFORM_VERSION}..."
  
  # Download and install Terraform
  TERRAFORM_ZIP="terraform_${TERRAFORM_VERSION}_linux_${TF_ARCH}.zip"
  curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP}" -o terraform.zip
  
  unzip -q terraform.zip
  sudo mv terraform /usr/local/bin/
  rm terraform.zip LICENSE.txt
  
  # Verify installation
  terraform version
  log "Terraform installed successfully"
fi

# 3) Install WireGuard
if command -v wg >/dev/null 2>&1; then
  log "WireGuard already installed: $(wg --version | head -1)"
else
  log "Installing WireGuard..."
  
  # Install WireGuard packages
  sudo apt-get install -y --no-install-recommends wireguard wireguard-tools
  
  # Load kernel module
  sudo modprobe wireguard
  
  # Verify installation
  wg --version
  log "WireGuard installed successfully"
fi

log "Installation complete!"
log "Available commands:"
log "  - terraform: $(which terraform)"
log "  - wg: $(which wg)"
log "  - wg-quick: $(which wg-quick)"