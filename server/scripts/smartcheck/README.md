# **Homelab SMART Check**

## Overview

Automatically runs a SMART health check on `/dev/sda` after system startup and saves the output to a log file. Runs via a systemd timer.

The SMART check runs 30 seconds after boot and stores the output in `/opt/homelab_smartcheck/logs/`.

## Install

The install script was designed with the contents of this folder inside `/home/user/scripts/smartcheck`, where `user` is the currently logged in user.

```bash
sudo ./install.sh
```

This copies the SMART check script to `/opt/homelab_smartcheck/`, creates the logs directory, and sets up a systemd timer.

## Files

### Scripts (`/opt/homelab_smartcheck/`):

* `smartcheck.sh` - Runs `smartctl` against `/dev/sda` and saves the output to the logs directory.
* `logs/` - Contains the SMART check output files, named by date.

### Systemd:

* `homelab_smartcheck.timer` - Runs the SMART check 30 seconds after system boot.
* `homelab_smartcheck.service` - Executes the SMART check script.

## Logs

SMART check results are stored in:

```text
/opt/homelab_smartcheck/logs/
```

Each log is named using the date of the check:

```text
YYYY-MM-DD.txt
```

Example:

```text
/opt/homelab_smartcheck/logs/2026-08-04.txt
```

The logs directory can be mounted as a read-only volume into a container or Kubernetes pod for use by a microservice API.
