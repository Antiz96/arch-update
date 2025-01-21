arch-update.conf(5) ["Arch-Update 3.6.0" ["Manuel de Arch-Update"]]

# NOM

arch-update.conf - Fichier de configuration pour Arch-Update.

# SYNOPSIS

*$XDG_CONFIG_HOME/arch-update/arch-update.conf*, *$HOME/.config/arch-update/arch-update.conf*

# DESCRIPTION

Fichier de configuration _optionnel_ pour Arch-Update.

Arch-Update tente d'abord de lire le fichier sous `$XDG_CONFIG_HOME/arch-update/arch-update.conf` puis sous `$HOME/.config/arch-update/arch-update.conf` si `$XDG_CONFIG_HOME` n'est pas paramétré, ou que le fichier n'existe pas.

Un fichier de configuration par défaut / exemple peut être généré en exécutant : `arch-update --gen-config`

# OPTIONS

Les options sont sensibles à la casse, les majuscules doivent donc être respectées.

*NoColor*
	Ne pas coloriser la sortie.

*NoVersion*
	Ne pas afficher les modifications de versions des paquets lors du listing des mises à jour en attente (y compris lors de l'utilisation de l'option `-l / --list`, voir la page de manuel *arch-update*(1) pour plus de détails).

*NoNotification*
	Ne pas envoyer de notifications de bureau.

*NewsNum=[Num]*
	Nombre de Arch news à afficher avant la mise à jour et avec l'option `-n / --news` (voir la page de manuel *arch-update*(1) pour plus de détails). La valeur par défaut est 5.

*AURHelper=[AUR Helper]*
	AUR helper à utiliser pour la prise en charge des paquets AUR. Les valeurs valides sont `paru`, `yay` ou `pikaur`. Si cette option n'est pas spécifiée, Arch-Update utilisera le premier AUR helper disponible dans l'ordre suivant : `paru` puis `yay` puis `pikaur` (si aucun d'eux n'est installé, Arch-Update ne prendra pas en compte les paquets AUR).

*PrivilegeElevationCommand=[Cmd]*
	Commande à utiliser pour l'élévation de privilège. Les valeurs valides sont `sudo`, `doas` ou `run0`. Si cette option n'est pas spécifiée, Arch-Update utilisera la première commande disponible dans l'ordre suivant: `sudo`, `doas` puis `run0`.

*KeepOldPackages=[Num]*
	Nombre d'anciennes versions de paquets à conserver dans le cache de pacman. La valeur par défaut est 3.

*KeepUninstalledPackages=[Num]*
	Nombre de versions de paquets désinstallés à conserver dans le cache de pacman. La valeur par défaut est 0.

*DiffProg=[Editeur]*
	Editeur à utiliser pour visualiser / editer les différences durant le traitement des fichiers pacnew. La valeur par défaut est la valeur de la variable d'environnement `$DIFFPROG` (ou `vimdiff` si `$DIFFPROG` n'est pas paramétrée).

*TrayIconStyle=[Style / Couleur]*
	Style à utiliser pour l'icône de l'applet systray. Les valeurs valides sont les variantes de style / couleur disponibles pour le set d'icône, listées ici : https://github.com/Antiz96/arch-update/blob/main/res/icons/README.md. La valeur par défaut est "light".

# VOIR AUSSI

*arch-update*(1)

# BUGS

Signalez les bugs sur la page GitHub : https://github.com/Antiz96/arch-update/issues

# AUTEUR

Robin Candau <robincandau@protonmail.com>
