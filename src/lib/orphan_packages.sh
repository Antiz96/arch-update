#!/bin/bash

# orphan_packages.sh: Display orphan packages and offer to remove them
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

mapfile -t orphan_packages < <(pacman -Qtdq)

if [ "${#orphan_packages[@]}" -gt 0 ]; then
	main_msg "$(eval_gettext "Orphan Packages:")"
	printf "%s\n" "${orphan_packages[@]}" ""

	if [ "${#orphan_packages[@]}" -eq 1 ]; then
		ask_msg "$(eval_gettext "Would you like to remove this orphan package (and its potential dependencies) now? [y/N]")"
	else
		ask_msg "$(eval_gettext "Would you like to remove these orphan packages (and their potential dependencies) now? [y/N]")"
	fi

	# shellcheck disable=SC2154
	case "${answer}" in
		"$(eval_gettext "Y")"|"$(eval_gettext "y")")
			echo
			main_msg "$(eval_gettext "Removing Orphan Packages...\n")"

			# shellcheck disable=SC2154
			if ! "${su_cmd}" pacman --color "${pacman_color_opt}" -Rns "${orphan_packages[@]}"; then
				echo
				error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
			else
				echo
				info_msg "$(eval_gettext "The removal has been applied\n")"
				unset orphan_packages
			fi
		;;
		*)
			echo
			info_msg "$(eval_gettext "The removal hasn't been applied\n")"
		;;
	esac
else
	info_msg "$(eval_gettext "No orphan package found\n")"
fi
