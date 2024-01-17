# Arch-Update

## Table des matières

- [Description](#description)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Documentation](#documentation)
- [Trucs et astuces](#trucs-et-astuces)
- [Contribuer](#contribuer)

## Description

Un notificateur/applicateur de mises à jour pour Arch Linux qui vous assiste dans les tâches importantes d'avant/après mise à jour et qui inclut une icône cliquable (.desktop) qui peut facilement être intégrée à n'importe quel environnement de bureau/gestionnaire de fenêtres, dock, barre d'état, barre de lancement ou menu d'application.  
Prise en charge optionnelle des mises à jour des paquets AUR/Flatpak et des notifications de bureau.

Fonctionnalités :

- Inclut une icône cliquable (.desktop) qui change automatiquement pour agir comme un notificateur/applicateur de mise à jour. Facile à intégrer avec n'importe quel DE/WM, dock, barre d'état/lancement, menu d'application, etc...
- Vérification et listing automatiques de tous les paquets disponibles pour la mise à jour (via [checkupdates](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "pacman-contrib package")).
- Propose d'afficher les news récentes d'Arch Linux avant d'appliquer les mises à jour (via [curl](https://archlinux.org/packages/core/x86_64/curl/ "curl package") et [htmlq] (https://archlinux.org/packages/extra/x86_64/htmlq/ "package htmlq")).
- Vérification et listing automatiques des paquets orphelins et vous propose de les supprimer.
- Vérification automatique des anciens paquets et/ou paquets désinstallés dans le cache de `pacman` et vous propose de les supprimer (via [paccache](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "package pacman-contrib")).
- Vous aide à traiter les fichiers pacnew/pacsave (via [pacdiff](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "pacman-contrib package"), nécessite optionnellement [vim](https:// archlinux.org/packages/extra/x86_64/vim/ "vim package") comme [programme de fusion par défaut](https://wiki.archlinux.org/title/Pacman/Pacnew_and_Pacsave#pacdiff "programme de fusion pacdiff")).
- Vérification automatique des mises à jour du noyau en attente nécessitant un redémarrage et propose de redémarrer s'il y en a une.
- Fonctionne avec [sudo](https://archlinux.org/packages/core/x86_64/sudo/ "sudo package") et [doas](https://archlinux.org/packages/extra/x86_64/opendoas/ "opendoas package").
- Prise en charge optionnelle de la mise à jour des paquets AUR (via [yay](https://aur.archlinux.org/packages/yay "yay AUR package") ou [paru](https://aur.archlinux.org/packages/paru "paru AUR package")).
- Prise en charge optionnelle de la mise à jour des paquets Flatpak (via [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak "Flatpak Package")).
- Prise en charge optionnelle des notifications de bureau (via [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify "libnotify package"), voir <https://wiki.archlinux.org/title/Desktop_notifications>) .

## Installation

### AUR

Installez le paquet AUR [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package").

### Depuis la source

Installer les dépendances :

```bash
sudo pacman -S --needed pacman-contrib curl htmlq diffutils
```

Téléchargez l'archive de la [dernière version stable](https://github.com/Antiz96/arch-update/releases/latest) et extrayez-la *(vous pouvez également cloner ce référentiel via `git`)*.

Pour installer `arch-update`, allez dans le répertoire extrait/cloné et exécutez la commande suivante :

```bash
sudo make install
```

Pour désinstaller `arch-update`, allez dans le répertoire extrait/cloné et exécutez la commande suivante :

```bash
sudo make uninstall
```

## Utilisation

L'utilisation consiste à intégrer [le fichier .desktop](#le-fichier-desktop) n'importe où (cela peut être votre bureau, votre dock, votre barre d'état/de lancement ou votre menu d'application) et à activer le [timer systemd](#le-timer-systemd).

Voici une petite présentation/revue YouTube de `arch-update` que [Cardiac](https://github.com/Cardiacman13) et moi-même avons réalisée sur [sa chaîne YouTube](https://www.youtube.com/@Cardiacman) :

*Attention : les fonctionnalités et le comportement par défaut d'Arch-Update peuvent avoir changé/évolué depuis !*

[![youtube_presentation](https://github.com/Antiz96/arch-update/assets/53110319/23af5180-1881-486d-bd5a-3edd48ed1a08)](https://www.youtube.com/watch?v=QkOkX70SEmo)

### Le fichier .desktop

Le fichier .desktop se trouve dans `/usr/share/applications/arch-update.desktop` (ou `/usr/local/share/applications/arch-update.desktop` si vous avez installé `arch-update` [depuis la source](#depuis-la-source)).  
Son icône changera automatiquement en fonction des différents états (vérification des mises à jour, mises à jour disponibles, installation des mises à jour, à jour).  
Il lancera la série de fonctions adéquates pour effectuer une mise à jour complète et correcte lorsque vous cliquez dessus (voir le chapitre [Documentation](#documentation)). Il est facile à intégrer à n’importe quel DE/WM, dock, barre d’état/lancement ou menu d’application.

### Le timer systemd

Il existe un service systemd dans `/usr/lib/systemd/user/arch-update.service` (ou dans `/usr/local/lib/systemd/user/arch-update.service` si vous avez installé `arch-update` [depuis la source](#depuis-la-source)) qui exécute la fonction `check` quand il est démarré (voir le chapitre [Documentation](#documentation)).  
Pour le démarrer automatiquement **au démarrage du système puis une fois toutes les heures**, activez le timer systemd associé (vous pouvez modifier le cycle de vérification automatique à votre guise, voir les [Trucs et astuces - Modifier le cycle de vérification automatique](#modifier-le-cycle-de-verification-automatique) :

```bash
systemctl --user enable --now arch-update.timer
```

### Capture d'écran

Personnellement, j'ai intégré l'icône .desktop dans ma barre supérieure.  
C'est la première icône en partant de la gauche.

![icon](https://github.com/Antiz96/arch-update/assets/53110319/25f3d2ca-b9d3-4a32-ace3-b0fa785662c2)

Lorsque `arch-update` vérifie les mises à jour, l'icône change en conséquence (la fonction `check` est automatiquement déclenchée au démarrage du système puis une fois toutes les heures si vous avez activé le [timer systemd](#le-timer-systemd) et peut être déclenchée manuellement en exécutant la commande `arch-update -c`) :

![icon-checking](https://github.com/Antiz96/arch-update/assets/53110319/f4c09898-7b21-430f-84be-431a31e25c3f)

Si de nouvelles mises à jour sont disponibles, l'icône affichera une cloche et une notification de bureau indiquant le nombre de mises à jour disponibles sera envoyée (nécessite [libnotify/notify-send](https://archlinux.org/packages/extra/x86_64/libnotify/ "paquet libnotify")) :

![icon-update-available](https://github.com/Antiz96/arch-update/assets/53110319/c1526ce7-5f94-41b8-a8fa-3587b9d00a9d)
![notification](https://github.com/Antiz96/arch-update/assets/53110319/631b8e67-487a-441a-84b4-6cce95223729)

Lorsque l'on clique sur l'icône, elle lance la série de fonctions adéquates pour effectuer une mise à jour complète et correcte, en commençant par actualiser la liste des packages disponibles pour les mises à jour, en l'affichant dans un terminal et en demandant la confirmation de l'utilisateur pour procéder à l'installation (elle peut également être lancée en exécutant la commande `arch-update`, nécessite [yay](https://aur.archlinux.org/packages/yay "yay") ou [paru](https://aur.archlinux.org/packages/paru "paru") pour la prise en charge de la mise à jour des paquets AUR et [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/) pour la prise en charge de la mise à jour des paquets Flatpak) :

*La sortie colorée peut être désactivée avec l'option `NoColor` dans le fichier de configuration `arch-update.conf`.*  
*Les changements de versions dans la listing des paquets peuvent être masqués avec l'option `NoVersion` dans le fichier de configuration `arch-update.conf`.*  
*Voir le [chapitre de documentation arch-update.conf](#fichier-de-configuration-arch-update) pour plus de détails.*

![listing-packages](https://github.com/Antiz96/arch-update/assets/53110319/43a990c8-ed93-420f-8c46-d50d60bff03f)

Une fois que vous avez donné la confirmation pour procéder, `arch-update` propose d'afficher les dernières Arch news.  
Les Arch news publiées au cours des 15 derniers jours sont étiquetées comme « [NEW] ».  
Sélectionnez la news à lire en tapant le numéro associé.  
Après avoir lu une news, `arch-update` vous proposera à nouveau d'afficher les dernières Arch news, afin que vous puissiez lire plusieurs news à la fois.  
Appuyez simplement sur « Entrée » sans saisir de chiffre pour procéder à la mise à jour :

*Le listing/affichage des Arch news peut être ignoré avec l'option `NoNews` dans le fichier de configuration `arch-update.conf`.*  
*Notez que l'utilisation de cette option générera un message d'avertissement pour rappeler que les utilisateurs sont censés consulter régulièrement les Arch news.*  
*Voir le [chapitre de documentation arch-update.conf](#fichier-de-configuration-arch-update) pour plus de détails.*

![list-news](https://github.com/Antiz96/arch-update/assets/53110319/b6883ec4-8c44-4b97-86d9-4d0a304b748b)

Pendant que `arch-update` effectue des mises à jour, l'icône change en conséquence :

![icon-installing](https://github.com/Antiz96/arch-update/assets/53110319/7c74ce84-7de4-4e09-aa2a-66afad9e61d7)

Une fois la mise à jour terminée, l'icône change en conséquence :

![icon-up-to-date](https://github.com/Antiz96/arch-update/assets/53110319/03f224a5-5fcf-450d-9aa5-bae90e7d2e8a)

`arch-update` recherchera ensuite les paquets orphelins/paquets Flatpak inutilisés et proposera de les supprimer (s'il y en a) :

![paquets-orphelins](https://github.com/Antiz96/arch-update/assets/53110319/76b795e5-076e-4070-9fe2-73165503011b)

![flatpak-unused-packages](https://github.com/Antiz96/arch-update/assets/53110319/cd4053bb-623e-44c2-8c74-9f87710f4074)

`arch-update` recherchera également les anciens paquets et/ou paquets désinstallés mis en cache et proposera de les supprimer (s'il y en a) :

*Le comportement par défaut consiste à conserver les 3 dernières versions en cache des paquets installés et à supprimer toutes les versions en cache des paquets désinstallés.*  
*Vous pouvez modifier le nombre d'anciennes versions de paquets et de versions de paquets désinstallés à conserver respectivement dans le cache de pacman avec les options `KeepOldPackages=Num` et `KeepUninstalledPackages=Num` dans le fichier de configuration `arch-update.conf`.*  
*Voir le [chapitre de documentation arch-update.conf](#fichier-de-configuration-arch-update) pour plus de détails.*

![cached-packages](https://github.com/Antiz96/arch-update/assets/53110319/7199bbf1-acd8-49a1-80eb-e9874b94fba6)

De plus, `arch-update` recherchera les fichiers pacnew/pacsave et proposera de les traiter via `pacdiff` (s'il y en a) :

![pacnew-files](https://github.com/Antiz96/arch-update/assets/53110319/5ee627ee-f7b7-4528-bf41-435d3c5892ac)

Enfin, `arch-update` vérifiera s'il y a une mise à jour du noyau en attente nécessitant un redémarrage et vous proposera de le faire (s'il y en a une) :

![kernel-pending-update](https://github.com/Antiz96/arch-update/assets/53110319/14aef5b2-db32-4296-8a60-bc840c09d457)

## Documentation

### arch-update

```text
Un notificateur/applicateur de mises à jour pour Arch Linux qui vous assiste dans les
tâches importantes d'avant/après mise à jour.

Lancez arch-update pour exécuter la fonction principale « update » :
Afficher la liste des paquets disponibles pour mise à jour, puis demandez la confirmation de l'utilisateur
pour procéder à l'installation.
Avant d'effectuer la mise à jour, propose d'afficher les dernières Arch news.
Après la mise à jour, vérification de la présence de paquets orphelins/inutilisés, d'anciens paquets mis en cache, de fichiers pacnew/pacsave
et de mise à jour du noyau en attente et, s'il y en a, propose de les traiter.

Options :
-c, --check    Vérifier les mises à jour disponibles, envoyer une notification de bureau contenant le nombre de mises à jour disponibles (si libnotify est installé)
-h, --help     Afficher ce message et quitter
-V, --version  Afficher les informations de version et quitter

Codes de sortie :
0  OK
1  Option invalide
2  Aucune méthode d'élévation de privilège (sudo ou doas) n'est installée
3  Erreur lors du changement d'icône
4  L'utilisateur n'a pas donné la confirmation de procéder
5  Erreur lors de la mise à jour des paquets
6  Erreur lors de l'appel de la commande reboot pour appliquer une mise à jour du noyau en attente
```

Pour plus d'informations, consultez la page de manuel arch-update(1).  
Certaines options peuvent être activées/désactivées ou modifiées via le fichier de configuration arch-update.conf, voir la page de manuel arch-update.conf(5).

### fichier de configuration arch-update

```text
Le fichier arch-update.conf est un fichier de configuration facultatif pour arch-update permettant d'activer/désactiver
ou modifier certaines options dans le script.

Ce fichier de configuration doit se trouver dans "${XDG_CONFIG_HOME}/arch-update/arch-update.conf"
ou "${HOME}/.config/arch-update/arch-update.conf".

Les options prises en charge sont :

- NoColor # Ne pas coloriser la sortie.
- NoVersion # Ne pas afficher les modifications de versions des paquets lors du listing des mises à jour en attente.
- NoNews # Ne pas afficher les Arch news. Notez que l'utilisation de cette option générera un message d'avertissement pour rappeler que les utilisateurs sont censés consulter régulièrement les Arch news.
- KeepOldPackages=Num # Nombre d'anciennes versions de paquets à conserver dans le cache de pacman. La valeur par défaut est 3.
- KeepUninstalledPackages=Num # Nombre de versions de paquets désinstallés à conserver dans le cache de pacman. La valeur par défaut est 0.

Les options sont sensibles à la casse, les majuscules doivent donc être respectées.
```

Pour plus d'informations, consultez la page de manuel arch-update(5).

## Trucs et astuces

### Prise en charge du AUR

Arch-Update prend en charge la mise à jour des paquets AUR lors de la vérification et de l'installation des mises à jour si **yay** ou **paru** est installé :  
Voir <https://github.com/Jguer/yay> et <https://aur.archlinux.org/packages/yay>  
Voir <https://github.com/morganamilo/paru> et <https://aur.archlinux.org/packages/paru>

### Prise en charge de Flatpak

Arch-Update prend en charge la mise à jour des paquets Flatpak lors de la vérification et de l'installation des mises à jour (ainsi que de la suppression des packages Flatpak inutilisés) si **flatpak** est installé :  
Voir <https://www.flatpak.org/> et <https://archlinux.org/packages/extra/x86_64/flatpak/>

### Notifications de bureau

Arch-Update prend en charge les notifications de bureau lors de l'exécution de la fonction `--check` si **libnotify (notify-send)** est installé :  
Voir <https://wiki.archlinux.org/title/Desktop_notifications>

### Modifier le cycle de vérification automatique

Si vous avez activé le [timer systemd](#le-timer-systemd), l'option `--check` est automatiquement lancée au démarrage du système puis une fois par heure.

Si vous souhaitez modifier le cycle de vérification, exécutez `systemctl --user edit arch-update.timer` pour créer une configuration de remplacement pour le timer et saisissez ce qui suit :

```text
[Timer]
OnUnitActiveSec=
OnUnitActiveSec=10m
```

Les unités de temps sont `s` pour les secondes, `m` pour les minutes, `h` pour les heures, `d` pour les jours...  
Voir <https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#Parsing%20Time%20Spans> pour plus de détails.

## Contribuer

Vous pouvez soulever vos problèmes, commentaires et suggestions dans l'onglet [Issues](https://github.com/Antiz96/arch-update/issues).  
Les [Pull requests](https://github.com/Antiz96/arch-update/pulls) sont également les bienvenues !
