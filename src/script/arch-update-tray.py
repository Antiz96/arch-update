#!/usr/bin/env python3
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

# Find Statefile
if 'XDG_STATE_HOME' in os.environ:
    STATE_FILE = os.path.join(
        os.environ['XDG_STATE_HOME'], 'arch-update', 'current_state')
elif 'HOME' in os.environ:
    STATE_FILE = os.path.join(
        os.environ['HOME'], '.local', 'state', 'arch-update', 'current_state')
if not os.path.isfile(STATE_FILE):
    log.error("Statefile does not exist: %s", STATE_FILE)
    sys.exit(1)

# Find translations
t = gettext.translation('Arch-Update', fallback=True)
_ = t.gettext


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
        """ Called when statefile contents change """

        contents = ""
        if self.watcher and not self.statefile in self.watcher.files():
            self.watcher.addPath(self.statefile)
        try:
            with open(self.statefile, encoding="utf-8") as f:
                contents = f.readline().strip()
        except FileNotFoundError:
            log.error("Statefile Missing")
            sys.exit(1)
        if contents.startswith("arch-update"):
            icon = QIcon.fromTheme(contents)
            self.tray.setIcon(icon)

    def run(self):
        """ Start arch-update """
        arch_update()

    def exit(self):
        """ Close systray process """
        sys.exit(0)

    def __init__(self, statefile):
        """ Start Qt6 System Tray """

        self.statefile = statefile
        self.watcher = None

        # Application
        app = QApplication([])
        app.setQuitOnLastWindowClosed(False)

        # Icon
        self.tray = QSystemTrayIcon()
        self.file_changed()
        self.tray.setVisible(True)
        self.tray.activated.connect(self.run)

        # Menu
        menu = QMenu()
        menu_launch = QAction(_("Run Arch-Update"))
        menu_exit = QAction(_("Exit"))
        menu.addAction(menu_launch)
        menu.addAction(menu_exit)

        menu_exit.triggered.connect(self.exit)
        menu_launch.triggered.connect(self.run)

        self.tray.setContextMenu(menu)

        # File Watcher
        self.watcher = QFileSystemWatcher([self.statefile])
        self.watcher.fileChanged.connect(self.file_changed)

        app.exec()


if __name__ == "__main__":
    ArchUpdateQt6(STATE_FILE)
