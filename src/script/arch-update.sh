#!/bin/bash

# arch-update: An update notifier/applier for Arch Linux that assists you with important pre/post update tasks.
# https://github.com/Antiz96/arch-update
# Licensed under the GPL-3.0 license

# General variables
name="arch-update"
version="1.9.0"
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
if command -v paru > /dev/null; then
	aur_helper="paru"
elif command -v yay > /dev/null; then
	aur_helper="yay"
fi

# Check if flatpak is installed for the optional Flatpak support
flatpak=$(command -v flatpak)

# Check if notify-send is installed for the optional desktop notification support
notif=$(command -v notify-send)

# Definition of the help function: Print the help message
help() {
	cat <<EOF
${name} v${version}

An update notifier/applier for Arch Linux that assists you with important pre/post update tasks.

Run arch-update to perform the main "update" function: Print the list of packages available for update, then ask for the user's confirmation to proceed with the installation. Before performing the update, offer to print the latest Arch Linux news. Post update, check for orphan/unused packages and pacnew/pacsave files and, if there are, offers to process them.

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

# Definition of the icon_checking function: Change icon to "checking"
icon_checking() {
	cp -f /usr/share/icons/arch-update/arch-update_checking.svg /usr/share/icons/arch-update/arch-update.svg || exit 3
}

# Definition of the icon_updates_available function: Change icon to "updates-available"
icon_updates_available() {
	cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg || exit 3
}

# Definition of the icon_installing function: Change icon to "installing"
icon_installing() {
	cp -f /usr/share/icons/arch-update/arch-update_installing.svg /usr/share/icons/arch-update/arch-update.svg || exit 3
}

# Definition of the icon_up_to_date function: Change icon to "up to date"
icon_up_to_date() {
	cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg || exit 3
}

# Definition of the check function: Check for available updates, change the icon accordingly and send a desktop notification containing the number of available updates
check() {
	icon_checking

	if [ -n "${aur_helper}" ] && [ -n "${flatpak}" ]; then
		update_available=$(checkupdates ; "${aur_helper}" -Qua ; flatpak update | awk '{print $2}' | grep -v '^$' | sed '1d;$d')
	elif [ -n "${aur_helper}" ] && [ -z "${flatpak}" ]; then
		update_available=$(checkupdates ; "${aur_helper}" -Qua)
	elif [ -z "${aur_helper}" ] && [ -n "${flatpak}" ]; then
		update_available=$(checkupdates ; flatpak update | awk '{print $2}' | grep -v '^$' | sed '1d;$d')
	else
		update_available=$(checkupdates)
	fi
	
	if [ -n "${notif}" ]; then
		statedir="${XDG_STATE_HOME:-${HOME}/.local/state}/${name}"
		mkdir -p "${statedir}"

		echo "${update_available}" > "${statedir}/current_check"
		sed -i '/^\s*$/d' "${statedir}/current_check"
	fi

	if [ -n "${update_available}" ]; then
		icon_updates_available

		if [ -n "${notif}" ]; then
			if ! diff "${statedir}/current_check" "${statedir}/last_check" &> /dev/null; then
				update_number=$(wc -l "${statedir}/current_check" | awk '{print $1}')

				if [ "${update_number}" -eq 1 ]; then
					notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "${update_number} update available"
				else
					notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "${update_number} updates available"
				fi
			fi
		fi
	else
		icon_up_to_date
	fi

	if [ -f "${statedir}/current_check" ]; then
		mv -f "${statedir}/current_check" "${statedir}/last_check"
	fi
}

# Definition of the list_packages function: Print packages that are available for update and offer to apply them if there are
list_packages() {
	icon_checking
	
	packages=$(checkupdates)

	if [ -n "${aur_helper}" ]; then
		aur_packages=$("${aur_helper}" -Qua)
	fi

	if [ -n "${flatpak}" ]; then
		flatpak_packages=$(flatpak update | awk '{print $2}' | grep -v '^$' | sed '1d;$d')
	fi

	if [ -n "${packages}" ]; then
		echo -e "--Packages--\n${packages}\n"
	fi

	if [ -n "${aur_packages}" ]; then
		echo -e "--AUR Packages--\n${aur_packages}\n"
	fi

	if [ -n "${flatpak_packages}" ]; then
		echo -e "--Flatpak Packages--\n${flatpak_packages}\n"
	fi

	if [ -z "${packages}" ] && [ -z "${aur_packages}" ] && [ -z "${flatpak_packages}" ]; then
		icon_up_to_date
		echo -e "No update available\n"
	else
		icon_updates_available
		read -rp $'Proceed with update? [Y/n] ' answer

		case "${answer}" in
			[Yy]|"")
				proceed_with_update="y"
			;;
			*)
				echo -e >&2 "The update has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
				exit 4
			;;
		esac
	fi
}

