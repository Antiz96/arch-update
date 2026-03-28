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
	flatpak update --appstream > /dev/null

	mapfile -t flatpak_mask < <(flatpak mask | tr -d ' ')

	if [ "${#flatpak_mask[@]}" -gt 0 ]; then
		mapfile -t flatpak_packages < <(flatpak remote-ls --updates --columns=application,version | tr -s '\t' ' ')

		declare -A app_names
		while read -r flatpak_id flatpak_name; do
			app_names["${flatpak_id}"]="${flatpak_name}"
		done < <(flatpak list --columns=application,name)

	        mapfile -t flatpak_packages < <(
			for packages in "${flatpak_packages[@]}"; do
				read -r app_id app_version <<< "${packages}"

				for pattern in "${flatpak_mask[@]}"; do
					# shellcheck disable=SC2053
					[[ "${app_id}" == ${pattern} ]] && continue 2
				done

				app_name="${app_names[${app_id}]:-${app_id}}"

				if [ -z "${no_version}" ]; then
					echo "${app_name} ${app_version}"
				else
					echo "${app_name}"
				fi
			done
		)
	else
		if [ -z "${no_version}" ]; then
			mapfile -t flatpak_packages < <(flatpak remote-ls --updates --columns=name,version | tr -s '\t' ' ')
		else
			mapfile -t flatpak_packages < <(flatpak remote-ls --updates --columns=name)
		fi
	fi

	printf "%s\n" "${flatpak_packages[@]}" > "${statedir}/last_updates_check_flatpak"
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

			systemd-run --user --unit="${name}"-notification-"$(date +%Y%m%d-%H%M%S)" --quiet \
				--setenv=DISPLAY="${DISPLAY}" \
				--setenv=DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS}" \
				--setenv=TEXTDOMAIN="${_name}" \
				--setenv=TEXTDOMAINDIR="${TEXTDOMAINDIR}" \
				--setenv=LANG="${LANG}" \
				--setenv=LANGUAGE="${LANGUAGE}" \
				--setenv=LC_ALL="${LC_ALL}" \
				--setenv=LC_MESSAGES="${LC_MESSAGES}" \
				--setenv=XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}" \
				--setenv=XDG_DATA_HOME="${XDG_DATA_HOME}" \
				--setenv=XDG_DATA_DIRS="${XDG_DATA_DIRS}" \
				--setenv=HOME="${HOME}" \
				--setenv=update_number="${update_number}" \
				--setenv=last_notif_id="${last_notif_id}" \
				--setenv=_name="${_name}" \
				--setenv=name="${name}" \
				--setenv=tray_icon_style="${tray_icon_style}" \
				--setenv=colorblind_mode="${colorblind_mode}" \
				--setenv=tmpdir="${tmpdir}" \
				--setenv=desktop_file="${desktop_file}" \
			 "${libdir}/notification.sh"
		fi
	fi
else
	icon_up-to-date
fi

if [ -f "${statedir}/current_updates_check" ]; then
	mv -f "${statedir}/current_updates_check" "${statedir}/last_updates_check"
fi
