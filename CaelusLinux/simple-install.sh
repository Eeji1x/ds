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

# Check Wine version
WINE_VERSION=$(wine --version)
echo "Wine version: $WINE_VERSION"

# Warn if Wine version is too old
if echo "$WINE_VERSION" | grep -q "wine-11\|wine-10\|wine-9\|wine-8\|wine-7\|wine-6\|wine-5\|wine-4\|wine-3\|wine-2\|wine-1"; then
    echo -e "${YELLOW}WARNING: Wine version is very old. Consider updating to Wine 8.0 or later for better compatibility.${NC}"
    echo "On Ubuntu/Debian: sudo apt install --install-recommends winehq-stable"
    echo "On Fedora: sudo dnf install wine"
    echo "On Arch: sudo pacman -S wine"
    echo ""
fi

# Check for winetricks
if ! command -v winetricks &> /dev/null; then
    echo -e "${YELLOW}Winetricks not found. Installing...${NC}"
    if command -v apt &> /dev/null; then
        sudo apt install -y winetricks
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y winetricks
    elif command -v pacman &> /dev/null; then
        sudo pacman -S winetricks
    else
        echo -e "${YELLOW}Please install winetricks manually${NC}"
    fi
fi

echo -e "${GREEN}✓ Winetricks found${NC}"

# Install required Wine components
echo -e "${YELLOW}Installing required Wine components...${NC}"
WINEPREFIX="$HOME/.caelus/wine" winetricks -q vcrun2019
WINEPREFIX="$HOME/.caelus/wine" winetricks -q dotnet48
WINEPREFIX="$HOME/.caelus/wine" winetricks -q msxml6
WINEPREFIX="$HOME/.caelus/wine" winetricks -q corefonts

echo -e "${GREEN}✓ Wine components installed${NC}"

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download CaelusLauncher.exe
echo -e "${YELLOW}Downloading CaelusLauncher.exe...${NC}"
curl -L -o "$INSTALL_DIR/CaelusLauncher.exe" "$CLIENT_URL"

echo -e "${GREEN}✓ Downloaded to $INSTALL_DIR/CaelusLauncher.exe${NC}"

# Launch with Wine
echo -e "${YELLOW}Launching CaelusLauncher.exe with Wine...${NC}"
WINEPREFIX="$HOME/.caelus/wine" wine "$INSTALL_DIR/CaelusLauncher.exe"

echo ""
echo -e "${GREEN}Done! Caelus should now be running.${NC}"
