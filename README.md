# Arch-Update

## Table of contents
* [Description](#description)
* [Installation](#installation)
* [Usage](#usage)
* [Documentation](#documentation)
* [Tips and tricks](#tips-and-tricks)
* [Contributing](#contributing)

## Description

An update notifier/applier for Arch Linux that assists you with important pre/post update tasks and that includes a (.desktop) clickeable icon that can easily be integrated with any DE/WM, dock, status/launch bar or app menu. Optional support for AUR package updates and desktop notifications.  
  
Features:
- Includes a (.desktop) clickeable icon that automatically changes to act as an update notifier/applier. Easy to integrate with any DE/WM, dock, status/launch bar, app menu, etc...
- Automatic check and listing of every packages available for update (through [checkupdates](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "pacman-contrib package")), optionally shows the version changes as well.
- Offers to print the latest Arch Linux news before applying updates (through [curl](https://archlinux.org/packages/core/x86_64/curl/ "curl package") and [htmlq](https://archlinux.org/packages/extra/x86_64/htmlq/ "htmlq package")).
- Automatic check and listing of orphan packages and offering you to remove them.
- Helps you processing pacnew/pacsave files (through [pacdiff](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "pacman-contrib package")).
- Support for both [sudo](https://archlinux.org/packages/core/x86_64/sudo/ "sudo package") and [doas](https://archlinux.org/packages/extra/x86_64/opendoas/ "opendoas package").
- Optional support for AUR package updates (through [yay](https://aur.archlinux.org/packages/yay "yay AUR package") or [paru](https://aur.archlinux.org/packages/paru "paru AUR package")).
- Optional support for desktop notifications (through [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify/ "libnotify package"), see: https://wiki.archlinux.org/title/Desktop_notifications).

## Installation

### AUR

Install the [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package") AUR package.

### From Source

Install dependencies:  
```
sudo pacman -S --needed pacman-contrib curl htmlq diffutils vim
```
  
Download the archive of the [latest stable release](https://github.com/Antiz96/arch-update/releases/latest) and extract it *(alternatively, you can clone this repository via `git`)*.  
  
To install `arch-update`, go into the extracted/cloned directory and run the following command:
```
sudo make install
```
   
To uninstall `arch-update`, go into the extracted/cloned directory and run the following command:  
```
sudo make uninstall
```

## Usage

The usage consist of integrating [the .desktop file](#the-desktop-file) anywhere (could be your desktop, your dock, your status/launch bar and/or your app menu) and enabling the [systemd timer](#the-systemd-timer).

### The .desktop file

The .desktop file is located in `/usr/share/applications/arch-update.desktop` (or `/usr/local/share/applications/arch-update.desktop` if you installed `arch-update` [from source](#from-source)).  
Its icon will automatically change depending on the different states (checking for updates, updates available, installing updates, up to date).  
It will launch the main `update` function when clicked (see the [Documentation](#documentation) chapter). It is easy to integrate with any DE/WM, dock, status/launch bar or app menu.  

### The systemd timer

There is a systemd service in `/usr/lib/systemd/user/arch-update.service` (or in `/etc/systemd/user/arch-update.service` if you installed `arch-update` [from source](#from-source)) that executes the `check` function when launched (see the [Documentation](#documentation) chapter).  
To launch it automatically **at boot and then once every hour**, enable the associated systemd timer:  
```
systemctl --user enable --now arch-update.timer
```

### Screenshot

Personally, I integrated the .desktop icon in my top bar.  
It is the first icon from the left.  
![Up_to_date](https://user-images.githubusercontent.com/53110319/204068077-40775c1c-06dd-4665-b837-08f0cefb3941.png)  
     
When `arch-update` is checking for updates, the icon changes accordingly *(the `check` function is automatically triggered at boot and then once every hour if you enabled the [systemd timer](#the-systemd-timer) and can be manually triggered by running the `arch-update -c` command)*:  
![Searching_for_updates](https://user-images.githubusercontent.com/53110319/204068136-25adb912-54f7-4d95-afd6-f08c5b73677d.png)  
   
If there are available updates, the icon will show a bell sign and a desktop notification indicating the number of available updates will be sent *(requires [libnotify/notify-send](https://archlinux.org/packages/extra/x86_64/libnotify/ "libnotify package"))*:  
![Updates_availables](https://user-images.githubusercontent.com/53110319/204068175-5ef1cb05-b72b-44b1-9f4b-0a801d363663.png)  
![Updates_availables+notif](https://user-images.githubusercontent.com/53110319/204068184-e2fddf44-ffd6-4b2a-80fe-75e8d20ecf7e.png)  
   
When the icon is clicked, it launches the main `update` function which refreshes the list of packages available for updates, print it inside a terminal window and asks for the user's confirmation to proceed with the installation *(It can also be launched by running the `arch-update` command. It requires [yay](https://aur.archlinux.org/packages/yay "yay") or [paru](https://aur.archlinux.org/packages/paru "paru") for AUR package updates support)*:  
![List_of_packages](https://user-images.githubusercontent.com/53110319/204068223-a31e7a21-8df7-4e51-ac4b-7df6c52c5d20.png)  
  
You can optionally configure `arch-update` to show the version changes during the package listing *(see: [Tips and tricks - Show package version changes](#show-package-version-changes))*:  
![List_of_packages_with_version](https://user-images.githubusercontent.com/53110319/204068369-2da6480f-7faa-4fa1-937c-6b168ca11795.png)  

Once you gave the confirmation to proceed, `arch-update` offers to print latest Arch Linux news so you can acknowledge them easily. Select which news to read by typing its associated number. After your read a news, `arch-update` will once again offers to print latest Arch Linux news, so you can read multiple news at once. Simply press "enter" without typing any number to proceed with update:  
![Arch_news](https://user-images.githubusercontent.com/53110319/204068653-de484935-344a-4956-b134-5b4b1771360e.png)  
   
While `arch-update` is performing updates, the icon changes accordingly:  
![Installing_updates](https://user-images.githubusercontent.com/53110319/204068693-1f71b07a-e273-46aa-a8c1-7d729617e466.png)  
  
When the update is over, the icon changes accordingly:  
![Up_to_date](https://user-images.githubusercontent.com/53110319/204068822-85f19af5-f817-49b9-9a25-96c5364e61fa.png)  
  
`arch-update` will also search for orphan packages and offers to remove them (if there are):
![Orphan](https://user-images.githubusercontent.com/53110319/217640788-c4d10023-185c-49a3-a3a9-b8beb893e09f.png)  
  
Additionally `arch-update` will search for pacnew/pacsave files and offers to process them via `pacdiff` (if there are):  
![Pacnew](https://user-images.githubusercontent.com/53110319/217660567-f00db345-55b9-424b-9436-77492d6c00b8.png)  

## Documentation

```
An update notifier/applier for Arch Linux that assists you with important pre/post update tasks.

Run arch-update to perform the main "update" function: Print the list of packages available for update, then ask for the user's confirmation to proceed with the installation. Before performing the update, offer to print the latest Arch Linux news. Post update, check for orphan packages and pacnew/pacsave files and, if there are, offers to process them.

Options:
  -c, --check    Check for available updates, send a desktop notification containing the number of available updates (if libnotify is installed)
  -h, --help     Display this message and exit
  -V, --version  Display version information and exit

Exit Codes:
0  OK
1  Invalid option
2  No privilege method (sudo or doas) is installed
3  Error when changing icon
4  User didn't gave the confirmation to proceed
5  Error when updating the packages
```
  
For more information, see the arch-update(1) man page

## Tips and tricks

### AUR Support

Arch-Update supports AUR package updates when checking and installing updates if **yay** or **paru** is installed:  
See https://github.com/Jguer/yay and https://aur.archlinux.org/packages/yay  
See https://github.com/morganamilo/paru and https://aur.archlinux.org/packages/paru  

### Desktop notifications Support  

Arch-Update supports desktop notifications when performing the `--check` function if **libnotify (notify-send)** is installed:  
See https://wiki.archlinux.org/title/Desktop_notifications

### Modify the auto-check cycle

If you enabled the systemd.timer, the `--check` option is automatically launched at boot and then once every hour.  
  
If you want to change that cycle, you can edit the `/usr/lib/systemd/user/arch-update.timer` file (or `/etc/systemd/user/arch-update.timer` if you installed `arch-update` [from source](#from-source)) and modify the `OnUnitActiveSec` value.  
The timer needs to be re-enabled to apply changes, you can do so by typing the following command:  
```
systemctl --user enable --now arch-update.timer
```
  
See https://www.freedesktop.org/software/systemd/man/systemd.time.html

### Show package version changes

If you want `arch-update` to show the packages version changes in the main `update` function, run the following command:  
```
sudo sed -i "s/ | awk '{print \$1}'//g" /usr/bin/arch-update /usr/local/bin/arch-update 2>/dev/null || true
```
  
**Be aware that you'll have to relaunch that command at each `arch-update`'s new release.**  

## Contributing

You can raise your issues, feedbacks and suggestions in the [issues tab](https://github.com/Antiz96/arch-update/issues).  
[Pull requests](https://github.com/Antiz96/arch-update/pulls) are welcomed as well!
