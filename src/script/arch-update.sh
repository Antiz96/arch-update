#!/bin/bash

# arch-update: An update notifier/applier for Arch Linux that assists you with important pre/post update tasks.
# https://github.com/Antiz96/arch-update
# SPDX-License-Identifier: GPL-3.0-or-later

# General variables
name="arch-update"
_name="Arch-Update"
version="2.3.1"
option="${1}"

# Display debug traces if the -D/--debug argument is passed
for arg in "${@}"; do
	case "${arg}" in
		-D|--debug)
			set -x
		;;
	esac
done

# Reset the option var if it is equal to -D/--debug (to avoid false negative "invalid option" error)
case "${option}" in
	-D|--debug)
		unset option
	;;
esac

# Declare necessary parameters for translations
# shellcheck disable=SC1091
. gettext.sh
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

# Checking options in arch-update.conf
config_file="${XDG_CONFIG_HOME:-${HOME}/.config}/${name}/${name}.conf"

if grep -Eq '^[[:space:]]*NoColor[[:space:]]*$' "${config_file}" 2> /dev/null; then
	no_color="y"
fi

if grep -Eq '^[[:space:]]*NoVersion[[:space:]]*$' "${config_file}" 2> /dev/null; then
	no_version="y"
fi

if grep -Eq '^[[:space:]]*AlwaysShowNews[[:space:]]*$' "${config_file}" 2> /dev/null; then
	show_news="y"
fi

