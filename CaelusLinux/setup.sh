#!/bin/bash

# Caelus One-Command Setup
# This script automatically configures everything for you

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Caelus One-Command Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check for Rust
echo -e "${YELLOW}Checking for Rust...${NC}"
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Rust not found. Installing...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
else
    echo -e "${GREEN}✓ Rust found${NC}"
fi

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p ~/.caelus/apk-runtime/apk
mkdir -p ~/.caelus/apk-runtime/libs
mkdir -p ~/.caelus/apk-runtime/cache
mkdir -p ~/.caelus/apk-runtime/config
echo -e "${GREEN}✓ Directories created${NC}"

# Create auto-config
echo -e "${YELLOW}Creating auto-configuration...${NC}"
cat > ~/.caelus/config.toml << EOF
client_url = "https://github.com/caelusinfra/windows-bootstrapper/releases/download/v2026.03.29.1453/CaelusLauncher.exe"
install_dir = "$HOME/.caelus"
wine_prefix = "$HOME/.caelus/wine"
wine_mode = 1
enable_dxvk = true
launch_args = ""
use_apk_runtime = true
apk_path = "$HOME/.caelus/apk-runtime/apk/caelus.apk"
EOF
echo -e "${GREEN}✓ Configuration created${NC}"

# Build the project
echo -e "${YELLOW}Building Caelus bootstrapper...${NC}"
cargo build --release
echo -e "${GREEN}✓ Build complete${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Everything is configured and ready!"
echo ""
echo "IMPORTANT: You need to provide your own Caelus APK file."
echo "The APK file is NOT included in this repository due to GitHub size limits."
echo ""
echo "Next steps:"
echo "1. Download the Caelus APK from the official source"
echo "2. Place it at: ~/.caelus/apk-runtime/apk/caelus.apk"
echo "3. Run: ./target/release/caelus-bootstrapper"
echo ""
echo "The bootstrapper will automatically:"
echo "- Extract the APK"
echo "- Configure the runtime"
echo "- Extract native libraries"
echo "- Create launch scripts"
echo "- Everything is pre-configured for easy use!"
