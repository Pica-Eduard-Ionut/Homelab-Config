#!/bin/bash

sudo rfkill block bluetooth
sudo systemctl disable --now bluetooth.service
sudo systemctl mask bluetooth.service

echo "Bluetooth is OFF"
