#!/bin/bash

# check.sh: Check for available updates
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC2154
touch "${statedir}"/last_updates_check_{packages,aur,flatpak}

# shellcheck disable=SC2154
checkupdates_db_tmpdir=$(mktemp -d "${checkupdates_db_tmpdir_prefix}XXXXX")

# shellcheck disable=SC2154
if [ -z "${no_version}" ]; then
	# shellcheck disable=SC2154
	CHECKUPDATES_DB="${checkupdates_db_tmpdir}" checkupdates > "${statedir}/last_updates_check_packages"
else
	# shellcheck disable=SC2154
	CHECKUPDATES_DB="${checkupdates_db_tmpdir}" checkupdates | awk '{print $1}' > "${statedir}/last_updates_check_packages"
fi

if [ -n "${aur_helper}" ]; then
	if [ -z "${no_version}" ]; then
		# shellcheck disable=SC2154
		"${aur_helper}" -Qua 2> /dev/null | sed 's/^ *//' | sed 's/ \+/ /g' | grep -vw "\[ignored\]$" > "${statedir}/last_updates_check_aur"
	else
		# shellcheck disable=SC2154
		"${aur_helper}" -Qua 2> /dev/null | sed 's/^ *//' | sed 's/ \+/ /g' | grep -vw "\[ignored\]$" | awk '{print $1}' > "${statedir}/last_updates_check_aur"
	fi
fi

if [ -n "${flatpak_support}" ]; then
	flatpak update | sed -n '/^ 1./,$p' | awk '{print $2}' | grep -v '^$' | sed '$d' > "${statedir}/last_updates_check_flatpak"
fi

sed -i '/^\s*$/d' "${statedir}"/last_updates_check_{packages,aur,flatpak}
sed -ri 's/\x1B\[[0-9;]*m//g' "${statedir}"/last_updates_check_{packages,aur,flatpak}
update_available=$(cat "${statedir}"/last_updates_check_{packages,aur,flatpak})

# shellcheck disable=SC2154
echo "${update_available}" > "${statedir}/current_updates_check"

if [ -n "${update_available}" ]; then
	icon_updates-available

	if [ -n "${notification_support}" ]; then
		if ! diff "${statedir}/current_updates_check" "${statedir}/last_updates_check" &> /dev/null; then
			update_number=$(wc -l "${statedir}/current_updates_check" | awk '{print $1}')

			# shellcheck disable=SC2154
			last_notif_id=$(sed -n '1p' "${tmpdir}/notif_param" 2> /dev/null)

			(
			if [ "${update_number}" -eq 1 ]; then
				if [ -z "${last_notif_id}" ]; then
					# shellcheck disable=SC2154
					notify-send -p -a "${_name}" -i "${name}_updates-available-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} update available")" -A "run=$(eval_gettext "Run Arch-Update")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
				else
					# shellcheck disable=SC2154
					notify-send -p -r "${last_notif_id}" -a "${_name}" -i "${name}_updates-available-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} update available")" -A "run=$(eval_gettext "Run Arch-Update")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
				fi
			else
				if [ -z "${last_notif_id}" ]; then
					notify-send -p -a "${_name}" -i "${name}_updates-available-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} updates available")" -A "run=$(eval_gettext "Run Arch-Update")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
				else
					notify-send -p -r "${last_notif_id}" -a "${_name}" -i "${name}_updates-available-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} updates available")" -A "run=$(eval_gettext "Run Arch-Update")" -A "close=$(eval_gettext "Close")" > "${tmpdir}/notif_param"
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
				error_msg "$(eval_gettext "Arch-Update desktop file not found")"
				exit 18
			fi

			if [ "$(sed -n '2p' "${tmpdir}/notif_param")" == "run" ]; then
				exec 9>"${tmpdir}/notif_action.lock"

				if flock -n 9; then
					gio launch "${desktop_file}" || exit 18
				fi
			fi
			) & disown
		fi
	fi
else
	icon_up-to-date
fi

if [ -f "${statedir}/current_updates_check" ]; then
	mv -f "${statedir}/current_updates_check" "${statedir}/last_updates_check"
fi
