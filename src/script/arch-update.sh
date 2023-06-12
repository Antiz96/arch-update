#!/bin/bash

# arch-update: An update notifier/applier for Arch Linux that assists you with important pre/post update tasks.
# https://github.com/Antiz96/arch-update
# Licensed under the GPL-3.0 license

# Variables definition
name="arch-update"
version="1.5.3"
option="${1}"

# Definition of the evelation method to use (depending on which one is installed on the system)
if command -v sudo > /dev/null; then
	su_cmd="sudo"
elif command -v doas > /dev/null; then
	su_cmd="doas"
else
	echo -e >&2 "A privilege elevation method is required\nPlease, install sudo or doas\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
	exit 2
fi

# Definition of the AUR helper to use (depending on if/which one is installed on the system) for the optional AUR packages support
if command -v yay > /dev/null; then
	aur_helper="yay"
elif command -v paru > /dev/null; then
	aur_helper="paru"
fi

# Check if notify-send is installed for the optional desktop notification support
notif=$(command -v notify-send)

# Definition of the help function: Print the help message
help() {
	cat <<EOF
${name} v${version}

An update notifier/applier for Arch Linux that assists you with important pre/post update tasks.

Run arch-update to perform the main "update" function: Print the list of packages available for update, then ask for the user's confirmation to proceed with the installation. Before performing the update, offer to print the latest Arch Linux news. Post update, check for orphan packages and pacnew/pacsave files and, if there are, offers to process them.

Options:
  -c, --check    Check for available updates, send a desktop notification containing the number of available updates (if libnotify is installed)
  -h, --help     Display this message and exit
  -V, --version  Display version information and exit

For more information, see the ${name}(1) man page
EOF
}

# Definition of the version function: Print the current version
version() {
	echo "${name} ${version}"
}

# Definition of the invalid_option function: Print an error message, ask the user to check the help and exit
invalid_option() {
	echo -e >&2 "${name}: invalid option -- '${option}'\nTry '${name} --help' for more information."
	exit 1
}

# Definition of the icon_checking function: Change icon to "checking" (used in the "list_packages" and "check" functions)
icon_checking() {
	cp -f /usr/share/icons/arch-update/arch-update_checking.svg /usr/share/icons/arch-update/arch-update.svg || exit 3
}

# Definition of the icon_updates_available function: Change icon to "updates-available" (used in the "list_packages", "update" and "check" functions)
icon_updates_available() {
	cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg || exit 3
}

# Definition of the icon_installing function: Change icon to "installing" (used in the "list_packages" function)
icon_installing() {
	cp -f /usr/share/icons/arch-update/arch-update_installing.svg /usr/share/icons/arch-update/arch-update.svg || exit 3
}

# Definition of the icon_up_to_date function: Change icon to "up to date" (used in the "list_packages", "update" and "check" functions)
icon_up_to_date() {
	cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg || exit 3
}

# Definition of the list_packages function: Print packages that are available for update and offer to apply them if there are (used in the "update" functions)
list_packages() {
	icon_checking
	
	packages=$(checkupdates | awk '{print $1}')

	if [ -n "${aur_helper}" ]; then
		aur_packages=$("${aur_helper}" -Qua | awk '{print $1}')
	fi

	if [ -n "${packages}" ]; then
		echo -e "--Packages--\n${packages}\n"
	fi

	if [ -n "${aur_packages}" ]; then
		echo -e "--AUR Packages--\n${aur_packages}\n"
	fi

	if [ -z "${packages}" ] && [ -z "${aur_packages}" ]; then
		icon_up_to_date
		echo -e "No update available\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
		exit 0
	else
		icon_updates_available
	fi

	read -rp $'Proceed with update? [Y/n] ' answer
	
	case "${answer}" in
		[Yy]|"")
			icon_installing
		;;
		*)
			echo -e >&2 "The update has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 4
		;;
	esac
}

