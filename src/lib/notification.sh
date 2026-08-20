#!/bin/bash

# notification.sh: Send a desktop notification for available updates
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# Launch Arch-Update in the terminal emulator configured in the desktop environment
# (as `gio`'s own list of known terminal emulators doesn't honor it)
launch_arch_update_in_terminal() {
	# Prefer `xdg-terminal-exec` (the freedesktop standard for launching applications in a
	# terminal emulator), which honors the terminal emulator configured in the
	# `xdg-terminals.list` file
	if command -v xdg-terminal-exec > /dev/null; then
		xdg-terminal-exec arch-update
		return
	fi

	# Otherwise, try to launch Arch-Update in the terminal emulator configured in the desktop
	# environment (KDE `kdeglobals` / GNOME `gsettings` / `$TERMINAL` environment variable)
	terminal=""

	# Check the `$TERMINAL` environment variable
	if [ -n "${TERMINAL}" ] && command -v "${TERMINAL%% *}" > /dev/null; then
		terminal="${TERMINAL%% *}"
	fi

	# Check the terminal emulator configured in KDE (kdeglobals)
	if [ -z "${terminal}" ] && [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/kdeglobals" ]; then
		terminal="$(sed -n 's/^TerminalApplication=//p' "${XDG_CONFIG_HOME:-${HOME}/.config}/kdeglobals" | head -n 1)"
	fi

	# Check the terminal emulator configured in GNOME (gsettings)
	if [ -z "${terminal}" ] && command -v gsettings > /dev/null; then
		terminal="$(gsettings get org.gnome.desktop.default-applications.terminal exec 2> /dev/null | tr -d "'")"
	fi

	if [ -n "${terminal}" ] && command -v "${terminal}" > /dev/null; then
		terminal_name="${terminal##*/}"
		case "${terminal_name}" in
			kitty|foot)
				"${terminal}" arch-update
			;;
			wezterm|wezterm-gui)
				"${terminal}" start arch-update
			;;
			gnome-terminal|ptyxis)
				"${terminal}" -- arch-update
			;;
			xfce4-terminal|mate-terminal)
				"${terminal}" -x arch-update
			;;
			*)
				"${terminal}" -e arch-update
			;;
		esac
		return
	fi

	# Fallback: launch the desktop file via `gio`
	gio launch "${1}"
}

# Declare necessary parameters for translations
# This script is executed in its own subshell via `systemd-run` so it needs this to be explicitly re-sourced
# shellcheck disable=SC1091
. gettext.sh

# shellcheck disable=SC2154
if [ "${update_number}" -eq 1 ]; then
	if [ -z "${last_notif_id}" ]; then
		# shellcheck disable=SC2154
		notify-send -p -a "${_name}" -n "${name}_updates-available-${tray_icon_style}${colorblind_mode}" "${_name}" "$(eval_gettext "1 update available")" -A "run=$(eval_gettext "Run \${_name}")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
	else
		# shellcheck disable=SC2154
		notify-send -p -r "${last_notif_id}" -a "${_name}" -n "${name}_updates-available-${tray_icon_style}${colorblind_mode}" "${_name}" "$(eval_gettext "1 update available")" -A "run=$(eval_gettext "Run \${_name}")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
	fi
else
	if [ -z "${last_notif_id}" ]; then
		notify-send -p -a "${_name}" -n "${name}_updates-available-${tray_icon_style}${colorblind_mode}" "${_name}" "$(eval_gettext "\${update_number} updates available")" -A "run=$(eval_gettext "Run \${_name}")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
	else
		notify-send -p -r "${last_notif_id}" -a "${_name}" -n "${name}_updates-available-${tray_icon_style}${colorblind_mode}" "${_name}" "$(eval_gettext "\${update_number} updates available")" -A "run=$(eval_gettext "Run \${_name}")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
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
	exec {fd_notif}>"${tmpdir}/notif_action.lock"

	if flock -n "${fd_notif}"; then
		# The launch function is exported so that it is available in the subshell started by
		# `systemd-run` below
		export -f launch_arch_update_in_terminal
		systemd-run --user --scope --unit="${name}"-run-"$(date +%Y%m%d-%H%M%S)" --quiet /bin/bash -c "launch_arch_update_in_terminal ${desktop_file}" || exit 18
	fi
fi