# Definition of the list_news function: Print the latest Arch news and offers to read them
list_news() {
	redo="y"

	while [ "${redo}" = "y" ]; do
		news=$(curl -Ls https://www.archlinux.org/news)
		news_titles=$(echo "${news}" | htmlq -a title a | grep ^"View:" | sed s/View:\ //g | head -5)
		mapfile -t news_dates < <(echo "${news}" | htmlq td | grep -v "class" | grep "[0-9]" | sed "s/<[^>]*>//g" | head -5 | xargs -I{} date -d "{}" "+%s")

		echo -e "\n--Arch News--"
		i=1
		while IFS= read -r line; do
			if [ "${news_dates["${i}-1"]}" -ge "$(date -d "$(date "+%Y-%m-%d" -d "15 days ago")" "+%s")" ]; then
				echo "${i} - ${line} [NEW]"
			else
				echo "${i} - ${line}"
			fi
			((i=i+1))
		done < <(printf '%s\n' "${news_titles}")

		read -rp $'\nSelect the news to read (or just press \"enter\" to proceed with update): ' answer

		case "${answer}" in
			1|2|3|4|5)
				news_selected=$(sed -n "${answer}"p <<< "${news_titles}")
				news_path=$(echo "${news_selected}" | sed s/\ -//g | sed s/\ /-/g | sed s/[.]//g | sed s/=//g | sed s/\>//g | sed s/\<//g | sed s/\`//g | sed s/://g | sed s/+//g | sed s/[[]//g | sed s/]//g | sed s/,//g | sed s/\(//g | sed s/\)//g | sed s/[/]//g | sed s/@//g | sed s/\'//g | sed s/--/-/g | awk '{print tolower($0)}')
				news_url="https://www.archlinux.org/news/${news_path}"
				news_content=$(curl -Ls "${news_url}")
				news_author=$(echo "${news_content}" | htmlq -t .article-info | cut -f3- -d " ")
				news_date=$(echo "${news_content}" | htmlq -t .article-info | cut -f1 -d " ")
				news_article=$(echo "${news_content}" | htmlq -t .article-content)
				echo -e "\n---\nTitle: ${news_selected}\nAuthor: ${news_author}\nPublication date: ${news_date}\nURL: ${news_url}\n---\n\n${news_article}\n" && read -n 1 -r -s -p $'Press \"enter\" to continue\n'
			;;
			*)
				redo="n"
			;;
		esac
	done
}

# Definition of the update function: Update packages
update() {
	icon_installing

	if [ -n "${packages}" ]; then
		echo -e "\n--Updating Packages--"
		if ! "${su_cmd}" pacman -Syu; then
			icon_updates_available
			echo -e >&2 "\nAn error has occurred\nThe update has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 5
		fi
	fi
					
	if [ -n "${aur_packages}" ]; then
		echo -e "\n--Updating AUR Packages--"
		if ! "${aur_helper}" -Syu; then
			icon_updates_available
			echo -e >&2 "\nAn error has occurred\nThe update has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 5
		fi
	fi

	if [ -n "${flatpak_packages}" ]; then
		echo -e "\n--Updating Flatpak Packages--"
		if ! flatpak update; then
			icon_updates_available
			echo -e >&2 "\nAn error has occurred\nThe update has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 5
		fi
	fi

	icon_up_to_date
	echo -e "\nThe update has been applied\n"
}

# Definition of the orphan_packages function: Print orphan packages and offer to remove them if there are
orphan_packages() {
	orphan_packages=$(pacman -Qtdq)

	if [ -n "${flatpak}" ]; then
		flatpak_unused=$(flatpak remove --unused | awk '{print $2}' | grep -v '^$' | sed '$d')
	fi

	if [ -n "${orphan_packages}" ]; then
		echo -e "--Orphan Packages--\n${orphan_packages}\n"

		if [ "$(echo "${orphan_packages}" | wc -l)" -eq 1 ]; then
			read -rp $'Would you like to remove this orphan package (and its potential dependencies) now? [y/N] ' answer
		else
			read -rp $'Would you like to remove these orphan packages (and their potential dependencies) now? [y/N] ' answer
		fi

		case "${answer}" in
			[Yy])
				echo -e "\n--Removing Orphan Packages--"
				pacman -Qtdq | "${su_cmd}" pacman -Rns - && echo -e "\nThe removal has been applied\n" || echo -e >&2 "\nAn error has occurred\nThe removal has been aborted\n"
			;;
			*)
				echo -e "The removal hasn't been applied\n"
			;;
		esac
	else
		echo -e "No orphan package found\n"
	fi

	if [ -n "${flatpak}" ]; then
		if [ -n "${flatpak_unused}" ]; then
			echo -e "--Flatpak Unused Packages--\n${flatpak_unused}\n"

			if [ "$(echo "${flatpak_unused}" | wc -l)" -eq 1 ]; then
				read -rp $'Would you like to remove this Flatpak unused package now? [y/N] ' answer
			else
				read -rp $'Would you like to remove these Flatpak unused packages now? [y/N] ' answer
			fi

			case "${answer}" in
				[Yy])
					echo -e "\n--Removing Flatpak Unused Packages--"
					flatpak remove --unused && echo -e "\nThe removal has been applied\n" || echo -e >&2 "\nAn error has occurred\nThe removal has been aborted\n"
				;;
				*)
					echo -e "The removal hasn't been applied\n"
				;;
			esac
		else
			echo -e "No Flatpak unused package found\n"
		fi
	fi
}

