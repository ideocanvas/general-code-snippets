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

# --- Pre-flight Checks ---
if [[ $EUID -ne 0 ]]; then echo "This script must be run as root. Please use 'sudo'."; exit 1; fi
if ! command -v docker &> /dev/null; then echo "Docker is not installed. Please install it first."; exit 1; fi
if ! ip link show "$WIFI_IF" > /dev/null 2>&1; then echo "Wi-Fi interface '$WIFI_IF' not found."; exit 1; fi
if [ ! -f "$SHORTCUT_SOURCE_FILE" ]; then
    echo "Error: Source script '$SHORTCUT_SOURCE_FILE' not found in the current directory."
    echo "Please ensure your customized 'run_on_wifi' script is in the same folder."
    exit 1
fi

echo "--- Starting Docker Wi-Fi Network Setup ---"

# --- 1. Create the Docker Network (if it doesn't exist) ---
if docker network inspect "$NETWORK_NAME" > /dev/null 2>&1; then
    echo "Docker network '$NETWORK_NAME' already exists. Skipping creation."
else
    echo "Discovering network settings for '$WIFI_IF'..."
    WIFI_SUBNET=$(ip -4 addr show "$WIFI_IF" | grep -oP 'inet \K[\d./]+' | sed 's/\.[0-9]*\//.0\//')
    WIFI_GATEWAY=$(ip route | grep default | grep "$WIFI_IF" | awk '{print $3}')

    if [ -z "$WIFI_SUBNET" ] || [ -z "$WIFI_GATEWAY" ]; then
        echo "Error: Could not determine Wi-Fi subnet or gateway. Is Wi-Fi connected?"
        exit 1
    fi

    echo "Found Subnet: $WIFI_SUBNET"
    echo "Found Gateway: $WIFI_GATEWAY"
    echo "Creating Docker macvlan network '$NETWORK_NAME'..."
    docker network create -d macvlan \
      --subnet="$WIFI_SUBNET" \
      --gateway="$WIFI_GATEWAY" \
      -o parent="$WIFI_IF" \
      "$NETWORK_NAME"
fi

# --- 2. Install the Shortcut Script ---
echo "Installing shortcut by copying '$SHORTCUT_SOURCE_FILE' to '$SHORTCUT_DEST_PATH'..."
sudo cp "$SHORTCUT_SOURCE_FILE" "$SHORTCUT_DEST_PATH"

# --- 3. Make Shortcut Executable ---
echo "Making shortcut executable..."
sudo chmod +x "$SHORTCUT_DEST_PATH"

echo ""
echo "--- Setup Complete! ---"
echo "You can now use the 'run_on_wifi' command system-wide."
echo "Example: run_on_wifi ollama pull gemma:2b"
