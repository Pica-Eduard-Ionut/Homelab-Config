#!/bin/bash

GPU="0000:01:00.0"
DRIVER="/sys/bus/pci/drivers/nouveau"

# Make sure the GPU is available for runtime power management
echo auto > "/sys/bus/pci/devices/$GPU/power/control"

# Bind the GPU to nouveau if it is not already bound
if [ ! -e "$DRIVER/$GPU" ]; then
    echo "$GPU" > "$DRIVER/bind"
fi

echo "NVIDIA GPU enabled and bound to nouveau"
