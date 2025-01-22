arch-update(1) ["Arch-Update 3.6.1" ["Manuel de Arch-Update"]]

# NOM

Arch-Update - Un notificateur & applicateur de mises à jour pour Arch Linux qui vous assiste dans les tâches importantes d'avant / après mise à jour.

# SYNOPSIS

*arch-update* [OPTION]

# DESCRIPTION

Un notificateur & applicateur de mises à jour pour Arch Linux qui vous assiste dans les tâches importantes d'avant / après mise à jour.
Inclut une applet systray dynamique & cliquable pour une intégration facile avec n'importe quel environnement de bureau / gestionnaire de fenêtres.

Arch-Update est conçu pour suivre les étapes usuelles de maintenance du système, telles que décrites dans le Arch Wiki à https://wiki.archlinux.org/title/System_maintenance.

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

# OPTIONS

Si aucune option n'est passée, lance la série de fonctions adéquates pour effectuer une mise à jour complète et appropriée du système (peut également être déclenché en cliquant sur l'applet systray). 

*-c, --check*
	Vérifier les mises à jour disponibles. S'il y en a, envoie une notification de bureau et met à jour l'icône de l'applet systray.
	Pour exécuter l'option `--check` automatiquement et périodiquement, voir le chapitre *"Le timer systemd"* dans la section *"UTILISATION"* ci-dessous.

*-l, --list*
	Afficher la liste des mises à jour en attente.

*-d, --devel*
	Inclure les mises à jour des paquets de développement AUR.

*-n, --news*
	Afficher les dernières Arch news.
	Vous pouvez optionnellement spécifier le nombre d'Arch news a afficher en tant qu'argument, comme ceci : `arch-update --news 10`. La valeur par défaut est 5.

*-D, --debug*
	Afficher les traces de débogage.

*--gen-config*
	Générer un fichier de configurationi `arch-update.conf` par défaut / exemple (voir la page de manuel *arch-update.conf*(5) pour plus de détails).
	Vous pouvez optionnellement passer l'argument `--force` pour écraser un fichier de configuration `arch-update.conf` existant.