if grep -Eq '^[[:space:]]*NewsNum[[:space:]]*=[[:space:]]*[1-9][0-9]*[[:space:]]*$' "${config_file}" 2> /dev/null; then
	news_num=$(grep -E '^[[:space:]]*NewsNum[[:space:]]*=[[:space:]]*[1-9][0-9]*[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
else
	news_num="5"
fi

if grep -Eq '^[[:space:]]*KeepOldPackages[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$' "${config_file}" 2> /dev/null; then
	old_packages_num=$(grep -E '^[[:space:]]*KeepOldPackages[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
else
	old_packages_num="3"
fi

if grep -Eq '^[[:space:]]*KeepUninstalledPackages[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$' "${config_file}" 2> /dev/null; then
	uninstalled_packages_num=$(grep -E '^[[:space:]]*KeepUninstalledPackages[[:space:]]*=[[:space:]]*[0-9]+[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
else
	uninstalled_packages_num="0"
fi

if grep -Eq '^[[:space:]]*PrivilegeElevationCommand[[:space:]]*=[[:space:]]*(sudo|doas|run0)[[:space:]]*$' "${config_file}" 2> /dev/null; then
	su_cmd=$(grep -E '^[[:space:]]*PrivilegeElevationCommand[[:space:]]*=[[:space:]]*(sudo|doas|run0)[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
fi

if grep -Eq '^[[:space:]]*DiffProg[[:space:]]*=[[:space:]]*[^[:space:]].*[[:space:]]*$' "${config_file}" 2> /dev/null; then
	diff_prog=$(grep -E '^[[:space:]]*DiffProg[[:space:]]*=[[:space:]]*[^[:space:]].*[[:space:]]*$' "${config_file}" 2> /dev/null | awk -F '=' '{print $2}' | tr -d '[:space:]')
fi

# Definition of the colors for the colorized output
if [ -z "${no_color}" ]; then
	bold="\e[1m"
	blue="${bold}\e[34m"
	green="${bold}\e[32m"
	yellow="${bold}\e[33m"
	red="${bold}\e[31m"
	color_off="\e[0m"
	pacman_color_opt="always"
else
	pacman_color_opt="never"
	contrib_color_opt+=("--nocolor")
fi

# Create state and tmp dirs if they don't exist
statedir="${XDG_STATE_HOME:-${HOME}/.local/state}/${name}"
tmpdir="${TMPDIR:-/tmp}/${name}-${UID}"
mkdir -p "${statedir}" "${tmpdir}"

# Definition of the main_msg function: Display a message as a main message
main_msg() {
	msg="${1}"
	echo -e "${blue}==>${color_off}${bold} ${msg}${color_off}"
}

# Definition of the info_msg function: Display a message as an information message
info_msg() {
	msg="${1}"
	echo -e "${green}==>${color_off}${bold} ${msg}${color_off}"
}

# Definition of the ask_msg function: Display a message as an interactive question
ask_msg() {
	msg="${1}"
	read -rp $"$(echo -e "${blue}->${color_off}${bold} ${msg}${color_off} ")" answer
}

# Definition of the ask_msg_array function: Display a message as an interactive question with multiple possible answers 
ask_msg_array() {
	msg="${1}"
	read -rp $"$(echo -e "${blue}->${color_off}${bold} ${msg}${color_off} ")" -a answer_array
}

# Definition of the warning_msg function: Display a message as a warning message
warning_msg() {
	msg="${1}"
	echo -e "${yellow}==> $(eval_gettext "WARNING"):${color_off}${bold} ${msg}${color_off}"
}

# Definition of the error_msg function: Display a message as an error message
error_msg() {
	msg="${1}"
	echo -e >&2 "${red}==> $(eval_gettext "ERROR"):${color_off}${bold} ${msg}${color_off}"
}

# Definition of the continue_msg function: Display the continue message
continue_msg() {
	msg="$(eval_gettext "Press \"enter\" to continue ")"
	read -n 1 -r -s -p $"$(info_msg "${msg}")" && echo
}

# Definition of the quit_msg function: Display the quit message
quit_msg() {
	msg="$(eval_gettext "Press \"enter\" to quit ")"
	read -n 1 -r -s -p $"$(info_msg "${msg}")" && echo
}

# Definition of the elevation command to use (depending on which one is installed on the system and if it's not already defined in arch-update.conf)
if [ -z "${su_cmd}" ]; then
	if command -v sudo > /dev/null; then
		su_cmd="sudo"
	elif command -v doas > /dev/null; then
		su_cmd="doas"
	elif command -v run0 > /dev/null; then
		su_cmd="run0"
	else
		error_msg "$(eval_gettext "A privilege elevation command is required (sudo, doas or run0)\n")" && quit_msg
		exit 2
	fi
else
	if ! command -v "${su_cmd}" > /dev/null; then
		error_msg "$(eval_gettext "The \${su_cmd} command set for privilege escalation in the arch-update.conf configuration file is not found\n")" && quit_msg
		exit 2
	fi
fi

# Definition of the diff program to use (if it is set in the arch-update.conf configuration file)
if [ -n "${diff_prog}" ]; then
	if [ "${su_cmd}" == "sudo" ]; then
		diff_prog_opt=("DIFFPROG=${diff_prog}")
	elif [ "${su_cmd}" == "run0" ]; then
		diff_prog_opt+=("--setenv=DIFFPROG=${diff_prog}")
	fi
fi

# Definition of the AUR helper to use (depending on if/which one is installed on the system) for the optional AUR packages support
if command -v paru > /dev/null; then
	aur_helper="paru"
elif command -v yay > /dev/null; then
	aur_helper="yay"
fi

# Check if flatpak is installed for the optional Flatpak support
flatpak=$(command -v flatpak)

# Check if notify-send is installed for the optional desktop notification support
notif=$(command -v notify-send)

# Definition of the help function: Display the help message
help() {
	cat <<EOF
${name} v${version}

$(eval_gettext "An update notifier/applier for Arch Linux that assists you with important pre/post update tasks.")

$(eval_gettext "Run \${name} to perform the main 'update' function:")
$(eval_gettext "Display the list of packages available for update, then ask for the user's confirmation to proceed with the installation.")
$(eval_gettext "Before performing the update, it offers to display the latest Arch Linux news.")
$(eval_gettext "Post update, it checks for orphan/unused packages, old cached packages, pacnew/pacsave files, services requiring a post upgrade restart as well as pending kernel update and, if there are, offers to process them.")

$(eval_gettext "Options:")
$(eval_gettext "  -c, --check       Check for available updates, change the systray icon and send a desktop notification containing the number of available updates (if there are new available updates compared to the last check)")
$(eval_gettext "  -l, --list        Display the list of pending updates")
$(eval_gettext "  -d, --devel       Include AUR development packages updates")
$(eval_gettext "  -n, --news [Num]  Display latest Arch news, you can optionally specify the number of Arch news to display with '--news [Num]' (e.g. '--news 10')")
$(eval_gettext "  -D, --debug       Display debug traces")
$(eval_gettext "  --gen-config      Generate a default/example 'arch-update.conf' configuration file")
$(eval_gettext "  --show-config     Display the 'arch-update.conf' configuration file currently used (if it exists)")
$(eval_gettext "  --edit-config     Edit the 'arch-update.conf' configuration file currently used (if it exists)")
$(eval_gettext "  --tray            Launch the Arch-Update systray applet, you can optionally add the '--enable' argument to start it automatically at boot")
$(eval_gettext "  -h, --help        Display this help message and exit")
$(eval_gettext "  -V, --version     Display version information and exit")

$(eval_gettext "For more information, see the \${name}(1) man page.")
$(eval_gettext "Certain options can be enabled/disabled or modified via the \${name}.conf configuration file, see the \${name}.conf(5) man page.")
EOF
}

# Definition of the version function: Display the version information
version() {
	echo "${name} ${version}"
}

# Definition of the invalid_option function: Display an error message, ask the user to check the help and exit
invalid_option() {
	echo -e >&2 "$(eval_gettext "\${name}: invalid option -- '\${option}'\nTry '\${name} --help' for more information.")"
	exit 1
}

# Definition of the state_updates_available function: Change state to "updates-available"
state_updates_available() {
	echo "${name}_updates-available" > "${statedir}/current_state"
}

# Definition of the state_up_to_date function: Change state to "up to date"
state_up_to_date() {
	echo "${name}" > "${statedir}/current_state"
}

# Definition of the check function: Check for available updates, change the icon accordingly and send a desktop notification containing the number of available updates
check() {
	if [ -n "${aur_helper}" ] && [ -n "${flatpak}" ]; then
		update_available=$(checkupdates ; "${aur_helper}" -Qua ; flatpak update | sed -n '/^ 1./,$p' | awk '{print $2}' | grep -v '^$' | sed '$d')
	elif [ -n "${aur_helper}" ] && [ -z "${flatpak}" ]; then
		update_available=$(checkupdates ; "${aur_helper}" -Qua)
	elif [ -z "${aur_helper}" ] && [ -n "${flatpak}" ]; then
		update_available=$(checkupdates ; flatpak update | sed -n '/^ 1./,$p' | awk '{print $2}' | grep -v '^$' | sed '$d')
	else
		update_available=$(checkupdates)
	fi

	if [ -n "${notif}" ]; then
		echo "${update_available}" > "${statedir}/current_updates_check"
		sed -i '/^\s*$/d' "${statedir}/current_updates_check"
	fi

	if [ -n "${update_available}" ]; then
		state_updates_available

		if [ -n "${notif}" ]; then
			if ! diff "${statedir}/current_updates_check" "${statedir}/last_updates_check" &> /dev/null; then
				update_number=$(wc -l "${statedir}/current_updates_check" | awk '{print $1}')
				last_notif_id=$(cat "${tmpdir}/last_notif_id" 2> /dev/null)
				if [ "${update_number}" -eq 1 ]; then
					if [ -z "${last_notif_id}" ]; then
						notify-send -p -i "${name}" "${_name}" "$(eval_gettext "\${update_number} update available")" > "${tmpdir}/last_notif_id"
					else
						notify-send -p -r "${last_notif_id}" -i "${name}" "${_name}" "$(eval_gettext "\${update_number} update available")" > "${tmpdir}/last_notif_id"
					fi

				else
					if [ -z "${last_notif_id}" ]; then
						notify-send -p -i "${name}" "${_name}" "$(eval_gettext "\${update_number} updates available")" > "${tmpdir}/last_notif_id"
					else
						notify-send -p -r "${last_notif_id}" -i "${name}" "${_name}" "$(eval_gettext "\${update_number} updates available")" > "${tmpdir}/last_notif_id"
					fi
				fi
			fi
		fi
	else
		state_up_to_date
	fi

	if [ -f "${statedir}/current_updates_check" ]; then
		mv -f "${statedir}/current_updates_check" "${statedir}/last_updates_check"
	fi
}

# Definition of the list_packages function: Display packages that are available for update and offer to apply them if there are
list_packages() {
	info_msg "$(eval_gettext "Looking for updates...\n")"

	if [ -z "${no_version}" ]; then
		packages=$(checkupdates "${contrib_color_opt[@]}")
	else
		packages=$(checkupdates "${contrib_color_opt[@]}" | awk '{print $1}')
	fi

	if [ -n "${aur_helper}" ]; then
		if [ -z "${no_version}" ]; then
			aur_packages=$("${aur_helper}" --color "${pacman_color_opt}" "${devel_flag[@]}" -Qua)
		else
			aur_packages=$("${aur_helper}" --color "${pacman_color_opt}" "${devel_flag[@]}" -Qua | awk '{print $1}')
		fi
	fi

	if [ -n "${flatpak}" ]; then
		flatpak_packages=$(flatpak update | sed -n '/^ 1./,$p' | awk '{print $2}' | grep -v '^$' | sed '$d')
	fi

	if [ -n "${packages}" ]; then
		main_msg "$(eval_gettext "Packages:")"
		echo -e "${packages}\n"
	fi

	if [ -n "${aur_packages}" ]; then
		main_msg "$(eval_gettext "AUR Packages:")"
		echo -e "${aur_packages}\n"
	fi

	if [ -n "${flatpak_packages}" ]; then
		main_msg "$(eval_gettext "Flatpak Packages:")"
		echo -e "${flatpak_packages}\n"
	fi

	if [ -z "${packages}" ] && [ -z "${aur_packages}" ] && [ -z "${flatpak_packages}" ]; then
		state_up_to_date
		info_msg "$(eval_gettext "No update available\n")"

		if [ -n "${list_option}" ]; then
			exit 7
		fi
	else
		state_updates_available
		if [ -z "${list_option}" ]; then
			ask_msg "$(eval_gettext "Proceed with update? [Y/n]")"

			case "${answer}" in
				"$(eval_gettext "Y")"|"$(eval_gettext "y")"|"")
					proceed_with_update="y"
					echo
				;;
				*)
					error_msg "$(eval_gettext "The update has been aborted\n")" && quit_msg
					exit 4
				;;
			esac
		fi
	fi
}