# Definition of the packages_cache function: Search for old package archives in the pacman cache and offer to remove them if there are
packages_cache() {
	pacman_cache_old=$(paccache -dk3 | sed -n 's/.*: \([0-9]*\) candidate.*/\1/p')
	pacman_cache_uninstalled=$(paccache -duk0 | sed -n 's/.*: \([0-9]*\) candidate.*/\1/p')

	[ -z "${pacman_cache_old}" ] && pacman_cache_old="0"
	[ -z "${pacman_cache_uninstalled}" ] && pacman_cache_uninstalled="0"
	pacman_cache_total=$(("${pacman_cache_old}+${pacman_cache_uninstalled}"))

	if [ "${pacman_cache_total}" -gt 0 ]; then
		echo "--Cached Packages--"

		if [ "${pacman_cache_total}" -eq 1 ]; then
			echo -e "There's an old or uninstalled cached package\n"
			read -rp $'Would you like to remove it from the cache now? [Y/n] ' answer
		else
			echo -e "There are old and/or uninstalled cached packages\n"
			read -rp $'Would you like to remove them from the cache now? [Y/n] ' answer
		fi
			
		case "${answer}" in
			[Yy]|"")
				echo -e "\n--Removing Cached Packages--"

				if [ "${pacman_cache_old}" -gt 0 ] && [ "${pacman_cache_uninstalled}" -eq 0 ]; then
					echo -e "\nRemoving old cached packages..." && "${su_cmd}" paccache -r && echo -e "\nThe removal has been applied\n" || echo -e >&2 "\nAn error has occurred\nThe removal has been aborted\n"
				elif [ "${pacman_cache_old}" -eq 0 ] && [ "${pacman_cache_uninstalled}" -gt 0 ]; then
					echo -e "\nRemoving uninstalled cached packages..." && "${su_cmd}" paccache -ruk0 && echo -e "\nThe removal has been applied\n" || echo -e >&2 "\nAn error has occurred\nThe removal has been aborted\n"
				elif [ "${pacman_cache_old}" -gt 0 ] && [ "${pacman_cache_uninstalled}" -gt 0 ]; then
					echo -e "\nRemoving old cached packages..." && "${su_cmd}" paccache -r && echo -e "\nRemoving uninstalled cached packages..." && "${su_cmd}" paccache -ruk0 && echo -e "\nThe removal has been applied\n" || echo -e >&2 "\nAn error has occurred\nThe removal has been aborted\n"
				fi
			;;
			*)
				echo -e "The removal hasn't been applied\n"
			;;
		esac
	else
		echo -e "No old or uninstalled cached package found\n"
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
				echo -e "\n--Processing Pacnew Files--"
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
}

# Definition of the kernel_reboot function: Verify if there's a kernel update waiting for a reboot to be applied
kernel_reboot() {
	if find /boot/vmlinuz* &> /dev/null; then
		kernel_compare=$(file /boot/vmlinuz* | sed 's/^.*version\ //' | awk '{print $1}' | grep "$(uname -r)")
	else
		kernel_compare=$(file /usr/lib/modules/*/vmlinuz* | sed 's/^.*version\ //' | awk '{print $1}' | grep "$(uname -r)")
	fi

	if [ -z "${kernel_compare}" ]; then
		echo -e "--Reboot required--\nThere's a pending kernel update on your system requiring a reboot to be applied\n"
		read -rp $'Would you like to reboot now? [y/N] ' answer

		case "${answer}" in
			[Yy])
				echo -e "\nRebooting in 5 seconds...\nPress ctrl+c to abort"
				sleep 5
				if ! reboot; then
					echo -e >&2 "\nAn error has occurred\nThe reboot has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
					exit 6
				else
					exit 0
				fi
			;;
			*)
				echo -e "\nThe reboot hasn't been performed\nPlease, consider rebooting to finalize the pending kernel update\n"
			;;
		esac
	else
		echo -e "No pending kernel update found\n"
	fi
}

# Execute the different functions depending on the option
case "${option}" in
	"")
		list_packages
		if [ -n "${proceed_with_update}" ]; then
			list_news
			update
		fi
		orphan_packages
		packages_cache
		pacnew_files
		kernel_reboot
		read -n 1 -r -s -p $'Press \"enter\" to quit\n'
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
