#!/bin/bash

sudo rm -f /usr/local/bin/arch-update || exit 1
sudo rm -rf /usr/share/icons/arch-update/ || exit 1
sudo rm -f /usr/share/applications/arch-update.desktop || exit 1
sudo rm -f /usr/local/share/man/man1/arch-update.1.gz || exit 1
sudo rm -f /etc/systemd/user/arch-update.timer || exit 1
sudo rm -f /etc/systemd/user/arch-update.service || exit 1

echo "Arch-Update has been successfully uninstalled"
