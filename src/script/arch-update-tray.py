#!/usr/bin/env python3
import gettext
import logging
import os
import sys
import shutil
import subprocess

# Import toolkits and list availability
available_tk_list = []

# Test for GTK3 availability
try:
    # pylint: disable=import-outside-toplevel
    import gi
    gi.require_version('AppIndicator3', '0.1')
    gi.require_version("Gtk", "3.0")
    from gi.repository import Gtk, Gio, GLib
    from gi.repository import AppIndicator3 as ai
    available_tk_list.append("gtk3")
except Exception:
    pass

# Test for QT6 availability
try:
    # pylint: disable=import-outside-toplevel
    from PyQt6.QtGui import QIcon
    from PyQt6.QtWidgets import QApplication, QSystemTrayIcon
    from PyQt6.QtCore import QFileSystemWatcher
    available_tk_list.append("qt6")
except Exception:
    pass

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
    log.error("Statefile does not exist: %s" % (STATE_FILE))
    sys.exit(1)

# Find translations
paths = []
if 'XDG_DATA_DIRS' in os.environ:
    paths.extend(os.environ['XDG_DATA_DIRS'].split(":"))
if 'XDG_DATA_HOME' in os.environ:
    paths.extend(os.environ['XDG_DATA_HOME'].split(":"))

_ = None
for path in paths:
    french_translation_file = os.path.join(
        path, "locale", "fr", "LC_MESSAGES", "Arch-Update.mo")
    if os.path.isfile(french_translation_file):
        t = gettext.translation('default', '.', fallback=True)
        _ = t.gettext
        break
if not _:
    log.error("No translations found")
    sys.exit(1)

# Find user preference
TOOLKIT_PREFERENCE = "qt6"
if 'ARCH_UPDATE_TK' in os.environ:
    match os.environ['ARCH_UPDATE_TK']:
        case 'gtk3':
            TOOLKIT_PREFERENCE = "gtk3"
        case 'qt6':
            TOOLKIT_PREFERENCE = 'qt6'
        case _:
            log.error("Unknown toolkit preference: %s" %
                      (os.environ['ARCH_UPDATE_TK']))


def arch_update():
    # Find a way to launch with terminal
    update = "/usr/share/applications/arch-update.desktop"
    if shutil.which("kioclient"):
        subprocess.run(["kioclient", "exec", update])
    elif shutil.which("gio"):
        subprocess.run(["gio", "launch", update])
    elif shutil.which("exo-open"):
        subprocess.run(["exo-open", update])
    else:
        log.error("Unable to start updater")
        sys.exit(1)


class ArchUpdateGtk3:
    def file_changed(self, a=None, b=None, c=None, d=None):
        try:
            with open(self.statefile, 'r') as f:
                contents = f.readline().strip()
        except FileNotFoundError:
            log.error("Statefile Missing")
            sys.exit(1)
        if contents.startswith("arch-update"):
            self.ind.set_icon(contents)

    def update(self, button=None):
        arch_update()

    def __init__(self, statefile):
        self.statefile = statefile

        self.ind = ai.Indicator.new(
            'arch-update', 'arch-update', ai.IndicatorCategory.SYSTEM_SERVICES)
        self.ind.set_status(ai.IndicatorStatus.ACTIVE)

        # Gtk won't allow indicators without a menu
        menu = Gtk.Menu()
        item = Gtk.MenuItem.new_with_label(_("Update now"))
        item.show()
        menu.append(item)
        self.ind.set_menu(menu)

        item.connect('activate', self.update)

        # File monitor
        gtkstatefile = Gio.File.new_for_path(self.statefile)
        monitor = gtkstatefile.monitor_file(0, None)
        monitor.connect("changed", self.file_changed)

        Gtk.main()


class ArchUpdateQt6:
    def file_changed(self):

        contents = ""
        if self.watcher and not self.statefile in self.watcher.files():
            self.watcher.addPath(self.statefile)
        try:
            with open(self.statefile, 'r') as f:
                contents = f.readline().strip()
        except FileNotFoundError:
            log.error("Statefile Missing")
            sys.exit(1)
        if contents.startswith("arch-update"):
            icon = QIcon.fromTheme(contents)
            self.tray.setIcon(icon)

    def update(self):
        arch_update()

    def __init__(self, statefile):

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


def start(toolkit):
    match toolkit:
        case 'qt6':
            archupdate = ArchUpdateQt6(STATE_FILE)
        case 'gtk3':
            archupdate = ArchUpdateGtk3(STATE_FILE)
        case _:
            log.error("Unknown toolkit selected: %s" % toolkit)


if __name__ == "__main__":
    # Starting point

    if TOOLKIT_PREFERENCE in available_tk_list:
        # User preference first
        start(TOOLKIT_PREFERENCE)
    elif len(available_tk_list) > 0:
        # Use any other, if preference isn't available
        start(available_tk_list[0])
    else:
        # Uh oh
        log.error("No available toolkits")