*--show-config*
	Afficher le contenu du fichier de configuration `arch-update.conf` (s'il existe).

*--edit-config*
	Editer le fichier de configuration `arch-update.conf` (s'il existe).

*--tray*
	Démarrer l'applet systray d'Arch-Update.
	Pour la démarrer automatiquement au démarrage du système, voir le chapitre *"L'applet systray"* dans la section *"UTILISATION"* ci dessous.

*-V, --version*
	Afficher les informations de version.

*-h, --help*
	Afficher le message d'aide.

Certaines options peuvent être activées, désactivées ou modifiées via le fichier de configuration `arch-update.conf`, voir la page de manuel *arch-update.conf*(5) pour plus de détails.

# UTILISATION

L'utilisation consiste à démarrer l'applet systray et à activer le timer systemd.

## L'applet systray

Pour démarrer l'applet systray, lancez l'application *Arch-Update Systray Applet* depuis votre menu d'application.

Pour la démarrer automatiquement au démarrage du système, utilisez l'une des options suivantes :

- Lancer la commande suivante (méthode recommandée pour la plupart des environnements de bureau, utilise XDG Autostart) : 

```
arch-update --tray --enable
```

- Activer le service systemd associé (dans le cas où votre environnement de bureau ne supporte pas XDG Autostart) : 

```
systemctl --user enable --now arch-update-tray.service
```

- Ajouter la commande suivante à vos applications "auto-start" / votre fichier de configuration (si vous utilisez un gestionnaire de fenêtre ou un compositeur Wayland) :

```
arch-update --tray
```

*Si l'applet systray ne démarre pas au démarrage du système malgré tout*, veuillez lire le chapitre *"L'applet systray ne démarre pas au démarrage du système"* dans la section *"TRUCS ET ASTUCES"* ci-dessous.

L'icône du systray change dynamiquement pour indiquer l'état actuel de votre système ("à jour" ou "mises à jour disponibles"). Lorsque vous cliquez dessus, elle lance `arch-update` dans une fenêtre de terminal via le fichier `arch-update.desktop`.

*Si cliquer sur l'applet systray ne fait rien*, veuillez lire le chapitre *"Lancer Arch-Update dans un émulateur de terminal spécifique"* dans la section *"TRUCS ET ASTUCES"* ci-dessous.

## Le timer systemd

Pour effectuer des vérifications automatiques et périodiques des mises à jour disponibles, activez le timer systemd associé :

```
systemctl --user enable --now arch-update.timer
```

Par défaut, une vérification est effectuée *au démarrage du système puis une fois toutes les heures*. Le cycle de vérification peut être personnalisé, voir le chapitre *"Modifier le cycle de vérification automatique"* dans la section *"TRUC ET ASTUCES"* ci-dessous.

# TRUCS ET ASTUCES

## L'applet systray ne démarre pas au démarrage du système

Assurez vous d'avoir suivi les instructions du chapitre *"L'applet systray"* dans la section *"UTILISATION"* ci-dessus.

Si l'applet systray ne démarre pas malgré tout, cela peut être due à une *situation de compétition*.
Pour éviter ceci, vous pouvez ajouter un léger délai au démarrage de l'applet systray en utilisant la commande `sleep` :

- Si vous avez utilisé `arch-update --tray --enable`, modifiez la ligne `Exec=` dans le fichier `arch-update-tray.desktop` (qui se trouve sous `~/.config/autostart/` par défaut), comme ceci :

```
[...]
Exec=sh -c "sleep 3 && arch-update --tray"
[...]
```

- Si vous avez utilisé le service systemd `arch-update-tray.service`, exécutez `systemctl --user edit --full arch-update-tray.service` et modifiez la ligne `ExecStart=`, comme ceci :

```
[...]
ExecStart=sh -c "sleep 3 && arch-update --tray"
[...]
```

- Si vous utilisez un gestionnaire de fenêtres ou un compositeur Wayland, modifiez la commande dans vos applications "auto-start" / vôtre fichier de configuration, comme ceci :

```
[...]
sleep 3 && arch-update --tray
[...]
```

Si l'applet systray ne démarre toujours pas au démarrage du système, essayez de graduellement augmenter la valeur du `sleep`.

## Modifier le cycle de vérification automatique

Si vous avez activé le timer systemd, une vérification des mises à jour disponible est lancée au démarrage du système puis une fois par heure.

Si vous souhaitez personnaliser le cycle de vérification, exécutez la commande `systemctl --user edit --full arch-update.timer` et modifiez la valeur `OnUnitActiveSec` à votre convenance.
Par exemple, si vous voulez qu'`Arch-Update` vérifie plutôt les mises à jour toutes les 10 minutes :"

```
[...]
[Timer]
OnStartupSec=15
OnUnitActiveSec=10m
[...]
```

Les unités de temps sont *s* pour secondes, *m* pour minutes, *h* pour heures, *d* pour jours...
Voir https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#Parsing%20Time%20Spans pour plus de détails.

Dans le cas où vous voulez qu'`Arch-Update` ne vérifie les nouvelles mises à jour qu'une fois au démarrage du système, vous pouvez simplement supprimer la ligne `OnUnitActiveSec` complètement.

## Lancer Arch-Update dans un émulateur de terminal spécifique

"gio" (utilisé pour lancer l'application `arch-update` dans un terminal via le fichier `arch-update.desktop` lorsque l'applet systray est cliquée) a actuellement une liste limitée d'émulateurs de terminal connus par défaut.  
Ainsi, si aucun de ces émulateurs de terminal "connus" n'est installé sur votre système, vous pourriez être confronté à un problème où le fait de cliquer sur l'applet du systray ne fait rien (car `gio` n'a pas pu trouver un émulateur de terminal dans la liste en question). Par ailleurs, vous pouvez avoir plusieurs émulateurs de terminal installés sur votre système. Dans les deux cas, vous pouvez spécifier l'émulateur de terminal à utiliser.

Pour ce faire, installez le paquet AUR `xdg-terminal-exec` (https://aur.archlinux.org/packages/xdg-terminal-exec), créez le fichier `~/.config/xdg-terminals.list` et ajoutez-y le nom du fichier `.desktop` de l'émulateur de terminal de votre choix (par exemple `Alacritty.desktop`).

Voir https://github.com/Vladimir-csp/xdg-terminal-exec?tab=readme-ov-file#configuration pour plus de détails.

# EXIT STATUS

*0*
	OK.

*1*
	Option invalide.

*2*
	Aucune commande d'élévation de privilège (`sudo`, `doas` ou `run0`) n'est installée ou celle définie dans le fichier de configuration `arch-update.conf` n'est pas disponible.

*3*
	Erreur lors du lancement de l'applet systray d'Arch-update.

*4*
	L'utilisateur n'a pas donné la confirmation de procéder.

*5*
	Erreur lors de la mise à jour des paquets.

*6*
	Erreur lors de l'appel de la commande reboot pour appliquer une mise à jour du noyau en attente.

*7*
	Aucune mise à jour en attente durant l'utilisation de l'option `-l/--list`.

*6*
	Erreur lors de la génération d'un fichier de configuration avec l'option `--gen-config`.

*9*
	Erreur lors de la lecture du fichier de configuration avec l'option `--show-config`.

*10*
	Erreur lors de la création du fichier desktop autostart pour l'applet systray avec l'option `--tray --enable`.

*11*
	Erreur lors du redémarrage des services nécessitant un redémarrage après mise à jour.

*12*
	Erreur lors du traitement des fichiers pacnew.

*13*
	Erreur lors de l'édition du fichier de configuration avec l'option `--edit-config`.

*14*
	Le dossier de librairies n'a pas été trouvé.

*15*
	L'éditeur "diff prog" défini dans le fichier de configuration `arch-update.conf` n'a pas été trouvé.

# VOIR AUSSI

*checkupdates*(8),
*pacman*(8),
*pacdiff*(8),
*paccache*(8),
*paru*(8),
*yay*(8),
*pikaur*(1),
*flatpak*(1),
*arch-update.conf*(5)

# BUGS

Signalez les bugs sur la page GitHub : https://github.com/Antiz96/arch-update/issues

# AUTHOR

Robin Candau <robincandau@protonmail.com>
