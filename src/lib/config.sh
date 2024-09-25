#!/bin/bash

# config.sh: Set configuration parameters, pre-steps and pre-verifications required for Arch-Update to work properly
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# Display debug traces if the -D/--debug argument is passed
for arg in "${@}"; do
	case "${arg}" in
		-D|--debug)
			set -x
		;;
	esac
done

# Reset the option var if it is equal to -D/--debug (to avoid false negative "invalid option" error)
# shellcheck disable=SC2154
case "${option}" in
	-D|--debug)
		unset option
	;;
esac

# Create state and tmp dirs if they don't exist
# shellcheck disable=SC2154
statedir="${XDG_STATE_HOME:-${HOME}/.local/state}/${name}"
tmpdir="${TMPDIR:-/tmp}/${name}-${UID}"
mkdir -p "${statedir}" "${tmpdir}"

# Declare necessary parameters for translations
# shellcheck disable=SC1091
. gettext.sh
# shellcheck disable=SC2154
export TEXTDOMAIN="${_name}" # Using "Arch-Update" as TEXTDOMAIN to avoid conflicting with the "arch-update" TEXTDOMAIN used by the arch-update Gnome extension (https://extensions.gnome.org/extension/1010/archlinux-updates-indicator/)
if [ -f "${XDG_DATA_HOME}/locale/fr/LC_MESSAGES/${_name}.mo" ]; then
	export TEXTDOMAINDIR="${XDG_DATA_HOME}/locale"
elif [ -f "${HOME}/.local/share/locale/fr/LC_MESSAGES/${_name}.mo" ]; then
	export TEXTDOMAINDIR="${HOME}/.local/share/locale"
elif [ -f "${XDG_DATA_DIRS}/locale/fr/LC_MESSAGES/${_name}.mo" ]; then
	export TEXTDOMAINDIR="${XDG_DATA_DIRS}/locale"
elif [ -f "/usr/local/share/locale/fr/LC_MESSAGES/${_name}.mo" ]; then
	export TEXTDOMAINDIR="/usr/local/share/locale"
fi

# Define the path to the arch-update.conf configuration file
config_file="${XDG_CONFIG_HOME:-${HOME}/.config}/${name}/${name}.conf"

# Check the "NoColor" option in arch-update.conf
if grep -Eq '^[[:space:]]*NoColor[[:space:]]*$' "${config_file}" 2> /dev/null; then
	# shellcheck disable=SC2034
	no_color="y"
fi

# Check the "NoVersion" option in arch-update.conf
if grep -Eq '^[[:space:]]*NoVersion[[:space:]]*$' "${config_file}" 2> /dev/null; then
	# shellcheck disable=SC2034
	no_version="y"
fi

# Check the "AlwaysShowNews" option in arch-update.conf
if grep -Eq '^[[:space:]]*AlwaysShowNews[[:space:]]*$' "${config_file}" 2> /dev/null; then
	# shellcheck disable=SC2034
	show_news="y"
fi

# Check the "NewsNum" option in arch-update.conf
if grep -Eq '^[[:space:]]*NewsNum[[:space:]]*=[[:space:]]*[1-9][0-9]*[[:space:]]*$' "${config_file}" 2> /dev/null; then
	# shellcheck disable=SC2034
	news_num=$(grep -E '^[[:space:]]*NewsNum[[:space:]]*=[[:space:]]*[1-9][0-9]*[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
else
	# shellcheck disable=SC2034
	news_num="5"
fi

# Check the "AURHelper" option in arch-update.conf
if grep -Eq '^[[:space:]]*AURHelper[[:space:]]*=[[:space:]]*(paru|yay)[[:space:]]*$' "${config_file}" 2> /dev/null; then
	# shellcheck disable=SC2034
	aur_helper=$(grep -E '^[[:space:]]*AURHelper[[:space:]]*=[[:space:]]*(paru|yay)[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
fi

# Check the "PrivilegeElevationCommand" option in arch-update.conf
if grep -Eq '^[[:space:]]*PrivilegeElevationCommand[[:space:]]*=[[:space:]]*(sudo|doas|run0)[[:space:]]*$' "${config_file}" 2> /dev/null; then
	# shellcheck disable=SC2034
	su_cmd=$(grep -E '^[[:space:]]*PrivilegeElevationCommand[[:space:]]*=[[:space:]]*(sudo|doas|run0)[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
fi

# Check the "KeepOldPackages" option in arch-update.conf
if grep -Eq '^[[:space:]]*KeepOldPackages[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$' "${config_file}" 2> /dev/null; then
	old_packages_num=$(grep -E '^[[:space:]]*KeepOldPackages[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
else
	# shellcheck disable=SC2034
	old_packages_num="3"
fi

# Check the "KeepUninstalledPackages" option in arch-update.conf
if grep -Eq '^[[:space:]]*KeepUninstalledPackages[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$' "${config_file}" 2> /dev/null; then
	uninstalled_packages_num=$(grep -E '^[[:space:]]*KeepUninstalledPackages[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
else
	# shellcheck disable=SC2034
	uninstalled_packages_num="0"
fi

# Check the "DiffProg" option in arch-update.conf
if grep -Eq '^[[:space:]]*DiffProg[[:space:]]*=[[:space:]]*[^[:space:]].*[[:space:]]*$' "${config_file}" 2> /dev/null; then
	# shellcheck disable=SC2034
	diff_prog=$(grep -E '^[[:space:]]*DiffProg[[:space:]]*=[[:space:]]*[^[:space:]].*[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
fi

# Check the "TrayIconStyle" option in arch-update.conf
if grep -Eq '^[[:space:]]*TrayIconStyle[[:space:]]*=[[:space:]]*(light|dark|blue)[[:space:]]*$' "${config_file}" 2> /dev/null; then
	# shellcheck disable=SC2034
	tray_icon_style=$(grep -E '^[[:space:]]*TrayIconStyle[[:space:]]*=[[:space:]]*(light|dark|blue)[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
fi
