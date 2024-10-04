#!/usr/bin/env python3

# arch-update-tray: A systray applet for Arch-Update
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

"""Arch-Update System Tray."""
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

# Find Icon file
ICON_FILE = None
if 'XDG_STATE_HOME' in os.environ:
    ICON_FILE = os.path.join(
        os.environ['XDG_STATE_HOME'], 'arch-update', 'tray_icon')
elif 'HOME' in os.environ:
    ICON_FILE = os.path.join(
        os.environ['HOME'], '.local', 'state', 'arch-update', 'tray_icon')
if not os.path.isfile(ICON_FILE):
    log.error("State icon file does not exist: %s", ICON_FILE)
    sys.exit(1)

# Find Updates file
UPDATES_FILE = None
if 'XDG_STATE_HOME' in os.environ:
    UPDATES_FILE = os.path.join(
        os.environ['XDG_STATE_HOME'], 'arch-update', 'last_updates_check')
elif 'HOME' in os.environ:
    UPDATES_FILE = os.path.join(
        os.environ['HOME'], '.local', 'state', 'arch-update', 'last_updates_check')
if not os.path.isfile(UPDATES_FILE):
    log.error("State updates file does not exist: %s", UPDATES_FILE)

# Find translations
paths = []
if 'XDG_DATA_DIRS' in os.environ:
    paths.extend(os.environ['XDG_DATA_DIRS'].split(":"))
if 'XDG_DATA_HOME' in os.environ:
    paths.extend(os.environ['XDG_DATA_HOME'].split(":"))
if 'HOME' in os.environ:
    paths.append(os.path.join(
        os.environ['HOME'], '.local', 'share'))
paths.extend(['/usr/share', '/usr/local/share'])
_ = None
for path in paths:
    french_translation_file = os.path.join(
        path, "locale", "fr", "LC_MESSAGES", "Arch-Update.mo")
    if os.path.isfile(french_translation_file):
        path = os.path.join(path, 'locale')
        t = gettext.translation('Arch-Update', localedir=path, fallback=True)
        _ = t.gettext
        break
if not _:
    t = gettext.translation('Arch-Update', fallback=True)
    _ = t.gettext
    log.error("No translations found")


def arch_update():
    """ Launch with desktop file """
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


class ArchUpdateQt6:
    """ System Tray using QT6 library """

    def file_changed(self):
        """ Update icon and tooltip on state file content changes """
        self.update_icon()
        self.update_tooltip()

    def update_icon(self):
        """ Update the tray icon based on the icon state file content """
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

    def update_tooltip(self):
        """ Update the tooltip with the number / list of pending updates """
        if self.watcher and not self.updatesfile in self.watcher.files():
            self.watcher.addPath(self.updatesfile)

        try:
            with open(self.updatesfile, encoding="utf-8") as f:
                updates_list = f.readlines()
        except FileNotFoundError:
            log.error("State updates file missing")
            tooltip = _("Arch-Update: 'updates' state file isn't found")
            self.tray.setToolTip(tooltip)
            return

        # Remove empty lines
        updates_list = [
            update.strip()
            for update in updates_list
            if update.strip()
        ]

        updates_count = len(updates_list)

        if updates_count == 0:
            tooltip = _("Arch-Update: System is up to date")
        elif updates_count == 1:
            update_list = "".join(updates_list)
            tooltip = _("Arch-Update: 1 update available\n\n{update_list}").format(
                update_list=update_list
            )
        else:
            update_list = "\n".join(updates_list)
            tooltip = _("Arch-Update: {updates} updates available\n\n{update_list}").format(
                updates=updates_count, update_list=update_list
            )

        self.tray.setToolTip(tooltip)

    def run(self):
        """ Start arch-update """
        arch_update()

    def check(self):
        """ Check for updates """
        subprocess.run(["arch-update", "--check"], check=False)

    def exit(self):
        """ Close systray process """
        sys.exit(0)

    def __init__(self, iconfile):
        """ Start Qt6 System Tray """

        self.iconfile = iconfile
        self.updatesfile = UPDATES_FILE
        self.watcher = None

        # Application
        app = QApplication(["Arch-Update"])
        app.setQuitOnLastWindowClosed(False)

        # Icon
        self.tray = QSystemTrayIcon()
        self.file_changed()
        self.tray.setVisible(True)
        self.tray.activated.connect(self.run)

        # Menu
        menu = QMenu()
        menu_launch = QAction(_("Run Arch-Update"))
        menu_check = QAction(_("Check for updates"))
        menu_exit = QAction(_("Exit"))
        menu.addAction(menu_launch)
        menu.addAction(menu_check)
        menu.addAction(menu_exit)

        menu_launch.triggered.connect(self.run)
        menu_check.triggered.connect(self.check)
        menu_exit.triggered.connect(self.exit)

        self.tray.setContextMenu(menu)

        # File Watcher
        self.watcher = QFileSystemWatcher([self.iconfile, self.updatesfile])
        self.watcher.fileChanged.connect(self.file_changed)

        app.exec()


if __name__ == "__main__":
    ArchUpdateQt6(ICON_FILE)
