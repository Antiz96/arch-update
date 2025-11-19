#!/usr/bin/env python3

# arch-update-tray: A systray applet for Arch-Update
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

"""Arch-Update System Tray"""
import gettext
import logging
import os
import sys
import subprocess
import time
import json
from math import floor
from PyQt6.QtGui import QIcon, QAction
from PyQt6.QtWidgets import QApplication, QSystemTrayIcon, QMenu
from PyQt6.QtCore import QFileSystemWatcher

# Create logger
log = logging.getLogger(__name__)

# Find Icon statefile
ICON_STATEFILE = None

if 'XDG_STATE_HOME' in os.environ:
    ICON_STATEFILE = os.path.join(
        os.environ['XDG_STATE_HOME'], 'arch-update', 'tray_icon')
elif 'HOME' in os.environ:
    ICON_STATEFILE = os.path.join(
        os.environ['HOME'], '.local', 'state', 'arch-update', 'tray_icon')
if not os.path.isfile(ICON_STATEFILE):
    log.error("State icon file does not exist: %s", ICON_STATEFILE)
    sys.exit(1)

# Find Updates statefiles
UPDATES_STATEFILE = None
UPDATES_STATEFILE_PACKAGES = None
UPDATES_STATEFILE_AUR = None
UPDATES_STATEFILE_FLATPAK = None

if 'XDG_STATE_HOME' in os.environ:
    UPDATES_STATEFILE = os.path.join(
        os.environ['XDG_STATE_HOME'], 'arch-update', 'last_updates_check')
    UPDATES_STATEFILE_PACKAGES = os.path.join(
        os.environ['XDG_STATE_HOME'], 'arch-update', 'last_updates_check_packages')
    UPDATES_STATEFILE_AUR = os.path.join(
        os.environ['XDG_STATE_HOME'], 'arch-update', 'last_updates_check_aur')
    UPDATES_STATEFILE_FLATPAK = os.path.join(
        os.environ['XDG_STATE_HOME'], 'arch-update', 'last_updates_check_flatpak')
elif 'HOME' in os.environ:
    UPDATES_STATEFILE = os.path.join(
        os.environ['HOME'], '.local', 'state', 'arch-update', 'last_updates_check')
    UPDATES_STATEFILE_PACKAGES = os.path.join(
        os.environ['HOME'], '.local', 'state', 'arch-update', 'last_updates_check_packages')
    UPDATES_STATEFILE_AUR = os.path.join(
        os.environ['HOME'], '.local', 'state', 'arch-update', 'last_updates_check_aur')
    UPDATES_STATEFILE_FLATPAK = os.path.join(
        os.environ['HOME'], '.local', 'state', 'arch-update', 'last_updates_check_flatpak')
if not os.path.isfile(UPDATES_STATEFILE):
    log.error("State updates file does not exist: %s", UPDATES_STATEFILE)

# Check where the translation files are installed (depending on the PREFIX used during the installation) to set the localedir
i18n_paths = []

if 'XDG_DATA_HOME' in os.environ:
    i18n_paths.extend(os.environ['XDG_DATA_HOME'].split(":"))
if 'HOME' in os.environ:
    i18n_paths.append(os.path.join(
        os.environ['HOME'], '.local', 'share'))
if 'XDG_DATA_DIRS' in os.environ:
    i18n_paths.extend(os.environ['XDG_DATA_DIRS'].split(":"))
i18n_paths.extend(['/usr/local/share', '/usr/share'])
_ = None

for path in i18n_paths:
    translation_file = os.path.join(
        path, "locale", "fr", "LC_MESSAGES", "Arch-Update.mo")
    if os.path.isfile(translation_file):
        path = os.path.join(path, 'locale')
        t = gettext.translation('Arch-Update', localedir=path, fallback=True)
        _ = t.gettext
        break
if not _:
    t = gettext.translation('Arch-Update', fallback=True)
    _ = t.gettext
    log.error("No translation found")

