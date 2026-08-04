#!/bin/bash

set -euo pipefail

LOG_DIR="/opt/homelab_smartcheck/logs"

mkdir -p "$LOG_DIR"

/usr/sbin/smartctl -a /dev/sda > "$LOG_DIR/$(date +%F).txt"