# Definition of the list_news function: Display the latest Arch news and offers to read them
list_news() {
	info_msg "$(eval_gettext "Looking for recent Arch News...")"
	news=$(curl -m 30 -Lfs https://www.archlinux.org/news || echo "error")

	if [ "${news}" == "error" ]; then
		echo
		warning_msg "$(eval_gettext "Unable to retrieve recent Arch News (HTTP error response or request timeout)\nPlease, look for any recent news at https://archlinux.org before updating your system")"
	else
		if [ -z "${show_news}" ]; then
			echo "${news}" | htmlq -a title a | grep ^"View:" | sed "s/View:\ //g" | head -1 > "${statedir}/current_news_check"
	
			if ! diff "${statedir}/current_news_check" "${statedir}/last_news_check" &> /dev/null; then
				show_news="y"
			else
				echo
				info_msg "$(eval_gettext "No recent Arch News found")"
			fi
	
			if [ -f "${statedir}/current_news_check" ]; then
				mv -f "${statedir}/current_news_check" "${statedir}/last_news_check"
			fi
		fi
	
		if [ -n "${show_news}" ]; then
			news_titles=$(echo "${news}" | htmlq -a title a | grep ^"View:" | sed "s/View:\ //g" | head -"${news_num}")
			mapfile -t news_dates < <(echo "${news}" | htmlq td | grep -v "class" | grep "[0-9]" | sed "s/<[^>]*>//g" | head -"${news_num}" | xargs -I{} date -d "{}" "+%s")
	
			echo
			main_msg "$(eval_gettext "Arch News:")"
	
			i=1
			while IFS= read -r line; do
				if [ -z "${news_option}" ] && [ "${news_dates["${i}-1"]}" -ge "$(date -d "$(cat "${statedir}/last_update_run" 2> /dev/null)" +%s)" ] 2> /dev/null; then
					new_tag="$(eval_gettext "[NEW]")"
					echo -e "${i} - ${line} ${green}${new_tag}${color_off}"
				else
					echo "${i} - ${line}"
				fi
				((i=i+1))
			done < <(printf '%s\n' "${news_titles}")
	
			echo
	
			if [ -n "${news_option}" ]; then
				ask_msg_array "$(eval_gettext "Select the news to read (e.g. 1 3 5), select 0 to read them all or press \"enter\" to quit:")"
			else
				ask_msg_array "$(eval_gettext "Select the news to read (e.g. 1 3 5), select 0 to read them all or press \"enter\" to proceed with update:")"
			fi
	
			if [ "${answer_array[0]}" -eq 0 ] 2> /dev/null; then
				answer_array=()
				for ((i=1; i<=news_num; i++)); do
					answer_array+=("${i}")
				done
			else
				array_to_string=$(printf "%s\n" "${answer_array[@]}")
				mapfile -t answer_array < <(echo "${array_to_string}" | awk '!seen[$0]++')
			fi
	
			for num in "${answer_array[@]}"; do
				if [ "${num}" -le "${news_num}" ] 2> /dev/null && [ "${num}" -gt "0" ]; then
					printed_news="y"
					news_selected=$(sed -n "${num}"p <<< "${news_titles}")
					news_path=$(echo "${news_selected}" | sed s/\ -//g | sed s/\ /-/g | sed s/[.]//g | sed s/=//g | sed s/\>//g | sed s/\<//g | sed s/\`//g | sed s/://g | sed s/+//g | sed s/[[]//g | sed s/]//g | sed s/,//g | sed s/\(//g | sed s/\)//g | sed s/[/]//g | sed s/@//g | sed s/\'//g | sed s/--/-/g | awk '{print tolower($0)}')
					news_url="https://www.archlinux.org/news/${news_path}"
					news_content=$(curl -m 30 -Lfs "${news_url}" || echo "error")

					if [ "${news_content}" == "error" ]; then
						echo
						warning_msg "$(eval_gettext "Unable to retrieve the selected Arch News (HTTP error response or request timeout)\nPlease, read the selected Arch News at \${news_url} before updating your system")"
					else
						news_author=$(echo "${news_content}" | htmlq -t .article-info | cut -f3- -d " ")
						news_date=$(echo "${news_content}" | htmlq -t .article-info | cut -f1 -d " ")
						news_article=$(echo "${news_content}" | htmlq -t .article-content)
						title_tag="$(eval_gettext "Title:")"
						author_tag="$(eval_gettext "Author:")"
						publication_date_tag="$(eval_gettext "Publication date:")"
						url_tag="$(eval_gettext "URL:")"
						echo -e "\n${blue}---${color_off}\n${bold}${title_tag}${color_off} ${news_selected}\n${bold}${author_tag}${color_off} ${news_author}\n${bold}${publication_date_tag}${color_off} ${news_date}\n${bold}${url_tag}${color_off} ${news_url}\n${blue}---${color_off}\n\n${news_article}"
					fi
				fi
			done
	
			if [ -z "${news_option}" ] && [ -n "${printed_news}" ]; then
				echo
				continue_msg
			fi
		fi
	fi
}

