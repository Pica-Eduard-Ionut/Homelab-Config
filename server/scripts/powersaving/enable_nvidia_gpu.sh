#!/bin/bash
GPU="0000:01:00.0"
GPU_AUDIO="0000:01:00.1"

# Wake the PCIe devices up
echo "on" | sudo tee "/sys/bus/pci/devices/$GPU/power/control" > /dev/null
echo "on" | sudo tee "/sys/bus/pci/devices/$GPU_AUDIO/power/control" > /dev/null
sleep 1

# Load the nouveau driver back into memory
sudo modprobe nouveau

# Re-bind the audio driver to the NVIDIA audio chip
if [ ! -e "/sys/bus/pci/drivers/snd_hda_intel/$GPU_AUDIO" ]; then
    echo "$GPU_AUDIO" | sudo tee /sys/bus/pci/drivers/snd_hda_intel/bind > /dev/null
fi

echo "NVIDIA GPU and Audio re-enabled."
