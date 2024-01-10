# Arch-Mise à jour

## Table des matières

- [Description](#description)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Documentation](#documentation)
- [Trucs et astuces](#trucs-et-astuces)
- [Contribuer](#contribuer)

## Description

Un notificateur/applicateur de mises à jour pour Arch Linux qui vous aide dans les tâches importantes de pré/post-mise à jour et qui comprend une icône cliquable (.desktop) qui peut facilement être intégrée à n'importe quel Environnement de Bureau/Manager de fenêtres, dock, barre d'état/lancement ou menu d'application.
Prise en charge facultative des mises à jour des packages AUR/Flatpak et des notifications sur le bureau.

Caractéristiques:

- Inclut une icône cliquable (.desktop) qui change automatiquement pour agir comme un notificateur/applicateur de mise à jour. Facile à intégrer avec n'importe quel DE/WM, dock, barre d'état/lancement, menu d'application, etc...
- Vérification et liste automatiques de tous les packages disponibles pour la mise à jour (via [checkupdates](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "pacman-contrib package")).
- Propose d'imprimer les dernières nouvelles d'Arch Linux avant d'appliquer les mises à jour (via [curl](https://archlinux.org/packages/core/x86_64/curl/ "curl package") et [htmlq] (https://archlinux. org/packages/extra/x86_64/htmlq/ "package htmlq")).
- Vérification et listage automatique des packages orphelins et vous proposant de les supprimer.
- Vérification automatique des paquets anciens et/ou désinstallés dans le cache de `pacman` et vous proposant de les supprimer (via [paccache](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "pacman -paquet de contribution")).
- Vous aide à traiter les fichiers pacnew/pacsave (via [pacdiff](https://archlinux.org/packages/extra/x86_64/pacman-contrib/ "pacman-contrib package"), nécessite éventuellement [vim](https:// archlinux.org/packages/extra/x86_64/vim/ "vim package") comme [programme de fusion] par défaut (https://wiki.archlinux.org/title/Pacman/Pacnew_and_Pacsave#pacdiff "programme de fusion pacdiff")).
- Vérification automatique des mises à jour du noyau en attente nécessitant un redémarrage et propose de le faire s'il y en a un.
- Prise en charge de [sudo](https://archlinux.org/packages/core/x86_64/sudo/ "sudo package") et de [doas](https://archlinux.org/packages/extra/x86_64/opendoas/ "paquet opendoas").
- Prise en charge facultative de la mise à jour des packages AUR (via [yay](https://aur.archlinux.org/packages/yay "yay AUR package") ou [paru](https://aur.archlinux.org/packages/paru "paquet paru AUR")).
- Prise en charge facultative de la mise à jour des packages Flatpak (via [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak "Package Flatpak")).
- Prise en charge facultative des notifications de bureau (via [libnotify](https://archlinux.org/packages/extra/x86_64/libnotify "libnotify package"), voir <https://wiki.archlinux.org/title/Desktop_notifications>) .

##Installation

### AUR

Installez le package AUR [arch-update](https://aur.archlinux.org/packages/arch-update "arch-update AUR package").

### Depuis les fichiers sources

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
sudo make désinstaller
```

## Utilisation

L'utilisation consiste à intégrer [le fichier .desktop](#the-desktop-file) n'importe où (cela peut être votre bureau, votre dock, votre barre d'état/de lancement et/ou le menu de votre application) et à activer le [timer systemd](# le-systemd-timer).

Voici une petite présentation/revue YouTube de `arch-update` que [Cardiac](https://github.com/Cardiacman13) et moi avons réalisée sur [sa chaîne YouTube](https://www.youtube.com/@ Cardiacman) (**les vidéos là-bas, dont celle-ci, sont en français**) :

*Attention : les fonctionnalités et le comportement par défaut d'Arch-Update peuvent avoir changé/évolué depuis !*

[![youtube_presentation](https://github.com/Antiz96/arch-update/assets/53110319/23af5180-1881-486d-bd5a-3edd48ed1a08)](https://www.youtube.com/watch?v= QkOkX70SEmo)

### Le fichier .desktop

Le fichier .desktop se trouve dans `/usr/share/applications/arch-update.desktop` (ou `/usr/local/share/applications/arch-update.desktop` si vous avez installé `arch-update` [à partir des sources ](#from-source)).
Son icône changera automatiquement en fonction des différents états (vérification des mises à jour, mises à jour disponibles, installation des mises à jour, à jour).
Il lancera la série de fonctions pertinentes pour effectuer une mise à jour complète et appropriée lorsque vous cliquez dessus (voir le chapitre [Documentation](#documentation)). Il est facile à intégrer à n’importe quel DE/WM, dock, barre d’état/lancement ou menu d’application.

### Le minuteur système

Il existe un service systemd dans `/usr/lib/systemd/user/arch-update.service` (ou dans `/usr/local/lib/systemd/user/arch-update.service` si vous avez installé `arch-update ` [from source](#from-source)) qui exécute la fonction `check` au démarrage (voir le chapitre [Documentation](#documentation)).
Pour le démarrer automatiquement **au démarrage puis une fois toutes les heures**, activez le timer systemd associé (vous pouvez modifier le cycle de vérification automatique à votre guise, voir les [Trucs et astuces - Modifier le cycle de vérification automatique](# chapitre modifier le cycle de vérification automatique) :

```bash
systemctl --user activer --now arch-update.timer
```

### Capture d'écran

Personnellement, j'ai intégré l'icône .desktop dans ma barre supérieure.
C'est la première icône en partant de la gauche.

![icône](https://github.com/Antiz96/arch-update/assets/53110319/25f3d2ca-b9d3-4a32-ace3-b0fa785662c2)

Lorsque `arch-update` vérifie les mises à jour, l'icône change en conséquence (la fonction `check` est automatiquement déclenchée au démarrage puis une fois toutes les heures si vous avez activé le [systemd timer](#the-systemd-timer) et peut être déclenché manuellement en exécutant la commande `arch-update -c`) :

![vérification des icônes](https://github.com/Antiz96/arch-update/assets/53110319/f4c09898-7b21-430f-84be-431a31e25c3f)

Si de nouvelles mises à jour sont disponibles, l'icône affichera une cloche et une notification sur le bureau indiquant le nombre de mises à jour disponibles sera envoyée (nécessite [libnotify/notify-send](https://archlinux.org/packages/extra/x86_64 /libnotify/ "paquet libnotify")) :

![icône-mise à jour-disponible](https://github.com/Antiz96/arch-update/assets/53110319/c1526ce7-5f94-41b8-a8fa-3587b9d00a9d)
![notification](https://github.com/Antiz96/arch-update/assets/53110319/631b8e67-487a-441a-84b4-6cce95223729)

Lorsque l'on clique sur l'icône, elle lance la série de fonctions correspondantes pour effectuer une mise à jour complète et appropriée, en commençant par actualiser la liste des packages disponibles pour les mises à jour, en l'imprimant dans une fenêtre de terminal et en demandant la confirmation de l'utilisateur pour procéder à l'installation (il peut également être lancé en exécutant la commande `arch-update`, nécessite [yay](https://aur.archlinux.org/packages/yay "yay") ou [paru](https://aur.archlinux.org /packages/paru "paru") pour la prise en charge de la mise à jour des packages AUR et [flatpak](https://archlinux.org/packages/extra/x86_64/flatpak/) pour la prise en charge de la mise à jour des packages Flatpak) :

*La sortie colorée peut être désactivée avec l'option `NoColor` dans le fichier de configuration `arch-update.conf`.*
*Les changements de versions dans la liste des packages peuvent être masqués avec l'option `NoVersion` dans le fichier de configuration `arch-update.conf`.*
*Voir le [chapitre de documentation arch-update.conf](#arch-update-configuration-file) pour plus de détails.*

![listing-packages](https://github.com/Antiz96/arch-update/assets/53110319/43a990c8-ed93-420f-8c46-d50d60bff03f)

Une fois que vous avez donné la confirmation pour continuer, `arch-update` propose d'imprimer les dernières nouvelles d'Arch Linux.
Les actualités arch publiées au cours des 15 derniers jours sont étiquetées comme « [NOUVEAU] ».
Sélectionnez les actualités à lire en tapant son numéro associé.
Après avoir lu une actualité, « arch-update » vous proposera à nouveau d'imprimer les dernières actualités Arch Linux, afin que vous puissiez lire plusieurs actualités à la fois.
Appuyez simplement sur « Entrée » sans saisir de chiffre pour procéder à la mise à jour :

*La liste/impression des actualités Arch peut être ignorée avec l'option `NoNews` dans le fichier de configuration `arch-update.conf`.*
*Notez que l'utilisation de cette option générera un message d'avertissement pour rappeler que les utilisateurs sont censés consulter régulièrement les actualités d'Arch.*
*Voir le [chapitre de documentation arch-update.conf](#arch-update-configuration-file) pour plus de détails.*

![liste-nouvelles](https://github.com/Antiz96/arch-update/assets/53110319/b6883ec4-8c44-4b97-86d9-4d0a304b748b)

Pendant que `arch-update` effectue des mises à jour, l'icône change en conséquence :

![installation d'icônes](https://github.com/Antiz96/arch-update/assets/53110319/7c74ce84-7de4-4e09-aa2a-66afad9e61d7)

Une fois la mise à jour terminée, l'icône change en conséquence :

![icône-à-date](https://github.com/Antiz96/arch-update/assets/53110319/03f224a5-5fcf-450d-9aa5-bae90e7d2e8a)

`arch-update` recherchera ensuite les packages orphelins/packages Flatpak inutilisés et proposera de les supprimer (s'il y en a) :

![paquets-orphelins](https://github.com/Antiz96/arch-update/assets/53110319/76b795e5-076e-4070-9fe2-73165503011b)

![flatpak-unused-packages](https://github.com/Antiz96/arch-update/assets/53110319/cd4053bb-623e-44c2-8c74-9f87710f4074)

`arch-update` recherchera également les packages mis en cache anciens et/ou désinstallés et proposera de les supprimer (le cas échéant) :

*Le comportement par défaut consiste à conserver les 3 dernières versions en cache des packages installés et à supprimer toutes les versions en cache des packages désinstallés.*
*Vous pouvez modifier le nombre d'anciennes versions de packages et de versions de packages désinstallés à conserver respectivement dans le cache de pacman avec les options `KeepOldPackages=Num` et `KeepUninstalledPackages=Num` dans le fichier de configuration `arch-update.conf`.*
*Voir le [chapitre de documentation arch-update.conf](#arch-update-configuration-file) pour plus de détails.*

![paquets-cachés](https://github.com/Antiz96/arch-update/assets/53110319/7199bbf1-acd8-49a1-80eb-e9874b94fba6)

De plus, `arch-update` recherchera les fichiers pacnew/pacsave et proposera de les traiter via `pacdiff` (s'il y en a) :

![pacnew-files](https://github.com/Antiz96/arch-update/assets/53110319/5ee627ee-f7b7-4528-bf41-435d3c5892ac)

Enfin, `arch-update` vérifiera s'il y a une mise à jour du noyau en attente nécessitant un redémarrage et vous proposera de le faire (s'il y en a) :

![kernel-ending-update](https://github.com/Antiz96/arch-update/assets/53110319/14aef5b2-db32-4296-8a60-bc840c09d457)

## Documentation

### arch-mise à jour

```texte
Un notificateur/applicateur de mises à jour pour Arch Linux qui vous aide à
tâches importantes avant/après la mise à jour.

Exécutez arch-update pour exécuter la fonction principale « mettre à jour » :
Imprimez la liste des packages disponibles en mise à jour, puis demandez la confirmation de l'utilisateur
pour procéder à l'installation.
Avant d'effectuer la mise à jour, proposez d'imprimer les dernières actualités d'Arch Linux.
Publier la mise à jour, vérifier les packages orphelins/inutilisés, les anciens packages mis en cache, les fichiers pacnew/pacsave
et en attente de mises à jour du noyau et, le cas échéant, propose de les traiter.

Possibilités :
-c, --check Vérifier les mises à jour disponibles, envoyer une notification sur le bureau contenant le nombre de mises à jour disponibles (si libnotify est installé)
-h, --help Afficher ce message et quitter
-V, --version Afficher les informations de version et quitter

Codes de sortie :
0 bien
1 option invalide
2 Aucune méthode de privilège (sudo ou doas) n'est installée
3 Erreur lors du changement d'icône
4 L'utilisateur n'a pas donné la confirmation pour continuer
5 Erreur lors de la mise à jour des packages
6 Erreur lors de l'appel de la commande reboot pour appliquer une mise à jour du noyau en attente
```

Pour plus d'informations, consultez la page de manuel arch-update(1).
Certaines options peuvent être activées/désactivées ou modifiées via le fichier de configuration arch-update.conf, voir la page de manuel arch-update.conf(5).

### fichier de configuration de la mise à jour arch

```texte
Le fichier arch-update.conf est un fichier de configuration facultatif permettant à arch-update d'activer/désactiver
ou modifier certaines options dans le script.

Ce fichier de configuration doit se trouver dans "${XDG_CONFIG_HOME}/arch-update/arch-update.conf"
ou "${HOME}/.config/arch-update/arch-update.conf".

Les options prises en charge sont :

- NoColor # Ne colorise pas la sortie.
- NoVersion # N'affiche pas les modifications de versions des packages lors de la liste des mises à jour en attente.
- NoNews # N'imprime pas les nouvelles d'Arch. Notez que l'utilisation de cette option générera un message d'avertissement pour rappeler que les utilisateurs sont censés consulter régulièrement les actualités d'Arch.
- KeepOldPackages=Num # Nombre d'anciennes versions de packages à conserver dans le cache de pacman. La valeur par défaut est 3.
- KeepUninstalledPackages=Num # Nombre de versions de packages désinstallés à conserver dans le cache de pacman. La valeur par défaut est 0.

Les options sont sensibles à la casse, les majuscules doivent donc être respectées.
```

Pour plus d'informations, consultez la page de manuel arch-update(5).

## Trucs et astuces

### Prise en charge AUR

Arch-Update prend en charge la mise à jour des packages AUR lors de la vérification et de l'installation des mises à jour si **yay** ou **paru** est installé :
Voir <https://github.com/Jguer/yay> et <https://aur.archlinux.org/packages/yay>
Voir <https://github.com/morganamilo/paru> et <https://aur.archlinux.org/packages/paru>

### Prise en charge des Flatpaks

Arch-Update prend en charge la mise à jour des packages Flatpak lors de la vérification et de l'installation des mises à jour (ainsi que de la suppression des packages Flatpak inutilisés) si **flatpak** est installé :
Voir <https://www.flatpak.org/> et <https://archlinux.org/packages/extra/x86_64/flatpak/>

### Notifications sur le bureau

Arch-Update prend en charge les notifications du bureau lors de l'exécution de la fonction `--check` si **libnotify (notify-send)** est installé :
Voir <https://wiki.archlinux.org/title/Desktop_notifications>

### Modifier le cycle de vérification automatique

Si vous avez activé le [systemd.timer](#the-systemd-timer), l'option `--check` est automatiquement lancée au démarrage puis une fois par heure.

Si vous souhaitez modifier le cycle de vérification, exécutez `systemctl --user edit arch-update.timer` pour créer une configuration de remplacement pour la minuterie et saisissez ce qui suit :

```texte
[Minuteur]
OnUnitActiveSec = 10 min
```

Les unités de temps sont « s » pour les secondes, « m » pour les minutes, « h » pour les heures, « d » pour les jours...
Voir <https://www.freedesktop.org/software/systemd/man/systemd.time.html> pour plus de détails.

## Contribuant

Vous pouvez soulever vos problèmes, commentaires et suggestions dans l'onglet [Issues](https://github.com/Antiz96/arch-update/issues).
Les [Pull request](https://github.com/Antiz96/arch-update/pulls) sont également les bienvenues !
