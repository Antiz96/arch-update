#!/bin/bash

# full_upgrade.sh: Execute the series of relevant functions/libraries to perform a complete and proper update of the system
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# Source the "list_packages" library which displays the list of packages available for updates
# shellcheck source=src/lib/list_packages.sh
source "${libdir}/list_packages.sh"

# If the user gave the confirmation to proceed to apply updates
if [ -n "${proceed_with_update}" ]; then
	# Source the "list_news" library which displays the latest Arch news and offers to read them
	# shellcheck source=src/lib/list_news.sh
	source "${libdir}/list_news.sh"

	# Source the "update" library which updates packages
	# shellcheck source=src/lib/update.sh
	source "${libdir}/update.sh"

	# Record the date of the last successful update (used by other stages) 
	date +%Y-%m-%d > "${statedir}/last_update_run"
fi

# Source the "orphan_packages" library which displays orphan packages and offers to remove them
# shellcheck source=src/lib/orphan_packages.sh
source "${libdir}/orphan_packages.sh"

# Source the "packages_cache" library which searches for old package archives in pacman cache and offers to remove them
# shellcheck source=src/lib/packages_cache.sh
source "${libdir}/packages_cache.sh"

# Source the "pacnew_files" library which display pacnew files and offers to process them 
# shellcheck source=src/lib/pacnew_files.sh
source "${libdir}/pacnew_files.sh"

# Source the "kernel_reboot" library which check if there's a pending kernel update requiring a reboot to be applied
# shellcheck source=src/lib/kernel_reboot.sh
source "${libdir}/kernel_reboot.sh"

# Source the "restart_services" library which displays services requiring a post update restart and offers to restart them
# shellcheck source=src/lib/restart_services.sh
source "${libdir}/restart_services.sh"

# Display the "quit" message on successful full upgrade
quit_msg
