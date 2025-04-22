# Arch-Update

<p align="center">
  <img width="460" height="300" src="https://github.com/user-attachments/assets/5782bd11-084a-4ca3-b599-1c322ee11b84">
</p>

[![lang-fr](https://img.shields.io/badge/lang-fr-blue.svg)](https://github.com/Antiz96/arch-update/blob/main/README-fr.md)

## Table of contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Tips and tricks](#tips-and-tricks)
- [Contributing](#contributing)
- [License](#license)

## Description

An update notifier & applier for Arch Linux that assists you with important pre / post update tasks.  
Includes a dynamic & clickeable systray applet for an easy integration with any Desktop Environment / Window Manager.

Arch-Update is designed to follow usual system maintenance steps, as described in the [Arch Wiki](https://wiki.archlinux.org/title/System_maintenance).

Features:

- Automatic check and listing of available updates.
- Check for recent Arch Linux news (and offers to display them if there are).
- Check for orphan packages (and offers to remove them if there are).
- Check for old & uninstalled packages in cache (and offers to remove them if there are).
- Check for pacnew & pacsave files (and offers to process them if there are).
- Check for pending kernel update requiring a reboot (and offers to do so if there's one).
- Check for services requiring a post upgrade restart (and offers to do so if there are).
- Support for `sudo`, `doas` & `run0`.

Optional support for:

- AUR packages (via `paru`, `yay` or `pikaur`).
- Flatpak packages (via `flatpak`).
- Desktop notifications (via `libnotify`).

## Installation

### AUR

Install the [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package") AUR package (also check the list of optional dependencies for anything you may want or need).

### From Source

Install required dependencies:

```bash
sudo pacman -S --needed pacman-contrib archlinux-contrib curl fakeroot htmlq diffutils hicolor-icon-theme python python-pyqt6 qt6-svg glib2
```

Additional optional dependencies you might want or need:

- [paru](https://aur.archlinux.org/packages/paru): AUR Packages support
- [yay](https://aur.archlinux.org/packages/yay): AUR Packages support
- [pikaur](https://aur.archlinux.org/packages/pikaur): AUR Packages support
- [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/): Flatpak Packages support
- [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify/): Desktop notifications support on new available updates (see <https://wiki.archlinux.org/title/Desktop_notifications>)
- [vim](https://archlinux.org/packages/extra/x86_64/vim/): Default merge program for pacdiff
- [qt6-wayland](https://archlinux.org/packages/extra/x86_64/qt6-wayland/): Systray applet support on Wayland

Install required build dependencies:

```bash
sudo pacman -S --asdeps make scdoc bats
```

Download the archive of the [latest stable release](https://github.com/Antiz96/arch-update/releases/latest) and extract it (alternatively, you can clone this repository with `git`).

To install `arch-update`, go into the extracted / cloned directory and run the following commands:

```bash
make
make test
sudo make install
```

Once the installation is complete, you may optionally clean up the directory of files generated during installation by running the following command:

```bash
make clean
```

To uninstall `arch-update`, go into the extracted / cloned directory and run the following command:

```bash
sudo make uninstall
```

## Usage

The usage consist of starting [the systray applet](#the-systray-applet) and enabling [the systemd timer](#the-systemd-timer).

### The systray applet

To start the systray applet, launch the "Arch-Update Systray Applet" application from your app menu.

To start it automatically at boot, you can either:

- Run the following command (preferred method for most Desktop Environments, uses [XDG Autostart](https://wiki.archlinux.org/title/XDG_Autostart)):

```bash
arch-update --tray --enable
```

- Enable the associated systemd service (in case your Desktop Environment doesn't support [XDG Autostart](https://wiki.archlinux.org/title/XDG_Autostart)):

```bash
systemctl --user enable --now arch-update-tray.service
```

- Add the following command to your "auto-start" apps / configuration file (in case you use a Window Manager or a Wayland Compositor):

```bash
arch-update --tray
```

**If the systray applet doesn't start at boot regardless or if it doesn't work as expected** (e.g the icon is missing or the click actions do not act as they should), please read [this chapter](#the-systray-applet-does-not-start-at-boot-or-does-not-work-as-expected).

The systray icon dynamically changes to indicate the current state of your system ('up to date' or 'updates available'). When clicked, it launches `arch-update` in a terminal window via the [arch-update.desktop](https://github.com/Antiz96/arch-update/blob/main/res/desktop/arch-update.desktop) file.

**If clicking the systray applet does nothing**, please read [this chapter](#run-arch-update-in-a-specific-terminal-emulator).

### The systemd timer

To perform automatic and periodic checks for available updates, enable the associated systemd timer:

```bash
systemctl --user enable --now arch-update.timer
```

By default, a check is performed **at boot and then once every hour**. The check cycle can be customized, see [this chapter](#modify-the-check-cycle).

### Screenshots

Once started, the systray applet appears in the systray area of your panel.  
It is the icon at the right of the 'coffee cup' one in the screenshot below (note that there are [different color variants available](https://github.com/Antiz96/arch-update/blob/main/res/icons/README.md) for it):

![icon](https://github.com/user-attachments/assets/e02645d1-3646-47f2-a218-08e4e5d6e4e0)

With [the systemd timer](#the-systemd-timer) enabled, checks for updates are automatically and periodically performed, but you can manually trigger one from the systray applet icon by right-clicking it and then clicking on the `Check for updates` menu entry:

![check_for_updates](https://github.com/user-attachments/assets/efd190f5-4338-4204-a19b-0a6f138b4435)

If there are new available updates, the systray icon shows a red circle and a desktop notification indicating the number of available updates is sent:

![notif](https://github.com/user-attachments/assets/976a435f-db44-477a-b339-1b257639501a)

You can see the list of available updates from the menu by right-clicking the systray icon.  
A dropdown menu displaying the number and the list of pending updates is dynamically created for each sources that have some (Packages, AUR, Flatpak).  
A "All" dropdown menu gathering the number and the list of pending updates for all sources is dynamically created if at least 2 different sources have pending updates:

![all](https://github.com/user-attachments/assets/798a4712-254b-470c-b83d-de2f3fcbdad4)

![packages](https://github.com/user-attachments/assets/056e2044-7e46-4bd0-8aad-6e8f93c8bc4b)

![aur](https://github.com/user-attachments/assets/f5d2c7a2-ea08-4749-ba43-9ef4c3510863)

When the systray icon is left-clicked, `arch-update` is run in a terminal window (alternatively, you can click the "*X* update(s) available" entry or the dedicated "Run Arch-Update" one from the right-click menu):

![run](https://github.com/user-attachments/assets/c776e778-cafc-4713-9bcd-13c871710bef)

If at least one Arch Linux news has been published since the last run, `Arch-Update` will offer you to read the latest Arch Linux news directly from the terminal window.  
The news published since the last run are tagged as `[NEW]`:

![news](https://github.com/user-attachments/assets/44dde466-00bb-4878-8134-c13a9bbb366d)

If no news has been published since the last run, `Arch-Update` directly asks for your confirmation to proceed with update.

From there, just let `Arch-Update` guide you through the various steps required for a complete and proper update of your system! :smile:

Certain options can be enabled, disabled or modified via the `arch-update.conf` configuration file. See the [arch-update.conf(5) man page](https://github.com/Antiz96/arch-update/blob/main/doc/man/arch-update.conf.5.scd) for more details.

## Documentation

### arch-update

See `arch-update --help` and the [arch-update(1) man page](https://github.com/Antiz96/arch-update/blob/main/doc/man/arch-update.1.scd).

### arch-update configuration file

See the [arch-update.conf(5) man page](https://github.com/Antiz96/arch-update/blob/main/doc/man/arch-update.conf.5.scd).

## Tips and tricks

### The systray applet does not start at boot or does not work as expected

Make sure you followed instructions of [this chapter](#the-systray-applet).

If the systray applet doesn't start at boot regardless or if it doesn't work as expected (e.g the icon is missing or the click actions do not act as they should), this could be the result of a [race condition](https://en.wikipedia.org/wiki/Race_condition#In_software).

To prevent that, you can add a small delay to the systray applet startup using the `sleep` command:

- If you used `arch-update --tray --enable`, modify the `Exec=` line in the `arch-update-tray.desktop` file (which is under `~/.config/autostart/` by default), like so:

```text
Exec=sh -c "sleep 3 && arch-update --tray"
```

- If you used the `arch-update-tray.service` systemd service, run `systemctl --user edit --full arch-update-tray.service` and modify the `ExecStart=` line, like so:

```text
ExecStart=sh -c "sleep 3 && arch-update --tray"
```

- If you're using a standalone Window Manager or a Wayland Compositor, modify the command in your "auto-start" apps / your configuration file, like so:

```text
sleep 3 && arch-update --tray
```

If the systray applet still does not start at boot, try to gradually increase the `sleep` value.

### Modify the check cycle

If you enabled the [systemd timer](#the-systemd-timer), a check for available updates is automatically launched at boot and then once per hour.

If you want to customize the check cycle, run `systemctl --user edit --full arch-update.timer` and modify the `OnUnitActiveSec` value to your liking.  
For instance, if you want `Arch-Update` to check for new updates every 10 minutes instead:

```text
[...]
[Timer]
OnStartupSec=15
OnUnitActiveSec=10m
[...]
```

Time units are `s` for seconds, `m` for minutes, `h` for hours, `d` for days...  
See <https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#Parsing%20Time%20Spans> for more details.

In case you want `Arch-Update` to check for new updates only once at boot, you can simply delete the `OnUnitActiveSec` line completely.

### Run Arch-Update in a specific terminal emulator

`gio` (used to launch the `arch-update` terminal application via the `arch-update.desktop` file when the systray applet is clicked) currently has a default limited list of known terminal emulators.  
As such, if you don't have any of these "known" terminal emulators installed on your system, you might face an issue where clicking the systray applet does nothing (as `gio` couldn't find a terminal emulator from the said list). Incidentally, you might have multiple terminal emulators installed on your system. In both cases, you can specify which terminal emulator to use.

To do so, install the [xdg-terminal-exec AUR package](https://aur.archlinux.org/packages/xdg-terminal-exec), create the `~/.config/xdg-terminals.list` file and add the name of the `.desktop` file of your terminal emulator of choice in it (e.g. `Alacritty.desktop`).  
See <https://github.com/Vladimir-csp/xdg-terminal-exec?tab=readme-ov-file#configuration> for more details.

## Contributing

See the [contributing guidelines](https://github.com/Antiz96/arch-update/blob/main/CONTRIBUTING.md).

## License

Arch-Update is licensed under the [GPL-3.0 license](https://github.com/Antiz96/arch-update/blob/main/LICENSE) (or any later version of that license).
