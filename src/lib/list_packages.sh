#!/bin/bash

# list_packages.sh: Display the list of packages available for updates
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

info_msg "$(eval_gettext "Looking for updates...\n")"

if [ -z "${no_version}" ]; then
	# shellcheck disable=SC2154
	packages=$(checkupdates "${contrib_color_opt[@]}")
else
	# shellcheck disable=SC2154
	packages=$(checkupdates "${contrib_color_opt[@]}" | awk '{print $1}')
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
	flatpak_packages=$(flatpak update | sed -n '/^ 1./,$p' | awk '{print $2}' | grep -v '^$' | sed '$d')
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

if [ -n "${flatpak_packages}" ]; then
	main_msg "$(eval_gettext "Flatpak Packages:")"
	echo -e "${flatpak_packages}\n"
	echo "${flatpak_packages}" >> "${statedir}/last_updates_check"
	echo "${flatpak_packages}" > "${statedir}/last_updates_check_flatpak"
fi

sed -ri 's/\x1B\[[0-9;]*m//g' "${statedir}"/last_updates_check{,_packages,_aur,_flatpak}

if [ -z "${packages}" ] && [ -z "${aur_packages}" ] && [ -z "${flatpak_packages}" ]; then
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
