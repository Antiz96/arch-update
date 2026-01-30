#!/bin/bash

# restart_services.sh: Display services requiring a post update restart and offer to restart them
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

if [ -n "${packages_updated}" ] || [ -n "${services_option}" ]; then
	# shellcheck disable=SC2154
	services=$("${su_cmd}" checkservices -F -P -R -i gdm.service -i plasmalogin.service -i sddm.service -i lightdm.service -i lxdm.service -i slim.service -i xdm.service -i greetd.service -i nodm.service -i ly.service -i lemurs.service 2> /dev/null | grep ".service" | cut -f2 -d "'")
	services_num=$(echo "${services}" | wc -l)

	if [ -n "${services}" ]; then
		if [ "${services_num}" -eq 1 ]; then
			main_msg "$(eval_gettext "Services:\nThe following service requires a post upgrade restart\n")"
		else
			main_msg "$(eval_gettext "Services:\nThe following services require a post upgrade restart\n")"
		fi

		i=1
		while IFS= read -r line; do
			echo "${i} - ${line}"
			((i=i+1))
		done < <(printf '%s\n' "${services}")

		echo
		ask_msg_array "$(eval_gettext "Select the service(s) to restart (e.g. 1 3 5), select 0 to restart them all or press \"enter\" to continue without restarting the service(s):")"
		echo

		if [ "${answer_array[0]}" -eq 0 ] 2> /dev/null; then
			# shellcheck disable=SC2086,SC2154
			if "${su_cmd}" systemctl restart ${services}; then
				info_msg "$(eval_gettext "Service(s) restarted successfully\n")"

			else
				error_msg "$(eval_gettext "An error has occurred during the service(s) restart\nPlease, verify the above service(s) status\n")" && quit_msg
				exit 11
			fi
		else
			array_to_string=$(printf "%s\n" "${answer_array[@]}")
			mapfile -t answer_array < <(echo "${array_to_string}" | awk '!seen[$0]++')

			for num in "${answer_array[@]}"; do
				if [ "${num}" -le "${services_num}" ] 2> /dev/null && [ "${num}" -gt "0" ]; then
					service_restarted="true"
					service_selected=$(sed -n "${num}"p <<< "${services}")

					if "${su_cmd}" systemctl restart "${service_selected}"; then
						info_msg "$(eval_gettext "The \${service_selected} service has been successfully restarted")"
					else
						error_msg "$(eval_gettext "An error has occurred during the restart of the \${service_selected} service")"
						service_fail="true"
					fi
				fi
			done

			if [ -n "${service_restarted}" ]; then
				if [ -z "${service_fail}" ]; then
					echo
					info_msg "$(eval_gettext "Service(s) restarted successfully\n")"
				else
					echo
					error_msg "$(eval_gettext "An error has occurred during the service(s) restart\nPlease, verify the above service(s) status\n")" && quit_msg
					exit 11
				fi
			else
				warning_msg "$(eval_gettext "The service(s) restart hasn't been performed\nPlease, consider restarting services that have been updated to fully apply the upgrade\n")"
			fi
		fi
	else
		info_msg "$(eval_gettext "No service requiring a post upgrade restart found\n")"
	fi
fi
