# WiFi Network Isolation Scripts

This collection provides Docker-based network isolation for running applications on a specific WiFi interface.

## 📁 Script Files

- [`setup_docker_wifi.sh`](setup_docker_wifi.sh) - Setup script for Docker WiFi network
- [`cleanup_docker_wifi.sh`](cleanup_docker_wifi.sh) - Cleanup script to remove network and shortcuts
- [`run_on_wifi`](run_on_wifi) - Main shortcut script for running commands on WiFi network
- [`copy_run_on_wifi.sh`](copy_run_on_wifi.sh) - Helper script for copying the main shortcut

## 🚀 Quick Start

1. **Setup**: Run the setup script (requires root/sudo)
   ```bash
   sudo ./setup_docker_wifi.sh
   ```

2. **Usage**: Use the installed shortcut to run commands on WiFi network
   ```bash
   run_on_wifi ollama pull gemma:2b
   run_on_wifi firefox
   ```

3. **Cleanup**: Remove the network and shortcut when done
   ```bash
   sudo ./cleanup_docker_wifi.sh
   ```

## ⚙️ Configuration

The scripts use a Docker macvlan network to isolate traffic to the specified WiFi interface (`wlP1p1s0` by default). Modify the scripts to match your WiFi interface name if different.

## 🔧 Requirements

- Docker installed and running
- Root/sudo privileges for network setup
- WiFi interface available and connected