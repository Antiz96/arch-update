#!/bin/bash

latest_release=$(curl -s https://raw.githubusercontent.com/Antiz96/Arch-Update/main/latest_release.txt)

curl -Ls https://github.com/Antiz96/Arch-Update/releases/download/v$latest_release/arch-update-$latest_release.tar.gz -o /tmp/arch-update-$latest_release.tar.gz || exit 1
mkdir -p /tmp/arch-update_src || exit 1
tar -xvf /tmp/arch-update-$latest_release.tar.gz -C /tmp/arch-update_src/ || exit 1
chmod +x /tmp/arch-update_src/bin/arch-update.sh || exit 1
sudo cp -f /tmp/arch-update_src/bin/arch-update.sh /usr/local/bin/arch-update || exit 1
sudo cp -rf /tmp/arch-update_src/icons/ /usr/share/icons/arch-update/ || exit 1
sudo chmod 666 /usr/share/icons/arch-update/* || exit 1
sudo cp -f /tmp/arch-update_src/desktop/arch-update.desktop /usr/share/applications/ || exit 1
sudo mkdir -p /usr/local/share/man/man1 || exit 1
sudo cp -f /tmp/arch-update_src/man/arch-update.1.gz /usr/local/share/man/man1/ || exit 1
sudo cp -f /tmp/arch-update_src/systemd/* /etc/systemd/user/ || exit 1
rm -rf /tmp/arch-update_src/ /tmp/arch-update-$latest_release.tar.gz || exit 1

echo -e "Arch-Update has been successfully installed\nPlease, check https://github.com/Antiz96/Arch-Update for more information\n\nThanks for downloading !"
