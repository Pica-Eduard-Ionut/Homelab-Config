#!/bin/bash

set -euo pipefail

SERVICE_NAME="homelab_smartcheck"
INSTALL_DIR="/opt/homelab_smartcheck"
LOG_DIR="$INSTALL_DIR/logs"

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root:"
    echo "  sudo $0"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Creating installation directory..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$LOG_DIR"

echo "Installing SMART check script..."

install -m 755 \
    "$SCRIPT_DIR/smartcheck.sh" \
    "$INSTALL_DIR/smartcheck.sh"

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
echo "SMART logs will be stored in:"
echo "  $LOG_DIR"
echo
echo "Timer status:"
systemctl status "$SERVICE_NAME.timer" --no-pager