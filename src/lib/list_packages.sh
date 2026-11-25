#!/bin/bash

# list_packages.sh: Display the list of packages available for updates
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

info_msg "$(eval_gettext "Looking for updates...\n")"

# Retrieve available updates
# shellcheck source=src/lib/check_updates.sh
source "${libdir}/check_updates.sh"

# Re-color update list output with version diff highlighting
color_update_list() {
	local line pkgname oldver newver counter seg
	local -a old_vers new_vers

	while IFS= read -r line; do
		[ -z "${line}" ] && continue
		read -r pkgname oldver _ newver <<< "${line}"
		IFS='-' read -r old_vers_upstream _old_vers_release <<< "${oldver}"
		IFS='-' read -r new_vers_upstream _new_vers_release <<< "${newver}"
		IFS=':.' read -ra old_vers <<< "${old_vers_upstream}"
		IFS=':.' read -ra new_vers <<< "${new_vers_upstream}"
		counter=0
		seg=0
		while [ "${seg}" -lt "${#old_vers[@]}" ] && [ "${seg}" -lt "${#new_vers[@]}" ] && [ "${old_vers[${seg}]}" = "${new_vers[${seg}]}" ]; do
			counter=$(( counter + ${#old_vers[${seg}]} + 1 ))
			seg=$(( seg + 1 ))
		done
		# shellcheck disable=SC2154
		printf "%b %b -> %b\n" "${bold}${pkgname}${color_off}" "${oldver:0:${counter}}${red}${bold}${oldver:${counter}}${color_off}" "${newver:0:${counter}}${green}${bold}${newver:${counter}}${color_off}"
	done
}

if [ -n "${packages}" ]; then
	main_msg "$(eval_gettext "Packages:")"
	if [ -n "${no_color}" ] || [ -n "${no_version}" ]; then
		echo "${packages}" | column -t
	else
		echo "${packages}" | color_update_list | column -t
	fi
	echo
fi

if [ -n "${aur_packages}" ]; then
	main_msg "$(eval_gettext "AUR Packages:")"
	if [ -n "${no_color}" ] || [ -n "${no_version}" ]; then
		echo "${aur_packages}" | column -t
	else
		echo "${aur_packages}" | color_update_list | column -t
	fi
	echo
fi

if [ "${#flatpak_packages[@]}" -gt 0 ]; then
	main_msg "$(eval_gettext "Flatpak Packages:")"
	printf "%s\n" "${flatpak_packages[@]}" | column -t
	echo
fi

if [ -z "${packages}" ] && [ -z "${aur_packages}" ] && [ "${#flatpak_packages[@]}" -eq 0 ]; then
	icon_up-to-date
	info_msg "$(eval_gettext "No update available\n")"

	if [ -n "${list_option}" ]; then
		exit 7
	fi
else
	icon_updates-available
	if [ -z "${list_option}" ]; then
		if [ -n "${alhp_support}" ]; then
			# shellcheck source=src/lib/alhp_check.sh disable=SC2154
			source "${libdir}/alhp_check.sh"
		fi
		ask_msg "$(eval_gettext "Proceed with update? [Y/n]")"

		# shellcheck disable=SC2154
		case "${answer}" in
			"$(eval_gettext "Y")"|"$(eval_gettext "y")"|"")
				# shellcheck disable=SC2034,SC2154
				proceed_with_update="true"
				echo
			;;
			*)
				echo
				error_msg "$(eval_gettext "The update has been aborted\n")" && quit_msg
				exit 4
			;;
		esac
	fi
fi
