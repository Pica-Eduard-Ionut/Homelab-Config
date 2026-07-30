#!/bin/bash

GPU="0000:01:00.0"
DRIVER="/sys/bus/pci/drivers/nouveau"

# If nouveau is currently bound, unbind it
if [ -e "$DRIVER/$GPU" ]; then
    echo "$GPU" > "$DRIVER/unbind"
fi

# Allow the PCI device to enter runtime suspend
echo auto > "/sys/bus/pci/devices/$GPU/power/control"
echo "NVIDIA GPU disabled"
