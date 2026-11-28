#!/bin/bash

# packages_cache.sh: Search for old packages archives in the pacman cache and offer to remove them
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC2154
pacman_cache_old=$(paccache -dvk"${old_packages_num}" | grep -E '\.pkg\.tar\.zst$')
pacman_cache_old_num=$(printf '%s\n' "${pacman_cache_old}" | grep -c .)
# shellcheck disable=SC2154
pacman_cache_uninstalled=$(paccache -duvk"${uninstalled_packages_num}" | grep -E '\.pkg\.tar\.zst$')
pacman_cache_uninstalled_num=$(printf '%s\n' "${pacman_cache_uninstalled}" | grep -c .)

pacman_cache_list=$(printf '%s\n%s\n' "${pacman_cache_old}" "${pacman_cache_uninstalled}" | awk 'NF' | sort -u)
pacman_cache_total=$(printf '%s\n' "${pacman_cache_list}" | grep -c .)

if [ "${pacman_cache_total}" -gt 0 ]; then

	main_msg "$(eval_gettext "Cached Packages:")"
	echo -e "${pacman_cache_list}\n"

	if [ "${pacman_cache_total}" -eq 1 ]; then
		ask_msg "$(eval_gettext "Would you like to remove this old or uninstalled package from the cache now? [Y/n]")"
	else
		ask_msg "$(eval_gettext "Would you like to remove these old and / or uninstalled packages from the cache now? [Y/n]")"
	fi

	# shellcheck disable=SC2154
	case "${answer}" in
		"$(eval_gettext "Y")"|"$(eval_gettext "y")"|"")
			if [ "${pacman_cache_old_num}" -gt 0 ] && [ "${pacman_cache_uninstalled_num}" -eq 0 ]; then
				echo
				main_msg "$(eval_gettext "Removing old cached packages...")"

				# shellcheck disable=SC2154
				if ! "${su_cmd}" paccache "${contrib_color_opt[@]}" -rk"${old_packages_num}"; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
				else
					echo
				fi
			elif [ "${pacman_cache_old_num}" -eq 0 ] && [ "${pacman_cache_uninstalled_num}" -gt 0 ]; then
				echo
				main_msg "$(eval_gettext "Removing uninstalled cached packages...")"

				if ! "${su_cmd}" paccache "${contrib_color_opt[@]}" -ruk"${uninstalled_packages_num}"; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
				else
					echo
				fi
			elif [ "${pacman_cache_old_num}" -gt 0 ] && [ "${pacman_cache_uninstalled_num}" -gt 0 ]; then
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
