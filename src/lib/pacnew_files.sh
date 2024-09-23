#!/bin/bash

# pacnew_files.sh: Display pacnew files and offer to process them
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

pacnew_files=$(pacdiff -o)

if [ -n "${pacnew_files}" ]; then
	main_msg "$(eval_gettext "Pacnew Files:")"
	echo -e "${pacnew_files}\n"

	if [ "$(echo "${pacnew_files}" | wc -l)" -eq 1 ]; then
		ask_msg "$(eval_gettext "Would you like to process this file now? [Y/n]")"
	else
		ask_msg "$(eval_gettext "Would you like to process these files now? [Y/n]")"
	fi

	# shellcheck disable=SC2154
	case "${answer}" in
		"$(eval_gettext "Y")"|"$(eval_gettext "y")"|"")
			echo
			main_msg "$(eval_gettext "Processing Pacnew Files...\n")"

			# shellcheck disable=SC2154
			if "${su_cmd}" "${diff_prog_opt[@]}" pacdiff "${contrib_color_opt[@]}"; then
				echo
				info_msg "$(eval_gettext "The pacnew file(s) processing has been applied\n")"
			else
				echo
				error_msg "$(eval_gettext "An error occurred during the pacnew file(s) processing\n")" && quit_msg
				exit 12
			fi
		;;
		*)
			echo
			warning_msg "$(eval_gettext "The pacnew file(s) processing hasn't been applied\nPlease, consider processing them promptly\n")"
		;;
	esac
else
	info_msg "$(eval_gettext "No pacnew file found\n")"
fi
