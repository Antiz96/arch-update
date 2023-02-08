#!/bin/bash

#Current version
version="1.4.2"

#Check which privilege elevation package is installed (sudo or doas)
if command -v sudo > /dev/null; then
	su_cmd="sudo"
elif command -v doas > /dev/null; then
	su_cmd="doas"
else
	echo -e >&2 "A privilege elevation method is required\nPlease, install sudo or doas\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
	exit 1
fi

#Check if an AUR helper is installed (yay or paru) for the optional AUR packages updates support
if command -v yay > /dev/null; then
	aur_helper="yay"
elif command -v paru > /dev/null; then
	aur_helper="paru"
fi

#Check if notify-send is installed for the optional desktop notification support
notif=$(command -v notify-send)

#Replace the $1 var by "option" just to make the script more readable
option="${1}"

case "${option}" in
	#If no option is passed to the "arch-update" command, execute the main update function
	#This is triggered by cliking on the desktop icon or by running the following command in a terminal: arch-update
	"")
		#Change the desktop icon to "checking"
		cp -f /usr/share/icons/arch-update/arch-update_checking.svg /usr/share/icons/arch-update/arch-update.svg
		
		#Get the list of available update(s) for Pacman
		packages=$(checkupdates | awk '{print $1}')

		#Get the list of available update(s) for the AUR (if "yay" or "paru" is installed)
		if [ -n "${aur_helper}" ]; then
			aur_packages=$("${aur_helper}" -Qua | awk '{print $1}')
		fi

		#If there are updates available for pacman, print them
		if [ -n "${packages}" ]; then
			echo -e "--Packages--\n${packages}\n"
		fi

		#If there are updates available for the AUR, print them
		if [ -n "${aur_packages}" ]; then
			echo -e "--AUR Packages--\n${aur_packages}\n"
		fi

		#If there is no update available for Pacman nor the AUR, change the desktop icon to "up-to-date" and print a relevant sentence
		if [ -z "${packages}" ] && [ -z "${aur_packages}" ]; then
			cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
			echo -e "No update available\n"
		#If there are updates available, change the desktop icon to "updates-available" and ask for the user's confirmation to proceed with the update
		else
			cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
			read -rp $'Proceed with update? [Y/n] ' answer

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
	
						#Ask the user which news to read
						read -rp $'\nSelect the news to read (or just press \"enter\" to proceed with update): ' answer
	
						case "${answer}" in
							#If the user selects a news to read, print its info and content and offer to read news once again (in case the user wants to read another one)
							1|2|3|4|5)
								news_selected=$(sed -n "${answer}"p <<< "${news_title}" | sed s/\ /-/g | sed s/[.]//g | awk '{print tolower($0)}')
								news_info=$(curl -Ls "https://www.archlinux.org/news/${news_selected}" | hq '.article-info' text)
								news_content=$(curl -Ls "https://www.archlinux.org/news/${news_selected}" | hq '.article-content' text)
								echo -e "\n${news_info}\n\n${news_content}\n" && read -n 1 -r -s -p $'Press \"enter\" to continue\n'
							;;
		
							#If the user doesn't select a news to read, proceed with update
							*)
								echo ""
								redo="n"
							;;
						esac
					done

					#Apply updates for Pacman (if there are)
					if [ -n "${packages}" ]; then
						#Launch the update process and check for errors. If there was an error, change the desktop icon to "updates-available", print an error and quit
						if ! "${su_cmd}" pacman -Syu; then
							cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
							echo -e >&2 "\nAn error has occured\nThe update has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
							exit 1
						fi
					fi
					
					#Apply updates for the AUR (if there are)
					if [ -n "${aur_packages}" ]; then
						#Launch the update process and check for errors. If there was an error, change the desktop icon to "updates-available", print an error and quit
						if ! "${aur_helper}" -Syu; then
							cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
							echo -e >&2 "\nAn error has occured\nThe update has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
							exit 1
						fi
					fi
				;;
				
				#If the user doesn't give the confirmation to proceed, print an error and exit
				*)
					echo -e >&2 "The update has been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
					exit 1
				;;
			esac

			#If everything goes well, change the desktop icon to "up-to-date"
			cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
			echo -e "\nThe update has been applied\n"
		fi

		#Checking for orphan packages
		orphan_packages=$(pacman -Qtdq)

		#If there are orphan packages, print them and ask the user's confirmation to proceed with the removal
		if [ -n "${orphan_packages}" ]; then
			echo -e "--Orphan Packages--\n${orphan_packages}\n"

			#Grammar
			if [ "$(echo "${orphan_packages}" | wc -l)" -eq 1 ]; then
				read -rp $'Would you like to remove this orphan package (and its potential dependencies) now? [y/N] ' answer
				echo ""
			else
				read -rp $'Would you like to remove these orphan packages (and their potential dependencies) now? [y/N] ' answer
				echo ""
			fi

			case "${answer}" in
				#If the user gives the confirmation to proceed, remove orphan package(s). If an error occured during the removal process, print an error
				[Yy])
					pacman -Qtdq | "${su_cmd}" pacman -Rns - && echo -e "\nThe removal has been applied\n" || echo -e >&2 "\nAn error has occured\nThe removel has been aborted\n"
				;;

				#If the user doesn't give the confirmation to proceed, print a relevant sentence
				*)
					echo -e "The removal hasn't been applied\n"
				;;
			esac
		#If there's no orphan package, print a relevant sentence
		else
			echo -e "No orphan package found\n"
		fi

		#Checking for pacnew/pacsave files
		pacnew_files=$(find /etc -regextype posix-extended -regex ".+\.pac(new|save)" 2> /dev/null)

		#If there are pacnew/pacsave files, print them and ask for the user's confirmation to process them
		if [ -n "${pacnew_files}" ]; then
			echo -e "--Pacnew files--\n${pacnew_files}\n"

			#Grammar
			if [ "$(echo "${pacnew_files}" | wc -l)" -eq 1 ]; then
				read -rp $'Would you like to process this file now? [Y/n] ' answer
				echo ""
			else
				read -rp $'Would you like to process these files now? [Y/n] ' answer
				echo ""
			fi

			case "${answer}" in
				#If the user gives the confirmation to proceed, launch pacdiff to manage the pacnew/pacsave files
				[Yy]|"")
					"${su_cmd}" pacdiff
					echo -e "\nPacnew/Pacsave files have been processed\n"
				;;

				#If the user doesn't give the confirmation to proceed, print a relevant sentence
				*)
					echo -e "Pacnew/Pacsave files haven't been processed\n"
				;;
			esac
		#If there's no pacnew/pacsave files, print a relevant sentence
		else
			echo -e "No Pacnew/Pacsave file found\n"
		fi

		#If everything goes well, exit
		read -n 1 -r -s -p $'Press \"enter\" to quit\n'
		exit 0
	;;
	
	#If the -c (or --check) option is passed to the "arch-update" command, execute the check function
	#This is triggered by the systemd --user arch-update.service, which is automatically launched at boot and then every hour by the systemd --user arch-update.timer (which has to be enabled by running the following command in a terminal: systemctl --user enable --now arch-update.timer)
	-c|--check)
		#Change the desktop icon to "checking"
		cp -f /usr/share/icons/arch-update/arch-update_checking.svg /usr/share/icons/arch-update/arch-update.svg

		#Get the number of available update(s)
		if [ -n "${aur_helper}" ]; then
			update_number=$( (checkupdates ; "${aur_helper}" -Qua) | wc -l )
		else
			update_number=$(checkupdates | wc -l)
		fi

		#If there are updates available, change the desktop icon to "updates-available" and quit
		if [ "${update_number}" -ne 0 ]; then
			cp -f /usr/share/icons/arch-update/arch-update_updates-available.svg /usr/share/icons/arch-update/arch-update.svg
			#If notify-send (libnotify) is installed, also send a desktop notification
			if [ -n "${notif}" ]; then
				#Grammar
				if [ "${update_number}" -eq 1 ]; then
					notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "${update_number} update available"
				else
					notify-send -i /usr/share/icons/arch-update/arch-update_updates-available.svg "Arch Update" "${update_number} updates available"
				fi
			fi
		#If there is no update available, change the desktop icon to "up-to-date"
		else
			cp -f /usr/share/icons/arch-update/arch-update_up-to-date.svg /usr/share/icons/arch-update/arch-update.svg
		fi

		exit 0
	;;

	#If the -v (or --version) option is passed to the "arch-update" command, print the current version and quit
	-v|--version)
		echo "${version}"
		exit 0
	;;
	
	#If the -h (or --help) option is passed to the "arch-update" command, print the documentation (man page)
	#The documentation is also readable here https://github.com/Antiz96/Arch-Update or by running the following command in a terminal: man arch-update
	-h|--help)
		#Print the documentation (man page) and quit
		man arch-update | col
		exit 0
	;;
	
	#If any other option(s) are passed to the "arch-update" command, print an error and quit
	*)
		echo -e >&2 "arch-update: invalid option -- '${option}'\nTry 'arch-update --help' for more information."
		exit 1
	;;
esac
