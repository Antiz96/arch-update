#!/bin/bash

# flatpak_unused_packages.sh: Display flatpak unused packages and offer to remove them
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

flatpak_unused=$(flatpak uninstall --unused | sed -n '/^ 1./,$p' | awk '{print $2}' | grep -v '^$' | sed '$d')

if [ -n "${flatpak_unused}" ]; then
	main_msg "$(eval_gettext "Flatpak Unused Packages:")"
	echo -e "${flatpak_unused}\n"

	if [ "$(echo "${flatpak_unused}" | wc -l)" -eq 1 ]; then
		ask_msg "$(eval_gettext "Would you like to remove this Flatpak unused package now? [y/N]")"
	else
		ask_msg "$(eval_gettext "Would you like to remove these Flatpak unused packages now? [y/N]")"
	fi

	# shellcheck disable=SC2154
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
			echo
			info_msg "$(eval_gettext "The removal hasn't been applied\n")"
		;;
	esac
else
	info_msg "$(eval_gettext "No Flatpak unused package found\n")"
fi