# Definition of the update function: Update packages
update() {
	if [ -n "${packages}" ]; then
		echo
		main_msg "$(eval_gettext "Updating Packages...\n")"

		if ! "${su_cmd}" pacman --color "${pacman_color_opt}" -Syu; then
			state_updates_available
			echo
			error_msg "$(eval_gettext "An error has occurred during the update process\nThe update has been aborted\n")" && quit_msg
			exit 5
		else
			packages_updated="y"
		fi
	fi

	if [ -n "${aur_packages}" ]; then
		echo
		main_msg "$(eval_gettext "Updating AUR Packages...\n")"

		if ! "${aur_helper}" --color "${pacman_color_opt}" "${devel_flag[@]}" -Syu; then
			state_updates_available
			echo
			error_msg "$(eval_gettext "An error has occurred during the update process\nThe update has been aborted\n")" && quit_msg
			exit 5
		else
			packages_updated="y"
		fi
	fi

	if [ -n "${flatpak_packages}" ]; then
		echo
		main_msg "$(eval_gettext "Updating Flatpak Packages...\n")"

		if ! flatpak update; then
			state_updates_available
			error_msg "$(eval_gettext "An error has occurred during the update process\nThe update has been aborted\n")" && quit_msg
			exit 5
		fi
	fi

	state_up_to_date
	echo
	info_msg "$(eval_gettext "The update has been applied\n")"
}

