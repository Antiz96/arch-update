#!/bin/bash

# config.sh: Check options set in the arch-update.conf configuration file
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# Define the path to the arch-update.conf configuration file
# shellcheck disable=SC2154
config_file="${XDG_CONFIG_HOME:-${HOME}/.config}/${name}/${name}.conf"

# Check options in the arch-update.conf configuration file if it exists
if [ -f "${config_file}" ]; then
	# Check the "NoColor" option in arch-update.conf
	# shellcheck disable=SC2034
	no_color=$(grep -Eq '^[[:space:]]*NoColor[[:space:]]*$' "${config_file}" 2> /dev/null && echo "true")

	# Check the "NoVersion" option in arch-update.conf
	# shellcheck disable=SC2034
	no_version=$(grep -Eq '^[[:space:]]*NoVersion[[:space:]]*$' "${config_file}" 2> /dev/null && echo "true")

	# Check the "NoAUR" option in arch-update.conf
	# shellcheck disable=SC2034
	no_aur=$(grep -Eq '^[[:space:]]*NoAUR[[:space:]]*$' "${config_file}" 2> /dev/null && echo "true")

	# Check the "NoFlatpak" option in arch-update.conf
	# shellcheck disable=SC2034
	no_flatpak=$(grep -Eq '^[[:space:]]*NoFlatpak[[:space:]]*$' "${config_file}" 2> /dev/null && echo "true")

	# Check the "NoNotification" option in arch-update.conf
	# shellcheck disable=SC2034
	no_notification=$(grep -Eq '^[[:space:]]*NoNotification[[:space:]]*$' "${config_file}" 2> /dev/null && echo "true")

	# Check the "NewsNum" option in arch-update.conf
	# shellcheck disable=SC2034
	news_num=$(grep -E '^[[:space:]]*NewsNum[[:space:]]*=[[:space:]]*[1-9][0-9]*[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "NewsTimeout" option in arch-update.conf
	# shellcheck disable=SC2034
	news_timeout=$(grep -E '^[[:space:]]*NewsTimeout[[:space:]]*=[[:space:]]*[0-9][0-9]*[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "AURHelper" option in arch-update.conf
	# shellcheck disable=SC2034
	aur_helper=$(grep -E '^[[:space:]]*AURHelper[[:space:]]*=[[:space:]]*(paru|yay|pikaur)[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "PrivilegeElevationCommand" option in arch-update.conf
	# shellcheck disable=SC2034
	su_cmd=$(grep -E '^[[:space:]]*PrivilegeElevationCommand[[:space:]]*=[[:space:]]*(sudo|sudo-rs|doas|run0)[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "KeepOldPackages" option in arch-update.conf
	# shellcheck disable=SC2034
	old_packages_num=$(grep -E '^[[:space:]]*KeepOldPackages[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "KeepUninstalledPackages" option in arch-update.conf
	# shellcheck disable=SC2034
	uninstalled_packages_num=$(grep -E '^[[:space:]]*KeepUninstalledPackages[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "DiffProg" option in arch-update.conf
	# shellcheck disable=SC2034
	diff_prog=$(grep -E '^[[:space:]]*DiffProg[[:space:]]*=[[:space:]]*[^[:space:]].*[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

	# Check the "TrayIconStyle" option in arch-update.conf
	# shellcheck disable=SC2034
	tray_icon_style=$(grep -E '^[[:space:]]*TrayIconStyle[[:space:]]*=[[:space:]]*(blue|light|dark)[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')

	# Check the "ColorblindMode" option in arch-update.conf
	# shellcheck disable=SC2034
	colorblind_mode=$(grep -Eq '^[[:space:]]*ColorblindMode[[:space:]]*$' "${config_file}" 2> /dev/null && echo "-cb")
fi

# Set the default / fallback value for options that require it (if the arch-update.conf configuration file doesn't exists, if the concerned option is commented or if the set value is invalid) 
[ -z "${news_num}" ] && news_num="5"
[ -z "${news_timeout}" ] && news_timeout="10"
[ -z "${old_packages_num}" ] && old_packages_num="3"
[ -z "${uninstalled_packages_num}" ] && uninstalled_packages_num="0"
[ -z "${tray_icon_style}" ] && tray_icon_style="blue"
