#!/bin/bash

# check.sh: Check for available updates
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck disable=SC2154
if [ "${2}" == "--enable" ]; then
	systemctl --user enable --now "${name}.timer"
	info_msg "$(eval_gettext "Automated update checks have been enabled")"
	exit 0
fi

# shellcheck source=src/lib/check_updates.sh
source "${libdir}/check_updates.sh" check

# shellcheck disable=SC2154
update_available=$(cat "${statedir}"/last_updates_check_{packages,aur,flatpak})
echo "${update_available}" > "${statedir}/current_updates_check"

if [ -n "${update_available}" ] && [ -n "${notification_support}" ] && ! diff "${statedir}/current_updates_check" "${statedir}/last_updates_check" &> /dev/null; then
	update_number=$(wc -l "${statedir}/current_updates_check" | awk '{print $1}')

	# shellcheck disable=SC2154
	last_notif_id=$(sed -n '1p' "${tmpdir}/notif_param" 2> /dev/null)

	systemctl --user stop "${name}-notification.service" 2>/dev/null || true

	systemd-run --user --unit="${name}-notification" --quiet \
		--setenv=DISPLAY="${DISPLAY}" \
		--setenv=DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS}" \
		--setenv=TEXTDOMAIN="${_name}" \
		--setenv=TEXTDOMAINDIR="${TEXTDOMAINDIR}" \
		--setenv=LANG="${LANG}" \
		--setenv=LANGUAGE="${LANGUAGE}" \
		--setenv=LC_ALL="${LC_ALL}" \
		--setenv=LC_MESSAGES="${LC_MESSAGES}" \
		--setenv=XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}" \
		--setenv=XDG_DATA_HOME="${XDG_DATA_HOME}" \
		--setenv=XDG_DATA_DIRS="${XDG_DATA_DIRS}" \
		--setenv=HOME="${HOME}" \
		--setenv=update_number="${update_number}" \
		--setenv=last_notif_id="${last_notif_id}" \
		--setenv=_name="${_name}" \
		--setenv=name="${name}" \
		--setenv=tray_icon_style="${tray_icon_style}" \
		--setenv=colorblind_mode="${colorblind_mode}" \
		--setenv=tmpdir="${tmpdir}" \
		--setenv=desktop_file="${desktop_file}" \
	"${libdir}/notification.sh"
fi

if [ -f "${statedir}/current_updates_check" ]; then
	mv -f "${statedir}/current_updates_check" "${statedir}/last_updates_check"
fi

if [ -n "${update_available}" ]; then
	icon_updates-available
else
	icon_up-to-date
fi
