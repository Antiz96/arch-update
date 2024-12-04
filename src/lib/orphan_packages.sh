#!/bin/bash

# orphan_packages.sh: Display orphan packages and offer to remove them
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

orphan_packages=$(pacman -Qtdq)

if [ -n "${flatpak}" ]; then
	flatpak_unused=$(flatpak uninstall --unused | sed -n '/^ 1./,$p' | awk '{print $2}' | grep -v '^$' | sed '$d')
fi

if [ -n "${orphan_packages}" ]; then
	main_msg "$(eval_gettext "Orphan Packages:")"
	echo -e "${orphan_packages}\n"

	if [ "$(echo "${orphan_packages}" | wc -l)" -eq 1 ]; then
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
			if ! pacman -Qtdq | "${su_cmd}" pacman --color "${pacman_color_opt}" -Rns -; then
				echo
				error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
			else
				echo
				info_msg "$(eval_gettext "The removal has been applied\n")"
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

if [ -n "${flatpak}" ]; then
	if [ -n "${flatpak_unused}" ]; then
		main_msg "$(eval_gettext "Flatpak Unused Packages:")"
		echo -e "${flatpak_unused}\n"

		if [ "$(echo "${flatpak_unused}" | wc -l)" -eq 1 ]; then
			ask_msg "$(eval_gettext "Would you like to remove this Flatpak unused package now? [y/N]")"
		else
			ask_msg "$(eval_gettext "Would you like to remove these Flatpak unused packages now? [y/N]")"
		fi

		case "${answer}" in
			"$(eval_gettext "Y")"|"$(eval_gettext "y")")
				echo
				main_msg "$(eval_gettext "Removing Flatpak Unused Packages...")"

				if ! flatpak uninstall --unused; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
				else
					echo
					info_msg "$(eval_gettext "The removal has been applied\n")"
				fi
			;;
			*)
				info_msg "$(eval_gettext "The removal hasn't been applied\n")"
			;;
		esac
	else
		info_msg "$(eval_gettext "No Flatpak unused package found\n")"
	fi
fi
