#!/bin/bash

for po in po/*.po; do
	msgmerge "${po}" "po/arch-update.pot" -o "${po}"
done
