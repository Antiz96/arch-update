#!/bin/bash

#Check for optionnal dependencies ("yay" for AUR support and "notify-send" (libnotify) for desktop notifications support)
AUR=$(command -v yay &> /dev/null ; echo $?)
NOTIF=$(command -v notify-send &> /dev/null ; echo $?)

case "$1" in
	#If no argument is passed to the script, execute the main update function
	#This is triggered by cliking on the desktop icon
	"")
		#Change the desktop icon to "checking"
		cp -f /usr/share/icons/arch-update/arch-update_checking.svg /usr/share/icons/arch-update/arch-update.svg
		
		#Get the available updates list for Pacman
		PACKAGES=$(checkupdates | awk '{print $1}')

		#Get the available updates list for AUR (if "yay" is installed)
		if [ "$AUR" -eq 0 ]; then
			AURPACKAGES=$(yay -Qua | awk '{print $1}')
		else
			AURPACKAGES=""
		fi

		#If there are updates available for pacman, print them
		if [ -n "$PACKAGES" ]; then
			echo -e "Packages :\n" && echo -e "$PACKAGES\n"
		fi

		#If there are updates available for AUR, print them
		if [ -n "$AURPACKAGES" ]; then
			echo -e "AUR Packages :\n" && echo -e "$AURPACKAGES\n"
		fi

		#If there is no update available for Pacman nor AUR, change the desktop icon to "up-to-date" and quit
		if [ -z "$PACKAGES" ] && [ -z "$AURPACKAGES" ]; then
			cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
			echo -e "No update available\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 0
		#If there are updates available, change the desktop icon to "updates-available" and ask the confirmation to apply them to the user
		else
			cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
			read -rp $'Proceed with installation ? [Y/n] ' answer

			case "$answer" in
				#If the user gives the confirmation, change the desktop icon to "installing" and apply updates...
				[Yy]|"")
					cp -f /usr/share/icons/arch-update/arch-update_installing.svg /usr/share/icons/arch-update/arch-update.svg

					#...for both pacman and AUR (if there are)
					if [ -n "$PACKAGES" ] && [ -n "$AURPACKAGES" ]; then
						sudo pacman -Syu && yay -Syu
					#... for pacman only (if there are)
					elif [ -n "$PACKAGES" ]; then
						sudo pacman -Syu
					#... for AUR only (if there are)
					else
						yay -Syu
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
			echo -e "\nAn error has occured\nUpdates have been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 1
		#If everything went well, change the desktop icon to "up-to-date" and quit
		else
			cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
			echo -e "\nUpdates have been applied\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
			exit 0
		fi
	fi
	;;

	#If the --check (or -c) argument is passed to the script, execute the check function
	#This is triggered by the systemd --user arch-update.service, which is automatically launched at boot and every hour by the systemd --user arch-update.timer (that has to be enabled)
	--check|-c)
		#Change the desktop icon to "checking"
		cp -f /usr/share/icons/arch-update/arch-update_checking.svg /usr/share/icons/arch-update/arch-update.svg

		#Get the number of available
		if [ "$AUR" -eq 0 ]; then
			UPDATE_NUMBER=$( (checkupdates ; yay -Qua) | wc -l)
		else
			UPDATE_NUMBER=$(checkupdates | wc -l)
		fi

		#If there are updates available, change the desktop icon to "updates-available" and quit
		if [ "$UPDATE_NUMBER" -gt 0 ]; then
			cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
				#If notify-send (libnotify) is installed, also send a desktop notification before quitting 
				if [ "$NOTIF" -eq 0 ]; then
					if [ "$UPDATE_NUMBER" -eq 1 ]; then
						notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "$UPDATE_NUMBER update available"
					else
						notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "$UPDATE_NUMBER updates available"
					fi
				fi
			exit 0
		#If there is no update available, change the desktop icon to "up-to-date" and quit
		else
			cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
			exit 0
		fi
	;;

	#If the --help (or -h) argument is passed to the script, print the documentation (man page)
	#This can be triggered directly by the user, by typing the following command in a terminal : arch-update --help
	#The documentation is also readable here https://github.com/Antiz96/Arch-Update/blob/main/README.md or by typing the following command in a terminal : man arch-update
	--help|-h)
		#Print the documentation (man page) and quit
		man arch-update | col
		exit 0
	;;

	#If any other arguments are passed to the script, print an error and quit
	*)
		echo "arch-update : invalid option -- '$1'"
		echo "Try 'arch-update --help' for more information."
		exit 1
	;;
esac
