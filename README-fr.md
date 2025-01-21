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

Un notificateur & applicateur de mises à jour pour Arch Linux qui vous assiste dans les tâches importantes d'avant / après mise à jour.  
Inclut une applet systray dynamique & cliquable pour une intégration facile avec n'importe quel environnement de bureau / gestionnaire de fenêtres.

Arch-Update est conçu pour suivre les étapes usuelles de maintenance du système, telles que décrites dans le [Arch Wiki](https://wiki.archlinux.org/title/System_maintenance).

Fonctionnalités :

- Vérification et listing automatiques des mises à jour disponibles.
- Vérification des Arch Linux news récentes (et propose de les afficher s'il y en a).
- Vérification des paquets orphelins (et propose de les supprimer s'il y en a).
- Vérification d'anciens paquets & paquets désinstallés dans le cache (et propose de les supprimer s'il y en a).
- Vérification des fichiers pacnew & pacsave (et propose de les traiters s'il y en a).
- Vérification des mises à jour du noyau en attente nécessitant un redémarrage (et propose de le faire s'il y en a une).
- Vérification des services nécessitant un redémarrage après mise à jour (et propose de le faire s'il y en a).
- Support de `sudo`, `doas` et `run0`.

Support optionnel pour :

- Les paquets AUR (via `paru`, `yay` ou `pikaur`).
- Les paquets Flatpak (via `flatpak`).
- Les notifications de bureau (via `libnotify`).

## Installation

### AUR

Installez le paquet AUR [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package") (consultez également la liste des dépendances optionnelles dont vous pourriez avoir envie ou besoin).

### Depuis la source

Installez les dépendances requises :

```bash
sudo pacman -S --needed pacman-contrib archlinux-contrib curl fakeroot htmlq diffutils hicolor-icon-theme python python-pyqt6 qt6-svg glib2
```

Dépendances optionnelles supplémentaires dont vous pourriez avoir envie ou besoin :

- [paru](https://aur.archlinux.org/packages/paru) : Support des paquets AUR
- [yay](https://aur.archlinux.org/packages/yay) : Support des paquets AUR
- [pikaur](https://aur.archlinux.org/packages/pikaur) : Support des paquets AUR
- [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/) : Support des paquets Flatpak
- [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify/) : Support des notifications de bureau lors de nouvelles mises à jour disponibles (voir <https://wiki.archlinux.org/title/Desktop_notifications>)
- [vim](https://archlinux.org/packages/extra/x86_64/vim/) : Programme de fusion par défaut pour pacdiff
- [qt6-wayland](https://archlinux.org/packages/extra/x86_64/qt6-wayland/) : Support de l'applet systray sur Wayland

Installez les dépendances de compilation requises :

```bash
sudo pacman -S --asdeps make scdoc bats
```

Téléchargez l'archive de la [dernière version stable](https://github.com/Antiz96/arch-update/releases/latest) et extrayez la (vous pouvez également cloner ce référentiel avec `git`).

Pour installer `arch-update`, allez dans le répertoire extrait / cloné et exécutez les commandes suivantes :

```bash
sudo make
sudo make test
sudo make install
```

Une fois l'installation terminée, vous pouvez optionnellement nettoyer le répertoire des fichiers générés durant l'installation en exécutant cette commande :

```bash
sudo make clean
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

- Ajouter la commande suivante à vos applications "auto-start" / votre fichier de configuration (si vous utilisez un gestionnaire de fenêtre ou un compositeur Wayland) :

```bash
arch-update --tray
```

**Si l'applet systray ne démarre pas au démarrage du système malgré tout**, veuillez lire [ce chapitre](#lapplet-systray-ne-démarre-pas-au-démarrage-du-système).

L'icône du systray change dynamiquement pour indiquer l'état actuel de votre système ('à jour' ou 'mises à jour disponibles'). Lorsque vous cliquez dessus, elle lance `arch-update` dans une fenêtre de terminal via le fichier [arch-update.desktop](https://github.com/Antiz96/arch-update/blob/main/res/desktop/arch-update.desktop).

**Si cliquer sur l'applet systray ne fait rien**, veuillez lire [ce chapitre](#lancer-arch-update-dans-un-émulateur-de-terminal-spécifique).

### Le timer systemd

Pour effectuer des vérifications automatiques et périodiques des mises à jour disponibles, activez le timer systemd associé :

```bash
systemctl --user enable --now arch-update.timer
```

Par défaut, une vérification est effectuée **au démarrage du système puis une fois toutes les heures**. Le cycle de vérification peut être personnalisé, voir [ce chapitre](#modifier-le-cycle-de-vérification).

### Captures d'écran

Une fois démarrée, l'applet systray apparait dans la zone systray de votre panneau.  
C'est l'icône à droite de celle du wifi dans la capture d'écran ci-dessous:

![systray-icon](https://github.com/Antiz96/arch-update/assets/53110319/fe032e68-3582-470a-9e6d-b51a9ea8c1ba)

Avec [le timer systemd](#le-timer-systemd) activé, les vérifications des mises à jour sont effectuées automatiqument et périodiquement, mais vous pouvez en déclencher une manuellement depuise l'applet systray en faisant un clic droit dessus puis en cliquant sur l'entrée `Vérifier les mises à jour` depuis le menu :

![check_menu_fr](https://github.com/user-attachments/assets/b0b7730b-0196-4973-ac90-bceb8a74845e)

Si de nouvelles mises à jour sont disponibles, l'icône du systray affiche un cercle rouge et une notification de bureau indiquant le nombre de mises à jour disponibles est envoyée :

![notif_fr](https://github.com/user-attachments/assets/56d72147-bde4-492b-8ad1-20caed9f22a9)

Vous pouvez alors voir la liste des mises à jour disponibles dans l'infobulle de l'icône du systray en passant votre souris dessus :

![tooltip_fr](https://github.com/user-attachments/assets/8bc3d339-f7ab-4c8b-aa3f-2b88ea68af42)

Autrement, vous pouvez voir la liste des mises à jour disponible dans le menu déroulant en faisant un clic droit sur l'icône du systray :

![dropdown_menu_fr](https://github.com/user-attachments/assets/60c3c0d8-8091-4047-b8da-ce8f8bc72476)

Quand l'icône du systray est cliquée, elle lance `arch-update` dans une fenêtre de terminal :

![listing_packages-FR](https://github.com/Antiz96/arch-update/assets/53110319/60547cde-f327-46f8-907c-61bf9bbee6c5)

Si au moins une news Arch Linux a été publiée depuis la dernière exécution, `Arch-Update` vous proposera de lire les dernières news Arch Linux directement depuis la fenêtre de terminal.  
Les news publiées depuis la dernière exécution sont labellisées comme `[NOUVEAU]` :

![listing_news-FR](https://github.com/Antiz96/arch-update/assets/53110319/72819197-d4f7-4c50-af21-0aac1c60ba41)

Si aucune news n'a été publiée depuis la dernière exécution, `Arch-Update` demande directement votre confirmation pour procéder à la mise à jour.

À partir de là, laissez simplement `Arch-Update` vous guider à travers les différentes étapes requises pour une mise à jour complète et appropriée de votre système ! :smile:

Certaines options peuvent être activées, désactivées ou modifiées via le fichier de configuration `arch-update.conf`. Voir la [page de manuel arch-update.conf(5)](https://github.com/Antiz96/arch-update/blob/main/doc/man/fr/arch-update.conf.5.scd) pour plus de détails.

## Documentation

### arch-update

Voir `arch-update --help` et la [page de manuel arch-update(1)](https://github.com/Antiz96/arch-update/blob/main/doc/man/fr/arch-update.1.scd).

### Fichier de configuration arch-update

Voir la [page de manuel arch-update.conf(5)](https://github.com/Antiz96/arch-update/blob/main/doc/man/fr/arch-update.conf.5.scd).

## Trucs et astuces

### L'applet systray ne démarre pas au démarrage du système

Assurez vous d'avoir suivi les instructions de [ce chapitre](#lapplet-systray).

Si l'applet systray ne démarre pas malgré tout, cela peut être le résultat d'une [situation de compétition](https://fr.wikipedia.org/wiki/Situation_de_comp%C3%A9tition).  
Pour éviter ceci, vous pouvez ajouter un léger délai au démarrage de l'applet systray en utilisant la commande `sleep` :

- Si vous avez utilisé `arch-update --tray --enable`, modifiez la ligne `Exec=` dans le fichier `arch-update-tray.desktop` (qui se trouve sous `~/.config/autostart/` par défaut), comme ceci :

```text
Exec=sh -c "sleep 3 && arch-update --tray"
```

- Si vous avez utilisé le service systemd `arch-update-tray.service`, exécutez `systemctl --user edit --full arch-update-tray.service` et modifiez la ligne `ExecStart=`, comme ceci :

```text
ExecStart=sh -c "sleep 3 && arch-update --tray"
```

- Si vous utilisez un gestionnaire de fenêtres ou un compositeur Wayland, modifiez la commande dans vos applications "auto-start" / vôtre fichier de configuration, comme ceci :

```text
sleep 3 && arch-update --tray
```

Si l'applet systray ne démarre toujours pas au démarrage du système, essayez de graduellement augmenter la valeur du `sleep`.

### Modifier le cycle de vérification

Si vous avez activé le [timer systemd](#le-timer-systemd), une vérification des mises à jour disponible est lancée au démarrage du système puis une fois par heure.

Si vous souhaitez personnaliser le cycle de vérification, exécutez la commande `systemctl --user edit --full arch-update.timer` et modifiez la valeur `OnUnitActiveSec` à votre convenance.  
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

### Lancer Arch-Update dans un émulateur de terminal spécifique

`gio` (utilisé pour lancer l'application `arch-update` dans un terminal via le fichier `arch-update.desktop` lorsque l'applet systray est cliquée) a actuellement une liste limitée d'émulateurs de terminal connus par défaut.  
Ainsi, si aucun de ces émulateurs de terminal "connus" n'est installé sur votre système, vous pourriez être confronté à un problème où le fait de cliquer sur l'applet du systray ne fait rien (car `gio` n'a pas pu trouver un émulateur de terminal dans la liste en question). Par ailleurs, vous pouvez avoir plusieurs émulateurs de terminal installés sur votre système. Dans les deux cas, vous pouvez spécifier l'émulateur de terminal à utiliser.

Pour ce faire, installez le paquet AUR [xdg-terminal-exec](https://aur.archlinux.org/packages/xdg-terminal-exec), créez le fichier `~/.config/xdg-terminals.list` et ajoutez-y le nom du fichier `.desktop` de l'émulateur de terminal de votre choix (par exemple `Alacritty.desktop`).  
Voir <https://github.com/Vladimir-csp/xdg-terminal-exec?tab=readme-ov-file#configuration> pour plus de détails.

## Contribuer

Voir le [guide de contribution](https://github.com/Antiz96/arch-update/blob/main/CONTRIBUTING.md).

## Licence

Arch-Update est sous [licence GPL-3.0](https://github.com/Antiz96/arch-update/blob/main/LICENSE) (ou toute version ultérieure de cette licence).
