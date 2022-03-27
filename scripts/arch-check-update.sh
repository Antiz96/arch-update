#!/bin/bash

cp -f /usr/share/icons/Arch-Check-Update/arch-check-update_checking.svg /usr/share/icons/Arch-Check-Update/arch-check-update.svg

PACKAGES=$(checkupdates | awk '{print $1}')
AURPACKAGES=$(yay -Qua | awk '{print $1}')

if [ -n "$PACKAGES" ]; then
        echo -e "Packages :\n" && echo -e "$PACKAGES\n"
fi

if [ -n "$AURPACKAGES" ]; then
        echo -e "AUR Packages :\n" && echo -e "$AURPACKAGES\n"
fi

if [ -z "$PACKAGES" ] && [ -z "$AURPACKAGES" ]; then
	cp -f /usr/share/icons/Arch-Check-Update/arch-check-update_up-to-date.svg /usr/share/icons/Arch-Check-Update/arch-check-update.svg
        echo -e "No update available\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
        exit 0
else
	cp -f /usr/share/icons/Arch-Check-Update/arch-check-update_updates-available.svg /usr/share/icons/Arch-Check-Update/arch-check-update.svg
        read -rp $'Proceed with installation ? [Y/n] ' answer

	case "$answer" in 
		[Yy]|"")
			cp -f /usr/share/icons/Arch-Check-Update/arch-check-update_installing.svg /usr/share/icons/Arch-Check-Update/arch-check-update.svg
			sudo pacman -Syu && yay -Syu
			;;
		*)
			exit 1
		;;
	esac

        if [ "$?" -ne 0 ]; then
		cp -f /usr/share/icons/Arch-Check-Update/arch-check-update_updates-available.svg /usr/share/icons/Arch-Check-Update/arch-check-update.svg
                echo -e "\nUpdates have been aborted\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
                exit 1
	else
		cp -f /usr/share/icons/Arch-Check-Update/arch-check-update_up-to-date.svg /usr/share/icons/Arch-Check-Update/arch-check-update.svg
		echo -e "\nUpdates have been applied\n" && read -n 1 -r -s -p $'Press \"enter\" to quit\n'
		exit 0
	fi
fi
