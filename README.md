# Arch-Update

A (.desktop) clickeable icon that automatically changes to act as a pacman update notifier/applier.

## Table of contents
* [Description](#description)
* [Dependencies](#dependencies)
* [Installation](#installation)
* [Usage](#usage)
* [Documentation](#documentation)
* [Tips and tricks](#tips-and-tricks)
* [Contributin](#contributing)

## Description

A (.desktop) clickeable icon that automatically changes to act as a pacman update notifier/applier, easy to integrate with any DE/WM, docks, launch bars or app menus.   
Optionnal support for the AUR (through [yay](https://aur.archlinux.org/packages/yay "yay") or [paru](https://aur.archlinux.org/packages/paru "paru")) and desktop notifications. 

## Dependencies

Arch-Update depends on:
- [pacman-contrib](https://archlinux.org/packages/community/x86_64/pacman-contrib/ "pacman-contrib package") to check and print the list packages available updates.  
  
Arch-Update **optionnally** depends on:
- [yay](https://aur.archlinux.org/packages/yay "yay package") or [paru](https://aur.archlinux.org/packages/paru "paru package") to check, list and apply AUR packages available updates.  
- [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify/ "libnotify package") (`notify-send`) to send desktop notifications when checking for available updates.  
*In order to get `libnotify` (and thus `notify-send`) you have to install a notification server (if you don't already have one).*  
*See https://wiki.archlinux.org/title/Desktop_notifications#Notification_servers*  

### Installing dependencies

*You don't need to install dependencies if you install `arch-update` via the [AUR](#aur) as it already takes care of them*  

```
sudo pacman -S pacman-contrib
```

## Installation

### AUR

Install the [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package") AUR package.

### From Source

After [installing dependencies](#installing-dependencies) on your system, download the archive of the [latest stable release](https://github.com/Antiz96/arch-update/releases/latest) and extract it.  
*Alternatively, you can clone this repository via `git`.*  
  
To install `arch-update`, go into the extracted/cloned directory and run the following command:
```
sudo make install
```
   
To uninstall `arch-update`, go into the extracted/cloned directory and run the following command:  
```
sudo make uninstall
```

## Usage

The usage consist of integrating [the .desktop file](#the-desktop-file) anywhere (could be your desktop, your dock, your launch bar and/or your app menu) and enabling the [systemd timer](#the-systemd-service-and-timer).

### The .desktop file

The .desktop file is located in `/usr/share/applications/arch-update.desktop` (or `/usr/local/share/applications/arch-update.desktop` if you installed `arch-update` [from source](#from-source).  
Its icon will automatically change depending on different states (cheking for updates, updates available, installing updates, up to date).  
It will launch the main `update` function when clicked. It is easy to integrate with any DE/WM, docks, launch bars or app menus.  

### The systemd service and timer

There is a systemd service in `/usr/lib/systemd/user/arch-update.service` (or in `/etc/systemd/user/arch-update.service` if you installed `arch-update` [from source](#from-source)) that launches the `--check` function.  
  
There's  also  a  systemd timer in `/usr/lib/systemd/user/arch-update.timer` (or in `/etc/systemd/user/arch-update.timer` if you installed `arch-update` [from source](#from-source)) that automatically launches the systemd service at boot and then every hour. 
   
In order to make the systemd timer work, you need to enable it with the following command:  
  
```
systemctl --user enable --now arch-update.timer
```
  
Check the screenshots below for more information.

### Screenshot

Personally, I integrated the (.desktop) file on my dock.  
  
It is the penultimate icon from left to right (next to the red "Power Sign" icon).  
This is how it looks like when `arch-update` is checking for available updates (*the check is automatically triggered at boot and then every hour if you enabled the [systemd timer](#the-systemd-service-and-timer) and can be manually triggered with the `arch-update -c` command:*  
![Arch-Update_Check](https://user-images.githubusercontent.com/53110319/161241670-8cab8a54-199b-41f1-80e3-95b171bbb70f.png)  
  
If there are available updates, the icon will change and a desktop notification indicating the number of available updates will be sent (*requires [libnotify/notify-send](https://archlinux.org/packages/extra/x86_64/libnotify/ "libnotify package")*):
![Arch-Update_Updates_Available+Notif](https://user-images.githubusercontent.com/53110319/161244079-b2ce8f2f-d4d3-42ad-83c1-62161d6da62f.png)  
  
When the icon is clicked, it refreshes the list of packages available for updates and print it inside a terminal window. Then it asks for the user's confirmation to proceed (*requires [yay](https://aur.archlinux.org/packages/yay "yay") or [paru](https://aur.archlinux.org/packages/paru "paru") for AUR packages support*):
![Arch-Update_List_Packages](https://user-images.githubusercontent.com/53110319/161244601-8ddeb5c4-b6cd-47a7-a035-debdbad75936.png)  
  
If you chose to show the packages version changes (refer to the [Tips and tricks](#tips-and-tricks) section below), this is how it looks like:
![Arch-Update_List_Packages_With_Version_Changes](https://user-images.githubusercontent.com/53110319/161244783-bb0de764-04bb-4c39-b17a-54dcfb9de449.png)  
  
Once the user gave the confirmation to proceed, the update process will begin and the icon will change accordingly:
![Arch-Update_Installing](https://user-images.githubusercontent.com/53110319/161245498-35bb8f9d-c050-40f5-ae67-d7a01b0bae19.png)  
  
Finally, when the update is over and your machine is up to date, the icon will look like this:
![Arch-Update_up_to_date](https://user-images.githubusercontent.com/53110319/161245726-b3adff52-f91e-40b6-9acc-a7f0d35fa7a5.png)

## Documentation

See the documentation below:  

*The documentation is also available as a man page and with the "--help" function*  
*Type `man arch-update` or `arch-update --help` after you've installed the **arch-update** package.*  
  
### SYNOPSIS

arch-update [OPTION]

### DESCRIPTION

A (.desktop) clickeable icon that automatically changes to act as a pacman update notifier/applier, easy to integrate with any DE/WM, docks, launch bars or app menus.  
Optionnal support for the AUR (through [yay](https://aur.archlinux.org/packages/yay) or [paru](https://aur.archlinux.org/packages/paru)) and desktop notifications.  

### OPTIONS

If no option is passed, perform the main update function: Check for available updates and print the list of packages available for update, then ask for the user's confirmation to proceed with the installation (``pacman -Syu``).  
It also supports AUR packages if [yay](https://aur.archlinux.org/packages/yay) or [paru](https://aur.archlinux.org/packages/paru) is installed.  
The update function is launched when you click on the (.desktop) icon.  

#### -c, --check

Check for available updates and change the (.desktop) icon if there are.  
It sends a desktop notification if [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify/) is installed.  
It supports AUR updates if [yay](https://aur.archlinux.org/packages/yay) or [paru](https://aur.archlinux.org/packages/paru) is installed.  
The `--check` option is automatically launched at boot and then every hour if you enabled the `systemd.timer` with the following command:  
```
systemctl --user enable --now arch-update.timer
```

#### -v, --version

Print the current version.

#### -h, --help

Print the help.

### EXIT STATUS

#### 0
      
if OK

#### 1
      
if problems (user didn't gave confirmation to proceed with the installation, a problem happened during the update process, the user passed an invalid option, ...)

## Tips and tricks

### AUR Support

Arch-Update supports AUR packages when checking and installing updates if **yay** or **paru** is installed:  
See https://github.com/Jguer/yay and https://aur.archlinux.org/packages/yay  
See https://github.com/morganamilo/paru and https://aur.archlinux.org/packages/paru  

### Desktop notifications Support  

Arch-Update supports desktop notifications when performing the `--check` function if **libnotify (notify-send)** is installed:  
See https://wiki.archlinux.org/title/Desktop_notifications

### Modify the auto-check cycle

If you enabled the systemd.timer, the `--check` option is launched automatically at boot and then every hour.  
  
If you want to change that cycle, you can edit the `/usr/lib/systemd/user/arch-update.timer` file (or `/etc/systemd/user/arch-update.timer` if you installed `arch-update` [from source](#from-source)) and modify the `OnUnitActiveSec` value.  
The timer needs to be re-enabled to apply changes, you can do so by typing the following command:  
```
systemctl --user enable --now arch-update.timer
```
  
See https://www.freedesktop.org/software/systemd/man/systemd.time.html

### Show packages version changes

If you want `arch-update` to show the packages version changes in the main `update` function, run the following command:  
```
sudo sed -i "s/ | awk '{print \$1}'//g" /usr/bin/arch-update
```

## Contributing

You can raise your issues, feedbacks and ideas in the [issues tab](https://github.com/Antiz96/arch-update/issues).  
[Pull requests](https://github.com/Antiz96/arch-update/pulls) are welcomed as well !
