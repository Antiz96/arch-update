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

    # Update the dropdown menu based on the state files content
    def update_dropdown_menu(self):
        """Update dropdown menu"""
    # Check presence of state files
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

        # Update the main dropdown menu title accordingly
        if updates_count == 0:
            self.dropdown_menu.setTitle(_("System is up to date"))
            self.dropdown_menu.setEnabled(False)
        elif updates_count == 1:
            self.dropdown_menu.setTitle(_("1 update available"))
            self.dropdown_menu.setEnabled(True)
        else:
            self.dropdown_menu.setTitle(_("{updates} updates available").format(updates=updates_count))
            self.dropdown_menu.setEnabled(True)

        # Add / update submenus if at least one available update, remove it otherwise
        if (updates_count_pkg >= 1) + (updates_count_aur >=1) + (updates_count_flatpak >=1) >= 2:
            self.dropdown_menu.addMenu(self.submenu_all)
            self.submenu_all.setTitle(_("All ({updates})").format(updates=updates_count))
            self.submenu_all.setEnabled(True)
            self.submenu_all.clear()
            for update in updates_list:
                self.submenu_all.addAction(update)
        else:
            self.dropdown_menu.removeAction(self.submenu_all.menuAction())

        if updates_count_pkg >= 1:
            self.dropdown_menu.addMenu(self.submenu_pkg)
            self.submenu_pkg.setTitle(_("Packages ({updates})").format(updates=updates_count_pkg))
            self.submenu_pkg.setEnabled(True)
            self.submenu_pkg.clear()
            for update in updates_list_pkg:
                self.submenu_pkg.addAction(update)
        else:
            self.dropdown_menu.removeAction(self.submenu_pkg.menuAction())

        if updates_count_aur >= 1:
            self.dropdown_menu.addMenu(self.submenu_aur)
            self.submenu_aur.setTitle(_("AUR ({updates})").format(updates=updates_count_aur))
            self.submenu_aur.setEnabled(True)
            self.submenu_aur.clear()
            for update in updates_list_aur:
                self.submenu_aur.addAction(update)
        else:
            self.dropdown_menu.removeAction(self.submenu_aur.menuAction())

        if updates_count_flatpak >= 1:
            self.dropdown_menu.addMenu(self.submenu_flatpak)
            self.submenu_flatpak.setTitle(_("Flatpak ({updates})").format(updates=updates_count_flatpak))
            self.submenu_flatpak.setEnabled(True)
            self.submenu_flatpak.clear()
            for update in updates_list_flatpak:
                self.submenu_flatpak.addAction(update)
        else:
            self.dropdown_menu.removeAction(self.submenu_flatpak.menuAction())

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
        tooltip = _("Arch-Update")
        self.tray.setToolTip(tooltip)

        # Definition of menus titles
        menu = QMenu()
        menu_launch = QAction(_("Run Arch-Update"))
        menu_check = QAction(_("Check for updates"))
        menu_exit = QAction(_("Exit"))

        # Initialisation of the dynamic dropdown menu
        self.dropdown_menu = QMenu(_("Checking for updates..."))
        self.submenu_all = QMenu(_("All"))
        self.submenu_pkg = QMenu(_("Packages"))
        self.submenu_aur = QMenu(_("AUR"))
        self.submenu_flatpak = QMenu(_("Flatpak"))

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
        self.watcher = QFileSystemWatcher([self.iconfile, self.updatesfile, self.updatesfilepkg, self.updatesfileaur, self.updatesfileflatpak])
        self.watcher.fileChanged.connect(self.file_changed)

        # Initial file check to set the right icon and dropdown menu text
        self.file_changed()

        app.exec()

if __name__ == "__main__":
    ArchUpdateQt6(ICON_STATEFILE)
