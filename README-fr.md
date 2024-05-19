# Arch-Update

<p align="center">
  <img width="460" height="300" src="https://github.com/Antiz96/arch-update/assets/53110319/e2374a41-a3e9-43bf-9b12-54f53d18a320">
</p>

[![lang-en](https://img.shields.io/badge/lang-en-blue.svg)](https://github.com/Antiz96/arch-update/blob/main/README.md)

## Table des matières

- [Description](#description)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Documentation](#documentation)
- [Trucs et astuces](#trucs-et-astuces)
- [Contribuer](#contribuer)

## Description

Un notificateur/applicateur de mises à jour pour Arch Linux qui vous assiste dans les tâches importantes d'avant/après mise à jour et qui inclut une applet systray cliquable pour une intégration facile avec n'importe quel panneau sur n'importe quel DE/WM.  
Prise en charge optionnelle des paquets AUR/Flatpak et des notifications de bureau.

Fonctionnalités :

- Inclut une applet systray cliquable qui change dynamiquemnt pour agir comme un notificateur/applicateur de mise à jour. Facile à intégrer avec n'importe quel panneau sur n'importe quel DE/WM.  
- Vérification et listing automatiques de tous les paquets disponibles pour la mise à jour.
- Propose d'afficher les news récentes d'Arch Linux avant d'appliquer les mises à jour.
- Vérification et listing automatiques des paquets orphelins et propose de les supprimer.
- Vérification automatique de la présence d'anciens paquets et/ou paquets désinstallés dans le cache et propose de les supprimer.
- Listing et aide au traitement des fichiers pacnew/pacsave.
- Vérification automatique des mises à jour du noyau en attente nécessitant un redémarrage et propose de redémarrer s'il y en a une.
- Support de `sudo` et `doas`.
- Prise en charge optionnelle des paquets AUR (via `yay` ou `paru`).
- Prise en charge optionnelle des paquets Flatpak.
- Prise en charge optionnelle des notifications de bureau lors de nouvelles mises à jour disponibles.

## Installation

### AUR

Installez le paquet AUR [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package").  
Consultez également [la liste des dépendances optionnelles](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=arch-update#n11) dont vous pourriez avoir besoin.

### Depuis la source

Installez les dépendancese requises :

```bash
sudo pacman -S --needed pacman-contrib curl htmlq diffutils hicolor-icon-theme python python-pyqt6 qt6-svg glib2
```

Dépendances optionnelles supplémentaires dont vous pourriez avoir besoin ou que vous pourriez souhaiter :

- [yay](https://aur.archlinux.org/packages/yay): Support des paquets AUR
- [paru](https://aur.archlinux.org/packages/paru): Support des paquets AUR
- [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/): Support des paquets Flatpak
- [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify/): Support des notifications de bureau lors de nouvelles mises à jour disponibles (voir <https://wiki.archlinux.org/title/Desktop_notifications>)
- [vim](https://archlinux.org/packages/extra/x86_64/vim/): Programme de fusion par défaut pour pacdiff
- [qt6-wayland](https://archlinux.org/packages/extra/x86_64/qt6-wayland/): Support de l'applet systray sur Wayland

Téléchargez l'archive de la [dernière version stable](https://github.com/Antiz96/arch-update/releases/latest) et extrayez-la *(vous pouvez également cloner ce référentiel via `git clone`)*.

Pour installer `arch-update`, allez dans le répertoire extrait/cloné et exécutez la commande suivante :

```bash
sudo make install
```

Pour désinstaller `arch-update`, allez dans le répertoire extrait/cloné et exécutez la commande suivante :

```bash
sudo make uninstall
```

## Utilisation

L'utilisation consiste à démarrer [l'applet systray](#lapplet-systray) et à activer [le timer systemd](#le-timer-systemd).

### L'applet systray

Pour démarrer l'applet systray automatiquement au démarrage du système, ajoutez la command `arch-update --tray` a vos commandes 'auto-start'/configuration de votre WM ou démarrez/activez le service systemd associé comme ceci :

```bash
systemctl --user enable --now arch-update-tray.service
```

L'icône du systray changera automatiquement en fonction de l'état actuel de votre système ('à jour' ou 'mises à jour disponibles'). Lorsque vous cliquez dessus, il lance `arch-update` via le fichier [arch-update.desktop](https://github.com/Antiz96/arch-update/blob/main/res/desktop/arch-update.desktop).

L'applet systray essaie de lire le fichier `arch-update.desktop` dans les chemins ci-dessous avec l'ordre suivant :

- `$XDG_DATA_HOME/applications/arch-update.desktop`
- `$HOME/.local/share/applications/arch-update.desktop`
- `$XDG_DATA_DIRS/applications/arch-update.desktop`
- `/usr/local/share/applications/arch-update.desktop` <-- Chemin d'installation par défaut lorsque vous installez Arch-Update [depuis la source](#depuis-la-source)
- `/usr/share/applications/arch-update.desktop` <-- Chemin d'installation par défaut lorsque vous installez Arch-Update [depuis le AUR](#AUR)

Dans le cas où vous avez envie/besoin de personnaliser le fichier `arch-update.desktop`, copiez le dans un chemin qui a une priorité plus élevée que le chemin d'installation par défaut et modifier le ici (afin d'assurer que votre ficher `arch-update.desktop` personnalisé remplace celui par défaut et que vos modifications ne soient pas écrasées à chaque mise à jour).

Cela peut être utile pour forcer le fichier `arch-update.desktop` à lancer `Arch-Update` dans un émulateur de terminal spécifique par exemple.  
**Si cliquer sur l'applet systray ne fait rien**, veuillez lire [ce chapitre](#forcer-le-fichier-desktop-a-se-lancer-avec-un-emulateur-de-terminal-specifique).

### Le timer systemd

Il existe un service systemd (sous `/usr/lib/systemd/user/arch-update.service` ou `/usr/local/lib/systemd/user/arch-update.service` si vous avez installé `Arch-Update` [depuis la source](#depuis-la-source)) qui exécute la fonction `check` quand il est démarré (voir le chapitre [Documentation](#documentation)).  
Pour le démarrer automatiquement **au démarrage du système puis une fois toutes les heures**, activez le timer systemd associé (vous pouvez modifier le cycle de vérification automatique à votre guise, voir les [Trucs et astuces - Modifier le cycle de vérification automatique](#modifier-le-cycle-de-vérification-automatique)) :

```bash
systemctl --user enable --now arch-update.timer
```

### Captures d'écran

Une fois démarrée, l'applet systray apparait dans la zone systray de votre panneau.  
C'est l'icône à droite de celle du wifi dans la capture d'écran ci-dessous:

![systray-icon](https://github.com/Antiz96/arch-update/assets/53110319/fe032e68-3582-470a-9e6d-b51a9ea8c1ba)

Avec [le systemd timer](#le-timer-systemd) activé, `Arch-Update` vérifie automatiquement les mises à jour au démarrage du système puis une fois chaque heure. La vérification peut être manuellement déclenchée en exécutant la commande `arch-update --check`.

Si de nouvelles mises à jour sont disponibles, l'icône systray affichera un cercle rouge et une notification de bureau indiquant le nombre de mises à jour disponibles sera envoyée s'il y a de nouvelles mises à jour depuis le dernier check (nécessite [libnotify/notify-send](https://archlinux.org/packages/extra/x86_64/libnotify/ "paquet libnotify") et un serveur de notification en cours d'exécution) :

![notification-FR](https://github.com/Antiz96/arch-update/assets/53110319/28f0b95a-5b8a-43a5-bc3c-df42cd40d87b)

Quand l'applet systray est cliquée, elle affiche la liste des paquets disponibles pour la mise à jour dans une fenêtre de terminal et demande la confirmation de l'utilisateur pour procéder à l'installation (peut aussi être lancé en exécutant la commande `arch-update`, requiert [yay](https://aur.archlinux.org/packages/yay "yay") ou [paru](https://aur.archlinux.org/packages/paru "paru") pour le support des paquets AUR et [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/) pour le support des paquets Flatpak).

![listing_packages-FR](https://github.com/Antiz96/arch-update/assets/53110319/60547cde-f327-46f8-907c-61bf9bbee6c5)

Par défaut, si au moins une news Arch Linux a été publiée depuis la dernière exécution, `Arch-Update` vous proposera de lire les dernières news Arch Linux directement depuis votre fenêtre de terminal.  
Les news publiées depuis la dernière exécution sont tagguées comme `[NOUVEAU]` :

![listing_news-FR](https://github.com/Antiz96/arch-update/assets/53110319/72819197-d4f7-4c50-af21-0aac1c60ba41)

Quand la liste des news récentes est affichée, vous pouvez soit taper le nombre associé à une news pour la lire (vous serez invité à nouveau à lire d'autres news par la suite, ce qui vous permettra de lire plusieurs news en une seule exécution), ou simplement appuyez sur "entrée" pour procéder à la mise à jour.  
Si aucune news n'a été publiée depuis la dernière exécution, `Arch-Update` procédera directement à la mise à jour après que vous ayez donné votre confirmation.

Dans les deux cas, à partir de là, vous avez simplement à laisser `Arch-Update` vous guider à travers les différentes étapes requises pour une mise à jour complète et appropriée de votre système ! :smile:

Certaines options peuvent être activées/désactivées ou modifiées via le fichier de configuration `arch-update.conf`. Voir le [chapitre de documentation arch-update.conf](#fichier-de-configuration-arch-update) pour plus de détails.

## Documentation

### arch-update

```text
Un notificateur/applicateur de mises à jour pour Arch Linux qui vous assiste dans les
tâches importantes d'avant/après mise à jour.

Lancez arch-update pour exécuter la fonction principale « update » :
Afficher la liste des paquets disponibles pour mise à jour, puis demander la confirmation de l'utilisateur
pour procéder à l'installation.
Avant d'effectuer la mise à jour, propose d'afficher les dernières Arch news.
Après la mise à jour, vérification de la présence de paquets orphelins/inutilisés, d'anciens paquets mis en cache,
de fichiers pacnew/pacsave et de mise à jour du noyau en attente et, s'il y en a, propose de les traiter.

Options :
-c, --check       Vérifier les mises à jour disponibles, changer l'icône systray et envoyer une notification de bureau contenant le nombre de mises à jour disponibles (s'il y a des nouvelles mises à jour disponibles depuis le dernier check)
-l, --list        Afficher la liste des mises à jour en attente
-d, --devel       Inclure les mises à jour des paquets de développement AUR
-n, --news [Num]  Afficher les dernieres Arch News, vous pouvez optionellement spécifier le nombre de Arch news à afficher avec `--news [Num]` (e.g. `--news 10`)
-D, --debug       Afficher les traces de débogage
--gen-config      Générer un fichier de configuration par défaut/exemple (voir la page de manuel arch-update.conf(5) pour plus de détails)
--tray            Lancer l'applet systray d'Arch-Update
-h, --help        Afficher ce message d'aide et quitter
-V, --version     Afficher les informations de version et quitter

Codes de sortie :
0  OK
1  Option invalide
2  Aucune méthode d'élévation de privilège (sudo ou doas) n'est installée
3  Erreur lors du lancement de l'applet systray d'Arch-Update
4  L'utilisateur n'a pas donné la confirmation de procéder
5  Erreur lors de la mise à jour des paquets
6  Erreur lors de l'appel de la commande reboot pour appliquer une mise à jour du noyau en attente
7  Aucune mise à jour en attente durant l'utilisation de l'option `-l/--list`
8  Erreur lors de la génération d'un fichier de configuration avec l'option `--gen-config`
```

Pour plus d'informations, consultez la page de manuel arch-update(1).  
Certaines options peuvent être activées/désactivées ou modifiées via le fichier de configuration arch-update.conf, voir la page de manuel arch-update.conf(5).

### Fichier de configuration arch-update

```text
Le fichier arch-update.conf est un fichier de configuration facultatif pour arch-update permettant
d'activer/désactiver ou modifier certaines options dans le script.

Ce fichier de configuration doit se trouver dans "${XDG_CONFIG_HOME}/arch-update/arch-update.conf"
ou "${HOME}/.config/arch-update/arch-update.conf".
Un fichier de configuration par défaut/exemple peut être généré en exécutant : `arch-update --gen-config`

Les options prises en charge sont :

- NoColor # Ne pas coloriser la sortie.
- NoVersion # Ne pas afficher les modifications de versions des paquets lors du listing des mises à jour en attente (y compris lors de l'utilisation de l'option `-l/--list`).
- AlwaysShowNews # Toujours afficher les Arch news avant de mettre à jour, peu importe s'il y en a une nouvelle depuis la dernière exécution ou non.
- NewsNum=[Num] # Nombre de Arch news à affcher avant la mise à jour et avec l'option `-n/--news` (voir la page de manuel arch-update(1) pour plus de details). La valeur par défaut est 5.
- KeepOldPackages=[Num] # Nombre d'anciennes versions de paquets à conserver dans le cache de pacman. La valeur par défaut est 3.
- KeepUninstalledPackages=[Num] # Nombre de versions de paquets désinstallés à conserver dans le cache de pacman. La valeur par défaut est 0.

Les options sont sensibles à la casse, les majuscules doivent donc être respectées.
```

Pour plus d'informations, consultez la page de manuel arch-update.conf(5).

## Trucs et astuces

### Support du AUR

Arch-Update prend en charge les paquets AUR si **yay** ou **paru** est installé :  
Voir <https://github.com/Jguer/yay> et <https://aur.archlinux.org/packages/yay>  
Voir <https://github.com/morganamilo/paru> et <https://aur.archlinux.org/packages/paru>

### Support de Flatpak

Arch-Update prend en charge les paquets Flatpak si **flatpak** est installé :  
Voir <https://www.flatpak.org/> et <https://archlinux.org/packages/extra/x86_64/flatpak/>

### Support des notifications de bureau

Arch-Update prend en charge les notifications de bureau lors de l'exécution de la fonction `--check` si **libnotify** est installé (et qu'un serveur de notification est en cours d'exécution) :  
Voir <https://wiki.archlinux.org/title/Desktop_notifications>

### Modifier le cycle de vérification automatique

Si vous avez activé le [timer systemd](#le-timer-systemd), l'option `--check` est automatiquement lancée au démarrage du système puis une fois par heure.

Si vous souhaitez modifier le cycle de vérification, exécutez la commande `systemctl --user edit --full arch-update.timer` et modifiez la valeur `OnUnitActiveSec` à votre convenance.  
Par exemple, si vous voulez qu'`Arch-Update` vérifie plutôt les nouvelles mises à jour toutes les 10 minutes :

```text
[...]
[Timer]
OnStartupSec=15
OnUnitActiveSec=10m
[...]
```

Les unités de temps sont `s` pour secondes, `m` pour minutes, `h` pour heures, `d` pour jours...  
Voir <https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#Parsing%20Time%20Spans> pour plus de détails.

Dans le cas où vous voulez qu'`Arch-Update` ne vérifie les nouvelles mises à jour qu'une fois au démarrage du système, vous pouvez simplement supprimer la ligne `OnUnitActiveSec` complètement.

### Forcer le fichier desktop à se lancer avec un émulateur de terminal spécifique

`gio` (qui est utilisé pour lancer le fichier `arch-update.desktop` quand l'applet systray est cliquée) ne supporte actuellement qu'une [liste limitée d'émulateurs de terminal](https://gitlab.gnome.org/GNOME/glib/-/blob/main/gio/gdesktopappinfo.c#L2694).  
Si vous n'avez aucun de ces émulateurs de terminal installé sur votre système, il se peut que vous soyez confronté à un problème où cliquer sur l'applet systray [ne fait rien](https://github.com/Antiz96/arch-update/issues/162) et rapporte l'erreur suivante : `[...] Unable to find terminal required for application`.

En attendant que Gnome implémente une méthode permettant aux utilisateurs d'utiliser l'émulateur de terminal de leur choix avec `gio` (ce qui, espérons-le, [arrivera à un moment ou à un autre](https://gitlab.freedesktop.org/terminal-wg/specifications/-/merge_requests/3)), vous pouvez contourner le problème en copiant le fichier `arch-update.desktop` dans `$HOME/.local/share/applications/arch-update.desktop` (par exemple, voir [ce chapitre](#lapplet-systray) pour plus de détails) et en modifiant la ligne `Exec` pour "forcer" `arch-update` à s'exécuter dans l'émulateur de terminal de votre choix.  
Par exemple, avec [alacritty](https://alacritty.org/) *(vérifier le manuel de votre émulateur de terminal pour trouver la bonne option à utiliser)* :

```text
[...]
Exec=alacritty -e arch-update
```

Alternativement, vous pouvez créer un lien symbolique de votre émulateur de terminal pointant vers `/usr/bin/xterm`, qui est l'option de "secours" pour `gio` (par exemple, avec [alacritty](https://alacritty.org) : `sudo ln -s /usr/bin/alacritty /usr/bin/xterm`) ou vous pouvez simplement installer un des émulateurs de terminal [connus/supportés](https://gitlab.gnome.org/GNOME/glib/-/blob/main/gio/gdesktopappinfo.c#L2694) par `gio`.

## Contribuer

Vous pouvez soulever vos problèmes, commentaires et suggestions dans l'onglet [Issues](https://github.com/Antiz96/arch-update/issues).  
Les [Pull requests](https://github.com/Antiz96/arch-update/pulls) sont également les bienvenues !
