#!/bin/bash

cp -f /usr/share/icons/Arch-Check-Update/arch-check-update_checking.svg /usr/share/icons/Arch-Check-Update/arch-check-update.svg

UPDATE_NUMBER=$( (checkupdates ; yay -Qua) | wc -l)

if [ "$UPDATE_NUMBER" -eq 1 ]; then
	cp -f /usr/share/icons/Arch-Check-Update/arch-check-update_updates-available.svg /usr/share/icons/Arch-Check-Update/arch-check-update.svg
	notify-send -i /usr/share/icons/Arch-Check-Update/arch-check-update_updates-available.svg "Arch Check Update" "$UPDATE_NUMBER update available"
elif  [ "$UPDATE_NUMBER" -gt 1 ]; then
	cp -f /usr/share/icons/Arch-Check-Update/arch-check-update_updates-available.svg /usr/share/icons/Arch-Check-Update/arch-check-update.svg
	notify-send -i /usr/share/icons/Arch-Check-Update/arch-check-update_updates-available.svg "Arch Check Update" "$UPDATE_NUMBER updates available"
else
	cp -f /usr/share/icons/Arch-Check-Update/arch-check-update_up-to-date.svg /usr/share/icons/Arch-Check-Update/arch-check-update.svg
fi
