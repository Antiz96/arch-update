#!/bin/bash

# help.sh: Display the help message
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

cat <<EOF
$(eval_gettext "An update notifier & applier for Arch Linux that assists you with important pre / post update tasks.")

$(eval_gettext "Run \${name} to perform the main 'update' function:")
$(eval_gettext "Display the list of packages available for update, then ask for the user's confirmation to proceed with the installation.")
$(eval_gettext "Before performing the update, it offers to display the latest Arch Linux news.")
$(eval_gettext "Post update, it checks for orphan & unused packages, old cached packages, pacnew & pacsave files, pending kernel update as well as services requiring a post upgrade restart and, if there are, offers to process them.")

$(eval_gettext "Options:")
$(eval_gettext "  -c, --check       Check for available updates, change the systray icon and send a desktop notification containing the number of available updates (if there are new available updates compared to the last check)")
$(eval_gettext "  -l, --list        Display the list of pending updates")
$(eval_gettext "  -d, --devel       Include AUR development packages updates")
$(eval_gettext "  -n, --news [Num]  Display latest Arch news, you can optionally specify the number of Arch news to display with '--news [Num]' (e.g. '--news 10')")
$(eval_gettext "  -s, --services    Check for services requiring a post upgrade restart")
$(eval_gettext "  -D, --debug       Display debug traces")
$(eval_gettext "  --gen-config      Generate a default / example '\${name}.conf' configuration file, you can optionally pass the '--force' argument to overwrite any existing '\${name}.conf' configuration file")
$(eval_gettext "  --show-config     Display the '\${name}.conf' configuration file currently used (if it exists)")
$(eval_gettext "  --edit-config     Edit the '\${name}.conf' configuration file currently used (if it exists)")
$(eval_gettext "  --tray            Launch the \${_name} systray applet, you can optionally add the '--enable' argument to start it automatically at boot")
$(eval_gettext "  -h, --help        Display this help message and exit")
$(eval_gettext "  -V, --version     Display version information and exit")

$(eval_gettext "For more information, see the \${name}(1) man page.")
$(eval_gettext "Certain options can be enabled, disabled or modified via the \${name}.conf configuration file, see the \${name}.conf(5) man page.")
EOF
