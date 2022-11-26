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
			echo "--Packages--" && echo -e "${packages}\n"
		fi

		#If there are updates available for the AUR, print them
		if [ -n "${aur_packages}" ]; then
			echo "--AUR Packages--" && echo -e "${aur_packages}\n"
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
				#If the user gives the confirmation to proceed, change the desktop icon to "installing"
				[Yy]|"")
					cp -f /usr/share/icons/arch-update/arch-update_installing.svg /usr/share/icons/arch-update/arch-update.svg
				
					#Offers to read latest Arch Linux news while the redo variable equals "y"
					redo="y"
					
					while [ "${redo}" = "y" ]; do
						#Get the titles of the latest Arch Linux news
						news_title=$(curl -Ls https://www.archlinux.org/news | hq a attr title | grep ^"View:" | sed s/View:\ //g | head -5)
	
						#Print them to the user with a unique number in front of them (so the user can easily select the one to read)
						echo -e "\n--Arch News--"
						i=1
						while IFS= read -r line; do
							echo "${i}" - "${line}"
							((i=i+1))
						done < <(printf '%s\n' "${news_title}")
	
						#Ask the user which news he wants to read
						read -rp $'\nSelect the news to read (just press \"enter\" to proceed with the installation): ' answer
	
						case "${answer}" in
							#If the user selected a news to read, print its info and content and offer to read news once again (in case the user wants to read another one)
							1|2|3|4|5)
								news_selected=$(sed -n "${answer}"p <<< "${news_title}" | sed s/\ /-/g | awk '{print tolower($0)}')
								news_info=$(curl -Ls "https://www.archlinux.org/news/${news_selected}" | hq '.article-info' text)
								news_content=$(curl -Ls "https://www.archlinux.org/news/${news_selected}" | hq '.article-content' text)
								echo -e "\n${news_info}\n\n${news_content}\n" && read -n 1 -r -s -p $'Press \"enter\" to continue\n'

							;;
		
							#If the user didn't select a news to read, proceed with the installation
							*)
								echo ""
								redo="n"
							;;
						esac
					done

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

		#If everything went well, change the desktop icon to "up-to-date"
		cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
		echo -e "\nUpdates have been applied\n"

		#Checking for pacnew/pacsave files
		pacnew_files=$(find /etc -regextype posix-extended -regex ".+\.pac(new|save)" 2> /dev/null)

		#If there are pacnew/pacsave files, ask the user if he wants to manage them
		if [ -n "${pacnew_files}" ]; then
			echo "Pacnew/Pacsave files has been found on the system"
			read -rp $'Would you like to process these files now? [Y/n] ' answer
			echo ""

			case "${answer}" in
				#If the user gives the confirmation to proceed, launch pacdiff to manage the pacnew/pacsave files and exit
				[Yy]|"")
					"${su_cmd}" pacdiff
					echo -e "\nPacnew/Pacsave files has been processed\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
					exit 0
				;;

				#If the user doesn't give the confirmation to proceed, exit
				*)
					exit 0
				;;
			esac
		#If there's no pacnew/pacsave files, exit
		else
			read -n 1 -r -s -p $'Press \"enter\" to quit\n'
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
