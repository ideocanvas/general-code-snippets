#!/bin/bash

# =================================================================
# Setup Script for Docker Wi-Fi Network Isolation
#
# This script creates the required Docker network and installs the
# local 'run_on_wifi' script into the system's path.
# =================================================================

set -e # Exit immediately if a command fails

# --- Configuration ---
WIFI_IF="wlP1p1s0"
NETWORK_NAME="wifi_net"
SHORTCUT_DEST_PATH="/usr/local/bin/run_on_wifi"
SHORTCUT_SOURCE_FILE="./run_on_wifi"

# --- 2. Install the Shortcut Script ---
echo "Installing shortcut by copying '$SHORTCUT_SOURCE_FILE' to '$SHORTCUT_DEST_PATH'..."
sudo cp "$SHORTCUT_SOURCE_FILE" "$SHORTCUT_DEST_PATH"