# Definition of the list_news function: Print the latest Arch news and offers to read them (used in the "update" function)
list_news() {
	redo="y"

	while [ "${redo}" = "y" ]; do
		news_title=$(curl -Ls https://www.archlinux.org/news | hq a attr title | grep ^"View:" | sed s/View:\ //g | head -5)

		echo -e "\n--Arch News--"
		i=1
		while IFS= read -r line; do
			echo "${i}" - "${line}"
			((i=i+1))
		done < <(printf '%s\n' "${news_title}")

		read -rp $'\nSelect the news to read (or just press \"enter\" to proceed with update): ' answer

		case "${answer}" in
			1|2|3|4|5)
				news_selected=$(sed -n "${answer}"p <<< "${news_title}" | sed s/\ /-/g | sed s/[.]//g | awk '{print tolower($0)}')
				news_info=$(curl -Ls "https://www.archlinux.org/news/${news_selected}" | hq '.article-info' text)
				news_content=$(curl -Ls "https://www.archlinux.org/news/${news_selected}" | hq '.article-content' text)
				echo -e "\n${news_info}\n\n${news_content}\n" && read -n 1 -r -s -p $'Press \"enter\" to continue\n'
			;;
			*)
				echo
				redo="n"
			;;
		esac
	done
}

# Definition of the update function: Update packages
update() {
	list_packages
	list_news

	if [ -n "${packages}" ]; then
		if ! "${su_cmd}" pacman -Syu; then
			icon_updates_available
			echo -e >&2 "\nAn error has occured\nThe update has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 5
		fi
	fi
					
	if [ -n "${aur_packages}" ]; then
		if ! "${aur_helper}" -Syu; then
			icon_updates_available
			echo -e >&2 "\nAn error has occured\nThe update has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 5
		fi
	fi

	icon_up_to_date
	echo -e "\nThe update has been applied\n"

	orphan_packages
	pacnew_files
}

# Definition of the orphan_packages function: Print orphan packages and offer to remove them if there are
orphan_packages() {
	orphan_packages=$(pacman -Qtdq)

	if [ -n "${orphan_packages}" ]; then
		echo -e "--Orphan Packages--\n${orphan_packages}\n"

		if [ "$(echo "${orphan_packages}" | wc -l)" -eq 1 ]; then
			read -rp $'Would you like to remove this orphan package (and its potential dependencies) now? [y/N] ' answer
		else
			read -rp $'Would you like to remove these orphan packages (and their potential dependencies) now? [y/N] ' answer
		fi

		case "${answer}" in
			[Yy])
				echo
				pacman -Qtdq | "${su_cmd}" pacman -Rns - && echo -e "\nThe removal has been applied\n" || echo -e >&2 "\nAn error has occured\nThe removal has been aborted\n"
			;;
			*)
				echo -e "The removal hasn't been applied\n"
			;;
		esac
	else
		echo -e "No orphan package found\n"
	fi
}

# Definition of the pacnew_files function: Print pacnew files and offer to process them if there are
pacnew_files() {
	pacnew_files=$(pacdiff -o)
		
	if [ -n "${pacnew_files}" ]; then
		echo -e "--Pacnew Files--\n${pacnew_files}\n"

		if [ "$(echo "${pacnew_files}" | wc -l)" -eq 1 ]; then
			read -rp $'Would you like to process this file now? [Y/n] ' answer
		else
			read -rp $'Would you like to process these files now? [Y/n] ' answer
		fi

		case "${answer}" in
			[Yy]|"")
				echo
				"${su_cmd}" pacdiff
				echo -e "\nThe pacnew file(s) processing has been applied\n"
			;;
			*)
				echo -e "The pacnew file(s) processing hasn't been applied\n"
			;;
		esac
	else
		echo -e "No pacnew file found\n"
	fi
		
	read -n 1 -r -s -p $'Press \"enter\" to quit\n'
}

# Definition of the check function: Check for available updates, change the icon accordingly and send a desktop notification containing the number of available updates
check() {
	icon_checking

	if [ -n "${aur_helper}" ]; then
		update_number=$( (checkupdates ; "${aur_helper}" -Qua) | wc -l )
	else
		update_number=$(checkupdates | wc -l)
	fi

	if [ "${update_number}" -ne 0 ]; then
		icon_updates_available
		if [ -n "${notif}" ]; then
			if [ "${update_number}" -eq 1 ]; then
				notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "${update_number} update available"
			else
				notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "${update_number} updates available"
			fi
		fi
	else
		icon_up_to_date
	fi
}

# Execute the different functions depending on the option
case "${option}" in
	"")
		update
	;;
	-c|--check)
		check
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
