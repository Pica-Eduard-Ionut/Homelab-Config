#!/bin/bash

GPU="0000:01:00.0"

# Wake the PCIe device up first
echo on > "/sys/bus/pci/devices/$GPU/power/control"
sleep 1

# Load the nouveau driver back into memory.
# It will automatically bind to the GPU.
modprobe nouveau

echo "NVIDIA GPU driver loaded and ready."
