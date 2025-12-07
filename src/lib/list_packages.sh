#!/bin/bash

# list_packages.sh: Display the list of packages available for updates
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

info_msg "$(eval_gettext "Looking for updates...\n")"

# shellcheck disable=SC2154
checkupdates_db_tmpdir=$(mktemp -d "${checkupdates_db_tmpdir_prefix}XXXXX")

if [ -z "${no_version}" ]; then
	# shellcheck disable=SC2154
	packages=$(CHECKUPDATES_DB="${checkupdates_db_tmpdir}" checkupdates "${contrib_color_opt[@]}")
else
	# shellcheck disable=SC2154
	packages=$(CHECKUPDATES_DB="${checkupdates_db_tmpdir}" checkupdates "${contrib_color_opt[@]}" | awk '{print $1}')
fi

if [ -n "${aur_helper}" ]; then
	if [ -z "${no_version}" ]; then
		# shellcheck disable=SC2154
		aur_packages=$("${aur_helper}" --color "${pacman_color_opt}" "${devel_flag[@]}" -Qua 2> /dev/null | sed 's/^ *//' | sed 's/ \+/ /g' | grep -vw "\[ignored\]$")
	else
		# shellcheck disable=SC2154
		aur_packages=$("${aur_helper}" --color "${pacman_color_opt}" "${devel_flag[@]}" -Qua 2> /dev/null | sed 's/^ *//' | sed 's/ \+/ /g' | grep -vw "\[ignored\]$" | awk '{print $1}')
	fi
fi

if [ -n "${flatpak_support}" ]; then
	flatpak update --appstream > /dev/null

	mapfile -t flatpak_packages < <(flatpak remote-ls --updates --columns=name,version,application | tr -s '\t' ' ')
	mapfile -t flatpak_mask < <(flatpak mask | tr -d ' ')

	if [ "${#flatpak_mask[@]}" -gt 0 ]; then
		mapfile -t flatpak_packages < <(
			for application in "${flatpak_packages[@]}"; do
				app_id=$(awk '{print $3}' <<< "${application}")
				for pattern in "${flatpak_mask[@]}"; do
					# shellcheck disable=SC2053
					[[ "${app_id}" == ${pattern} ]] && continue 2
				done
				echo "${application}"
			done
		)
	fi

	if [ -z "${no_version}" ]; then
		mapfile -t flatpak_packages < <(printf "%s\n" "${flatpak_packages[@]}" | awk '{print $1,$2}' | sed '/^[[:space:]]*$/d')
	else
		mapfile -t flatpak_packages < <(printf "%s\n" "${flatpak_packages[@]}" | awk '{print $1}' | sed '/^[[:space:]]*$/d')
	fi
fi

# shellcheck disable=SC2154
true > "${statedir}/last_updates_check"
true > "${statedir}/last_updates_check_packages"
true > "${statedir}/last_updates_check_aur"
true > "${statedir}/last_updates_check_flatpak"

if [ -n "${packages}" ]; then
	main_msg "$(eval_gettext "Packages:")"
	echo -e "${packages}\n"
	echo "${packages}" >> "${statedir}/last_updates_check"
	echo "${packages}" > "${statedir}/last_updates_check_packages"
fi

if [ -n "${aur_packages}" ]; then
	main_msg "$(eval_gettext "AUR Packages:")"
	echo -e "${aur_packages}\n"
	echo "${aur_packages}" >> "${statedir}/last_updates_check"
	echo "${aur_packages}" > "${statedir}/last_updates_check_aur"
fi

if [ "${#flatpak_packages[@]}" -gt 0 ]; then
	main_msg "$(eval_gettext "Flatpak Packages:")"
	printf "%s\n" "${flatpak_packages[@]}" ""
	printf "%s\n" "${flatpak_packages[@]}" >> "${statedir}/last_updates_check"
	printf "%s\n" "${flatpak_packages[@]}" > "${statedir}/last_updates_check_flatpak"
fi

sed -ri 's/\x1B\[[0-9;]*m//g' "${statedir}"/last_updates_check{,_packages,_aur,_flatpak}

if [ -z "${packages}" ] && [ -z "${aur_packages}" ] && [ "${#flatpak_packages[@]}" -eq 0 ]; then
	icon_up-to-date
	info_msg "$(eval_gettext "No update available\n")"

	if [ -n "${list_option}" ]; then
		exit 7
	fi
else
	icon_updates-available
	if [ -z "${list_option}" ]; then
		ask_msg "$(eval_gettext "Proceed with update? [Y/n]")"

		# shellcheck disable=SC2154
		case "${answer}" in
			"$(eval_gettext "Y")"|"$(eval_gettext "y")"|"")
				# shellcheck disable=SC2034,SC2154
				proceed_with_update="true"
				echo
			;;
			*)
				error_msg "$(eval_gettext "The update has been aborted\n")" && quit_msg
				exit 4
			;;
		esac
	fi
fi
