#!/bin/bash

# list_packages.sh: Display the list of packages available for updates
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

info_msg "$(eval_gettext "Looking for updates...\n")"

# shellcheck disable=SC2154
checkupdates_db_tmpdir=$(mktemp -d "${checkupdates_db_tmpdir_prefix}XXXXX")
# shellcheck disable=SC2154
packages=$(CHECKUPDATES_DB="${checkupdates_db_tmpdir}" timeout "${update_check_timeout}" checkupdates --nocolor)
packages_exit_code=$?

if [ "${packages_exit_code}" -eq 124 ]; then
	warning_msg "$(eval_gettext "Unable to retrieve Packages updates (request timeout)\n")"
	unset packages
elif [ -n "${no_version}" ]; then
	packages=$(echo "${packages}" | awk '{print $1}')
fi

if [ -n "${aur_helper}" ]; then
	# "< /dev/null" and "2 > /dev/null" needed for pikaur (which is not completely script friendly)
	# The former because it assumes an interactive TTY environment (causing `timeout` to behave unexpectedly) 
	# The latter because it outputs some descriptive string in stderr when looking for updates with -Qua
	# shellcheck disable=SC2154
	unformatted_aur_packages=$(timeout "${update_check_timeout}" "${aur_helper}" --color never "${devel_flag[@]}" -Qua < /dev/null 2> /dev/null)
	unformatted_aur_packages_exit_code=$?
	aur_packages=$(echo "${unformatted_aur_packages}" | sed 's/^ *//' | sed 's/ \+/ /g' | grep -vw "\[ignored\]$")

	if [ "${unformatted_aur_packages_exit_code}" -eq 124 ]; then
		warning_msg "$(eval_gettext "Unable to retrieve AUR Packages updates (request timeout)\n")"
		unset aur_packages
	elif [ -n "${no_version}" ]; then
		aur_packages=$(echo "${aur_packages}" | awk '{print $1}')
	fi
fi

if [ -n "${flatpak_support}" ]; then
	# `--foreground` because Flatpak requires interactive authentications through Polkit's `pkttyagent` if it is executed from a TTY / SSH environment
	timeout --foreground "${update_check_timeout}" flatpak update --appstream > /dev/null
	flatpak_metadata_update_exit_code=$?

	if [ "${flatpak_metadata_update_exit_code}" -eq 124 ]; then
		warning_msg "$(eval_gettext "Unable to retrieve Flatpak packages updates (request timeout)\n")"
	else
		mapfile -t flatpak_mask < <(flatpak mask | tr -d ' ')

		if [ "${#flatpak_mask[@]}" -gt 0 ]; then
			mapfile -t flatpak_packages < <(flatpak remote-ls --updates --cached --columns=application,version | tr -s '\t' ' ')

			declare -A app_names
			while read -r flatpak_id flatpak_name; do
				app_names["${flatpak_id}"]="${flatpak_name}"
			done < <(flatpak list --columns=application,name)

			mapfile -t flatpak_packages < <(
				for packages in "${flatpak_packages[@]}"; do
					read -r app_id app_version <<< "${packages}"

					for pattern in "${flatpak_mask[@]}"; do
						# shellcheck disable=SC2053
						[[ "${app_id}" == ${pattern} ]] && continue 2
					done

					app_name="${app_names[${app_id}]:-${app_id}}"

					if [ -z "${no_version}" ]; then
						echo "${app_name} ${app_version}"
					else
						echo "${app_name}"
					fi
				done
			)
		else
			if [ -z "${no_version}" ]; then
				mapfile -t flatpak_packages < <(flatpak remote-ls --updates --cached --columns=name,version | tr -s '\t' ' ')
			else
				mapfile -t flatpak_packages < <(flatpak remote-ls --updates --cached --columns=name)
			fi
		fi
	fi
fi

# shellcheck disable=SC2154
true > "${statedir}/last_updates_check"
true > "${statedir}/last_updates_check_packages"
true > "${statedir}/last_updates_check_aur"
true > "${statedir}/last_updates_check_flatpak"

# Re-color update list output with version diff highlighting
color_update_list() {
	local line pkgname oldver newver counter seg
	local -a old_vers new_vers

	while IFS= read -r line; do
		[ -z "${line}" ] && continue
		read -r pkgname oldver _ newver <<< "${line}"
		IFS='-' read -r old_vers_upstream _old_vers_release <<< "${oldver}"
		IFS='-' read -r new_vers_upstream _new_vers_release <<< "${newver}"
		IFS='.' read -ra old_vers <<< "${old_vers_upstream}"
		IFS='.' read -ra new_vers <<< "${new_vers_upstream}"
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
	echo "${packages}" >> "${statedir}/last_updates_check"
	echo "${packages}" > "${statedir}/last_updates_check_packages"
fi

if [ -n "${aur_packages}" ]; then
	main_msg "$(eval_gettext "AUR Packages:")"
	if [ -n "${no_color}" ] || [ -n "${no_version}" ]; then
		echo "${aur_packages}" | column -t
	else
		echo "${aur_packages}" | color_update_list | column -t
	fi
	echo
	echo "${aur_packages}" >> "${statedir}/last_updates_check"
	echo "${aur_packages}" > "${statedir}/last_updates_check_aur"
fi

if [ "${#flatpak_packages[@]}" -gt 0 ]; then
	main_msg "$(eval_gettext "Flatpak Packages:")"
	printf "%s\n" "${flatpak_packages[@]}" | column -t
	echo
	printf "%s\n" "${flatpak_packages[@]}" >> "${statedir}/last_updates_check"
	printf "%s\n" "${flatpak_packages[@]}" > "${statedir}/last_updates_check_flatpak"
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
				error_msg "$(eval_gettext "The update has been aborted\n")" && quit_msg
				exit 4
			;;
		esac
	fi
fi
