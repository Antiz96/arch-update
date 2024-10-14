#!/bin/bash

# packages_cache.sh: Search for old packages archives in the pacman cache and offer to remove them
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC2154
pacman_cache_old=$(paccache -dk"${old_packages_num}" | sed -n 's/.*: \([0-9]*\) candidate.*/\1/p')
# shellcheck disable=SC2154
pacman_cache_uninstalled=$(paccache -duk"${uninstalled_packages_num}" | sed -n 's/.*: \([0-9]*\) candidate.*/\1/p')

# shellcheck disable=SC2154
[ -z "${pacman_cache_old}" ] && pacman_cache_old="0"
# shellcheck disable=SC2154
[ -z "${pacman_cache_uninstalled}" ] && pacman_cache_uninstalled="0"
pacman_cache_total=$(("${pacman_cache_old}+${pacman_cache_uninstalled}"))

if [ "${pacman_cache_total}" -gt 0 ]; then

	if [ "${pacman_cache_total}" -eq 1 ]; then
		main_msg "$(eval_gettext "Cached Packages:\nThere's an old or uninstalled cached package\n")"
		ask_msg "$(eval_gettext "Would you like to remove it from the cache now? [Y/n]")"
	else
		main_msg "$(eval_gettext "Cached Packages:\nThere are old and / or uninstalled cached packages\n")"
		ask_msg "$(eval_gettext "Would you like to remove them from the cache now? [Y/n]")"
	fi

	# shellcheck disable=SC2154
	case "${answer}" in
		"$(eval_gettext "Y")"|"$(eval_gettext "y")"|"")
			if [ "${pacman_cache_old}" -gt 0 ] && [ "${pacman_cache_uninstalled}" -eq 0 ]; then
				echo
				main_msg "$(eval_gettext "Removing old cached packages...")"

				# shellcheck disable=SC2154
				if ! "${su_cmd}" paccache "${contrib_color_opt[@]}" -rk"${old_packages_num}"; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
				else
					echo
				fi
			elif [ "${pacman_cache_old}" -eq 0 ] && [ "${pacman_cache_uninstalled}" -gt 0 ]; then
				echo
				main_msg "$(eval_gettext "Removing uninstalled cached packages...")"

				if ! "${su_cmd}" paccache "${contrib_color_opt[@]}" -ruk"${uninstalled_packages_num}"; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
				else
					echo
				fi
			elif [ "${pacman_cache_old}" -gt 0 ] && [ "${pacman_cache_uninstalled}" -gt 0 ]; then
				echo
				main_msg "$(eval_gettext "Removing old cached packages...")"

				if ! "${su_cmd}" paccache "${contrib_color_opt[@]}" -rk"${old_packages_num}"; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
				else
					echo
				fi

				main_msg "$(eval_gettext "Removing uninstalled cached packages...")"

				if ! "${su_cmd}" paccache "${contrib_color_opt[@]}" -ruk"${uninstalled_packages_num}"; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
				else
					echo
				fi
			fi
		;;
		*)
			echo
			info_msg "$(eval_gettext "The removal hasn't been applied\n")"
		;;
	esac
else
	info_msg "$(eval_gettext "No old or uninstalled cached package found\n")"
fi
