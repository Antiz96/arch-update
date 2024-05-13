#!/usr/bin/env python3
"""Arch-Update System Tray."""
import logging
import os
import sys
import subprocess
from PyQt6.QtGui import QIcon
from PyQt6.QtWidgets import QApplication, QSystemTrayIcon
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


def arch_update():
    """ Launch with desktop file """
    if 'XDG_DATA_HOME' in os.environ:
        DESKTOP_FILE = os.path.join(
            os.environ['XDG_DATA_HOME'], 'applications', 'arch-update.desktop')
    if not os.path.isfile(DESKTOP_FILE):
        if 'HOME' in os.environ:
            DESKTOP_FILE = os.path.join(
                os.environ['HOME'], '.local', 'share', 'applications', 'arch-update.desktop')
    if not os.path.isfile(DESKTOP_FILE):
        if 'XDG_DATA_DIRS' in os.environ:
            DESKTOP_FILE = os.path.join(
                os.environ['XDG_DATA_DIRS'], 'applications', 'arch-update.desktop')
    if not os.path.isfile(DESKTOP_FILE):
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

    def update(self):
        """ Start arch-update """
        arch_update()

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
        self.tray.activated.connect(self.update)

        # File Watcher
        self.watcher = QFileSystemWatcher([self.statefile])
        self.watcher.fileChanged.connect(self.file_changed)

        app.exec()


if __name__ == "__main__":
    ArchUpdateQt6(STATE_FILE)
