#!/bin/bash

# tray.sh: Start the Arch-Update systray applet
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

if [ "${2}" == "--enable" ]; then
	# shellcheck disable=SC2154
	if [ -f "${XDG_DATA_HOME}/applications/${name}-tray.desktop" ]; then
		tray_desktop_file="${XDG_DATA_HOME}/applications/${name}-tray.desktop"
	elif [ -f "${HOME}/.local/share/applications/${name}-tray.desktop" ]; then
		tray_desktop_file="${HOME}/.local/share/applications/${name}-tray.desktop"
	elif [ -f "${XDG_DATA_DIRS}/applications/${name}-tray.desktop" ]; then
		tray_desktop_file="${XDG_DATA_DIRS}/applications/${name}-tray.desktop"
	elif [ -f "/usr/local/share/applications/${name}-tray.desktop" ]; then
		tray_desktop_file="/usr/local/share/applications/${name}-tray.desktop"
	elif [ -f "/usr/share/applications/${name}-tray.desktop" ]; then
		tray_desktop_file="/usr/share/applications/${name}-tray.desktop"
	else
		error_msg "$(eval_gettext "Arch-Update tray desktop file not found")"
		exit 10
	fi

	tray_desktop_file_autostart="${XDG_CONFIG_HOME:-${HOME}/.config}/autostart/arch-update-tray.desktop"

	if [ -f "${tray_desktop_file_autostart}" ]; then
		error_msg "$(eval_gettext "The '\${tray_desktop_file_autostart}' file already exists")"
		exit 10
	else
		mkdir -p "${XDG_CONFIG_HOME:-${HOME}/.config}/autostart/" || exit 10
		cp "${tray_desktop_file}" "${tray_desktop_file_autostart}" || exit 10
		info_msg "$(eval_gettext "The '\${tray_desktop_file_autostart}' file has been created, the Arch-Update systray applet will be automatically started at your next log on\nTo start it right now, you can launch the \"Arch-Update Systray Applet\" application from your app menu")"
	fi
else
	# shellcheck disable=SC2154
	if [ ! -f "${statedir}/tray_icon" ]; then
		icon_up-to-date
	fi

	# shellcheck disable=SC2154
	if pgrep -f "${libdir}/tray.py" > /dev/null; then
		error_msg "$(eval_gettext "There's already a running instance of the Arch-Update systray applet")"
		exit 3
	fi

	# shellcheck disable=SC2154
	"${libdir}/tray.py" || exit 3
fi
