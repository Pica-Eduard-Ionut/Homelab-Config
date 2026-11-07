#!/bin/bash
GPU="0000:01:00.0"
GPU_AUDIO="0000:01:00.1"

# Safely remove the nouveau driver
sudo rmmod nouveau 2>/dev/null

# Unbind the audio driver from the NVIDIA audio chip (The Magic Step!)
if [ -e "/sys/bus/pci/drivers/snd_hda_intel/$GPU_AUDIO" ]; then
    echo "$GPU_AUDIO" | sudo tee /sys/bus/pci/drivers/snd_hda_intel/unbind > /dev/null
fi

# Allow both the GPU and Audio to suspend
echo "auto" | sudo tee "/sys/bus/pci/devices/$GPU/power/control" > /dev/null
echo "auto" | sudo tee "/sys/bus/pci/devices/$GPU_AUDIO/power/control" > /dev/null

# Force an immediate power state evaluation
echo "on" | sudo tee "/sys/bus/pci/devices/$GPU/power/control" > /dev/null
sleep 1
echo "auto" | sudo tee "/sys/bus/pci/devices/$GPU/power/control" > /dev/null

# Apply all system-wide powertop tweaks
sudo powertop --auto-tune > /dev/null 2>&1

echo "NVIDIA GPU and Audio safely suspended."