# Definition of the orphan_packages function: Display orphan packages and offer to remove them if there are
orphan_packages() {
	orphan_packages=$(pacman -Qtdq)

	if [ -n "${flatpak}" ]; then
		flatpak_unused=$(flatpak remove --unused | awk '{print $2}' | grep -v '^$' | sed '$d')
	fi

	if [ -n "${orphan_packages}" ]; then
		main_msg "$(eval_gettext "Orphan Packages:")"
		echo -e "${orphan_packages}\n"

		if [ "$(echo "${orphan_packages}" | wc -l)" -eq 1 ]; then
			ask_msg "$(eval_gettext "Would you like to remove this orphan package (and its potential dependencies) now? [y/N]")"
		else
			ask_msg "$(eval_gettext "Would you like to remove these orphan packages (and their potential dependencies) now? [y/N]")"
		fi

		case "${answer}" in
			"$(eval_gettext "Y")"|"$(eval_gettext "y")")
				echo
				main_msg "$(eval_gettext "Removing Orphan Packages...\n")"

				if ! pacman -Qtdq | "${su_cmd}" pacman --color "${pacman_color_opt}" -Rns -; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
				else
					echo
					info_msg "$(eval_gettext "The removal has been applied\n")"
				fi
			;;
			*)
				echo
				info_msg "$(eval_gettext "The removal hasn't been applied\n")"
			;;
		esac
	else
		info_msg "$(eval_gettext "No orphan package found\n")"
	fi

	if [ -n "${flatpak}" ]; then
		if [ -n "${flatpak_unused}" ]; then
			main_msg "$(eval_gettext "Flatpak Unused Packages:")"
			echo -e "${flatpak_unused}\n"

			if [ "$(echo "${flatpak_unused}" | wc -l)" -eq 1 ]; then
				ask_msg "$(eval_gettext "Would you like to remove this Flatpak unused package now? [y/N]")"
			else
				ask_msg "$(eval_gettext "Would you like to remove these Flatpak unused packages now? [y/N]")"
			fi

			case "${answer}" in
				"$(eval_gettext "Y")"|"$(eval_gettext "y")")
					echo
					main_msg "$(eval_gettext "Removing Flatpak Unused Packages...")"

					if ! flatpak remove --unused; then
						echo
						error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
					else
						echo
						info_msg "$(eval_gettext "The removal has been applied\n")"
					fi
				;;
				*)
					info_msg "$(eval_gettext "The removal hasn't been applied\n")"
				;;
			esac
		else
			info_msg "$(eval_gettext "No Flatpak unused package found\n")"
		fi
	fi
}

