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
echo "Choose a game (put game id):"
read -r GAME_ID

if [ -z "$GAME_ID" ]; then
    echo "No game ID provided"
    exit 1
fi

echo ""
echo "Launching game ID: $GAME_ID..."
echo ""

# Launch with correct Caelus parameters
# Based on supreme-dollop bootstrapper URI_KEY_ARG_MAP
WINEPREFIX="$WINEPREFIX" wine "$CAELUS_EXE" -placeId "$GAME_ID" --play

echo ""
echo "Game launched!"
