#!/bin/bash

# Simple Caelus Linux Installer
# Just downloads CaelusLauncher.exe and runs it with Wine

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
CLIENT_URL="https://github.com/caelusinfra/windows-bootstrapper/releases/download/v2026.03.29.1453/CaelusLauncher.exe"
INSTALL_DIR="$HOME/.caelus"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Caelus Linux Simple Installer${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check for Wine
if ! command -v wine &> /dev/null; then
    echo -e "${RED}Error: Wine not found${NC}"
    echo "Please install Wine first:"
    echo "  Ubuntu/Debian: sudo apt install wine64"
    echo "  Fedora: sudo dnf install wine"
    echo "  Arch: sudo pacman -S wine"
    exit 1
fi

echo -e "${GREEN}✓ Wine found${NC}"

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download CaelusLauncher.exe
echo -e "${YELLOW}Downloading CaelusLauncher.exe...${NC}"
curl -L -o "$INSTALL_DIR/CaelusLauncher.exe" "$CLIENT_URL"

echo -e "${GREEN}✓ Downloaded to $INSTALL_DIR/CaelusLauncher.exe${NC}"

# Launch with Wine
echo -e "${YELLOW}Launching CaelusLauncher.exe with Wine...${NC}"
WINEPREFIX="$HOME/.wine" wine "$INSTALL_DIR/CaelusLauncher.exe"

echo ""
echo -e "${GREEN}Done! Caelus should now be running.${NC}"
