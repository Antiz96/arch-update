#!/bin/bash

# show-config.sh: Display the current "arch-update.conf" configuration file
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC2154
if [ ! -f "${config_file}" ]; then
	error_msg "$(eval_gettext "No configuration file found\nYou can generate one with \"\${name} --gen-config\"")"
	exit 9
else
	cat "${config_file}" || exit 9
fi
