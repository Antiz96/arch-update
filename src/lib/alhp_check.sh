#!/bin/bash

# alhp_check.sh: Check ALHP status for outdated mirrors or packages in the build queue.
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

alhp_utils_output="$(alhp.utils -m 2>&1)"
alhp_utils_exit_code=$?

# Exit code 20 is returned if the primary ALHP mirror is out of date.
# Other exit codes return other errors that we should show to the user.
# Exit code 0 or 20 means there are queued packages.
if [ "${alhp_utils_exit_code}" -eq 20 ]; then
	warning_msg "$(eval_gettext "Your primary ALHP mirror is out of date!\n")"
fi

if [ -n "${alhp_utils_output}" ]; then
	# if exit code is 0 or 20, output packages. Otherwise, output error.
	if [ "${alhp_utils_exit_code}" -eq 0 ] || [ "${alhp_utils_exit_code}" -eq 20 ]; then
		warning_msg "$(eval_gettext "The following packages still have pending ALHP builds:")"
		echo -e "${alhp_utils_output}\n"
	else
		warning_msg "$(eval_gettext "Error during ALHP check:") ${alhp_utils_output}\n"
	fi
fi
