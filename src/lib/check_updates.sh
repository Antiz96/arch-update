#!/bin/bash

# check_updates.sh: Retrieve available updates
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC2154
touch "${statedir}"/last_updates_check{,_time,_packages,_aur,_flatpak}

# shellcheck disable=SC2154
checkupdates_db_tmpdir=$(mktemp -d "${checkupdates_db_tmpdir_prefix}XXXXX")
# shellcheck disable=SC2154
packages=$(CHECKUPDATES_DB="${checkupdates_db_tmpdir}" timeout "${update_check_timeout}" checkupdates --nocolor)
packages_exit_code=$?

if [ "${packages_exit_code}" -eq 124 ]; then
	warning_msg "$(eval_gettext "Unable to retrieve Packages updates (request timeout)\n")"
	unset packages
	packages_timeout="true"
elif [ -n "${no_version}" ]; then
	packages=$(echo "${packages}" | awk '{print $1}')
fi

if [ -n "${aur_helper}" ]; then
	# "< /dev/null" and "2 > /dev/null" needed for pikaur (which is not completely script friendly)
	# The former because it assumes an interactive TTY environment (causing `timeout` to behave unexpectedly) 
	# The latter because it outputs some descriptive string in stderr when looking for updates with -Qua
	# shellcheck disable=SC2154
	unformatted_aur_packages=$(LC_ALL=C timeout "${update_check_timeout}" "${aur_helper}" --color never "${devel_flag[@]}" -Qua < /dev/null 2> /dev/null)
	unformatted_aur_packages_exit_code=$?
	aur_packages=$(echo "${unformatted_aur_packages}" | sed 's/^ *//' | sed 's/ \+/ /g' | grep -vw "\[ignored\]$")

	if [ "${unformatted_aur_packages_exit_code}" -eq 124 ]; then
		warning_msg "$(eval_gettext "Unable to retrieve AUR Packages updates (request timeout)\n")"
		unset aur_packages
		aur_packages_timeout="true"
	elif [ -n "${no_version}" ]; then
		aur_packages=$(echo "${aur_packages}" | awk '{print $1}')
	fi
fi

if [ -n "${flatpak_support}" ]; then
	# `--foreground` because Flatpak requires interactive authentications through Polkit's `pkttyagent` if it is executed from a TTY / SSH environment
	timeout --foreground "${update_check_timeout}" flatpak update --appstream > /dev/null
	flatpak_metadata_update_exit_code=$?

	if [ "${flatpak_metadata_update_exit_code}" -eq 124 ]; then
		warning_msg "$(eval_gettext "Unable to retrieve Flatpak packages updates (request timeout)\n")"
		flatpak_packages_timeout="true"
	else
		mapfile -t flatpak_mask < <(flatpak mask | tr -d ' ')

		if [ "${#flatpak_mask[@]}" -gt 0 ]; then
			mapfile -t flatpak_packages < <(flatpak remote-ls --updates --cached --columns=application,version | tr -s '\t' ' ')

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
				mapfile -t flatpak_packages < <(flatpak remote-ls --updates --cached --columns=name,version | tr -s '\t' ' ')
			else
				mapfile -t flatpak_packages < <(flatpak remote-ls --updates --cached --columns=name)
			fi
		fi
	fi
fi

if [ -n "${packages}" ]; then
	echo "${packages}" > "${statedir}/last_updates_check_packages"
elif [ -z "${packages_timeout}" ]; then
	true > "${statedir}/last_updates_check_packages"
fi

if [ -n "${aur_packages}" ]; then
	echo "${aur_packages}" > "${statedir}/last_updates_check_aur"
elif [ -z "${aur_packages_timeout}" ]; then
	true > "${statedir}/last_updates_check_aur"
fi

if [ "${#flatpak_packages[@]}" -gt 0 ]; then
	printf "%s\n" "${flatpak_packages[@]}" > "${statedir}/last_updates_check_flatpak"
elif [ -z "${flatpak_packages_timeout}" ]; then
	true > "${statedir}/last_updates_check_flatpak"
fi

# Don't rewrite the last_updates_check statefile if we come from the `check.sh` library as it already handles it after comparing the (previous) last update batch to the current one
[ "${1}" == "check" ] || cat "${statedir}"/last_updates_check_{packages,aur,flatpak} > "${statedir}/last_updates_check"

date "+%s%n%F %T" > "${statedir}/last_updates_check_time"
