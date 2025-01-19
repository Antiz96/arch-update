arch-update(1) - v3.5.0

# NAME

Arch-Update - An update notifier & applier for Arch Linux that assists you with important pre / post update tasks.

# SYNOPSIS

*arch-update* [OPTION]

# DESCRIPTION

An update notifier & applier for Arch Linux that assists you with important pre / post update tasks and that includes a clickeable systray applet for an easy integration with any panel on any Desktop Environment / Window Manager.

Optional support for:
- AUR packages (via `paru`, `yay` or `pikaur`).
- Flatpak packages (via `flatpak`).
- Desktop notifications (via `libnotify`).

Arch-Update is designed to follow usual system maintenance steps, as described in the Arch Wiki at https://wiki.archlinux.org/title/System_maintenance.

# OPTIONS

If no option is passed, launch the relevant series of functions to perform a complete and proper update, starting by displaying the list of packages available for update and asking for the user's confirmation to proceed with the installation.

It also supports AUR packages update (if `paru`, `yay` or `pikaur` is installed) and Flatpak packages update (if `flatpak` is installed).

Before performing the update, it offers to display the latest Arch Linux news to the user. By default, Arch news are only displayed if at least a new one has been published since the last run. Arch news published since the last run are tagged as *[NEW]*.

Arch-Update also checks for orphan packages, unused Flatpak packages, as well as old and / or uninstalled packages in `pacman`'s cache. It also offers to proccess pacnew & pacsave files, pending kernel update requiring a reboot to be applied, as well as services requiring a post upgrade restart.

Those functions are launched when the systray applet is clicked.

*`-c`, `--check`*
	Check for available updates. If there are, send a desktop notification and update the systray icon.
	The `--check` option is ran automatically at boot and then every hour if you enabled the associated systemd timer with the following command: `systemctl --user enable --now arch-update.timer`.

*`-l`, `--list`*
	Display the list of pending updates.

*`-d`, `--devel`*
	Include AUR development packages updates.

*`-n`, `--news`*
	Display latest Arch news.
	You can optionally specify how much Arch news to display as an argument, like so: `arch-update --news 10`. Defaults to 5.

*`-D`, `--debug`*
	Display debug traces.

*`--gen-config`*
	Generate a default / example `arch-update.conf` configuration file (see the *arch-update.conf(5)* man page for more details).
	You can optionally pass the `--force` argument to overwrite any existing `arch-update.conf` configuration file.

*`--show-config`*
	Display the content of the `arch-update.conf` configuration file (if it exists).

*`--edit-config`*
	Edit the `arch-update.conf` configuration file (if it exists).

