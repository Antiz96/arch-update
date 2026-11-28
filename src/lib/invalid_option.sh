#!/bin/bash

# invalid_option.sh: Display an error message when an invalid option is passed, hint users to check the help and exit
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

error_msg "$(eval_gettext "Invalid option: \${option}\nTry '\${name} --help' for more information")"
exit 1
