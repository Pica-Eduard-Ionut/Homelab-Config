# **Homelab Power Saving**

## Overview
Automatically disables Bluetooth, NVIDIA GPU, and screen after idle periods to save power. Runs via systemd timer.

## Install

```bash
    sudo ./install_powersaving_service.sh
```

This copies scripts to /opt/homelab_powersaving/ and sets up a systemd timer.

## Files
### Scripts (`/opt/homelab_powersaving/`):
 - `screen_off.sh` / `screen_on.sh`
 - `bluetooth_off.sh` / `bluetooth_on.sh`
 - `disable_nvidia_gpu.sh` / `enable_nvidia_gpu.sh`
### Systemd:
- `homelab_powersaving.timer` - Triggers the service periodically
- `homelab_powersaving.service` - Runs the scripts