# Launch arch-update with desktop file
def arch_update():
    """Launch with desktop file"""
    DESKTOP_FILE = None
    if 'XDG_DATA_HOME' in os.environ:
        DESKTOP_FILE = os.path.join(
            os.environ['XDG_DATA_HOME'], 'applications', 'arch-update.desktop')
    if not DESKTOP_FILE or not os.path.isfile(DESKTOP_FILE):
        if 'HOME' in os.environ:
            DESKTOP_FILE = os.path.join(
                os.environ['HOME'], '.local', 'share', 'applications', 'arch-update.desktop')
    if not DESKTOP_FILE or not os.path.isfile(DESKTOP_FILE):
        if 'XDG_DATA_DIRS' in os.environ:
            DESKTOP_FILE = os.path.join(
                os.environ['XDG_DATA_DIRS'], 'applications', 'arch-update.desktop')
    if not DESKTOP_FILE or not os.path.isfile(DESKTOP_FILE):
        DESKTOP_FILE = "/usr/local/share/applications/arch-update.desktop"
    if not os.path.isfile(DESKTOP_FILE):
        DESKTOP_FILE = "/usr/share/applications/arch-update.desktop"
    subprocess.run(["gio", "launch", DESKTOP_FILE], check=False)

# Helper function to extract human-readable duration from systemctl JSON output
def get_next_check_duration_human_readable(input_json):
    """Calculate human-readable duration from systemctl output"""
    result = None
    timer_json = json.loads(input_json)
    if timer_json:
        next_microseconds = timer_json[0].get("next")
        if next_microseconds:
            seconds = floor((next_microseconds - int(time.time() * 1_000_000))/1_000_000)
            days = floor(seconds/86400)
            hours = floor((seconds % 86400) / 3600)
            minutes = floor((seconds % 3600) / 60)
            seconds = floor(seconds % 60)
            parts = []
            if days > 0:
                parts.append(f"{days}d")
            if hours > 0:
                parts.append(f"{hours}h")
            if minutes > 0:
                parts.append(f"{minutes}m")
            if seconds > 0:
                parts.append(f"{seconds}s")
            if parts:
                result = " ".join(parts)
    return result