*`--tray`*
	Start the Arch-Update systray applet.
	To start it automatically at boot, you can either run the `arch-update --tray --enable` command _(preferred method for most Desktop Environments, uses XDG Autostart)_ or enable the associated systemd service _(in case your Desktop Environment doesn't support XDG Autostart)_ by running `systemctl --user enable --now arch-update-tray.service`.
	If you use a window manager or a Wayland compositor, you can add the `arch-update --tray` command to your auto-start apps in your configuration file instead.

*`-V`, `--version`*
	Display version information.

*-h, --help*
	Display the help message.

Certain options can be enabled, disabled or modified via the `arch-update.conf` configuration file, see the *arch-update.conf(5)* man page for more details.

# USAGE

## The systray applet

To start the systray applet, launch the *Arch-Update Systray Applet* application from your app menu.

To start it automatically at boot, you can either:

- Run the following command _(preferred method for most Desktop Environments, uses XDG Autostart)_: `arch-update --tray --enable`

- Enable the associated systemd service _(in case your Desktop Environment doesn't support XDG Autostart)_: `systemctl --user enable --now arch-update-tray.service`

If you use a Window Manager or a Wayland Compositor, you can add the `arch-update --tray` command to your auto-start apps in your configuration file instead.

If the systray applet doesn't start at boot regardless, please read the *"The systray applet does not start at boot"* chapter in the *"Tips and Tricks"* section below.

The systray icon will automatically change depending on the current state of your system _("up to date" or "updates available")_. When clicked, it launches `arch-update` via the `arch-update.desktop` file.

The systray applet attempts to read the `arch-update.desktop` file at the below paths and in the following order:

- `$XDG_DATA_HOME/applications/arch-update.desktop`

- `$HOME/.local/share/applications/arch-update.desktop`

- `$XDG_DATA_DIRS/applications/arch-update.desktop`

- `/usr/local/share/applications/arch-update.desktop` _<-- Default installation path when installing Arch-Update from source_

- `/usr/share/applications/arch-update.desktop` _<-- Default installation path when installing Arch-Update from the AUR_

In case you want (or need) to customize the `arch-update.desktop` file, copy it in a path that has a higher priority than the default installation path and modify it there (to ensure that your custom `arch-update.desktop` file supersedes the default one and that your modifications are not being overwritten on updates).
This can be useful to force the `arch-update.desktop` file to launch `Arch-Update` within a specific terminal emulator for instance.

If clicking the systray applet does nothing, please read the *"Force the desktop file to run with a specific terminal emulator"* chapter in the *"Tips and Tricks"* section below.

## The systemd timer

There is a systemd service in `/usr/lib/systemd/user/arch-update.service` _(or in `/usr/local/lib/systemd/user/arch-update.service` if you installed `arch-update` from source)_ that executes the `--check` function when started. To start it automatically at boot and then once every hour, enable the associated systemd timer (the auto-check cycle can be modified to your liking. See the *"TIPS AND TRICKS"* chapter below):" `systemctl --user enable --now arch-update.timer`

# TIPS AND TRICKS 

## AUR Support

Arch-Update supports AUR packages if `paru`, `yay` or `pikaur` is installed:
See https://github.com/morganamilo/paru and https://aur.archlinux.org/packages/paru
See https://github.com/Jguer/yay and https://aur.archlinux.org/packages/yay
See https://github.com/actionless/pikaur and https://aur.archlinux.org/packages/pikaur

## Flatpak Support

Arch-Update supports Flatpak packages if `flatpak` is installed:
See https://www.flatpak.org/ and https://archlinux.org/packages/extra/x86_64/flatpak/

## Desktop notifications Support

Arch-Update supports desktop notifications when performing the `--check` function if `libnotify` is installed:
See https://wiki.archlinux.org/title/Desktop_notifications

## The systray applet does not start at boot

Make sure you followed instructions of the *"The systray applet"* chapter in the *"Usage"* section above.

If the systray applet doesn't start regardless, this could be the result of a *race condition*.
In such case, it might be useful to slightly delay the startup of the systray applet by using a `sleep` statement beforehand:

- If you used `arch-update --tray --enable`, modify the `Exec=` line in the `arch-update-tray.desktop` file _(which is under `~/.config/autostart/` by default)_, like so: `Exec=sh -c "sleep 3 && arch-update --tray"`

- If you used the `arch-update-tray.service` systemd service, run `systemctl --user edit --full arch-update-tray.service` and modify the `ExecStart=` line, like so: `ExecStart=sh -c "sleep 3 && arch-update --tray"`

- If you're using a standalone Window Manager or a Wayland Compositor, add a `sleep` statement before the `arch-update --tray` command in your auto-start apps in your configuration file, like so: `sleep 3 && arch-update --tray`

If the systray applet still does not start at boot, try to gradually increase the value of the `sleep`.

## Modify the auto-check cycle

If you enabled the systemd timer, the `--check` function is automatically launched at boot and then once per hour.

If you want to change the check cycle, run `systemctl --user edit --full arch-update.timer` and modify the `OnUnitActiveSec` value to your liking.
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

## Force the desktop file to run with a specific terminal emulator

"gio" (which is used to launch the `arch-update.desktop` file when the systray applet is clicked) currently supports a limited list of terminal emulators (see https://gitlab.gnome.org/GNOME/glib/-/blob/main/gio/gdesktopappinfo.c#L2701).

If you don't have any of these terminal emulators installed on your system, you might face an issue where clicking the systray applet does nothing and reports the following error: "[...] Unable to find terminal required for application".

While waiting for Gnome to implement a way to allow people using their terminal emulator of choice with `gio`, you can workaround this issue by copying the `arch-update.desktop` file to `$HOME/.local/share/applications/arch-update.desktop` (for instance, see *"The systray applet"* chapter for more details) and modifying the `Exec=` line in it to 'force' `arch-update` to run with your terminal emulator of choice.

For instance, with "alacritty" _(check your terminal emulator's manual to find the correct option to use)_:

```
[...]
Exec=alacritty -e arch-update
```

Alternatively, you can create a symlink for your terminal emulator that points to `/usr/bin/xterm`, which is the fallback option for `gio` (for instance, with "alacritty": `sudo ln -s /usr/bin/alacritty /usr/bin/xterm`) or you can simply install one of the terminal emulators supported by `gio` (see https://gitlab.gnome.org/GNOME/glib/-/blob/main/gio/gdesktopappinfo.c#L2701).

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
	Error when updating the packages.

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
	The diff prog editor set in the `arch-update.conf` configuration file isn't found.

# SEE ALSO

*checkupdates (8)*
*pacman (8)*
*pacdiff (8)*
*paccache (8)*
*paru (8)*
*yay (8)*
*pikaur (1)*
*flatpak (1)*
*arch-update.conf (5)*

# BUGS

Please report bugs to the GitHub page: https://github.com/Antiz96/arch-update/issues

# AUTHOR

Robin Candau <robincandau@protonmail.com>
