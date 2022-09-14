#!/bin/bash

#Current version
version="1.3.2"

#Check for optionnal dependencies ("yay" or "paru" for AUR support and "notify-send" (libnotify) for desktop notifications support)
YAY=$(command -v yay)
PARU=$(command -v paru)
NOTIF=$(command -v notify-send)

#Replace the $1 var by "option" just to make the script more readable/less complex
option="${1}"

case "${option}" in
	#If no option is passed to the "arch-update" command, execute the main update function
	#This is triggered by cliking on the desktop icon
	"")
		#Change the desktop icon to "checking"
		cp -f /usr/share/icons/arch-update/arch-update_checking.svg /usr/share/icons/arch-update/arch-update.svg
		
		#Get the available updates list for Pacman
		PACKAGES=$(checkupdates | awk '{print $1}')

		#Get the available updates list for AUR (if "yay" or "paru" is installed)
		if [ -n "${YAY}" ]; then
			AURPACKAGES=$(yay -Qua | awk '{print $1}')
		elif [ -n "${PARU}" ]; then
			AURPACKAGES=$(paru -Qua | awk '{print $1}')
		else
			AURPACKAGES=""
		fi

		#If there are updates available for pacman, print them
		if [ -n "${PACKAGES}" ]; then
			echo -e "Packages :\n" && echo -e "${PACKAGES}\n"
		fi

		#If there are updates available for AUR, print them
		if [ -n "${AURPACKAGES}" ]; then
			echo -e "AUR Packages :\n" && echo -e "${AURPACKAGES}\n"
		fi

		#If there is no update available for Pacman nor AUR, change the desktop icon to "up-to-date" and quit
		if [ -z "${PACKAGES}" ] && [ -z "${AURPACKAGES}" ]; then
			cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
			echo -e "No update available\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 0
		#If there are updates available, change the desktop icon to "updates-available" and ask the confirmation to apply them to the user
		else
			cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
			read -rp $'Proceed with installation ? [Y/n] ' answer

			case "${answer}" in
				#If the user gives the confirmation, change the desktop icon to "installing" and apply updates...
				[Yy]|"")
					cp -f /usr/share/icons/arch-update/arch-update_installing.svg /usr/share/icons/arch-update/arch-update.svg

					#...for both pacman and AUR (if there are)
					if [ -n "${PACKAGES}" ] && [ -n "${AURPACKAGES}" ]; then
						if [ -n "${YAY}" ]; then
							sudo pacman -Syu && yay -Syu
						else
							sudo pacman -Syu && paru -Syu
						fi
					#... for pacman only (if there are)
					elif [ -n "${PACKAGES}" ]; then
						sudo pacman -Syu
					#... for AUR only (if there are)
					else
						if [ -n "${YAY}" ]; then
							yay -Syu
						else
							paru -Syu
						fi
					fi
				;;

				#If the user didn't give the confirmation, quit
				*)
					exit 1
				;;
			esac

		#If there was an error during the update process, change the desktop icon to "updates-available" and quit
		if [ "$?" -ne 0 ]; then
			cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
			echo -e >&2 "\nAn error has occured\nUpdates have been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 1
		#If everything went well, change the desktop icon to "up-to-date" and quit
		else
			cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
			echo -e "\nUpdates have been applied\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 0
		fi
	fi
	;;
	#If the -c (or --check) option is passed to the "arch-update" command, execute the check function
	#This is triggered by the systemd --user arch-update.service, which is automatically launched at boot and then every hour by the systemd --user arch-update.timer (that has to be enabled)
	-c|--check)
		#Change the desktop icon to "checking"
		cp -f /usr/share/icons/arch-update/arch-update_checking.svg /usr/share/icons/arch-update/arch-update.svg

		#Get the number of available
		if [ -n "${YAY}" ]; then
			UPDATE_NUMBER=$( (checkupdates ; yay -Qua) | wc -l)
		elif [ -n "${PARU}" ]; then
			UPDATE_NUMBER=$( (checkupdates ; paru -Qua) | wc -l)
		else
			UPDATE_NUMBER=$(checkupdates | wc -l)
		fi

		#If there are updates available, change the desktop icon to "updates-available" and quit
		if [ "${UPDATE_NUMBER}" -gt 0 ]; then
			cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
			#If notify-send (libnotify) is installed, also send a desktop notification before quitting
			if [ -n "${NOTIF}" ]; then
				if [ "${UPDATE_NUMBER}" -eq 1 ]; then
					notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "${UPDATE_NUMBER} update available"
				else
					notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "${UPDATE_NUMBER} updates available"
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
	#This can be triggered directly by the user, by typing the following command in a terminal : arch-update --help
	#The documentation is also readable here https://github.com/Antiz96/Arch-Update or by typing the following command in a terminal : man arch-update
	-h|--help)
		#Print the documentation (man page) and quit
		man arch-update | col
		exit 0
	;;

	#If any other option(s) are passed to the script, print an error and quit
	*)
		echo -e >&2 "arch-update : invalid option -- '${option}'\nTry 'arch-update --help' for more information."
		exit 1
	;;
esac
