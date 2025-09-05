#!/bin/bash

# =================================================================
# Cleanup Script for Docker Wi-Fi Network Isolation
#
# This script removes the Docker macvlan network and the shortcut.
# =================================================================

# --- Configuration ---
NETWORK_NAME="wifi_net"
SHORTCUT_PATH="/usr/local/bin/run_on_wifi"

# --- Pre-flight Check ---
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root. Please use 'sudo'."; exit 1; fi

echo "--- Starting Docker Wi-Fi Network Cleanup ---"

# --- 1. Remove the Docker Network (if it exists) ---
if docker network inspect "$NETWORK_NAME" > /dev/null 2>&1; then
    echo "Removing Docker network '$NETWORK_NAME'..."
    docker network rm "$NETWORK_NAME"
else
    echo "Docker network '$NETWORK_NAME' not found. Skipping."
fi

# --- 2. Remove the Shortcut Script (if it exists) ---
if [ -f "$SHORTCUT_PATH" ]; then
    echo "Removing shortcut script '$SHORTCUT_PATH'..."
    rm -f "$SHORTCUT_PATH"
else
    echo "Shortcut '$SHORTCUT_PATH' not found. Skipping."
fi

echo ""
echo "--- Cleanup Complete. ---"
