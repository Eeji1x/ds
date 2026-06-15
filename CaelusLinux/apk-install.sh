#!/bin/bash

# Caelus APK Runtime Installer
# This script sets up the APK-based runtime for Caelus on Linux

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
INSTALL_DIR="$HOME/.caelus"
APK_DIR="$INSTALL_DIR/apk-runtime/apk"
CONFIG_DIR="$INSTALL_DIR/apk-runtime/config"
CACHE_DIR="$INSTALL_DIR/apk-runtime/cache"
RUNTIME_DIR="$INSTALL_DIR/apk-runtime/runtime"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Caelus APK Runtime Installer${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Create directories
echo -e "${YELLOW}Creating directory structure...${NC}"
mkdir -p "$APK_DIR" "$CONFIG_DIR" "$CACHE_DIR" "$RUNTIME_DIR"
echo -e "${GREEN}✓ Directories created${NC}"

# Check for APK
echo ""
echo -e "${YELLOW}Checking for Caelus APK...${NC}"
if [ -f "$APK_DIR/caelus.apk" ]; then
    echo -e "${GREEN}✓ Caelus APK found${NC}"
else
    echo -e "${RED}✗ Caelus APK not found${NC}"
    echo "Please place your Caelus APK at: $APK_DIR/caelus.apk"
    echo ""
    echo "You can get the Caelus APK from the official source."
    exit 1
fi

# Update config to use APK runtime
echo ""
echo -e "${YELLOW}Updating configuration...${NC}"
CONFIG_FILE="$INSTALL_DIR/config.toml"

if [ -f "$CONFIG_FILE" ]; then
    # Update existing config
    sed -i 's/use_apk_runtime = false/use_apk_runtime = true/' "$CONFIG_FILE" 2>/dev/null || true
    echo -e "${GREEN}✓ Configuration updated${NC}"
else
    # Create new config
    cat > "$CONFIG_FILE" << EOF
client_url = "https://github.com/caelusinfra/windows-bootstrapper/releases/download/v2026.03.29.1453/CaelusLauncher.exe"
install_dir = "$INSTALL_DIR"
wine_prefix = "$INSTALL_DIR/wine"
wine_mode = 1
enable_dxvk = true
launch_args = ""
use_apk_runtime = true
apk_path = "$APK_DIR/caelus.apk"
EOF
    echo -e "${GREEN}✓ Configuration created${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  APK Runtime Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "APK runtime is now configured."
echo "To use it, run the Rust bootstrapper:"
echo "  cargo run --release"
echo ""
echo "Or build and run:"
echo "  cargo build --release"
echo "  ./target/release/caelus-bootstrapper"
