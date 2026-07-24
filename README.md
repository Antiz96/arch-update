# Arch-Update

<p align="center">
  <img width="460" height="300" src="https://github.com/user-attachments/assets/5782bd11-084a-4ca3-b599-1c322ee11b84">
</p>

## Table of contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Tips & tricks and troubleshooting](#tips--tricks-and-troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Description

An interactive update notifier & applier for Arch Linux that assists you with important pre / post update tasks.  
Includes a systray applet for an easy integration with any desktop / graphical environment.

Arch-Update is designed to follow usual system maintenance steps, as [described in the Arch Wiki](https://wiki.archlinux.org/title/System_maintenance).

Features:

- Automatic check and listing of available updates.
- Check for recent Arch Linux news (and offers to display them if there are).
- Check for orphan packages (and offers to remove them if there are).
- Check for old & uninstalled packages in cache (and offers to remove them if there are).
- Check for pacnew & pacsave files (and offers to process them if there are).
- Check for pending kernel update requiring a reboot (and offers to do so if there's one).
- Check for services requiring a post upgrade restart (and offers to do so if there are).
- Support for `sudo`, `sudo-rs`, `doas` & `run0`.
- Extensive CLI.

Optional support for:

- AUR packages (via `paru`, `yay` or `pikaur`).
- Flatpak packages (via `flatpak`).
- Desktop notifications (via `libnotify`).
- Check for ALHP build queue or outdated mirrors (via `alhp-utils`).

## Installation

### AUR

Install the [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package") AUR package (also check the list of optional dependencies for anything you may want or need).

### From Source

Install required runtime dependencies:

```bash
sudo pacman -S --needed bash systemd pacman pacman-contrib archlinux-contrib glibc libgcc curl fakeroot htmlq diffutils hicolor-icon-theme glib2 xdg-utils util-linux
```

Additional optional dependencies you might want or need:

- [paru](https://aur.archlinux.org/packages/paru): AUR Packages support
- [yay](https://aur.archlinux.org/packages/yay): AUR Packages support
- [pikaur](https://aur.archlinux.org/packages/pikaur): AUR Packages support
- [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/): Flatpak Packages support
- [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify/): Desktop notifications support on new available updates (see <https://wiki.archlinux.org/title/Desktop_notifications>)
- [alhp-utils](https://aur.archlinux.org/packages/alhp-utils): Check for ALHP build queue or outdated mirrors
- [vim](https://archlinux.org/packages/extra/x86_64/vim/): Default diff program for pacdiff
- [neovim](https://archlinux.org/packages/extra/x86_64/neovim/): Default diff program for pacdiff if `EDITOR=nvim`
- [sudo](https://archlinux.org/packages/core/x86_64/sudo/): Privilege elevation
- [sudo-rs](https://archlinux.org/packages/extra/x86_64/sudo-rs/): Privilege elevation
- [opendoas](https://archlinux.org/packages/extra/x86_64/opendoas/): Privilege elevation

Install required build dependencies:

```bash
sudo pacman -S --asdeps make scdoc bats cargo
```

Download the archive of the [latest stable release](https://github.com/Antiz96/arch-update/releases/latest) and extract it (alternatively, you can clone this repository with `git`).

To build and install `arch-update`, go into the extracted / cloned directory and run the following commands:

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

For desktop machines, the usage consist of starting [the systray applet](#the-systray-applet) and enabling [the automated updates checks](#automated-updates-check).  
For headless machines, `Arch-Update` includes an extensive CLI.

### The systray applet

To start the systray applet and enable it automatically at boot, run the following command (preferred method for most environments, uses [XDG Autostart](https://wiki.archlinux.org/title/XDG_Autostart)):

```bash
arch-update --tray --enable
```

In case your graphical environment doesn't support XDG Autostart, add the following command your environment auto-start method instead:

```bash
arch-update --tray
```

The systray icon dynamically changes to indicate the current state of your system ('up to date' or 'updates available'). When clicked, it launches `arch-update` in a terminal window via the [arch-update.desktop](https://github.com/Antiz96/arch-update/blob/main/res/desktop/arch-update.desktop) file.  
The systray applet menu shows further information (like the list of pending updates, time of the last and next checks, ...) and allows to trigger specific actions (like running Arch-Update, check for updates, ...). See [screenshots](#screenshots) for more details.

**If the systray applet doesn't start at boot regardless or if it doesn't work as expected** (e.g the icon is missing or the click actions do not act as they should), please read [this chapter](#the-systray-applet-does-not-start-at-boot-or-does-not-work-as-expected).  
**If clicking the systray applet does nothing**, please read [this chapter](#run-arch-update-in-a-specific-terminal-emulator).

**Note:** GNOME shell does not support systray icons natively, GNOME users need to install the ["AppIndicator and KStatusNotifierItem Support" extension](https://extensions.gnome.org/extension/615/appindicator-support/) for the systray applet to work.

### Automated updates check

To enable automated and periodic checks for available updates, run the following command:

```bash
arch-update --check --enable
```

By default, a check is performed **at boot and then once every 6 hours**. The check cycle can be customized, see [this chapter](#modify-the-check-cycle).

### Screenshots

Once started, the systray applet appears in the systray area of your panel.  
It is the icon at the right of the 'coffee cup' one in the screenshot below (note that there are [different color variants available](https://github.com/Antiz96/arch-update/blob/main/res/icons/README.md) for it):

![icon](https://github.com/user-attachments/assets/ec5f4ab7-7eb0-4c41-8b2b-9983e789d516)

With [the automated updates checks](#the-automated-updates-checks) enabled, checks for updates are automatically and periodically performed, but you can manually trigger one from the systray applet icon by right-clicking it and then clicking on the `Check for updates` menu entry. You can also see timestamps report for the last and next update checks:

![check_for_updates](https://github.com/user-attachments/assets/4b73946d-f9f5-4be6-87b8-42112fca642d)

If there are new available updates, the systray icon shows a red circle and a desktop notification indicating the number of available updates is sent. You can directly run Arch-Update from it or close / dismiss it thanks to the related click actions:

![notif](https://github.com/user-attachments/assets/d96b1831-fc11-4343-9f81-eee2a906961b)

You can see the list of available updates from the menu by right-clicking the systray icon.  
A dropdown menu displaying the number and the list of pending updates is dynamically created for each sources that have some (Packages, AUR, Flatpak).  
A "All" dropdown menu gathering the number and the list of pending updates for all sources is dynamically created if at least 2 different sources have pending updates:

*Clicking on the entry for a package opens the upstream project's URL in your web browser (except for Flatpak packages).*

![all](https://github.com/user-attachments/assets/f1a6a6de-ac06-4234-a0a8-e5dd326bb5a0)

![packages](https://github.com/user-attachments/assets/f94dfe9f-95b1-46fc-a5fe-fbc8adc704ad)

![aur](https://github.com/user-attachments/assets/cf9cd829-fc97-4a05-9a6a-f5cba1649e29)

When the systray icon is left-clicked, `arch-update` is run in a terminal window (alternatively, you can click the "*X* update(s) available" entry or the dedicated "Run Arch-Update" one from the right-click menu):

![run](https://github.com/user-attachments/assets/874e4f9e-4498-41bf-b257-1e5ecb782377)

If at least one Arch Linux news has been published since the last run, `Arch-Update` will offer you to read the latest Arch Linux news directly from the terminal window.  
The news published since the last run are tagged as `[NEW]`:

![news](https://github.com/user-attachments/assets/42472294-ce87-4d86-87fc-3adb0f6f3e9e)

If no news has been published since the last run, `Arch-Update` directly asks for your confirmation to proceed with update.

From there, just let `Arch-Update` guide you through the various steps required for a complete and proper update of your system! :smile:

Certain options can be enabled, disabled or modified via the `arch-update.conf` configuration file. See the [arch-update.conf(5) man page](https://raw.githubusercontent.com/Antiz96/arch-update/refs/heads/main/doc/man/arch-update.conf.5.scd) for more details.

## Documentation

### arch-update

See `arch-update --help` and the [arch-update(1) man page](https://raw.githubusercontent.com/Antiz96/arch-update/refs/heads/main/doc/man/arch-update.1.scd).

### arch-update configuration file

See the [arch-update.conf(5) man page](https://raw.githubusercontent.com/Antiz96/arch-update/refs/heads/main/doc/man/arch-update.conf.5.scd).

## Tips & tricks and troubleshooting

### Automated updates checks

#### Modify the check cycle

If you enabled the [automated updates checks](#automated-updates-checks), a check for available updates is automatically launched at boot and then once each 6 hours.

If you want to customize the check cycle, run `systemctl --user edit --full arch-update.timer` and modify the `OnUnitActiveSec` value to your liking.  
For instance, if you want `Arch-Update` to check for new updates every 4 hours instead:

```text
[...]
[Timer]
OnStartupSec=15
OnUnitActiveSec=4h
[...]
```

Time units are `s` for seconds, `m` for minutes, `h` for hours, `d` for days...  
See <https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#Parsing%20Time%20Spans> for more details.

In case you want `Arch-Update` to check for new updates only once at boot, you can simply delete the `OnUnitActiveSec` line completely.

### Systray applet

**Note:** GNOME shell does not support systray icons natively, GNOME users need to install the ["AppIndicator and KStatusNotifierItem Support" extension](https://extensions.gnome.org/extension/615/appindicator-support/) for the systray applet to work.

#### The systray applet does not start at boot or does not work as expected

Make sure you followed instructions of [this chapter](#the-systray-applet).

If the systray applet doesn't start at boot regardless or if it doesn't work as expected (e.g the icon is missing or the click actions do not act as they should), this could be the result of a [race condition](https://en.wikipedia.org/wiki/Race_condition#In_software).

To prevent that, you can add a small delay to the systray applet startup using the `sleep` command:

- If you used `arch-update --tray --enable`, modify the `Exec=` line in the `arch-update-tray.desktop` file (which is under `~/.config/autostart/` by default) like so:

```text
Exec=/bin/sh -c "sleep 3 && arch-update --tray"
```

- If you added the `arch-update --tray` command to the auto-start method of your environment, modify the command like so:

```text
sleep 3 && arch-update --tray
```

If the systray applet still does not start at boot, you can eventually try to gradually increase the `sleep` value.  
Otherwise, feel free to [open a bug report](https://github.com/Antiz96/arch-update/issues/new?template=bug-report.md).

#### Run Arch-Update in a specific terminal emulator

`gio` (used to launch the `arch-update` terminal application via the `arch-update.desktop` file when the systray applet is clicked) currently has a default limited list of known terminal emulators.  
As such, if you don't have any of these "known" terminal emulators installed on your system, you might face an issue where clicking the systray applet does nothing (as `gio` couldn't find a terminal emulator from the said list). Incidentally, you might have multiple terminal emulators installed on your system and you may want to force Arch-Update to use a specific one. In both cases, you can specify which terminal emulator to use.

To do so, install the [xdg-terminal-exec AUR package](https://aur.archlinux.org/packages/xdg-terminal-exec), create the `~/.config/xdg-terminals.list` file and add the name of the `.desktop` file of your terminal emulator of choice in it (e.g. `Alacritty.desktop`).  
See <https://github.com/Vladimir-csp/xdg-terminal-exec?tab=readme-ov-file#configuration> for more details.

## Contributing

See the [contributing guidelines](https://github.com/Antiz96/arch-update/blob/main/CONTRIBUTING.md).

## License

Arch-Update is licensed under the [GPL-3.0 license](https://github.com/Antiz96/arch-update/blob/main/LICENSE) (or any later version of that license).
