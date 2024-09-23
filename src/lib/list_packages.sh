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
		aur_packages=$("${aur_helper}" --color "${pacman_color_opt}" "${devel_flag[@]}" -Qua)
	else
		# shellcheck disable=SC2154
		aur_packages=$("${aur_helper}" --color "${pacman_color_opt}" "${devel_flag[@]}" -Qua | awk '{print $1}')
	fi
fi

if [ -n "${flatpak}" ]; then
	flatpak_packages=$(flatpak update | sed -n '/^ 1./,$p' | awk '{print $2}' | grep -v '^$' | sed '$d')
fi

if [ -n "${packages}" ]; then
	main_msg "$(eval_gettext "Packages:")"
	echo -e "${packages}\n"
fi

if [ -n "${aur_packages}" ]; then
	main_msg "$(eval_gettext "AUR Packages:")"
	echo -e "${aur_packages}\n"
fi

if [ -n "${flatpak_packages}" ]; then
	main_msg "$(eval_gettext "Flatpak Packages:")"
	echo -e "${flatpak_packages}\n"
fi

if [ -z "${packages}" ] && [ -z "${aur_packages}" ] && [ -z "${flatpak_packages}" ]; then
	state_up_to_date
	info_msg "$(eval_gettext "No update available\n")"

	if [ -n "${list_option}" ]; then
		exit 7
	fi
else
	state_updates_available
	if [ -z "${list_option}" ]; then
		ask_msg "$(eval_gettext "Proceed with update? [Y/n]")"

		# shellcheck disable=SC2154
		case "${answer}" in
			"$(eval_gettext "Y")"|"$(eval_gettext "y")"|"")
				# shellcheck disable=SC2034,SC2154
				proceed_with_update="y"
				echo
			;;
			*)
				error_msg "$(eval_gettext "The update has been aborted\n")" && quit_msg
				exit 4
			;;
		esac
	fi
fi
