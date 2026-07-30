#!/bin/bash

set -euo pipefail

SERVICE_NAME="homelab_powersaving"
INSTALL_DIR="/opt/homelab_powersaving"

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root:"
    echo "  sudo $0"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"

echo "Copying power saving scripts to $INSTALL_DIR..."

install -m 755 \
    "$SCRIPT_DIR/screen_off.sh" \
    "$INSTALL_DIR/screen_off.sh"

install -m 755 \
    "$SCRIPT_DIR/bluetooth_off.sh" \
    "$INSTALL_DIR/bluetooth_off.sh"

install -m 755 \
    "$SCRIPT_DIR/disable_nvidia_gpu.sh" \
    "$INSTALL_DIR/disable_nvidia_gpu.sh"

echo "Installing systemd unit files..."

install -m 644 \
    "$SCRIPT_DIR/$SERVICE_NAME.service" \
    /etc/systemd/system/

install -m 644 \
    "$SCRIPT_DIR/$SERVICE_NAME.timer" \
    /etc/systemd/system/

echo "Reloading systemd..."
systemctl daemon-reload

echo "Enabling timer..."
systemctl enable "$SERVICE_NAME.timer"

echo "Restarting timer..."
systemctl restart "$SERVICE_NAME.timer"

echo
echo "Installation complete."
echo
systemctl status "$SERVICE_NAME.timer" --no-pager
