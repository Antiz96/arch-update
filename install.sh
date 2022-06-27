#!/bin/bash

pkgname="arch-update"
url="https://github.com/Antiz96/arch-update"
latest_release=$(curl -s https://raw.githubusercontent.com/Antiz96/arch-update/main/latest_release.txt)

checksum=$(curl -Ls "$url"/releases/download/v"$latest_release"/sha256sum.txt)
installed=$(command -v "$pkgname")
current_version=$("$pkgname" -v 2>/dev/null)

package() {
	curl -Ls "$url"/archive/v"$latest_release".tar.gz -o /tmp/"$pkgname"-"$latest_release".tar.gz || { echo -e >&2 "An error occured during the download of the $pkgname's archive\n\nPlease, verify that you have a working internet connexion and curl installed on your machine\nIf the problem persists anyway, you can open an issue at $url/issues" ; exit 1; }

	if ! echo "$checksum /tmp/$pkgname-$latest_release.tar.gz" | sha256sum -c --status -; then
		echo -e >&2 "\n$pkgname's archive integrity check failed\nAborting\n\nPlease, verify that you have a working internet connexion and curl installed on your machine\nIf the problem persists anyway, you can open an issue at $url/issues"
		rm -f /tmp/"$pkgname"-"$latest_release".tar.gz
		exit 1
	else
		echo -e "\n$pkgname's archive integrity validated\nProceeding to installation..."
	fi

	tar -xf /tmp/"$pkgname"-"$latest_release".tar.gz -C /tmp/ || exit 1
	chmod +x /tmp/"$pkgname"-"$latest_release"/src/bin/"$pkgname".sh || exit 1
	gzip /tmp/"$pkgname"-"$latest_release"/src/man/"$pkgname".1 || exit 1
	sudo cp -f /tmp/"$pkgname"-"$latest_release"/src/bin/"$pkgname".sh /usr/local/bin/"$pkgname" || exit 1
	sudo cp -rf /tmp/"$pkgname"-"$latest_release"/src/icons/ /usr/share/icons/"$pkgname"/ || exit 1
	sudo chmod 666 /usr/share/icons/"$pkgname"/*
	sudo cp -f /tmp/"$pkgname"-"$latest_release"/src/desktop/"$pkgname".desktop /usr/share/applications/ || exit 1
	sudo mkdir -p /usr/local/share/man/man1 || exit 1
	sudo cp -f /tmp/"$pkgname"-"$latest_release"/src/man/"$pkgname".1.gz /usr/local/share/man/man1/ || exit 1
	sudo cp -f /tmp/"$pkgname"-"$latest_release"/src/systemd/"$pkgname".* /etc/systemd/user/ || exit 1
	rm -rf /tmp/"$pkgname"-"$latest_release" /tmp/"$pkgname"-"$latest_release".tar.gz || exit 1
}

if [ -z "$installed" ]; then
	echo "$pkgname is going to be installed"
	package
	echo -e "\n$pkgname has been successfully installed\nPlease, visit $url for more information\n\nThanks for downloading !"
	exit 0
elif [ "$current_version" != "$latest_release" ]; then
	echo "A new update is available for $pkgname"
	package
	echo -e "\n$pkgname has been successfully updated to version $latest_release\nPlease, visit $url for more information"
	exit 0
else
	echo "$pkgname is up to date -- reinstallation"
	package
	echo -e "\n$pkgname has been successfully reinstalled\nPlease, visit $url for more information"
	exit 0
fi