# User Interface
class ArchUpdateQt6:
    """System Tray using QT6 library"""

    # Definition of functions to update the icon and dropdown menus when their respective state files content change
    def file_changed(self):
        """Update icon and dropdown menus"""
        self.update_icon()
        self.update_dropdown_menus()

    # Update the icon based on the 'tray_icon' statefile content
    def update_icon(self):
        """Update icon"""
        if self.watcher and not self.iconfile in self.watcher.files():
            self.watcher.addPath(self.iconfile)

        try:
            with open(self.iconfile, encoding="utf-8") as f:
                contents = f.readline().strip()
        except FileNotFoundError:
            log.error("Statefile Missing")
            sys.exit(1)

        if contents.startswith("cachy-update"):
            icon = QIcon.fromTheme(contents)
            self.tray.setIcon(icon)

    # Open packages upstream URL in browser when clicked
    def showUpdate(self, update):
        """Open upstream URL in browser"""
        package = update.split(' ')[0]
        if not package:
            return
        with subprocess.Popen(["/usr/bin/pacman", "-Qi", package], stdout=subprocess.PIPE, stderr=subprocess.PIPE) as p:
            stdout, _ = p.communicate()
        if p.returncode != 0:
            return
        outs = stdout.decode()
        for line in outs.splitlines():
            if line.startswith("URL"):
                parts = line.split(":", 1)
                print(parts)
                if len(parts) < 2:
                    return
                url = parts[1].strip()
                # Make sure to only send URLs to xdg-open
                if url.startswith("http://") or url.startswith("https://"):
                    subprocess.run(["xdg-open", url], check=False)

    # Update dropdown menus based on the state files content
    def update_dropdown_menus(self):
        """Update dropdown menus"""
        # Check presence of state files
        last_check_time = "never"
        if self.watcher and not self.updatesfile in self.watcher.files():
            self.watcher.addPath(self.updatesfile)

        try:
            with open(self.updatesfile, encoding="utf-8") as f:
                updates_list = f.readlines()
                last_check_time = time.strftime("%d %b %H:%M:%S", time.localtime(os.path.getmtime(self.updatesfile)))
        except FileNotFoundError:
            log.error("State updates file missing")
            self.menu_count.setText(_("'updates' state file isn't found"))
            return

        if self.watcher and not self.updatesfilepkg in self.watcher.files():
            self.watcher.addPath(self.updatesfilepkg)

        try:
            with open(self.updatesfilepkg, encoding="utf-8") as f:
                updates_list_pkg = f.readlines()
        except FileNotFoundError:
            log.error("State updatespkg file missing")
            return

        if self.watcher and not self.updatesfileaur in self.watcher.files():
            self.watcher.addPath(self.updatesfileaur)

        try:
            with open(self.updatesfileaur, encoding="utf-8") as f:
                updates_list_aur = f.readlines()
        except FileNotFoundError:
            log.error("State updatesaur file missing")
            return

        if self.watcher and not self.updatesfileflatpak in self.watcher.files():
            self.watcher.addPath(self.updatesfileflatpak)

        try:
            with open(self.updatesfileflatpak, encoding="utf-8") as f:
                updates_list_flatpak = f.readlines()
        except FileNotFoundError:
            log.error("State updatesflatpak file missing")
            return

        # Remove empty lines from statefiles
        updates_list = [update.strip() for update in updates_list if update.strip()]
        updates_list_pkg = [update.strip() for update in updates_list_pkg if update.strip()]
        updates_list_aur = [update.strip() for update in updates_list_aur if update.strip()]
        updates_list_flatpak = [update.strip() for update in updates_list_flatpak if update.strip()]

        # Count the number of pending updates (according to the number of lines of statefiles)
        updates_count = len(updates_list)
        updates_count_pkg = len(updates_list_pkg)
        updates_count_aur = len(updates_list_aur)
        updates_count_flatpak = len(updates_list_flatpak)

        # Update the update main menu title accordingly
        if updates_count == 0:
            self.menu_count.setText(_("System is up to date"))
            self.menu_count.setEnabled(False)
        elif updates_count == 1:
            self.menu_count.setText(_("1 update available"))
            self.menu_count.setEnabled(True)
        else:
            self.menu_count.setText(_("{updates} updates available").format(updates=updates_count))
            self.menu_count.setEnabled(True)

        # Update last check timestamp (always False to not pull unwanted attention)
        self.menu_last_check.setText(_("Last check:\n{time}").format(time=last_check_time))
        self.menu_last_check.setEnabled(False)

        # Update next check timestamp (always False to not pull unwanted attention)
        timer_left = subprocess.run(
            "/usr/bin/systemctl --user list-timers arch-update.timer -o json",
            check=False,
            shell=True,
            capture_output=True,
            text=True,
            timeout=1,
        )
        next_check_output = get_next_check_duration_human_readable(timer_left.stdout.strip())

        if next_check_output:
            self.menu_next_check = QAction(_("Next check in {time}").format(time=next_check_output))
            self.menu_next_check.setEnabled(False)
        else:
            self.menu_next_check = None

        # Clear the menu (to update entries)
        self.menu.clear()
        self.menu.addAction(self.menu_count)

        # Add / update dropdown menus if there's at least one available update, remove it otherwise
        if (updates_count_pkg >= 1) + (updates_count_aur >=1) + (updates_count_flatpak >=1) >= 2:
            self.dropdown_menu_all.setTitle(_("All ({updates})").format(updates=updates_count))
            self.dropdown_menu_all.setEnabled(True)
            self.dropdown_menu_all.clear()
            for update in [*updates_list_pkg, *updates_list_aur]:
                action = self.dropdown_menu_all.addAction(update)
                action.triggered.connect(lambda x, update=update: self.showUpdate(update))
            for update in updates_list_flatpak:
                self.dropdown_menu_all.addAction(update)
            self.menu.addMenu(self.dropdown_menu_all)
        else:
            self.menu.removeAction(self.dropdown_menu_all.menuAction())

        if updates_count_pkg >= 1:
            self.dropdown_menu_pkg.setTitle(_("Packages ({updates})").format(updates=updates_count_pkg))
            self.dropdown_menu_pkg.setEnabled(True)
            self.dropdown_menu_pkg.clear()
            for update in updates_list_pkg:
                action = self.dropdown_menu_pkg.addAction(update)
                action.triggered.connect(lambda x, update=update: self.showUpdate(update))
            self.menu.addMenu(self.dropdown_menu_pkg)
        else:
            self.menu.removeAction(self.dropdown_menu_pkg.menuAction())

        if updates_count_aur >= 1:
            self.dropdown_menu_aur.setTitle(_("AUR ({updates})").format(updates=updates_count_aur))
            self.dropdown_menu_aur.setEnabled(True)
            self.dropdown_menu_aur.clear()
            for update in updates_list_aur:
                action = self.dropdown_menu_aur.addAction(update)
                action.triggered.connect(lambda x, update=update: self.showUpdate(update))
            self.menu.addMenu(self.dropdown_menu_aur)
        else:
            self.menu.removeAction(self.dropdown_menu_aur.menuAction())

        if updates_count_flatpak >= 1:
            self.dropdown_menu_flatpak.setTitle(_("Flatpak ({updates})").format(updates=updates_count_flatpak))
            self.dropdown_menu_flatpak.setEnabled(True)
            self.dropdown_menu_flatpak.clear()
            for update in updates_list_flatpak:
                self.dropdown_menu_flatpak.addAction(update)
            self.menu.addMenu(self.dropdown_menu_flatpak)
        else:
            self.menu.removeAction(self.dropdown_menu_flatpak.menuAction())

        # Add check timestamps (after updates list)
        if updates_count >= 1:
            self.menu.addSeparator()
        self.menu.addAction(self.menu_last_check)
        if self.menu_next_check:
            self.menu.addAction(self.menu_next_check)

        # Restore static menu entries (after clearing the menu)
        self.menu.addSeparator()
        self.menu.addAction(self.menu_launch)
        self.menu.addAction(self.menu_check)
        self.menu.addAction(self.menu_exit)

    # Action to run the arch_update function
    def run(self, reason):
        """Run arch-update"""
        if reason in (QSystemTrayIcon.ActivationReason.Trigger, QSystemTrayIcon.ActivationReason.MiddleClick, "menu_click_action"):
            arch_update()

    # Action to run `arch-update --check`
    def check(self):
        """Run check for updates"""
        subprocess.run(["arch-update", "--check"], check=False)

    # Action to exit the systray
    def exit(self):
        """Exit systray"""
        sys.exit(0)

    # Start the systray
    def __init__(self, iconfile):
        """Start Qt6 System Tray"""

        # Variables definition
        self.iconfile = iconfile
        self.updatesfile = UPDATES_STATEFILE
        self.updatesfilepkg = UPDATES_STATEFILE_PACKAGES
        self.updatesfileaur = UPDATES_STATEFILE_AUR
        self.updatesfileflatpak = UPDATES_STATEFILE_FLATPAK
        self.watcher = None

        # General application parameters
        app = QApplication(["Arch-Update"])
        app.setQuitOnLastWindowClosed(False)

        # Icon
        self.tray = QSystemTrayIcon()
        self.tray.setVisible(True)
        self.tray.activated.connect(self.run)

        # Tooltip
        tooltip = _("Cachy-Update")
        self.tray.setToolTip(tooltip)

        # Definition of menus titles
        self.menu = QMenu()
        self.menu_count = QAction(_("Arch-Update"))
        self.menu_last_check = QAction(_("Last check"))
        self.menu_next_check = QAction(_("Next check"))
        self.menu_launch = QAction(_("Run Cachy-Update"))
        self.menu_check = QAction(_("Check for updates"))
        self.menu_exit = QAction(_("Exit"))

        # Initialisation of the dynamic dropdown menus
        self.dropdown_menu_all = QMenu(_("All"))
        self.dropdown_menu_pkg = QMenu(_("Packages"))
        self.dropdown_menu_aur = QMenu(_("AUR"))
        self.dropdown_menu_flatpak = QMenu(_("Flatpak"))

        # Link actions to the menu
        self.menu.addAction(self.menu_count)
        self.menu.addAction(self.menu_last_check)
        self.menu.aboutToShow.connect(self.update_dropdown_menus) # Function connector for the menu_next_check entry
        self.menu.addSeparator()
        self.menu.addAction(self.menu_launch)
        self.menu.addAction(self.menu_check)
        self.menu.addAction(self.menu_exit)

        self.menu_count.triggered.connect(lambda: self.run("menu_click_action"))
        self.menu_launch.triggered.connect(lambda: self.run("menu_click_action"))
        self.menu_check.triggered.connect(self.check)
        self.menu_exit.triggered.connect(self.exit)

        self.tray.setContextMenu(self.menu)

        # File Watcher (watches for statefiles content changes)
        self.watcher = QFileSystemWatcher([self.iconfile, self.updatesfile, self.updatesfilepkg, self.updatesfileaur, self.updatesfileflatpak])
        self.watcher.fileChanged.connect(self.file_changed)

        # Initial file check to set the right icon and dynamic menu text
        self.file_changed()

        app.exec()

if __name__ == "__main__":
    ArchUpdateQt6(ICON_STATEFILE)
