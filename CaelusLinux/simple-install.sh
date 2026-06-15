#!/bin/bash

# Caelus Linux Installer
# Downloads CaelusLauncher.exe and sets up Linux integration

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
CLIENT_URL="https://github.com/caelusinfra/windows-bootstrapper/releases/download/v2026.03.29.1453/CaelusLauncher.exe"
INSTALL_DIR="$HOME/.caelus"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
SCRIPT_PATH="$INSTALL_DIR/caelus-launcher.sh"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Caelus Linux Installer${NC}"
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

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download CaelusLauncher.exe
echo -e "${YELLOW}Downloading CaelusLauncher.exe...${NC}"
curl -L -o "$INSTALL_DIR/CaelusLauncher.exe" "$CLIENT_URL"

echo -e "${GREEN}✓ Downloaded to $INSTALL_DIR/CaelusLauncher.exe${NC}"

# Create launcher script
echo -e "${YELLOW}Creating launcher script...${NC}"
cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash
# Caelus Launcher Script
INSTALL_DIR="$HOME/.caelus"

# Handle caelus:// URIs
if [[ "$1" == caelus://* ]]; then
    # Extract URI parameters and convert to command line args
    URI="$1"
    ARGS=()
    
    # Parse URI parameters (format: caelus://key:value+key2:value2)
    # Remove caelus:// prefix
    PARAMS="${URI#caelus://}"
    
    # Split by + and parse each parameter
    IFS='+' read -ra PARAM_ARRAY <<< "$PARAMS"
    for param in "${PARAM_ARRAY[@]}"; do
        if [[ "$param" == *:* ]]; then
            key="${param%%:*}"
            value="${param#*:}"
            
            # Map URI keys to command line arguments
            case "$key" in
                launchmode)
                    ARGS+=("--$value")
                    ;;
                gameinfo)
                    ARGS+=("-t" "$value")
                    ;;
                placelauncherurl)
                    ARGS+=("-j" "$value")
                    ;;
                launchtime)
                    ARGS+=("--launchtime=$value")
                    ;;
                task)
                    ARGS+=("-task" "$value")
                    ;;
                placeId)
                    ARGS+=("-placeId" "$value")
                    ;;
                universeId)
                    ARGS+=("-universeId" "$value")
                    ;;
                userId)
                    ARGS+=("-userId" "$value")
                    ;;
                *)
                    # Pass unknown parameters as-is
                    ARGS+=("$key=$value")
                    ;;
            esac
        fi
    done
    
    # Launch with parsed arguments
    wine "$INSTALL_DIR/CaelusLauncher.exe" "${ARGS[@]}"
else
    # Launch normally with provided arguments
    wine "$INSTALL_DIR/CaelusLauncher.exe" "$@"
fi
EOF

chmod +x "$SCRIPT_PATH"
echo -e "${GREEN}✓ Launcher script created${NC}"

# Create desktop entry
echo -e "${YELLOW}Creating desktop entry...${NC}"
mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/caelus.desktop" << EOF
[Desktop Entry]
Name=Caelus
Comment=Caelus Linux Client
Exec=$SCRIPT_PATH %u
Type=Application
Terminal=false
MimeType=x-scheme-handler/caelus;
Categories=Game;
Icon=caelus
EOF

echo -e "${GREEN}✓ Desktop entry created${NC}"

# Register MIME type
echo -e "${YELLOW}Registering MIME type...${NC}"
xdg-mime default caelus.desktop x-scheme-handler/caelus 2>/dev/null || true
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
echo -e "${GREEN}✓ MIME type registered${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Caelus has been installed to: $INSTALL_DIR"
echo "Desktop entry created: $DESKTOP_DIR/caelus.desktop"
echo ""
echo "You can now:"
echo "  - Launch Caelus from your application menu"
echo "  - Use caelus:// URIs to join games"
echo "  - Run manually: $SCRIPT_PATH"
echo ""
echo -e "${YELLOW}Launching Caelus now...${NC}"
"$SCRIPT_PATH"