# Definition of the packages_cache function: Search for old package archives in the pacman cache and offer to remove them if there are
packages_cache() {
	pacman_cache_old=$(paccache -dk"${old_packages_num}" | sed -n 's/.*: \([0-9]*\) candidate.*/\1/p')
	pacman_cache_uninstalled=$(paccache -duk"${uninstalled_packages_num}" | sed -n 's/.*: \([0-9]*\) candidate.*/\1/p')

	[ -z "${pacman_cache_old}" ] && pacman_cache_old="0"
	[ -z "${pacman_cache_uninstalled}" ] && pacman_cache_uninstalled="0"
	pacman_cache_total=$(("${pacman_cache_old}+${pacman_cache_uninstalled}"))

	if [ "${pacman_cache_total}" -gt 0 ]; then

		if [ "${pacman_cache_total}" -eq 1 ]; then
			main_msg "$(eval_gettext "Cached Packages:\nThere's an old or uninstalled cached package\n")"
			ask_msg "$(eval_gettext "Would you like to remove it from the cache now? [Y/n]")"
		else
			main_msg "$(eval_gettext "Cached Packages:\nThere are old and/or uninstalled cached packages\n")"
			ask_msg "$(eval_gettext "Would you like to remove them from the cache now? [Y/n]")"
		fi

		case "${answer}" in
			"$(eval_gettext "Y")"|"$(eval_gettext "y")"|"")
				if [ "${pacman_cache_old}" -gt 0 ] && [ "${pacman_cache_uninstalled}" -eq 0 ]; then
					echo
					main_msg "$(eval_gettext "Removing old cached packages...")"

					if ! "${su_cmd}" paccache "${contrib_color_opt[@]}" -rk"${old_packages_num}"; then
						echo
						error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
					else
						echo
					fi
				elif [ "${pacman_cache_old}" -eq 0 ] && [ "${pacman_cache_uninstalled}" -gt 0 ]; then
					echo
					main_msg "$(eval_gettext "Removing uninstalled cached packages...")"

					if ! "${su_cmd}" paccache "${contrib_color_opt[@]}" -ruk"${uninstalled_packages_num}"; then
						echo
						error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
					else
						echo
					fi
				elif [ "${pacman_cache_old}" -gt 0 ] && [ "${pacman_cache_uninstalled}" -gt 0 ]; then
					echo
					main_msg "$(eval_gettext "Removing old cached packages...")"

					if ! "${su_cmd}" paccache "${contrib_color_opt[@]}" -rk"${old_packages_num}"; then
						echo
						error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
					else
						echo
					fi

					main_msg "$(eval_gettext "Removing uninstalled cached packages...")"

					if ! "${su_cmd}" paccache "${contrib_color_opt[@]}" -ruk"${uninstalled_packages_num}"; then
						echo
						error_msg "$(eval_gettext "An error has occurred during the removal process\nThe removal has been aborted\n")"
					else
						echo
					fi
				fi
			;;
			*)
				echo
				info_msg "$(eval_gettext "The removal hasn't been applied\n")"
			;;
		esac
	else
		info_msg "$(eval_gettext "No old or uninstalled cached package found\n")"
	fi
}

# Definition of the pacnew_files function: Display pacnew files and offer to process them if there are
pacnew_files() {
	pacnew_files=$(pacdiff -o)

	if [ -n "${pacnew_files}" ]; then
		main_msg "$(eval_gettext "Pacnew Files:")"
		echo -e "${pacnew_files}\n"

		if [ "$(echo "${pacnew_files}" | wc -l)" -eq 1 ]; then
			ask_msg "$(eval_gettext "Would you like to process this file now? [Y/n]")"
		else
			ask_msg "$(eval_gettext "Would you like to process these files now? [Y/n]")"
		fi

		case "${answer}" in
			"$(eval_gettext "Y")"|"$(eval_gettext "y")"|"")
				echo
				main_msg "$(eval_gettext "Processing Pacnew Files...\n")"

				if "${su_cmd}" "${diff_prog_opt[@]}" pacdiff "${contrib_color_opt[@]}"; then
					echo
					info_msg "$(eval_gettext "The pacnew file(s) processing has been applied\n")"
				else
					echo
					error_msg "$(eval_gettext "An error occurred during the pacnew file(s) processing\n")" && quit_msg
					exit 12
				fi
			;;
			*)
				echo
				warning_msg "$(eval_gettext "The pacnew file(s) processing hasn't been applied\nPlease, consider processing them promptly\n")"
			;;
		esac
	else
		info_msg "$(eval_gettext "No pacnew file found\n")"
	fi
}

