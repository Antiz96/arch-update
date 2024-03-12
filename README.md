# Arch-Update

[![lang-fr](https://img.shields.io/badge/lang-fr-blue.svg)](https://github.com/Antiz96/arch-update/blob/main/README-fr.md)

## Table of contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Tips and tricks](#tips-and-tricks)
- [Contributing](#contributing)

## Description

An update notifier/applier for Arch Linux that assists you with important pre/post update tasks and that includes a (.desktop) clickeable icon that can easily be integrated with any DE/WM, dock, status/launch bar or app menu.  
Optional support for AUR/Flatpak packages updates and desktop notifications.

Features:

- Includes a (.desktop) clickeable icon that automatically changes to act as an update notifier/applier. Easy to integrate with any DE/WM, dock, status/launch bar, app menu, etc...
- Automatic check and listing of every packages available for update (through [checkupdates](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "pacman-contrib package")).
- Offers to display the latest Arch Linux news before applying updates (through [curl](https://archlinux.org/packages/core/x86_64/curl/ "curl package") and [htmlq](https://archlinux.org/packages/extra/x86_64/htmlq/ "htmlq package")).
- Automatic check and listing of orphan packages and offering you to remove them.
- Automatic check for old and/or uninstalled cached packages in `pacman`'s cache and offering you to remove them (through [paccache](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "pacman-contrib package")).
- Helps you processing pacnew/pacsave files (through [pacdiff](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "pacman-contrib package"), optionally requires [vim](https://archlinux.org/packages/extra/x86_64/vim/ "vim package") as the default [merge program](https://wiki.archlinux.org/title/Pacman/Pacnew_and_Pacsave#pacdiff "pacdiff merge program")).
- Automatic check for pending kernel updates requiring a reboot to be applied and offers to do so if there's one.
- Support for both [sudo](https://archlinux.org/packages/core/x86_64/sudo/ "sudo package") and [doas](https://archlinux.org/packages/extra/x86_64/opendoas/ "opendoas package").
- Optional support for AUR packages update (through [yay](https://aur.archlinux.org/packages/yay "yay AUR package") or [paru](https://aur.archlinux.org/packages/paru "paru AUR package")).
- Optional support for Flatpak packages update (through [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak "Flatpak package")).
- Optional support for desktop notifications (through [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify "libnotify package"), see <https://wiki.archlinux.org/title/Desktop_notifications>).

## Installation

### AUR

Install the [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package") AUR package.

### From Source

Install dependencies:

```bash
sudo pacman -S --needed pacman-contrib curl htmlq diffutils
```

Download the archive of the [latest stable release](https://github.com/Antiz96/arch-update/releases/latest) and extract it *(alternatively, you can clone this repository via `git`)*.

To install `arch-update`, go into the extracted/cloned directory and run the following command:

```bash
sudo make install
```

To uninstall `arch-update`, go into the extracted/cloned directory and run the following command:

```bash
sudo make uninstall
```

## Usage

The usage consist of integrating [the .desktop file](#the-desktop-file) somewhere (could be your desktop, your dock, your status/launch bar and/or your app menu) and enabling the [systemd timer](#the-systemd-timer).

Here is a little YouTube presentation/review of `arch-update` that [Cardiac](https://github.com/Cardiacman13) and I made on [his YouTube channel](https://www.youtube.com/@Cardiacman) (**videos there, including this one, are in french**):

*Warning: Arch-Update's features and default behavior may have changed/evolved since then!*

[![youtube_presentation](https://github.com/Antiz96/arch-update/assets/53110319/23af5180-1881-486d-bd5a-3edd48ed1a08)](https://www.youtube.com/watch?v=QkOkX70SEmo)

### The .desktop file

The .desktop file is located in `/usr/share/applications/arch-update.desktop` (or `/usr/local/share/applications/arch-update.desktop` if you installed `arch-update` [from source](#from-source)).  
Its icon will automatically change depending on the different states (checking for updates, updates available, installing updates, up to date).  
It will launch the relevant series of functions to perform a complete and proper update when clicked (see the [Documentation](#documentation) chapter). It is easy to integrate with any DE/WM, dock, status/launch bar or app menu.

### The systemd timer

There is a systemd service in `/usr/lib/systemd/user/arch-update.service` (or in `/usr/local/lib/systemd/user/arch-update.service` if you installed `arch-update` [from source](#from-source)) that executes the `check` function when started (see the [Documentation](#documentation) chapter).  
To start it automatically **at boot and then once every hour**, enable the associated systemd timer (you can modify the auto-check cycle to your liking, see the [Tips and tricks - Modify the auto-check cycle](#modify-the-auto-check-cycle) chapter):

```bash
systemctl --user enable --now arch-update.timer
```

### Screenshots

Personally, I integrated the .desktop icon in my top bar.  
It is the first icon from the left.

![icon](https://github.com/Antiz96/arch-update/assets/53110319/25f3d2ca-b9d3-4a32-ace3-b0fa785662c2)

When `arch-update` is checking for updates, the icon changes accordingly (the `check` function is automatically triggered at boot and then once every hour if you enabled the [systemd timer](#the-systemd-timer) and can be manually triggered by running the `arch-update -c` command):

![icon-checking](https://github.com/Antiz96/arch-update/assets/53110319/f4c09898-7b21-430f-84be-431a31e25c3f)

If there are new available updates, the icon will show a bell sign and a desktop notification indicating the number of available updates will be sent (requires [libnotify/notify-send](https://archlinux.org/packages/extra/x86_64/libnotify/ "libnotify package")):

![icon-update-available](https://github.com/Antiz96/arch-update/assets/53110319/c1526ce7-5f94-41b8-a8fa-3587b9d00a9d)
![notification](https://github.com/Antiz96/arch-update/assets/53110319/631b8e67-487a-441a-84b4-6cce95223729)

When the icon is clicked, it launches the relevant series of functions to perform a complete and proper update starting by refreshing the list of packages available for updates, display it inside a terminal window and asks for the user's confirmation to proceed with the installation (it can also be launched by running the `arch-update` command, requires [yay](https://aur.archlinux.org/packages/yay "yay") or [paru](https://aur.archlinux.org/packages/paru "paru") for AUR packages update support and [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/) for Flatpak packages update support):

*The colored output can be disabled with the `NoColor` option in the `arch-update.conf` configuration file.*  
*The list of pending updates can be displayed at anytime by running `arch-update -l` or `arch-update --list`.*  
*The versions changes in the packages listing can be hidden with the `NoVersion` option in the `arch-update.conf` configuration file.*  
*See the [arch-update.conf documentation chapter](#arch-update-configuration-file) for more details.*

![listing-packages](https://github.com/Antiz96/arch-update/assets/53110319/43a990c8-ed93-420f-8c46-d50d60bff03f)

Once you gave the confirmation to proceed, `arch-update` offers to display latest Arch Linux news.  
By default, Arch news are only displayed if at least a new one has been published since the last run. Arch news published since the last run or at the same date are tagged as `[NEW]`.  
Select which news to read by typing its associated number.  
After your read a news, `arch-update` will once again offers to display latest Arch Linux news, so you can read multiple news at once.  
Simply press "enter" without typing any number to proceed with update:

*Arch news can be displayed at any time by running the `arch-update --news` command.*  
*The number of Arch news to display before updating and with the `-n/--news` option defaults to 5 but can be customised with the `NewsNum=[Num]` option in the `arch-update.conf` configuration file.*  
*Arch news can be displayed every time before updating, regardless of whether there's a new one since the last run or not, by setting the `AlwaysShowNews` option in the `arch-update.conf` configuration file.*  
*See the [documentation chapter](#Documentation) for more details.*

![list-news](https://github.com/Antiz96/arch-update/assets/53110319/b6883ec4-8c44-4b97-86d9-4d0a304b748b)

While `arch-update` is performing updates, the icon changes accordingly:

![icon-installing](https://github.com/Antiz96/arch-update/assets/53110319/7c74ce84-7de4-4e09-aa2a-66afad9e61d7)

When the update is over, the icon changes accordingly:

![icon-up-to-date](https://github.com/Antiz96/arch-update/assets/53110319/03f224a5-5fcf-450d-9aa5-bae90e7d2e8a)

`arch-update` will then search for orphan packages/unused Flatpak packages and offers to remove them (if there are):

![orphan-packages](https://github.com/Antiz96/arch-update/assets/53110319/76b795e5-076e-4070-9fe2-73165503011b)

![flatpak-unused-packages](https://github.com/Antiz96/arch-update/assets/53110319/cd4053bb-623e-44c2-8c74-9f87710f4074)

`arch-update` will also search for old and/or uninstalled cached packages and offers to remove them (if there are):

*The default behavior is to keep the last 3 cached versions of installed packages and remove every cached versions of uninstalled packages.*  
*You can modify the number of old packages' versions and uninstalled packages' versions to keep in pacman's cache respectively with the `KeepOldPackages=[Num]` and `KeepUninstalledPackages=[Num]` options in the `arch-update.conf` configuration file.*  
*See the [arch-update.conf documentation chapter](#arch-update-configuration-file) for more details.*

![cached-packages](https://github.com/Antiz96/arch-update/assets/53110319/7199bbf1-acd8-49a1-80eb-e9874b94fba6)

Additionally `arch-update` will search for pacnew/pacsave files and offers to process them via `pacdiff` (if there are):

![pacnew-files](https://github.com/Antiz96/arch-update/assets/53110319/5ee627ee-f7b7-4528-bf41-435d3c5892ac)

Finally, `arch-update` will check if there's a pending kernel update requiring a reboot to be applied and offers you to do so (if there is):

![kernel-pending-update](https://github.com/Antiz96/arch-update/assets/53110319/14aef5b2-db32-4296-8a60-bc840c09d457)

## Documentation

### arch-update

```text
An update notifier/applier for Arch Linux that assists you with
important pre/post update tasks.

Run arch-update to perform the main "update" function:
Display the list of packages available for update, then ask for the user's confirmation
to proceed with the installation.
Before performing the update, offer to display the latest Arch Linux news.
Post update, check for orphan/unused packages, old cached packages, pacnew/pacsave files
and pending kernel update and, if there are, offers to process them.

Options:
-c, --check       Check for available updates, send a desktop notification containing the number of available updates (if libnotify is installed)
-l, --list        Display the list of pending updates
-n, --news [Num]  Display latest Arch News, you can optionally specify the number of Arch news to display with `--news [Num]` (e.g. `--news 10`)
-h, --help        Display this help message and exit
-V, --version     Display version information and exit

Exit Codes:
0  OK
1  Invalid option
2  No privilege elevation method (sudo or doas) is installed
3  Error when changing icon
4  User didn't gave the confirmation to proceed
5  Error when updating the packages
6  Error when calling the reboot command to apply a pending kernel update
7  No pending update when using the "-l/--list" option
```

For more information, see the arch-update(1) man page.  
Certain options can be enabled/disabled or modified via the arch-update.conf configuration file, see the arch-update.conf(5) man page.

### arch-update configuration file

```text
The arch-update.conf file is an optional configuration file for arch-update to enable/disable
or modify certain options within the script.

This configuration file has to be located in "${XDG_CONFIG_HOME}/arch-update/arch-update.conf"
or "${HOME}/.config/arch-update/arch-update.conf".

The supported options are:

- NoColor # Do not colorize output.
- NoVersion # Do not show versions changes for packages when listing pending updates (including when using the "-l/--list" option).
- AlwaysShowNews # Always display Arch news before updating, regardless of whether there's a new one since the last run or not.
- NewsNum=[Num] # Number of Arch news to display before updating and with the `-n/--news` option (see the arch-update(1) man page for more details). Defaults to 5.
- KeepOldPackages=[Num] # Number of old packages' versions to keep in pacman's cache. Defaults to 3.
- KeepUninstalledPackages=[Num] # Number of uninstalled packages' versions to keep in pacman's cache. Defaults to 0.

Options are case sensitive, so capital letters have to be respected.
```

For more information, see the arch-update(5) man page.

## Tips and tricks

### AUR Support

Arch-Update supports AUR packages update when checking and installing updates if **yay** or **paru** is installed:  
See <https://github.com/Jguer/yay> and <https://aur.archlinux.org/packages/yay>  
See <https://github.com/morganamilo/paru> and <https://aur.archlinux.org/packages/paru>

### Flatpak Support

Arch-Update supports Flatpak packages update when checking and installing updates (as well as removing unused Flatpak packages) if **flatpak** is installed:  
See <https://www.flatpak.org/> and <https://archlinux.org/packages/extra/x86_64/flatpak/>

### Desktop notifications Support  

Arch-Update supports desktop notifications when performing the `--check` function if **libnotify (notify-send)** is installed:  
See <https://wiki.archlinux.org/title/Desktop_notifications>

### Modify the auto-check cycle

If you enabled the [systemd.timer](#the-systemd-timer), the `--check` option is automatically launched at boot and then once per hour.

If you want to change the check cycle, run `systemctl --user edit arch-update.timer` to create an override configuration for the timer and input the following in it:

```text
[Timer]
OnUnitActiveSec=
OnUnitActiveSec=10m
```

Time units are `s` for seconds, `m` for minutes, `h` for hours, `d` for days...  
See <https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#Parsing%20Time%20Spans> for more details.

## Contributing

You can raise your issues, feedbacks and suggestions in the [issues tab](https://github.com/Antiz96/arch-update/issues).  
[Pull requests](https://github.com/Antiz96/arch-update/pulls) are welcomed as well!
