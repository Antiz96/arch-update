arch-update(1) - v3.5.0

# NOM

Arch-Update - Un notificateur & applicateur de mises à jour pour Arch Linux qui vous assiste dans les tâches importantes d'avant / après mise à jour.

# SYNOPSIS

*arch-update* [OPTION]

# DESCRIPTION

Un notificateur & applicateur de mises à jour pour Arch Linux qui vous assiste dans les tâches importantes d'avant / après mise à jour et qui inclut une applet systray cliquable pour une intégration facile avec n'importe quel panneau sur n'importe quel environnement de bureau ou gestionnaire de fenêtres.

Support optionnel pour:

- Les paquets AUR (via `paru`, `yay` ou `pikaur`)
- Les paquets Flatpak (via `flatpak`).
- Les notifications de bureau (via `libnotify`).

Arch-Update est conçu pour suivre les étapes usuelles de maintenance du système, telles que décrites dans le Arch Wiki à https://wiki.archlinux.org/title/System_maintenance.

# OPTIONS

Si aucune option n'est passée, lance la série de fonctions adéquates pour effectuer une mise à jour complète et correcte, en commençant par afficher la liste des paquets disponibles pour la mise à jour et en demandant la confirmation de l'utilisateur pour procéder à l'installation.

Arch-Update supporte les mises à jour des paquets AUR (si `paru`, `yay` ou `pikaur` est installé) et des paquets Flatpak (si `flatpak` est installé).

Avant d'effectuer la mise à jour, Arch-Update propose d'afficher les dernières Arch news à l'utilisateur. Par défaut, les Arch news sont seulement affichées si au moins une nouvelle news a été publiée depuis la dernière exécution. Les Arch news publiées depuis la dernière exécution ou à la même date sont étiquetées comme *[NOUVEAU]*.

Arch-Update vérifie aussi la présence de paquets orphelins, des paquets Flatpak inutilisés, ainsi que des anciens paquets mis en cache par pacman. Il propose également de traiter les fichiers pacnew & pacsave, les mises à jour du noyau en attente ainsi que les services nécessitant un redémarrage après mise à jour.

Ces fonctions sont lancées quand vous cliquez sur l'applet systray.

*`-c`, `--check`*
	Vérifier les mises à jour disponibles. S'il y en a, envoie une notification de bureau et met à jour l'icône de l'applet systray.
	L'option `--check` est automatiquement lancée au démarrage du système puis une fois chaque heure si vous avez activé le systemd timer associé avec la commande suivante : `systemctl --user enable --now arch-update.timer`.

*`-l`, `--list`*
	Afficher la liste des mises à jour en attente.

*`-d`, `--devel`*
	Inclure les mises à jour des paquets de développement AUR.

*`-n`, `--news`*
	Afficher les dernières Arch news.
	Vous pouvez optionnellement spécifier le nombre d'Arch news a afficher en tant qu'argument, comme ceci : `arch-update --news 10`. La valeur par défaut est 5.

*`-D`, `--debug`*
	Afficher les traces de débogage.

*`--gen-config`*
	Générer un fichier de configurationi `arch-update.conf` par défaut / exemple (voir la page de manuel *arch-update.conf(5)* pour plus de détails).
	Vous pouvez optionnellement passer l'argument `--force` pour écraser un fichier de configuration `arch-update.conf` existant.

