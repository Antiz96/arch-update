# Arch-Update

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
- Offers to print the latest Arch Linux news before applying updates (through [curl](https://archlinux.org/packages/core/x86_64/curl/ "curl package") and [htmlq](https://archlinux.org/packages/extra/x86_64/htmlq/ "htmlq package")).
- Automatic check and listing of orphan packages and offering you to remove them.
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

The usage consist of integrating [the .desktop file](#the-desktop-file) anywhere (could be your desktop, your dock, your status/launch bar and/or your app menu) and enabling the [systemd timer](#the-systemd-timer).

Here is a little YouTube presentation/review of `arch-update` that [Cardiac](https://github.com/Cardiacman13) and I made on [his YouTube channel](https://www.youtube.com/@Cardiacman) (**videos there, including this one, are in french**):

*Warning: Arch-Update's features and default behavior may have changed/evolved since then!*

[![youtube_presentation](https://github.com/Antiz96/arch-update/assets/53110319/23af5180-1881-486d-bd5a-3edd48ed1a08)](https://www.youtube.com/watch?v=QkOkX70SEmo)

### The .desktop file

The .desktop file is located in `/usr/share/applications/arch-update.desktop` (or `/usr/local/share/applications/arch-update.desktop` if you installed `arch-update` [from source](#from-source)).  
Its icon will automatically change depending on the different states (checking for updates, updates available, installing updates, up to date).  
It will launch the main `update` function when clicked (see the [Documentation](#documentation) chapter). It is easy to integrate with any DE/WM, dock, status/launch bar or app menu.

### The systemd timer

There is a systemd service in `/usr/lib/systemd/user/arch-update.service` (or in `/etc/systemd/user/arch-update.service` if you installed `arch-update` [from source](#from-source)) that executes the `check` function when launched (see the [Documentation](#documentation) chapter).  
To launch it automatically **at boot and then once every hour**, enable the associated systemd timer:

```bash
systemctl --user enable --now arch-update.timer
```

### Screenshot

Personally, I integrated the .desktop icon in my top bar.  
It is the first icon from the left.

![top_bar_up_to_date](https://github.com/Antiz96/arch-update/assets/53110319/794696a0-3452-4afd-8d64-a41d64225082)

When `arch-update` is checking for updates, the icon changes accordingly *(the `check` function is automatically triggered at boot and then once every hour if you enabled the [systemd timer](#the-systemd-timer) and can be manually triggered by running the `arch-update -c` command)*:

![top_bar_checking](https://github.com/Antiz96/arch-update/assets/53110319/27cc96c7-6871-4235-81d2-20bc4528fa18)

If there are available updates, the icon will show a bell sign and a desktop notification indicating the number of available updates will be sent *(requires [libnotify/notify-send](https://archlinux.org/packages/extra/x86_64/libnotify/ "libnotify package"))*:

![top_bar_update_available](https://github.com/Antiz96/arch-update/assets/53110319/e76be2e4-07b1-41db-8a5d-8cff89e904f6)  
![notification](https://github.com/Antiz96/arch-update/assets/53110319/4d7fb15e-2d94-4740-9831-fe4dfd264c13)

When the icon is clicked, it launches the main `update` function which refreshes the list of packages available for updates, print it inside a terminal window and asks for the user's confirmation to proceed with the installation *(it can also be launched by running the `arch-update` command, requires [yay](https://aur.archlinux.org/packages/yay "yay") or [paru](https://aur.archlinux.org/packages/paru "paru") for AUR packages update support and [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/) for Flatpak packages update support)*:

![main_update_function](https://github.com/Antiz96/arch-update/assets/53110319/43ff2d3a-a6d6-455b-9642-b11c42ed1985)

You can optionally configure `arch-update` to not show the version changes during the package listing *(see [Tips and tricks - Do not show package version changes](#do-not-show-package-version-changes)*:

![main_update_function_without_version_changes](https://github.com/Antiz96/arch-update/assets/53110319/76827a27-be4f-4937-b231-53be62d9115f)

Once you gave the confirmation to proceed, `arch-update` offers to print latest Arch Linux news.  
Arch news that have been published within the last 15 days are tagged as `[NEW]`.  
Select which news to read by typing its associated number.  
After your read a news, `arch-update` will once again offers to print latest Arch Linux news, so you can read multiple news at once.  
Simply press "enter" without typing any number to proceed with update:

![print_news](https://github.com/Antiz96/arch-update/assets/53110319/0570d6fd-64a2-4c00-9aba-8c253e8a6053)

While `arch-update` is performing updates, the icon changes accordingly:

![top_bar_installing](https://github.com/Antiz96/arch-update/assets/53110319/7fdbf6f3-0576-4ab2-9d80-a602594321e9)

When the update is over, the icon changes accordingly:

![top_bar_up_to_date](https://github.com/Antiz96/arch-update/assets/53110319/794696a0-3452-4afd-8d64-a41d64225082)

`arch-update` will also search for orphan packages/unused Flatpak packages and offers to remove them (if there are):

![remove_orphan](https://github.com/Antiz96/arch-update/assets/53110319/4abf2623-ba27-4c42-8289-884199bfb579)

Additionally `arch-update` will search for pacnew/pacsave files and offers to process them via `pacdiff` (if there are):

![process_pacnew](https://github.com/Antiz96/arch-update/assets/53110319/6f3430f7-fc28-48fa-b107-230f3f32ac5b)

Finally, `arch-update` will check if there's a pending kernel update requiring a reboot to be applied and offers you to do so (if there is):

![kernel_reboot](https://github.com/Antiz96/arch-update/assets/53110319/1eec68c0-e619-44ab-9dd9-74a341f7a5b7)

## Documentation

```text
Run arch-update to perform the main "update" function:
Print the list of packages available for update, then ask for the user's confirmation to proceed with the installation.
Before performing the update, offer to print the latest Arch Linux news.
Post update, check for orphan/unused packages and pacnew/pacsave files and, if there are, offers to process them.

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
6  Error when calling the reboot command to apply a pending kernel update
```

For more information, see the arch-update(1) man page

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

If you enabled the systemd.timer, the `--check` option is automatically launched at boot and then once every hour.

If you want to change that cycle, you can edit the `/usr/lib/systemd/user/arch-update.timer` file (or `/etc/systemd/user/arch-update.timer` if you installed `arch-update` [from source](#from-source)) and modify the `OnUnitActiveSec` value.  
The timer needs to be re-enabled to apply changes, you can do so by typing the following command:

```bash
systemctl --user enable --now arch-update.timer
```

See <https://www.freedesktop.org/software/systemd/man/systemd.time.html>

### Do not show package version changes

If you don't want `arch-update` to show the packages version changes in the main `update` function, run the following command:

```bash
sudo sed -i "s/packages=\$(checkupdates)/packages=\$(checkupdates | awk '{print \$1}')/g" /usr/bin/arch-update /usr/local/bin/arch-update 2>/dev/null ; sudo sed -i "s/aur_packages=\$(\"\${aur_helper}\" -Qua)/aur_packages=\$(\"\${aur_helper}\" -Qua | awk '{print \$1}')/g" /usr/bin/arch-update /usr/local/bin/arch-update 2>/dev/null || true
```

**Be aware that you'll have to relaunch that command at each `arch-update`'s new release.**

## Contributing

You can raise your issues, feedbacks and suggestions in the [issues tab](https://github.com/Antiz96/arch-update/issues).  
[Pull requests](https://github.com/Antiz96/arch-update/pulls) are welcomed as well!
