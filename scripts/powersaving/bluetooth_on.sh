#!/bin/bash

sudo systemctl unmask bluetooth.service
sudo systemctl enable --now bluetooth.service
sudo rfkill unblock bluetooth

echo "Bluetooth is ON"
