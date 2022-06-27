#!/bin/bash

pkgname="arch-update"
url="https://github.com/Antiz96/arch-update"

echo -e "$pkgname is going to be uninstalled\n"

sudo rm -f /usr/local/bin/"$pkgname" || exit 1
sudo rm -rf /usr/share/icons/"$pkgname"/ || exit 1
sudo rm -f /usr/share/applications/"$pkgname".desktop || exit 1
sudo rm -f /usr/local/share/man/man1/"$pkgname".1.gz || exit 1
sudo rm -f /etc/systemd/user/"$pkgname".timer || exit 1
sudo rm -f /etc/systemd/user/"$pkgname".service || exit 1

echo -e "$pkgname has been successfully uninstalled\nPlease, visit $url for more information"
