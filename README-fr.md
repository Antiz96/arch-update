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
- [Licence](#licence)

## Description

Un notificateur & applicateur de mises à jour pour Arch Linux qui vous assiste dans les tâches importantes d'avant / après mise à jour et qui inclut une applet systray cliquable pour une intégration facile avec n'importe quel panneau sur n'importe quel environnement de bureau / gestionnaire de fenêtres.  
Prise en charge optionnelle des paquets AUR / Flatpak et des notifications de bureau.

Arch-Update est conçu pour suivre les étapes usuelles de maintenance du système, telles que décrites dans le [Arch Wiki](https://wiki.archlinux.org/title/System_maintenance).

Fonctionnalités :

- Inclut une applet systray cliquable qui change dynamiquement pour agir comme un notificateur & applicateur de mise à jour. Facile à intégrer avec n'importe quel panneau sur n'importe quel environnement de bureau & gestionnaire de fenêtres.
- Vérification et listing automatiques de tous les paquets disponibles pour la mise à jour.
- Propose d'afficher les news récentes d'Arch Linux avant d'appliquer les mises à jour.
- Vérification et listing automatiques des paquets orphelins et propose de les supprimer.
- Vérification automatique de la présence d'anciens paquets et / ou paquets désinstallés dans le cache et propose de les supprimer.
- Listing et aide au traitement des fichiers pacnew / pacsave.
- Vérification automatique des mises à jour du noyau en attente nécessitant un redémarrage et propose de redémarrer s'il y en a une.
- Vérification automatique des services nécessitant un redémarrage après mise à jour et propose de les redémarrer s'il y en a.
- Support de `sudo`, `doas` et `run0`.
- Prise en charge optionnelle des paquets AUR (via `paru`, `yay` ou `pikaur`).
- Prise en charge optionnelle des paquets Flatpak.
- Prise en charge optionnelle des notifications de bureau lors de nouvelles mises à jour disponibles.

## Installation

### AUR

Installez le paquet AUR [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package").  
Consultez également la liste des dépendances optionnelles (disponible dans la section ["depuis la source"](#depuis-la-source) ci-dessous) dont vous pourriez avoir besoin.

### Depuis la source

Installez les dépendances requises :

```bash
sudo pacman -S --needed pacman-contrib archlinux-contrib curl fakeroot htmlq diffutils hicolor-icon-theme python python-pyqt6 qt6-svg glib2
```

Dépendances optionnelles supplémentaires dont vous pourriez avoir besoin ou que vous pourriez souhaiter :

- [paru](https://aur.archlinux.org/packages/paru) : Support des paquets AUR
- [yay](https://aur.archlinux.org/packages/yay) : Support des paquets AUR
- [pikaur](https://aur.archlinux.org/packages/pikaur) : Support des paquets AUR
- [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/) : Support des paquets Flatpak
- [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify/) : Support des notifications de bureau lors de nouvelles mises à jour disponibles (voir <https://wiki.archlinux.org/title/Desktop_notifications>)
- [vim](https://archlinux.org/packages/extra/x86_64/vim/) : Programme de fusion par défaut pour pacdiff
- [qt6-wayland](https://archlinux.org/packages/extra/x86_64/qt6-wayland/) : Support de l'applet systray sur Wayland

Téléchargez l'archive de la [dernière version stable](https://github.com/Antiz96/arch-update/releases/latest) et extrayez la *(vous pouvez également cloner ce référentiel via `git clone`)*.

Pour installer `arch-update`, allez dans le répertoire extrait / cloné et exécutez la commande suivante :

```bash
sudo make install
```

Si vous voulez exécuter des tests unitaires simples, vous pouvez exécuter la commande suivante (requiert [bats](https://archlinux.org/packages/extra/any/bats/)) :

```bash
make test
```

Pour désinstaller `arch-update`, allez dans le répertoire extrait / cloné et exécutez la commande suivante :

```bash
sudo make uninstall
```

## Utilisation

L'utilisation consiste à démarrer [l'applet systray](#lapplet-systray) et à activer [le timer systemd](#le-timer-systemd).

### L'applet systray

Pour démarrer l'applet systray, lancez l'application "Arch-Update Systray Applet" depuis votre menu d'application.

Pour la démarrer automatiquement au démarrage du système, utilisez l'une des options suivantes :

- Lancer la commande suivante (méthode recommandée pour la plupart des environnements de bureau, utilise [XDG Autostart](https://wiki.archlinux.org/title/XDG_Autostart)) :

```bash
arch-update --tray --enable
```

- Activer le service systemd associé (dans le cas où votre environnement de bureau ne supporte pas [XDG Autostart](https://wiki.archlinux.org/title/XDG_Autostart)) :

```bash
systemctl --user enable --now arch-update-tray.service
```

Si vous utilisez un gestionnaire de fenêtre ou un compositeur Wayland, vous pouvez plutôt ajouter la commande `arch-update --tray` à vos applications "auto-start" dans votre fichier de configuration.

**Si l'applet systray ne démarre pas au démarrage du système malgré tout**, veuillez lire [ce chapitre](#lapplet-systray-ne-démarre-pas-au-démarrage-du-système).

L'icône du systray changera automatiquement en fonction de l'état actuel de votre système ('à jour' ou 'mises à jour disponibles'). Lorsque vous cliquez dessus, elle lance `arch-update` via le fichier [arch-update.desktop](https://github.com/Antiz96/arch-update/blob/main/res/desktop/arch-update.desktop).

L'applet systray essaie de lire le fichier `arch-update.desktop` dans les chemins ci-dessous avec l'ordre suivant :

- `$XDG_DATA_HOME/applications/arch-update.desktop`
- `$HOME/.local/share/applications/arch-update.desktop`
- `$XDG_DATA_DIRS/applications/arch-update.desktop`
- `/usr/local/share/applications/arch-update.desktop` <-- Chemin d'installation par défaut lorsque vous installez Arch-Update [depuis la source](#depuis-la-source)
- `/usr/share/applications/arch-update.desktop` <-- Chemin d'installation par défaut lorsque vous installez Arch-Update [depuis le AUR](#AUR)

Dans le cas où vous avez envie (ou besoin) de personnaliser le fichier `arch-update.desktop`, copiez le dans un chemin qui a une priorité plus élevée que le chemin d'installation par défaut et modifier le ici (afin d'assurer que votre ficher `arch-update.desktop` personnalisé remplace celui par défaut et que vos modifications ne soient pas écrasées à chaque mise à jour).

Cela peut être utile pour forcer `Arch-Update` à se lancer avec un émulateur de terminal spécifique lorsque l'on clique sur l'applet systray.  
**Si cliquer sur l'applet systray ne fait rien**, veuillez lire [ce chapitre](#forcer-le-fichier-desktop-à-se-lancer-avec-un-émulateur-de-terminal-spécifique).

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

Avec [le systemd timer](#le-timer-systemd) activé, `Arch-Update` vérifie automatiquement les mises à jour au démarrage du système puis une fois chaque heure. La vérification peut être manuellement déclenchée en exécutant la commande `arch-update --check` ou en faisant un clic droit sur l'icône du systray puis en cliquant sur l'entrée `Vérifier les mises à jour` depuis le menu :

![check_menu_fr](https://github.com/user-attachments/assets/b0b7730b-0196-4973-ac90-bceb8a74845e)

Si de nouvelles mises à jour sont disponibles, l'icône du systray affichera un cercle rouge et une notification de bureau indiquant le nombre de mises à jour disponibles sera envoyée (nécessite [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify/ "paquet libnotify") et un serveur de notification en cours d'exécution) :

![notif_fr](https://github.com/user-attachments/assets/56d72147-bde4-492b-8ad1-20caed9f22a9)

Vous pouvez alors voir la liste des mises à jour disponibles dans l'infobulle de l'icône du systray en passant votre souris dessus :

![tooltip_fr](https://github.com/user-attachments/assets/8bc3d339-f7ab-4c8b-aa3f-2b88ea68af42)

Alternativement, vous pouvez voir la liste des mises à jour disponible dans le menu déroulant en faisant un clic droit sur l'icône du systray :

![dropdown_menu_fr](https://github.com/user-attachments/assets/60c3c0d8-8091-4047-b8da-ce8f8bc72476)

Quand l'icône du systray est cliquée, elle affiche la liste des paquets disponibles pour la mise à jour dans une fenêtre de terminal et demande la confirmation de l'utilisateur pour procéder à l'installation (peut aussi être lancé en exécutant la commande `arch-update`, requiert [paru](https://aur.archlinux.org/packages/paru "paru"), [yay](https://aur.archlinux.org/packages/yay "yay") ou [pikaur](https://aur.archlinux.org/packages/pikaur "pikaur") pour le support des paquets AUR et [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/) pour le support des paquets Flatpak).

![listing_packages-FR](https://github.com/Antiz96/arch-update/assets/53110319/60547cde-f327-46f8-907c-61bf9bbee6c5)

Par défaut, si au moins une news Arch Linux a été publiée depuis la dernière exécution, `Arch-Update` vous proposera de lire les dernières news Arch Linux directement depuis votre fenêtre de terminal.  
Les news publiées depuis la dernière exécution sont tagguées comme `[NOUVEAU]` :

![listing_news-FR](https://github.com/Antiz96/arch-update/assets/53110319/ec4032f3-835e-418c-b19a-b7bd089d6bd9)

Quand la liste des news récentes est affichée, vous pouvez sélectionner les news à lire (par exemple: 1 3 5), sélectionner 0 pour toutes les lire ou appuyer sur "entrée" pour procéder à la mise à jour.  
Si aucune news n'a été publiée depuis la dernière exécution, `Arch-Update` procédera directement à la mise à jour après que vous ayez donné votre confirmation.

Dans les deux cas, à partir de là, vous avez simplement à laisser `Arch-Update` vous guider à travers les différentes étapes requises pour une mise à jour complète et appropriée de votre système ! :smile:

Certaines options peuvent être activées, désactivées ou modifiées via le fichier de configuration `arch-update.conf`. Voir le [chapitre de documentation arch-update.conf](#fichier-de-configuration-arch-update) pour plus de détails.

## Documentation

### arch-update

```text
Un notificateur & applicateur de mises à jour pour Arch Linux qui vous assiste dans les
tâches importantes d'avant / après mise à jour.

Lancez arch-update pour exécuter la fonction principale « update » :
Afficher la liste des paquets disponibles pour mise à jour, puis demander la confirmation de l'utilisateur
pour procéder à l'installation.
Avant d'effectuer la mise à jour, propose d'afficher les dernières Arch news.
Après la mise à jour, vérification de la présence de paquets orphelins & inutilisés, d'anciens paquets mis en cache,
de fichiers pacnew & pacsave, de mise à jour du noyau en attente ainsi que des services nécessitant un redémarrage après mise à jour
et, s'il y en a, propose de les traiter.

Options :
-c, --check       Vérifier les mises à jour disponibles, changer l'icône du systray et envoyer une notification de bureau contenant le nombre de mises à jour disponibles (s'il y a des nouvelles mises à jour disponibles depuis le dernier check)
-l, --list        Afficher la liste des mises à jour en attente
-d, --devel       Inclure les mises à jour des paquets de développement AUR
-n, --news [Num]  Afficher les dernieres Arch News, vous pouvez optionellement spécifier le nombre de Arch news à afficher avec `--news [Num]` (e.g. `--news 10`)
-D, --debug       Afficher les traces de débogage
--gen-config      Générer un fichier de configuration `arch-update.conf` par défaut / exemple (voir la page de manuel arch-update.conf(5) pour plus de détails), vous pouvez optionnellement passer l'argument `--force` pour écraser un fichier de configuration `arch-update.conf` existant
--show-config     Afficher le fichier de configuration `arch-update.conf` actuellement utilisé (s'il existe)
--edit-config     Editer le fichier de configuration `arch-update.conf` actuellement utilisé (s'il existe)
--tray            Lancer l'applet systray d'Arch-Update, vous pouvez optionnellement ajouter l'argument `--enable` pour la démarrer automatiquement au démarrage du système.
-h, --help        Afficher ce message d'aide et quitter
-V, --version     Afficher les informations de version et quitter

Codes de sortie :
0  OK
1  Option invalide
2  Aucune commande d'élévation de privilège (sudo, doas ou run0) n'est installée ou celle définie dans le fichier de configuration `arch-update.conf` n'est pas disponible
3  Erreur lors du lancement de l'applet systray d'Arch-Update
4  L'utilisateur n'a pas donné la confirmation de procéder
5  Erreur lors de la mise à jour des paquets
6  Erreur lors de l'appel de la commande reboot pour appliquer une mise à jour du noyau en attente
7  Aucune mise à jour en attente durant l'utilisation de l'option `-l / --list`
8  Erreur lors de la génération d'un fichier de configuration avec l'option `--gen-config`
9  Erreur lors de la lecture du fichier de configuration avec l'option `--show-config`
10 Erreur lors de la creation du fichier desktop autostart pour l'applet systray avec l'option `--tray --enable`
11 Erreur lors du redémarrage des services nécessitant un redémarrage après mise à jour
12 Erreur lors du traitement des fichiers pacnew
13 Erreur lors de l'édition du fichier de configuration avec l'option `--edit-config`
14 Le dossier de librairies n'a pas été trouvé
15 L'éditeur "diff prog" défini dans le fichier de configuration `arch-update.conf` n'est pas disponible
```

Pour plus d'informations, consultez la page de manuel arch-update(1).  
Certaines options peuvent être activées, désactivées ou modifiées via le fichier de configuration arch-update.conf, voir la page de manuel arch-update.conf(5).

### Fichier de configuration arch-update

```text
Le fichier arch-update.conf est un fichier de configuration facultatif pour arch-update permettant
d'activer, désactiver ou modifier certaines options dans le script.

Ce fichier de configuration doit se trouver dans "${XDG_CONFIG_HOME}/arch-update/arch-update.conf"
ou "${HOME}/.config/arch-update/arch-update.conf".
Un fichier de configuration par défaut / exemple peut être généré en exécutant : `arch-update --gen-config`

Les options prises en charge sont :

- NoColor # Ne pas coloriser la sortie.
- NoVersion # Ne pas afficher les modifications de versions des paquets lors du listing des mises à jour en attente (y compris lors de l'utilisation de l'option `-l / --list`).
- NewsNum=[Num] # Nombre de Arch news à affcher avant la mise à jour et avec l'option `-n / --news` (voir la page de manuel arch-update(1) pour plus de details). La valeur par défaut est 5.
- AURHelper=[AUR Helper] # AUR helper à utiliser pour la prise en charge des paquets AUR. Les valeurs valides sont `paru`, `yay` ou `pikaur`. Si cette option n'est pas spécifiée, Arch-Update utilisera le premier AUR helper disponible dans l'ordre suivant : `paru` puis `yay` puis `pikaur` (si aucun d'eux n'est installé, Arch-Update ne prendra pas en compte les paquets AUR).
- PrivilegeElevationCommand=[Cmd] # Commande à utiliser pour l'élévation de privilège. Les valeurs valides sont `sudo`, `doas` ou `run0`. Si cette option n'est pas spécifiée, Arch-Update utilisera la première commande disponible dans l'odre suivant : `sudo`, `doas` puis `run0`.
- KeepOldPackages=[Num] # Nombre d'anciennes versions de paquets à conserver dans le cache de pacman. La valeur par défaut est 3.
- KeepUninstalledPackages=[Num] # Nombre de versions de paquets désinstallés à conserver dans le cache de pacman. La valeur par défaut est 0.
- DiffProg=[Editeur] # Editeur à utiliser pour visualiser / editer les différences durant le traitement des fichiers pacnew. La valeur par défaut est la valeur de la variable d'environnement `$DIFFPROG` (ou `vimdiff` si `$DIFFPROG` n'est pas paramétrée). Notez qu'en raison de l'absence d'option pour préserver les variables d'environnement dans `doas`, cette option sera ignorée lors de l'utilisation de `doas` comme méthode d'élévation de privilèges.
- TrayIconStyle=[Style / Color] # Style à utiliser pour l'icône de l'applet systray. Les valeurs valides sont les variantes de style / couleur disponibles pour le set d'icône, listées ici : https://github.com/Antiz96/arch-update/tree/main/res/icons. La valeur par défaut est "light".

Les options sont sensibles à la casse, les majuscules doivent donc être respectées.
```

Pour plus d'informations, consultez la page de manuel arch-update.conf(5).

## Trucs et astuces

### Support du AUR

Arch-Update prend en charge les paquets AUR si **paru**, **yay** ou **pikaur** est installé :  
Voir <https://github.com/morganamilo/paru> et <https://aur.archlinux.org/packages/paru>  
Voir <https://github.com/Jguer/yay> et <https://aur.archlinux.org/packages/yay>  
Voir <https://github.com/actionless/pikaur> et <https://aur.archlinux.org/packages/pikaur>

### Support de Flatpak

Arch-Update prend en charge les paquets Flatpak si **flatpak** est installé :  
Voir <https://www.flatpak.org/> et <https://archlinux.org/packages/extra/x86_64/flatpak/>

### Support des notifications de bureau

Arch-Update prend en charge les notifications de bureau lors de l'exécution de la fonction `--check` si **libnotify** est installé (et qu'un serveur de notification est en cours d'exécution) :  
Voir <https://wiki.archlinux.org/title/Desktop_notifications>

### L'applet systray ne démarre pas au démarrage du système

Assurez vous d'avoir suivi les instructions de [ce chapitre](#lapplet-systray).

Si l'applet systray ne démarre pas malgré tout, cela peut être le résultat d'une [situation de compétition](https://fr.wikipedia.org/wiki/Situation_de_comp%C3%A9tition).  
Dans ce cas, il peut être utile de légèrement retarder le démarrage de l'applet systray en utilisant une déclaration `sleep` au préalable :

- Si vous avez utilisé `arch-update --tray --enable`, modifiez la ligne `Exec=` dans le fichier `arch-update-tray.desktop` (qui se trouve sous `~/.config/autostart/` par défaut), comme ceci :

> Exec=sh -c "sleep 3 && arch-update --tray"

- Si vous avez utilisé le service systemd `arch-update-tray.service`, exécutez `systemctl --user edit --full arch-update-tray.service` et modifiez la ligne `ExecStart=`, comme ceci :

> ExecStart=sh -c "sleep 3 && arch-update --tray"

- Si vous utilisez un gestionnaire de fenêtres ou un compositeur Wayland, ajoutez une déclaration `sleep` avant la commande `arch-update --tray` dans vos applications "auto-start" dans votre fichier de configuration, comme ceci :

> `sleep 3 && arch-update --tray`

Si l'applet systray ne démarre toujours au démarrage du système, essayez de graduellement augmenter la valeur du `sleep`.

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

Alternativement, vous pouvez créer un lien symbolique de votre émulateur de terminal pointant vers `/usr/bin/xterm`, qui est l'option de "secours" pour `gio` (par exemple, avec [alacritty](https://alacritty.org) : `sudo ln -s /usr/bin/alacritty /usr/bin/xterm`) ou vous pouvez simplement installer un des émulateurs de terminal [supportés](https://gitlab.gnome.org/GNOME/glib/-/blob/main/gio/gdesktopappinfo.c#L2701) par `gio`.

## Contribuer

Veuillez lire le [guide de contribution](https://github.com/Antiz96/arch-update/blob/main/CONTRIBUTING.md).

## Licence

Arch-Update est sous [licence GPL-3.0](https://github.com/Antiz96/arch-update/blob/main/LICENSE) (ou toute version ultérieure de cette licence).
