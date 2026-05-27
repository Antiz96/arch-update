#!/bin/bash

# update.sh: Update packages and state files
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

if [ -n "${packages}" ]; then
	echo
	main_msg "$(eval_gettext "Updating Packages...\n")"

	# shellcheck disable=SC2154
	if ! "${su_cmd}" pacman --color "${pacman_color_opt}" -Syu; then
		echo
		error_msg "$(eval_gettext "An error has occurred during the update process\nThe update has been aborted\n")" && quit_msg
		exit 5
	else
		true > "${statedir}/last_updates_check_packages"
		cat "${statedir}"/last_updates_check_{packages,aur,flatpak} > "${statedir}/last_updates_check"
		packages_updated="true"
	fi
fi

if [ -n "${aur_packages}" ]; then
	echo
	# shellcheck disable=SC2154
	# shellcheck source=src/lib/orphan_packages.sh
	source "${libdir}/orphan_packages.sh"

	main_msg "$(eval_gettext "Updating AUR Packages...\n")"

	# shellcheck disable=SC2154
	if ! "${aur_helper}" --color "${pacman_color_opt}" "${devel_flag[@]}" -Syu; then
		echo
		warning_msg "$(eval_gettext "An error has occurred during the update process\nThe update has been aborted\n")"
		error_during_update="true"
	else
		true > "${statedir}/last_updates_check_aur"
		cat "${statedir}"/last_updates_check_{packages,aur,flatpak} > "${statedir}/last_updates_check"
		# shellcheck disable=SC2034
		packages_updated="true"
	fi
fi

if [ -n "${flatpak_packages}" ]; then
	echo
	main_msg "$(eval_gettext "Updating Flatpak Packages...\n")"

	if ! flatpak update; then
		echo
		warning_msg "$(eval_gettext "An error has occurred during the update process\nThe update has been aborted\n")"
		error_during_update="true"
	else
		true > "${statedir}/last_updates_check_flatpak"
		cat "${statedir}"/last_updates_check_{packages,aur,flatpak} > "${statedir}/last_updates_check"
	fi
fi

if [ -z "${error_during_update}" ]; then
	icon_up-to-date
	echo
	info_msg "$(eval_gettext "The update has been applied\n")"
fi
