#!/bin/bash

GPU="0000:01:00.0"
# Safely remove the nouveau driver from kernel memory.
# Because modeset=0, it is not holding the console hostage
rmmod nouveau 2>/dev/null

# Tell the PCIe subsystem to allow runtime power management (D3cold)
echo auto > "/sys/bus/pci/devices/$GPU/power/control"

# Force an immediate power state evaluation
echo on > "/sys/bus/pci/devices/$GPU/power/control"
sleep 1
echo auto > "/sys/bus/pci/devices/$GPU/power/control"

echo "NVIDIA GPU driver unloaded and PCIe power management enabled."
