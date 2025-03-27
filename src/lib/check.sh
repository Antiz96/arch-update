#!/bin/bash

# check.sh: Check for available updates
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC2154
if [ -z "${no_version}" ]; then
	# shellcheck disable=SC2154
	packages=$(checkupdates)
else
	# shellcheck disable=SC2154
	packages=$(checkupdates | awk '{print $1}')
fi

echo "${packages}" > "${statedir}/last_updates_check_packages"

if [ -n "${aur_helper}" ]; then
	if [ -z "${no_version}" ]; then
		# shellcheck disable=SC2154
		aur_packages=$("${aur_helper}" -Qua 2> /dev/null | sed 's/^ *//' | sed 's/ \+/ /g' | grep -vw "\[ignored\]$")
	else
		# shellcheck disable=SC2154
		aur_packages=$("${aur_helper}" -Qua 2> /dev/null | sed 's/^ *//' | sed 's/ \+/ /g' | grep -vw "\[ignored\]$" | awk '{print $1}')
	fi

	echo "${aur_packages}" > "${statedir}/last_updates_check_aur"
fi

if [ -n "${flatpak_support}" ]; then
	flatpak_packages=$(flatpak update | sed -n '/^ 1./,$p' | awk '{print $2}' | grep -v '^$' | sed '$d')
	echo "${flatpak_packages}" > "${statedir}/last_updates_check_flatpak"
fi

sed -i '/^\s*$/d' "${statedir}"/last_updates_check_{_packages,_aur,_flatpak}
sed -ri 's/\x1B\[[0-9;]*m//g' "${statedir}"/last_updates_check_{_packages,_aur,_flatpak}
update_available=$(cat "${statedir}"/last_updates_check_{packages,aur,flatpak})

# shellcheck disable=SC2154
echo "${update_available}" > "${statedir}/current_updates_check"

if [ -n "${update_available}" ]; then
	icon_updates-available

	if [ -n "${notification_support}" ]; then
		if ! diff "${statedir}/current_updates_check" "${statedir}/last_updates_check" &> /dev/null; then
			update_number=$(wc -l "${statedir}/current_updates_check" | awk '{print $1}')
			# shellcheck disable=SC2154
			last_notif_id=$(cat "${tmpdir}/last_notif_id" 2> /dev/null)
			if [ "${update_number}" -eq 1 ]; then
				if [ -z "${last_notif_id}" ]; then
					# shellcheck disable=SC2154
					notify-send -p -i "${name}-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} update available")" > "${tmpdir}/last_notif_id"
				else
					# shellcheck disable=SC2154
					notify-send -p -r "${last_notif_id}" -i "${name}-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} update available")" > "${tmpdir}/last_notif_id"
				fi

			else
				if [ -z "${last_notif_id}" ]; then
					notify-send -p -i "${name}-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} updates available")" > "${tmpdir}/last_notif_id"
				else
					notify-send -p -r "${last_notif_id}" -i "${name}-${tray_icon_style}" "${_name}" "$(eval_gettext "\${update_number} updates available")" > "${tmpdir}/last_notif_id"
				fi
			fi
		fi
	fi
else
	icon_up-to-date
fi

if [ -f "${statedir}/current_updates_check" ]; then
	mv -f "${statedir}/current_updates_check" "${statedir}/last_updates_check"
fi
