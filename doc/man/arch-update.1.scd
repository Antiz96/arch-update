arch-update(1) ["Arch-Update 3.6.1" ["Arch-Update Manual"]]

# NAME

Arch-Update - An update notifier & applier for Arch Linux that assists you with important pre / post update tasks.

# SYNOPSIS

*arch-update* [OPTION]

# DESCRIPTION

An update notifier & applier for Arch Linux that assists you with important pre / post update tasks.
Includes a dynamic & clickeable systray applet for an easy integration with any Desktop Environment / Window Manager.

Arch-Update is designed to follow usual system maintenance steps, as described in the Arch Wiki at https://wiki.archlinux.org/title/System_maintenance.

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

# OPTIONS

If no option is passed, launch the relevant series of functions to perform a complete and proper system update (can also be triggered by clicking the systray applet).

*-c, --check*
	Check for available updates. If there are, send a desktop notification and update the systray icon.
	To run the `--check` option automatically and periodically, see the *"The systemd timer"* chapter in the *"USAGE"* section below.

*-l, --list*
	Display the list of pending updates.

*d, --devel*
	Include AUR development packages updates.

*-n, --news*
	Display latest Arch news.
	You can optionally specify how much Arch news to display as an argument, like so: `arch-update --news 10`. Defaults to 5.

*-D, --debug*
	Display debug traces.

*--gen-config*
	Generate a default / example `arch-update.conf` configuration file (see the *arch-update.conf*(5) man page for more details).
	You can optionally pass the `--force` argument to overwrite any existing `arch-update.conf` configuration file.

*--show-config*
	Display the content of the `arch-update.conf` configuration file (if it exists).

*--edit-config*
	Edit the `arch-update.conf` configuration file (if it exists).

*--tray*
	Start the Arch-Update systray applet.
	To start it automatically at boot, see the *"The systray applet"* chapter in the *"USAGE"* section below.

*-V, --version*
	Display version information.

*-h, --help*
	Display the help message.

Certain options can be enabled, disabled or modified via the `arch-update.conf` configuration file, see the *arch-update.conf*(5) man page for more details.

# USAGE

The usage consist of starting the systray applet and enabling the systemd timer.

## The systray applet

To start the systray applet, launch the *Arch-Update Systray Applet* application from your app menu.

To start it automatically at boot, you can either:

- Run the following command (preferred method for most Desktop Environments, uses XDG Autostart): 

```
arch-update --tray --enable
```

- Enable the associated systemd service (in case your Desktop Environment doesn't support XDG Autostart): 

```
systemctl --user enable --now arch-update-tray.service
```

- Add the following command to your "auto-start" apps / configuration file (in case you use a Window Manager or a Wayland Compositor):

```
arch-update --tray
```

*If the systray applet doesn't start at boot regardless*, please read the *"The systray applet does not start at boot"* chapter in the *"TIPS AND TRICKS"* section below.

The systray icon dynamically changes to indicate the current state of your system ("up to date" or "updates available"). When clicked, it launches `arch-update` in a terminal window via the `arch-update.desktop` file.

*If clicking the systray applet does nothing*, please read the *"Run Arch-Update in a specific terminal emulator"* chapter in the *"TIPS AND TRICKS"* section below.

## The systemd timer

To perform automatic and periodic checks for available updates, enable the associated systemd timer:

```
systemctl --user enable --now arch-update.timer
```

By default, a check is performed at *boot and then once every hour*. The check cycle can be customized, see the *"Modify the check cycle"* chapter in the *"TIPS AND TRICKS"* section below.

# TIPS AND TRICKS 

## The systray applet does not start at boot

Make sure you followed instructions of the *"The systray applet"* chapter in the *"USAGE"* section above.

If the systray applet doesn't start regardless, this could be the result of a *race condition*.
To prevent that, you can add a small delay to the systray applet startup using the `sleep` command:

- If you used `arch-update --tray --enable`, modify the `Exec=` line in the `arch-update-tray.desktop` file (which is under `~/.config/autostart/` by default), like so: 

```
[...]
Exec=sh -c "sleep 3 && arch-update --tray"
[...]
```

- If you used the `arch-update-tray.service` systemd service, run `systemctl --user edit --full arch-update-tray.service` and modify the `ExecStart=` line, like so:

```
[...]
ExecStart=sh -c "sleep 3 && arch-update --tray"
[...]
```

- If you're using a standalone Window Manager or a Wayland Compositor, modify the command in your "auto-start" apps / your configuration file, like so:

```
[...]
sleep 3 && arch-update --tray
[...]
```

If the systray applet still does not start at boot, try to gradually increase the `sleep` value.

## Modify the check cycle

If you enabled the systemd timer, a check for available updates is automatically launched at boot and then once per hour.

If you want to customize the check cycle, run `systemctl --user edit --full arch-update.timer` and modify the `OnUnitActiveSec` value to your liking.
For instance, if you want `Arch-Update` to check for new updates every 10 minutes instead:

```
[...]
[Timer]
OnStartupSec=15
OnUnitActiveSec=10m
[...]
```

Time units are *s* for seconds, *m* for minutes, *h* for hours, *d* for days...
See https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#Parsing%20Time%20Spans for more details.

In case you want `Arch-Update` to check for new updates only once at boot, you can simply delete the `OnUnitActiveSec` line completely.

## Run Arch-Update in a specific terminal emulator

"gio" (used to launch the `arch-update` terminal application via the `arch-update.desktop` file when the systray applet is clicked) currently has a default limited list of known terminal emulators.  
As such, if you don't have any of these "known" terminal emulators installed on your system, you might face an issue where clicking the systray applet does nothing (as `gio` couldn't find a terminal emulator from the said list). Incidentally, you might have multiple terminal emulators installed on your system. In both cases, you can specify which terminal emulator to use.

To do so, install the `xdg-terminal-exec` AUR package (https://aur.archlinux.org/packages/xdg-terminal-exec), create the `~/.config/xdg-terminals.list` file and add the name of the `.desktop` file of your terminal emulator of choice in it (e.g. `Alacritty.desktop`).

See https://github.com/Vladimir-csp/xdg-terminal-exec?tab=readme-ov-file#configuration for more details.

# EXIT STATUS

*0*
	OK.

*1*
	Invalid option.

*2*
	No privilege elevation command (`sudo`, `doas` or `run0`) is installed or the one set in the `arch-update.conf` configuration file isn't found.

*3*
	Error when launching the Arch-Update systray applet.

*4*
	User didn't gave the confirmation to proceed.

*5*
	Error when updating packages.

*6*
	Error when calling the reboot command to apply a pending kernel update.

*7*
	No pending update when using the `-l / --list` option.

*8*
	Error when generating a configuration file with the `--gen-config` option.

*9*
	Error when reading the configuration file with the `--show-config` option.

*10*
	Error when creating the autostart desktop file for the systray applet with the `--tray --enable` option.

*11*
	Error when restarting services that require a post upgrade restart.

*12*
	Error during the pacnew files processing.

*13*
	Error when editing the configuration file with the `--edit-config` option.

*14*
	Libraries directory not found.

*15*
	The "diff prog" editor set in the `arch-update.conf` configuration file isn't found.

# SEE ALSO

*checkupdates*(8),
*pacman*(8),
*pacdiff*(8),
*paccache*(8),
*paru*(8),
*yay*(8),
*pikaur*(1),
*flatpak*(1),
*arch-update.conf*(5)

# BUGS

Please report bugs to the GitHub page: https://github.com/Antiz96/arch-update/issues

# AUTHOR

Robin Candau <robincandau@protonmail.com>
