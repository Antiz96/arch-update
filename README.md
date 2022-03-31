# Arch-Update

A (.desktop) clickeable icon that automatically changes to act as a pacman update notifier/applier


## Table of contents
* [Description](#description)
* [Installation](#installation)
* [Dependencies] (#dependencies)
* [Usage](#usage)
* [Documentation](#documentation)
* [Tips and tricks] (#tipsandtricks)


## Description

A (.desktop) clickeable icon that automatically changes to act as a pacman update notifier/applier, easy to integrate with any DE/WM, docks, launchbars or app menus. 
<br>
Optionnal supports for the AUR (through **yay**) and desktop notifications. 


## Installation

### AUR

Install the [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package") AUR package

### Manual installation

Download the latest [release](https://github.com/Antiz96/arch-update/releases "latest release") ".tar.gz" archive and put it in "/tmp"
<br>
Then type the following commands (the commands preceded with a "#" need to be launched with root privileges. Use sudo for instance) :
<br>
```
$ cd /tmp
$ mkdir arch-update
$ tar -xvf arch-update-X.X.X.tar.gz -C arch-update #Replace "X.X.X" by the version of the release
$ chmod +x arch-update/bin/arch-update.sh
# cp arch-update/bin/arch-update.sh /usr/local/bin/arch-update
# cp -r arch-update/icons/ /usr/share/icons/arch-update
# chmod 666 /usr/share/icons/arch-update/*
# cp arch-update/desktop/arch-update.desktop /usr/share/applications/
# mkdir -p /usr/local/share/man/man1
# cp arch-update/man/arch-update.1.gz /usr/local/share/man/man1/
# cp arch-update/systemd/* /etc/systemd/user/
# rm -rf arch-update arch-update-X.X.X.tar.gz #Replace "X.X.X" by the version of the release
```
<br>
**Be aware that the manual installation will not provide any automatic update or uninstall process. You'll need to redo all the above steps each time there's a new release in order to get the latest version.
<br>
With that said, unless you have specific reasons to perform a manual installation, I'd recommend using the AUR package installation method.**


## Usage

### Wiki Usage Page

The usage consist of integrating the (.desktop) icon anywhere (could be your desktop, your dock, your launchbar and/or your app menu) and enabling the systemd timer.
<br>
Refer to the [Wiki Usage Page](https://github.com/Antiz96/arch-update/wiki/Usage "Wiki Usage Page") and to the screenshots below for more information.

### Screenshot

Coming soon


## Documentation

Refer to the [Wiki Documentation Page](https://github.com/Antiz96/arch-update/wiki/Documentation "Wiki Documentation Page")


## Tips and tricks

Refer to the [Wiki Tips and tricks Page](https://github.com/Antiz96/arch-update/wiki/Tips-and-tricks "Wiki Tricks and tips Page")