# Definition of the restart_services function: Verify if any services require a post update restart
restart_services() {
	if [ -n "${packages_updated}" ]; then
		services=$(sudo checkservices -F -P -R -i gdm.service -i sddm.service -i lightdm.service -i lxdm.service -i slim.service -i xdm.service -i greetd.service -i nodm.service -i ly.service -i lemurs.service 2> /dev/null | grep ".service"  | cut -f2 -d "'")
		services_num=$(echo "${services}" | wc -l)
	
		if [ -n "${services}" ]; then
			if [ "${services_num}" -eq 1 ]; then
				main_msg "$(eval_gettext "Services:\nThe following service requires a post upgrade restart\n")"
			else
				main_msg "$(eval_gettext "Services:\nThe following services require a post upgrade restart\n")"
			fi
	
			i=1
			while IFS= read -r line; do
				echo "${i} - ${line}"
				((i=i+1))
			done < <(printf '%s\n' "${services}")
	
			echo
			ask_msg_array "$(eval_gettext "Select the service(s) to restart (e.g. 1 3 5), select 0 to restart them all or press \"enter\" to continue without restarting the service(s):")"
			echo
	
			if [ "${answer_array[0]}" -eq 0 ] 2> /dev/null; then
				# shellcheck disable=SC2086
				if "${su_cmd}" systemctl restart ${services}; then
					info_msg "$(eval_gettext "Service(s) restarted successfully\n")"
	
				else
					error_msg "$(eval_gettext "An error has occurred during the service(s) restart\nPlease, verify the above service(s) status\n")" && quit_msg
					exit 11
				fi
			else
				array_to_string=$(printf "%s\n" "${answer_array[@]}")
				mapfile -t answer_array < <(echo "${array_to_string}" | awk '!seen[$0]++')
	
				for num in "${answer_array[@]}"; do
					if [ "${num}" -le "${services_num}" ] 2> /dev/null && [ "${num}" -gt "0" ]; then
						service_restarted="y"
						service_selected=$(sed -n "${num}"p <<< "${services}")
	
						if "${su_cmd}" systemctl restart "${service_selected}"; then
							info_msg "$(eval_gettext "The \${service_selected} service has been successfully restarted")"
						else
							error_msg "$(eval_gettext "An error has occurred during the restart of the \${service_selected} service")"
							service_fail="y"
						fi
					fi
				done
	
				if [ -n "${service_restarted}" ]; then
					if [ -z "${service_fail}" ]; then
						echo
						info_msg "$(eval_gettext "Service(s) restarted successfully\n")"
					else
						echo
						error_msg "$(eval_gettext "An error has occurred during the service(s) restart\nPlease, verify the above service(s) status\n")" && quit_msg
						exit 11
					fi
				else
					warning_msg "$(eval_gettext "The service(s) restart hasn't been performed\nPlease, consider restarting services that have been updated to fully apply the upgrade\n")"
				fi
			fi
		else
			info_msg "$(eval_gettext "No service requiring a post upgrade restart found\n")"
		fi
	fi
}
# Definition of the kernel_reboot function: Verify if there's a kernel update waiting for a reboot to be applied
kernel_reboot() {
	kernel_compare=$(file /boot/vmlinuz* /usr/lib/modules/*/vmlinuz* | sed 's/^.*version\ //' | awk '{print $1}' | grep "$(uname -r)")

	if [ -z "${kernel_compare}" ]; then
		main_msg "$(eval_gettext "Reboot required:\nThere's a pending kernel update on your system requiring a reboot to be applied\n")"
		ask_msg "$(eval_gettext "Would you like to reboot now? [y/N]")"

		case "${answer}" in
			"$(eval_gettext "Y")"|"$(eval_gettext "y")")
				echo

				# shellcheck disable=SC2317,SC2329
				restore_cursor() {
					tput cnorm
				}
				trap restore_cursor EXIT
				# shellcheck disable=SC2034
				for sec in {5..1}; do
					tput civis ; echo -ne "${blue}==>${color_off}${bold} $(eval_gettext "Rebooting in \${sec}...\r")${color_off}"
					sleep 1
				done

				if ! reboot; then
					echo
					error_msg "$(eval_gettext "An error has occurred during the reboot process\nThe reboot has been aborted\n")" && quit_msg
					exit 6
				else
					exit 0
				fi
			;;
			*)
				echo
				warning_msg "$(eval_gettext "The reboot hasn't been performed\nPlease, consider rebooting to finalize the pending kernel update\n")"
			;;
		esac
	else
		info_msg "$(eval_gettext "No pending kernel update found\n")"
	fi
}

# Definition of the full_upgrade function: Launch the relevant series of function for a complete and proper update
full_upgrade() {
	list_packages
	if [ -n "${proceed_with_update}" ]; then
		list_news
		update
		date +%Y-%m-%d > "${statedir}/last_update_run"
	fi
	orphan_packages
	packages_cache
	pacnew_files
	restart_services
	kernel_reboot
	quit_msg
}

# Execute the different functions depending on the option
case "${option}" in
	"")
		full_upgrade
	;;
	-d|--devel)
		devel_flag+=("--devel")
		full_upgrade
	;;
	-c|--check)
		check
	;;
	-l|--list)
		list_option="y"
		list_packages
	;;
	-n|--news)
		show_news="y"
		news_option="y"
		if [ "${2}" -gt 0 ] 2> /dev/null; then
			news_num="${2}"
		fi
		list_news
	;;
	--gen-config)
		if [ -f "${XDG_DATA_HOME}/doc/${name}/${name}.conf.example" ]; then
			example_config_file="${XDG_DATA_HOME}/doc/${name}/${name}.conf.example"
		elif [ -f "${HOME}/.local/share/doc/${name}/${name}.conf.example" ]; then
			example_config_file="${HOME}/.local/share/doc/${name}/${name}.conf.example"
		elif [ -f "${XDG_DATA_DIRS}/doc/${name}/${name}.conf.example" ]; then
			example_config_file="${XDG_DATA_DIRS}/doc/${name}/${name}.conf.example"
		elif [ -f "/usr/local/share/doc/${name}/${name}.conf.example" ]; then
			example_config_file="/usr/local/share/doc/${name}/${name}.conf.example"
		elif [ -f "/usr/share/doc/${name}/${name}.conf.example" ]; then
			example_config_file="/usr/share/doc/${name}/${name}.conf.example"
		else
			error_msg "$(eval_gettext "Example configuration file not found")"
			exit 8
		fi

		if [ -f "${config_file}" ]; then
			error_msg "$(eval_gettext "The '\${config_file}' configuration file already exists\nPlease, remove it before generating a new one")"
			exit 8
		else
			mkdir -p "${XDG_CONFIG_HOME:-${HOME}/.config}/${name}/"
			cp "${example_config_file}" "${config_file}" || exit 8
			info_msg "$(eval_gettext "The '\${config_file}' configuration file has been generated")"
		fi
	;;
	--show-config)
		if [ ! -f "${config_file}" ]; then
			error_msg "$(eval_gettext "No configuration file found\nYou can generate one with \"arch-update --gen-config\"")"
			exit 9
		else
			cat "${config_file}" || exit 9
		fi
	;;
	--edit-config)
		if [ ! -f "${config_file}" ]; then
			error_msg "$(eval_gettext "No configuration file found\nYou can generate one with \"arch-update --gen-config\"")"
			exit 13
		else
			if ! "${EDITOR:-nano}" "${config_file}" 2> /dev/null; then
				error_msg "$(eval_gettext "Unable to determine the editor to use\nThe \"EDITOR\" environment variable is not set and \"nano\" (fallback option) is not installed")"
				exit 13
			fi
		fi
	;;
	--tray)
		if [ "${2}" == "--enable" ]; then
			if [ -f "${XDG_DATA_HOME}/applications/${name}-tray.desktop" ]; then
				tray_desktop_file="${XDG_DATA_HOME}/applications/${name}-tray.desktop"
			elif [ -f "${HOME}/.local/share/applications/${name}-tray.desktop" ]; then
				tray_desktop_file="${HOME}/.local/share/applications/${name}-tray.desktop"
			elif [ -f "${XDG_DATA_DIRS}/applications/${name}-tray.desktop" ]; then
				tray_desktop_file="${XDG_DATA_DIRS}/applications/${name}-tray.desktop"
			elif [ -f "/usr/local/share/applications/${name}-tray.desktop" ]; then
				tray_desktop_file="/usr/local/share/applications/${name}-tray.desktop"
			elif [ -f "/usr/share/applications/${name}-tray.desktop" ]; then
				tray_desktop_file="/usr/share/applications/${name}-tray.desktop"
			else
				error_msg "$(eval_gettext "Arch-Update tray desktop file not found")"
				exit 10
			fi

			tray_desktop_file_autostart="${XDG_CONFIG_HOME:-${HOME}/.config}/autostart/arch-update-tray.desktop"

			if [ -f "${tray_desktop_file_autostart}" ]; then
				error_msg "$(eval_gettext "The '\${tray_desktop_file_autostart}' file already exists")"
				exit 10
			else
				mkdir -p "${XDG_CONFIG_HOME:-${HOME}/.config}/autostart/"
				cp "${tray_desktop_file}" "${tray_desktop_file_autostart}" || exit 10
				info_msg "$(eval_gettext "The '\${tray_desktop_file_autostart}' file has been created, the Arch-Update systray applet will be automatically started at your next log on\nTo start it right now, you can launch the \"Arch-Update Systray Applet\" application from your app menu")"
			fi
		else
			if [ ! -f "${statedir}/current_state" ]; then
				state_up_to_date
			fi

			if pgrep -f arch-update-tray > /dev/null; then
				error_msg "$(eval_gettext "There's already a running instance of the Arch-Update systray applet")"
				exit 3
			fi

			arch-update-tray || exit 3
		fi
	;;
	-h|--help)
		help
	;;
	-V|--version)
		version
	;;
	*)
		invalid_option
	;;
esac
