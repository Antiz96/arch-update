#!/bin/bash

#Current version
version="1.4.0"

#Check which privilege elevation package is installed (sudo or doas)
if command -v sudo > /dev/null; then
	su_cmd="sudo"
elif command -v doas > /dev/null; then
	su_cmd="doas"
else
	echo -e >&2 "A privilege elevation method is required\nPlease, install sudo or doas\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
	exit 1
fi

#Check if an AUR helper is installed (yay or paru) for the optional AUR package updates support
if command -v yay > /dev/null; then
	aur_helper="yay"
elif command -v paru > /dev/null; then
	aur_helper="paru"
fi

#Check if notify-send is installed for the optional desktop notification support
notif=$(command -v notify-send)

#Replace the $1 var by "option" just to make the script more readable/less complex
option="${1}"

case "${option}" in
	#If no option is passed to the "arch-update" command, execute the main update function
	#This is triggered by cliking on the desktop icon
	"")
		#Change the desktop icon to "checking"
		cp -f /usr/share/icons/arch-update/arch-update_checking.svg /usr/share/icons/arch-update/arch-update.svg
		
		#Get the available updates list for Pacman
		packages=$(checkupdates | awk '{print $1}')

		#Get the available updates list for the AUR (if "yay" or "paru" is installed)
		if [ -n "${aur_helper}" ]; then
			aur_packages=$("${aur_helper}" -Qua | awk '{print $1}')
		fi

		#If there are updates available for pacman, print them
		if [ -n "${packages}" ]; then
			echo -e "Packages:\n" && echo -e "${packages}\n"
		fi

		#If there are updates available for the AUR, print them
		if [ -n "${aur_packages}" ]; then
			echo -e "AUR Packages:\n" && echo -e "${aur_packages}\n"
		fi

		#If there is no update available for Pacman nor the AUR, change the desktop icon to "up-to-date" and quit
		if [ -z "${packages}" ] && [ -z "${aur_packages}" ]; then
			cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
			echo -e "No update available\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 0
		#If there are updates available, change the desktop icon to "updates-available" and ask the confirmation to apply them to the user
		else
			cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
			read -rp $'Proceed with installation? [Y/n] ' answer

			case "${answer}" in
				#If the user gives the confirmation to proceed, change the desktop icon to "installing" and apply updates
				[Yy]|"")
					cp -f /usr/share/icons/arch-update/arch-update_installing.svg /usr/share/icons/arch-update/arch-update.svg

					#Update for pacman (if there are)
					if [ -n "${packages}" ]; then
						#Launch the update and check if there was an error during the update process. If there was an error, change the desktop icon to "updates-available", print an error and quit
						if ! "${su_cmd}" pacman -Syu; then
							cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
							echo -e >&2 "\nAn error has occured\nUpdates have been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
							exit 1
						fi
					fi
					
					#Update for the AUR (if there are)
					if [ -n "${aur_packages}" ]; then
						#Launch the update and check if there was an error during the update process. If there was an error, change the desktop icon to "updates-available", print an error and quit
						if ! "${aur_helper}" -Syu; then
							cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
							echo -e >&2 "\nAn error has occured\nUpdates have been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
							exit 1
						fi
					fi
				;;
				
				#If the user doesn't give the confirmation to proceed, exit
				*)
					exit 1
				;;
			esac

		#If everything went well, change the desktop icon to "up-to-date" and quit
		cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
		echo -e "\nUpdates have been applied\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
		exit 0
	fi
	;;
	
	#If the -c (or --check) option is passed to the "arch-update" command, execute the check function
	#This is triggered by the systemd --user arch-update.service, which is automatically launched at boot and then every hour by the systemd --user arch-update.timer (that has to be enabled)
	-c|--check)
		#Change the desktop icon to "checking"
		cp -f /usr/share/icons/arch-update/arch-update_checking.svg /usr/share/icons/arch-update/arch-update.svg

		#Get the number of available
		if [ -n "${aur_helper}" ]; then
			update_number=$( (checkupdates ; "${aur_helper}" -Qua) | wc -l)
		else
			update_number=$(checkupdates | wc -l)
		fi

		#If there are updates available, change the desktop icon to "updates-available" and quit
		if [ "${update_number}" -gt 0 ]; then
			cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
			#If notify-send (libnotify) is installed, also send a desktop notification before quitting
			if [ -n "${notif}" ]; then
				if [ "${update_number}" -eq 1 ]; then
					notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "${update_number} update available"
				else
					notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "${update_number} updates available"
				fi
			fi
			exit 0
		#If there is no update available, change the desktop icon to "up-to-date" and quit
		else
			cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
			exit 0
		fi
	;;

	#If the -v (or --version) option is passed to the "malias" command, print the current version
	-v|--version)
		echo "${version}"
		exit 0
	;;
	
	#If the -h (or --help) option is passed to the script, print the documentation (man page)
	#This can be triggered directly by the user, by typing the following command in a terminal: arch-update --help
	#The documentation is also readable here https://github.com/Antiz96/Arch-Update or by typing the following command in a terminal: man arch-update
	-h|--help)
		#Print the documentation (man page) and quit
		man arch-update | col
		exit 0
	;;
	
	#If any other option(s) are passed to the script, print an error and quit
	*)
		echo -e >&2 "arch-update: invalid option -- '${option}'\nTry 'arch-update --help' for more information."
		exit 1
	;;
esac
