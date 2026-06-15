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
WINEPREFIX="$HOME/.caelus/wine"
CAELUS_INSTALLER="$INSTALL_DIR/CaelusLauncher.exe"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"
SCRIPT_PATH="$INSTALL_DIR/caelus-launcher.sh"
LOCAL_LAUNCHER="./caelus.sh"

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
curl -L -o "$CAELUS_INSTALLER" "$CLIENT_URL"

echo -e "${GREEN}✓ Downloaded to $CAELUS_INSTALLER${NC}"

# Initialize Wine prefix
echo -e "${YELLOW}Initializing Wine prefix...${NC}"
if [ ! -d "$WINEPREFIX" ]; then
    WINEPREFIX="$WINEPREFIX" wineboot --init
    echo -e "${GREEN}✓ Wine prefix created${NC}"
else
    echo -e "${GREEN}✓ Wine prefix already exists${NC}"
fi

# Run the installer to install Caelus
echo -e "${YELLOW}Installing Caelus (this may take a while)...${NC}"
WINEPREFIX="$WINEPREFIX" wine "$CAELUS_INSTALLER"
echo -e "${GREEN}✓ Caelus installation complete${NC}"

# Find the installed Caelus executable
echo -e "${YELLOW}Finding Caelus game executable...${NC}"
CAELUS_EXE=$(find "$WINEPREFIX/drive_c" -name "CaelusPlayer.exe" -o -name "Caelus.exe" 2>/dev/null | head -n 1)

if [ -z "$CAELUS_EXE" ]; then
    echo -e "${RED}Could not find Caelus executable. Using installer as fallback.${NC}"
    CAELUS_EXE="$CAELUS_INSTALLER"
else
    echo -e "${GREEN}✓ Found Caelus executable: $CAELUS_EXE${NC}"
fi

# Create launcher script
echo -e "${YELLOW}Creating launcher script...${NC}"
cat > "$SCRIPT_PATH" << EOF
#!/bin/bash
# Caelus Launcher Script
INSTALL_DIR="$HOME/.caelus"
WINEPREFIX="$HOME/.caelus/wine"
CAELUS_EXE="$CAELUS_EXE"

# Handle caelus:// URIs
if [[ "\$1" == caelus://* ]]; then
    # Extract URI parameters and convert to command line args
    URI="\$1"
    ARGS=()
    
    # Parse URI parameters (format: caelus://key:value+key2:value2)
    # Remove caelus:// prefix
    PARAMS="\${URI#caelus://}"
    
    # Split by + and parse each parameter
    IFS='+' read -ra PARAM_ARRAY <<< "\$PARAMS"
    for param in "\${PARAM_ARRAY[@]}"; do
        if [[ "\$param" == *:* ]]; then
            key="\${param%%:*}"
            value="\${param#*:}"
            
            # Map URI keys to command line arguments
            case "\$key" in
                launchmode)
                    ARGS+=("--\$value")
                    ;;
                gameinfo)
                    ARGS+=("-t" "\$value")
                    ;;
                placelauncherurl)
                    ARGS+=("-j" "\$value")
                    ;;
                launchtime)
                    ARGS+=("--launchtime=\$value")
                    ;;
                task)
                    ARGS+=("-task" "\$value")
                    ;;
                placeId)
                    ARGS+=("-placeId" "\$value")
                    ;;
                universeId)
                    ARGS+=("-universeId" "\$value")
                    ;;
                userId)
                    ARGS+=("-userId" "\$value")
                    ;;
                *)
                    # Pass unknown parameters as-is
                    ARGS+=("\$key=\$value")
                    ;;
            esac
        fi
    done
    
    # Launch with parsed arguments
    echo "Launching Caelus with game parameters..."
    WINEPREFIX="\$WINEPREFIX" wine "\$CAELUS_EXE" "\${ARGS[@]}"
else
    # Launch normally with provided arguments
    echo "Launching Caelus..."
    WINEPREFIX="\$WINEPREFIX" wine "\$CAELUS_EXE" "\$@"
fi
EOF

chmod +x "$SCRIPT_PATH"
echo -e "${GREEN}✓ Launcher script created${NC}"

# Create simple local launcher in current directory
echo -e "${YELLOW}Creating local launcher script...${NC}"
cat > "$LOCAL_LAUNCHER" << 'EOF'
#!/bin/bash
# Caelus Local Launcher
# Run this script to launch Caelus games

WINEPREFIX="$HOME/.caelus/wine"
INSTALL_DIR="$HOME/.caelus"

# Find the Caelus executable
CAELUS_EXE=$(find "$WINEPREFIX/drive_c" -name "CaelusPlayer.exe" -o -name "Caelus.exe" 2>/dev/null | head -n 1)

if [ -z "$CAELUS_EXE" ]; then
    echo "Caelus not found. Please run the installer first."
    exit 1
fi

echo "=========================================="
echo "       Caelus Game Launcher"
echo "=========================================="
echo ""
echo "Choose a game (put game id):"
read -r GAME_ID

if [ -z "$GAME_ID" ]; then
    echo "No game ID provided"
    exit 1
fi

echo ""
echo "Launching game ID: $GAME_ID..."
echo ""

# Launch with game parameters
WINEPREFIX="$WINEPREFIX" wine "$CAELUS_EXE" --game="$GAME_ID" --launchmode=play

echo ""
echo "Game launched!"
EOF

chmod +x "$LOCAL_LAUNCHER"
echo -e "${GREEN}✓ Local launcher created: $LOCAL_LAUNCHER${NC}"

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
echo "Local launcher created: $LOCAL_LAUNCHER"
echo ""
echo "You can now:"
echo "  - Run ./caelus.sh to launch games (enter any game ID)"
echo "  - Launch Caelus from your application menu"
echo "  - Use caelus:// URIs to join games"
echo "  - Run manually: $SCRIPT_PATH"
echo ""

# Ask user if they want to launch Caelus now
echo -e "${YELLOW}Do you want to launch the game selector now? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Launching game selector...${NC}"
    "$LOCAL_LAUNCHER"
else
    echo "You can launch games later by running: $LOCAL_LAUNCHER"
fi
