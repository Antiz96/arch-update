#!/bin/bash

# notification.sh: Send a desktop notification for available updates
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# Declare necessary parameters for translations
# This script is executed in its own subshell via `systemd-run` so it needs this to be explicitly re-sourced
# shellcheck disable=SC1091
. gettext.sh

# shellcheck disable=SC2154
if [ "${update_number}" -eq 1 ]; then
	if [ -z "${last_notif_id}" ]; then
		# shellcheck disable=SC2154
		notify-send -p -a "${_name}" -i "${name}_updates-available-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} update available")" -A "run=$(eval_gettext "Run \${_name}")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
	else
		# shellcheck disable=SC2154
		notify-send -p -r "${last_notif_id}" -a "${_name}" -i "${name}_updates-available-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} update available")" -A "run=$(eval_gettext "Run \${_name}")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
	fi
else
	if [ -z "${last_notif_id}" ]; then
		notify-send -p -a "${_name}" -i "${name}_updates-available-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} updates available")" -A "run=$(eval_gettext "Run \${_name}")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
	else
		notify-send -p -r "${last_notif_id}" -a "${_name}" -i "${name}_updates-available-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} updates available")" -A "run=$(eval_gettext "Run \${_name}")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
	fi
fi

# shellcheck disable=SC2154
if [ -f "${XDG_DATA_HOME}/applications/${name}.desktop" ]; then
	desktop_file="${XDG_DATA_HOME}/applications/${name}.desktop"
elif [ -f "${HOME}/.local/share/applications/${name}.desktop" ]; then
	desktop_file="${HOME}/.local/share/applications/${name}.desktop"
elif [ -f "${XDG_DATA_DIRS}/applications/${name}.desktop" ]; then
	desktop_file="${XDG_DATA_DIRS}/applications/${name}.desktop"
elif [ -f "/usr/local/share/applications/${name}.desktop" ]; then
	desktop_file="/usr/local/share/applications/${name}.desktop"
elif [ -f "/usr/share/applications/${name}.desktop" ]; then
	desktop_file="/usr/share/applications/${name}.desktop"
else
	error_msg "$(eval_gettext "\${_name} desktop file not found")"
	exit 18
fi

if [ "$(sed -n '2p' "${tmpdir}/notif_param")" == "run" ]; then
	# shellcheck disable=SC2154
	exec {fd_notif}>"${notif_lockfile}" 2> /dev/null

	if flock -n "${fd_notif}"; then
		systemd-run --user --scope --unit="${name}"-run-"$(date +%Y%m%d-%H%M%S)" --quiet /bin/bash -c "gio launch ${desktop_file}" || exit 18
	fi
fi
