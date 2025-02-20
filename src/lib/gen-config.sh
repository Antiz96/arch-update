#!/bin/bash

# gen.config.sh: Generate a default "arch-update.conf" configuration file (if it doesn't exists yet)
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC2154
if [ -f "${XDG_DATA_HOME}/${name}/config/${name}.conf.example" ]; then
	example_config_file="${XDG_DATA_HOME}/${name}/config/${name}.conf.example"
elif [ -f "${HOME}/.local/share/${name}/config/${name}.conf.example" ]; then
	example_config_file="${HOME}/.local/share/${name}/config/${name}.conf.example"
elif [ -f "${XDG_DATA_DIRS}/${name}/config/${name}.conf.example" ]; then
	example_config_file="${XDG_DATA_DIRS}/${name}/config/${name}.conf.example"
elif [ -f "/usr/local/share/${name}/config/${name}.conf.example" ]; then
	example_config_file="/usr/local/share/${name}/config/${name}.conf.example"
elif [ -f "/usr/share/${name}/config/${name}.conf.example" ]; then
	example_config_file="/usr/share/${name}/config/${name}.conf.example"
else
	error_msg "$(eval_gettext "Example configuration file not found")"
	exit 8
fi

# shellcheck disable=SC2154
if [ -f "${config_file}" ] && [ -z "${overwrite_config_file}" ]; then
	error_msg "$(eval_gettext "The '\${config_file}' configuration file already exists\nPlease, remove it before generating a new one (or use --force to overwrite it)")"
	exit 8
else
	mkdir -p "${XDG_CONFIG_HOME:-${HOME}/.config}/${name}/" || exit 8
	cp -f "${example_config_file}" "${config_file}" || exit 8
	info_msg "$(eval_gettext "The '\${config_file}' configuration file has been generated")"
fi