*`--show-config`*
	Afficher le contenu du fichier de configuration `arch-update.conf` (s'il existe).

*`--edit-config`*
	Editer le fichier de configuration `arch-update.conf` (s'il existe).

*`--tray`*
	Démarrer l'applet systray d'Arch-Update.
	Pour la démarrer automatiquement au démarrage du système, vous pouvez soit exécuter la commande `arch-update --tray --enable` _(méthode recommandée pour la plupart des environnements de bureau, utilise XDG Autostart)_ ou vous pouvez activer le service systemd associé _(dans le cas où vôtre environnement de bureau ne supporte pas XDG Autostart)_ en exécutant `systemctl --user enable --now arch-update-tray.service`.
	Si vous utilisez un gestionnaire de fenêtres ou un compositeur Wayland, vous pouvez plutôt ajouter la commande `arch-update --tray` à vos applications auto-start dans votre fichier de configuration.

*`-V`, `--version`*
	Afficher les informations de version.

*-h, --help*
	Afficher le message d'aide.

Certaines options peuvent être activées, désactivées ou modifiées via le fichier de configuration `arch-update.conf`, voir la page de manuel *arch-update.conf(5)* pour plus de détails.

# UTILISATION

## L'applet systray

Pour démarrer l'applet systray, lancez l'application *Arch-Update Systray Applet* depuis votre menu d'application.

Pour la démarrer automatiquement au démarrage du système, utilisez l'une des options suivantes :

- Lancer la commande suivante _(méthode recommandée pour la plupart des environnements de bureau, utilise XDG Autostart)_ : `arch-update --tray --enable`

- Activer le service systemd associé _(dans le cas où votre environnement de bureau ne supporte pas XDG Autostart)_ : `systemctl --user enable --now arch-update-tray.service`

Si vous utilisez un gestionnaire de fenêtre ou un compositeur Wayland, vous pouvez plutôt ajouter la commande `arch-update --tray` à vos applications auto-start dans votre fichier de configuration.

Si l'applet systray ne démarre pas au démarrage du système malgré tout, veuillez lire le chapitre *"l'applet systray ne démarre pas au démarrage du système"* dans la section *"Trucs et Astuces"* ci-dessous.

L'icône du systray changera automatiquement en fonction de l'état actuel de votre système ("à jour" ou "mises à jour disponibles"). Lorsque vous cliquez dessus, elle lance `arch-update` via le fichier `arch-update.desktop`.

L'applet systray essaie de lire le fichier `arch-update.desktop` dans les chemins ci-dessous avec l'ordre suivant :

- `$XDG_DATA_HOME/applications/arch-update.desktop`

- `$HOME/.local/share/applications/arch-update.desktop`

- `$XDG_DATA_DIRS/applications/arch-update.desktop`

- `/usr/local/share/applications/arch-update.desktop` _<-- Chemin d'installation par défaut lorsque vous installez Arch-Update depuis la source_

- `/usr/share/applications/arch-update.desktop` _<-- Chemin d'installation par défaut lorsque vous installez Arch-Update depuis le AUR_

Dans le cas où vous avez envie (ou besoin) de personnaliser le fichier `arch-update.desktop`, copiez le dans un chemin qui a une priorité plus élevée que le chemin d'installation par défaut et modifiez le ici (afin d'assurer que votre ficher `arch-update.desktop` personnalisé remplace celui par défaut et que vos modifications ne soient pas écrasées à chaque mise à jour).
Cela peut être utile pour forcer le fichier `arch-update.desktop` à lancer `Arch-Update` dans un émulateur de terminal spécifique par exemple.

Si cliquer sur l'applet systray ne fait rien, veuillez lire le chapitre *"Forcer le fichier desktop à se lancer avec un émulateur de terminal spécifique"* dans la section *"Trucs et Astuces"* ci-dessous.

## Le timer systemd

Il existe un service systemd dans `/usr/lib/systemd/user/arch-update.service` _(ou dans `/usr/local/lib/systemd/user/arch-update.service` si vous avez installé `arch-update` depuis la source)_ qui exécute la fonction `--check` quand il est démarré. Pour le démarrer automatiquement au démarrage du système puis une fois toutes les heures, activez le timer systemd associé (vous pouvez modifier le cycle de vérification automatique à votre guise, voir le chapitre *"TRUCS ET ASTUCES"* ci-dessous) : `systemctl --user enable --now arch-update.timer`

# TRUCS ET ASTUCES

## Prise en charge du AUR

Arch-Update prend en charge les paquets AUR si `paru`, `yay` ou `pikaur` est installé:
Voir https://github.com/morganamilo/paru et https://aur.archlinux.org/packages/paru
Voir https://github.com/Jguer/yay et https://aur.archlinux.org/packages/yay
Voir https://github.com/actionless/pikaur et https://aur.archlinux.org/packages/pikaur

## Prise en charge de Flatpak

Arch-Update prend en charge les paquets Flatpak si `flatpak` est installé:
Voir https://www.flatpak.org/ et https://archlinux.org/packages/extra/x86_64/flatpak/

## Notifications de bureau

Arch-Update prend en charge les notifications de bureau lors de l'exécution de la fonction `--check` si `libnotify` est installé.
Voir https://wiki.archlinux.org/title/Desktop_notifications

## L'applet systray ne démarre pas au démarrage du système

Assurez vous d'avoir suivi les instructions du chapitre *"l'applet systray"* dans la section *"Utilisation"* ci-dessus.

Si l'applet systray ne démarre pas malgré tout, cela peut être due à une *situation de compétition*.
Dans ce cas, il peut être utile de légèrement retarder le démarrage de l'applet systray en utilisant une déclaration `sleep` au préalable :

- Si vous avez utilisé `arch-update --tray --enable`, modifiez la ligne `Exec=` dans le fichier `arch-update-tray.desktop` (qui se trouve sous `~/.config/autostart/` par défaut), comme ceci : `Exec=sh -c "sleep 3 && arch-update --tray"`

- Si vous avez utilisé le service systemd `arch-update-tray.service`, exécutez `systemctl --user edit --full arch-update-tray.service` et modifiez la ligne `ExecStart=`, comme ceci : `ExecStart=sh -c "sleep 3 && arch-update --tray"`

- Si vous utilisez un gestionnaire de fenêtres ou un compositeur Wayland, ajoutez une déclaration `sleep` avant la commande `arch-update --tray` à vos applications auto-start dans votre fichier de configuration, comme ceci : `sleep 3 && arch-update --tray`

Si l'applet systray ne démarre toujours au démarrage du système, essayez de graduellement augmenter la valeur du `sleep`.

## Modifier le cycle de vérification automatique

Si vous avez activé le systemd timer, l'option `--check` est automatiquement lancée au démarrage du système puis une fois par heure.

Si vous souhaitez modifier le cycle de vérification, exécutez la commande `systemctl --user edit --full arch-update.timer` et modifiez la valeur `OnUnitActiveSec` à votre convenance.
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

## Forcer le fichier desktop à se lancer avec un émulateur de terminal spécifique

"gio" (qui est utilisé pour lancer le fichier `arch-update.desktop` quand l'applet systray est cliquée) ne supporte actuellement qu'une liste limitée d'émulateurs de terminal (voir https://gitlab.gnome.org/GNOME/glib/-/blob/main/gio/gdesktopappinfo.c#L2701).

Si vous n'avez aucun de ces émulateurs de terminal installé sur votre système, il se peut que vous soyez confronté à un problème où cliquer sur l'applet systray ne fait rien et rapporte l'erreur suivante : "[...] Unable to find terminal required for application".

En attendant que Gnome implémente une méthode permettant aux utilisateurs d'utiliser l'émulateur de terminal de leur choix avec `gio`,vous pouvez contourner le problème en copiant le fichier `arch-update.desktop` dans `$HOME/.local/share/applications/arch-update.desktop` (par exemple, voir le chapitre *"L'applet systray"* pour plus de détails) et en modifiant la ligne `Exec=` pour 'forcer' `arch-update` à s'exécuter dans l'émulateur de terminal de votre choix.

Par exemple, avec `alacritty` _(vérifier le manuel de votre émulateur de terminal pour trouver la bonne option à utiliser)_:

```
[...]
Exec=alacritty -e arch-update
```

Alternativement, vous pouvez créer un lien symbolique de votre émulateur de terminal pointant vers `/usr/bin/xterm`, qui est l'option de 'secours' pour `gio` (par exemple, avec `alacritty` : `sudo ln -s /usr/bin/alacritty /usr/bin/xterm`) ou vous pouvez simplement installer un des émulateurs de terminal supportés par `gio` (voir https://gitlab.gnome.org/GNOME/glib/-/blob/main/gio/gdesktopappinfo.c#L2701).

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
	Erreur lors de l'édition du fichier de configuration avec l'optionu `--edit-config`.

*14*
	Le dossier de librairies n'a pas été trouvé.

*15*
	L'éditeur "diff prog" défini dans le fichier de configuration `arch-update.conf` n'a pas été trouvé.

# VOIR AUSSI

*checkupdates (8)*
*pacman (8)*
*pacdiff (8)*
*paccache (8)*
*paru (8)*
*yay (8)*
*pikaur (1)*
*flatpak (1)*
*arch-update.conf (5)*

# BUGS

Signalez les bugs sur la page GitHub : https://github.com/Antiz96/arch-update/issues

# AUTHOR

Robin Candau <robincandau@protonmail.com>
