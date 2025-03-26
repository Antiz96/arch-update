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
UPDATES_STATEFILE_PACKAGE = None
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

# User Interface
class ArchUpdateQt6:
    """System Tray using QT6 library"""

    # Definition of functions to update the icon and the dropdown menu when their respective state files content change
    def file_changed(self):
        """Update icon and dropdown menu"""
        self.update_icon()
        self.update_dropdown_menu()

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

        if contents.startswith("arch-update"):
            icon = QIcon.fromTheme(contents)
            self.tray.setIcon(icon)

    # Update the dropdown menu based on the 'last_updates_check' statefile content (including the number and the list of pending updates)
    def update_dropdown_menu(self):
        """Update dropdown menu"""
        if self.watcher and not self.updatesfile in self.watcher.files():
            self.watcher.addPath(self.updatesfile)

        try:
            with open(self.updatesfile, encoding="utf-8") as f:
                updates_list = f.readlines()
        except FileNotFoundError:
            log.error("State updates file missing")
            self.dropdown_menu.setTitle(_("'updates' state file isn't found"))
            self.dropdown_menu.setEnabled(False)
            return

        # Remove empty lines
        updates_list = [update.strip() for update in updates_list if update.strip()]

	# Count the number of pending updates (according to the number of lines of the 'last_updates_check' statefile)
        updates_count = len(updates_list)

        # Update the dropdown menu title accordingly
        if updates_count == 0:
            self.dropdown_menu.setTitle(_("System is up to date"))
            self.dropdown_menu.setEnabled(False)
        elif updates_count == 1:
            self.dropdown_menu.setTitle(_("1 update available"))
            self.dropdown_menu.setEnabled(True)
        else:
            self.dropdown_menu.setTitle(_("{updates} updates available").format(updates=updates_count))
            self.dropdown_menu.setEnabled(True)

        # Add the list on pending updates to the dropdown menu
        self.dropdown_menu.clear()
        if updates_list:
            for update in updates_list:
                self.dropdown_menu.addAction(update)

    # Action to run the arch_update function
    def run(self):
        """Run arch-update"""
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
        self.watcher = None

        # General application parameters
        app = QApplication(["Arch-Update"])
        app.setQuitOnLastWindowClosed(False)

        # Icon
        self.tray = QSystemTrayIcon()
        self.tray.setVisible(True)
        self.tray.activated.connect(self.run)

        # Tooltip
        tooltip = _("Arch-Update")
        self.tray.setToolTip(tooltip)

        # Definition of menus titles
        menu = QMenu()
        menu_launch = QAction(_("Run Arch-Update"))
        menu_check = QAction(_("Check for updates"))
        menu_exit = QAction(_("Exit"))

        # Initialisation of the dynamic dropdown menu
        self.dropdown_menu = QMenu(_("Checking for updates..."))

        # Link actions to the menu
        menu.addMenu(self.dropdown_menu)
        menu.addSeparator()
        menu.addAction(menu_launch)
        menu.addAction(menu_check)
        menu.addAction(menu_exit)

        menu_launch.triggered.connect(self.run)
        menu_check.triggered.connect(self.check)
        menu_exit.triggered.connect(self.exit)

        self.tray.setContextMenu(menu)

        # File Watcher (watches for statefiles content changes)
        self.watcher = QFileSystemWatcher([self.iconfile, self.updatesfile])
        self.watcher.fileChanged.connect(self.file_changed)

        # Initial file check to set the right icon and dropdown menu text
        self.file_changed()

        app.exec()

if __name__ == "__main__":
    ArchUpdateQt6(ICON_STATEFILE)
