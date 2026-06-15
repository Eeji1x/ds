#!/bin/bash
# Caelus Linux Launcher
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
echo "Choose an option:"
echo "1. Launch Caelus (no specific game)"
echo "2. Join specific game (requires game ID)"
echo ""
read -r CHOICE

case "$CHOICE" in
    1)
        echo ""
        echo "Launching Caelus..."
        WINEPREFIX="$WINEPREFIX" wine "$CAELUS_EXE"
        ;;
    2)
        echo ""
        echo "Enter game ID:"
        read -r GAME_ID

        if [ -z "$GAME_ID" ]; then
            echo "No game ID provided"
            exit 1
        fi

        echo ""
        echo "Attempting to join game: $GAME_ID..."
        echo ""

        # Try different parameter combinations
        # First try as placeId
        echo "Trying as placeId..."
        WINEPREFIX="$WINEPREFIX" wine "$CAELUS_EXE" -placeId "$GAME_ID" --play
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Game launched!"
