# Changelog

All notable changes to this project will be documented in this file.

## [unreleased]

### Fixes

- Add a category to the desktop file (#179) - ([5bbb86e](https://github.com/Antiz96/arch-update/commit/5bbb86e6c8b8d029e25fef8ebf71c5a8dfb82a8c))

### Miscellaneous

- *(CONTRIBUTING)* Update contributing guidelines (#189) - ([7bf057d](https://github.com/Antiz96/arch-update/commit/7bf057d7a2ed8ec952f8a236fc41b29088ce50f6))
- Add contributing guidelines (CONTRIBUTING.md) (#188) - ([9307079](https://github.com/Antiz96/arch-update/commit/930707987b401ec200fac1778d5faea97f07428f))
- Add a link to sponsor page (#187) - ([8ebab0a](https://github.com/Antiz96/arch-update/commit/8ebab0a74018a3926cdfa076495b94ba9f3fcc88))
- Add a config for issue templates (#186) - ([2062fdd](https://github.com/Antiz96/arch-update/commit/2062fdd58ae6951051b2677d1635a82a2bb1bc86))
- Update issue templates (#185) - ([658a3ae](https://github.com/Antiz96/arch-update/commit/658a3aebd0fa0de1cd786668aae972b7be7ac669))
- Add templates for issues and pull requests (#184) - ([7cf1245](https://github.com/Antiz96/arch-update/commit/7cf1245a305db8b1b00c9d2f8441b5cfb3b29455))

## [2.1.0](https://github.com/Antiz96/arch-update/releases/tag/v2.1.0) - 2024-06-20

### Features

- Add support for systemd run0 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/172
- Add an option in the configuration file to explicitly set which command to use for privilege elevation (`sudo`, `doas` or `run0`) by @Antiz96 in https://github.com/Antiz96/arch-update/pull/175
- Add the `--show-config` option that displays the current configuration file by @Antiz96 in https://github.com/Antiz96/arch-update/pull/177

### Fixes

- Assign the STATE_FILE var before it is accessed in arch-update-tray.py script by @Antiz96 in https://github.com/Antiz96/arch-update/pull/174

## [2.0.2](https://github.com/Antiz96/arch-update/releases/tag/v2.0.2) - 2024-05-19

### Features

- Add a right click context menu to the systray applet (to "quit/exit" it and run arch-update) by @trigg in https://github.com/Antiz96/arch-update/pull/165
- Make the reboot countdown after a kernel upgrade showing remaining seconds in real time by @Antiz96 in https://github.com/Antiz96/arch-update/pull/169

### Improvements/Fixes

- Add the method to force `arch-update` to run in a specific terminal emulator via the desktop file to the documentation (as workaround for people using a terminal emulator not [known/supported](https://gitlab.gnome.org/GNOME/glib/-/blob/main/gio/gdesktopappinfo.c#L2694) by `gio` for whom cliking on the systray applet icon does nothing) by @Antiz96 in https://github.com/Antiz96/arch-update/pull/168
- Improve documentation regarding the check function and how to modify the check cycle by @Antiz96 in https://github.com/Antiz96/arch-update/pull/167
- Use the 'state_up_to_date' function to initialize the state file if it does not exists by @Antiz96 in https://github.com/Antiz96/arch-update/pull/159
- Make Arch-Update also look in XDG_DATA_HOME/XDG_DATA_DIRS for translation files and example config by @Antiz96 in https://github.com/Antiz96/arch-update/pull/170
- Fix wording in Makefile by @Antiz96 in https://github.com/Antiz96/arch-update/pull/158
- Fix typos in READMEs by @Antiz96 in https://github.com/Antiz96/arch-update/pull/161

## [2.0.1](https://github.com/Antiz96/arch-update/releases/tag/v2.0.1) - 2024-05-13

### Improvements/Fixes

- Fix a typo in the FR documentation by @Antiz96 in https://github.com/Antiz96/arch-update/pull/155
- Make systray applet also searching in XDG_DATA_HOME & XDG_DATA_DIRS when looking for the .desktop file by @Antiz96 and @trigg in https://github.com/Antiz96/arch-update/pull/156

## [2.0.0](https://github.com/Antiz96/arch-update/releases/tag/v2.0.0) - 2024-05-10

### Features

- Add a systray applet by @trigg in https://github.com/Antiz96/arch-update/pull/148 and https://github.com/Antiz96/arch-update/pull/149

### Improvements

- Move icons into hicolor theme by @trigg in https://github.com/Antiz96/arch-update/pull/147
- Drop icon changing for the .desktop file and remove superfluous icons/states by @Antiz96 in https://github.com/Antiz96/arch-update/pull/150
- New icons set by @Tearling27 in https://github.com/Antiz96/arch-update/pull/152 and https://github.com/Antiz96/arch-update/pull/153
- Simplification of the README for an easier and more fluid reading

### Important notes

- People running Wayland additionally need the `qt6-wayland` package for the systray applet to work properly.
- For people using the Arch-Update AUR package :
        The following error is expected when using `arch-update` to update from v1.X.X to v2.X.X: `cp: cannot stat '/usr/share/icons/arch-update/arch-update_up-to-date.svg': No such file or directory`. It will only happen once during the switch from v1 to v2 and will not happen again after that :)
- For people installing Arch-Update [from source](https://github.com/Antiz96/arch-update?tab=readme-ov-file#from-source):
        First uninstall the current version running on your system (via `sudo make uninstall`) before downloading this release's archive (or pulling the repo locally) and re-installing Arch-Update (via `sudo make install`), otherwise you'll keep unnecessary residues of the previous version on your system. Also make sure to install the newly required dependencies listed in the installation instructions.

## [1.15.0](https://github.com/Antiz96/arch-update/releases/tag/v1.15.0) - 2024-05-01

### Features

- Introduce the `--gen-config` option that allows to generate an example configuration file by @Antiz96 in https://github.com/Antiz96/arch-update/pull/143

## [1.14.4](https://github.com/Antiz96/arch-update/releases/tag/v1.14.4) - 2024-04-18

### Improvements

- Add an explicit message that the script is looking for updates by @Antiz96 in https://github.com/Antiz96/arch-update/pull/141

## [1.14.3](https://github.com/Antiz96/arch-update/releases/tag/v1.14.3) - 2024-04-14

### Improvements/Fixes

- Explicitly set color option of wrapped tools in the main script by @Antiz96 in https://github.com/Antiz96/arch-update/pull/140

## [1.14.2](https://github.com/Antiz96/arch-update/releases/tag/v1.14.2) - 2024-04-13

### Improvements

- Add a trust path for users by @Antiz96 in https://github.com/Antiz96/arch-update/pull/138

### Fixes

- Fix a typo in ZSH completions by @Antiz96 in https://github.com/Antiz96/arch-update/pull/139

## [1.14.1](https://github.com/Antiz96/arch-update/releases/tag/v1.14.1) - 2024-03-24

### Improvement

- Replace the previously sent desktop notification instead of sending a new one during the check function by @Antiz96 in https://github.com/Antiz96/arch-update/pull/134

### Other

- [Release Prep] v1.14.1 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/135

## [1.14.0](https://github.com/Antiz96/arch-update/releases/tag/v1.14.0) - 2024-03-22

### Features

- Add the `-D/--debug` argument to display debug traces by @Antiz96 in https://github.com/Antiz96/arch-update/pull/131

### Other

- [Release Prep] v1.14.0 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/132

## [1.13.0](https://github.com/Antiz96/arch-update/releases/tag/v1.13.0) - 2024-03-21

### Features

- Add the new `-d/--devel` option to include AUR development packages updates by @derethil in https://github.com/Antiz96/arch-update/pull/125

### Improvements/Fixes

- Add the `-l/--list` option to shell completions by @Sparkway in https://github.com/Antiz96/arch-update/pull/127
- Make the pending kernel update detection more robust (for EndeavourOS) by @Antiz96 in https://github.com/Antiz96/arch-update/pull/129
- Fix a small typo in the main script by @Antiz96 in https://github.com/Antiz96/arch-update/pull/128

### Other

- [Release Prep] v1.13.0 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/130

## [1.12.2](https://github.com/Antiz96/arch-update/releases/tag/v1.12.2) - 2024-03-12

### Features

- Add the new `-l/--list` option to simply get the list of pending updates by @Antiz96 in https://github.com/Antiz96/arch-update/pull/123

### Other

- [Release Prep] v1.12.2 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/124

## [1.12.1](https://github.com/Antiz96/arch-update/releases/tag/v1.12.1) - 2024-02-29

### Features

- Add shell completions for bash, zsh and fish by @Antiz96 in https://github.com/Antiz96/arch-update/pull/118

### Other

- [Release Prep] v1.12.1 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/120

## [1.12.0](https://github.com/Antiz96/arch-update/releases/tag/v1.12.0) - 2024-02-25

### Features

- Introduce the `-n/--news` option that allows to display latest Arch News by @Antiz96 in https://github.com/Antiz96/arch-update/pull/113
- Allow to customize the number of Arch news to display before updating and with the `-n/--news` option by @Antiz96 in https://github.com/Antiz96/arch-update/pull/114
- Only display Arch news if a new one has been published since the last run by @Antiz96 in https://github.com/Antiz96/arch-update/pull/115

### Improvements

- Improve documentation by @Antiz96 in https://github.com/Antiz96/arch-update/pull/112 & https://github.com/Antiz96/arch-update/pull/116

### Other

- [Release Prep] v1.12.0 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/117

## [1.11.0](https://github.com/Antiz96/arch-update/releases/tag/v1.11.0) - 2024-02-09

### Features

- French translation for the main script by @Antiz96 in https://github.com/Antiz96/arch-update/pull/107
- French translation for the documentation (README + Man pages) by @Antiz96 & @jfchadeyron in https://github.com/Antiz96/arch-update/pull/102

### Improvements/Fixes

- Make Flatpak packages updates detection more robust to avoid false positives by @Antiz96 in https://github.com/Antiz96/arch-update/pull/104
- Improvement the packaging method by @Antiz96 in https://github.com/Antiz96/arch-update/pull/107

### Other

- Licensing: Precise that Arch-Update is licensed under GPL3+ by @Antiz96 in https://github.com/Antiz96/arch-update/pull/105
- [Release Prep] v1.11.0 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/108

## [1.10.1](https://github.com/Antiz96/arch-update/releases/tag/v1.10.1) - 2024-01-14

### Fixes

- Correction of documentation regarding how to change the auto-check cycle by @Antiz96 in https://github.com/Antiz96/arch-update/pull/97
- Update url for systemd Time Spans in documentation  by @Antiz96 in https://github.com/Antiz96/arch-update/pull/98

### Other

- Harmonize name as 'Arch-Update' everywhere by @Antiz96 in https://github.com/Antiz96/arch-update/pull/94
- [Release Prep] v1.10.1 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/99

## [1.10.0](https://github.com/Antiz96/arch-update/releases/tag/v1.10.0) - 2024-01-06

### Features

- Add colors to the output of the script by @Antiz96 in https://github.com/Antiz96/arch-update/pull/87
- Add an optional configuration file to enable/disable or modify certain options by @Antiz96 in https://github.com/Antiz96/arch-update/pull/89

### Improvements

- Switch to a self-hosted runner for CI-CD + Add actionlint to CI by @Antiz96 in https://github.com/Antiz96/arch-update/pull/77
- Use complete version ref in man page by @wmemcpy in https://github.com/Antiz96/arch-update/pull/78
- Update documentation to advice using 'systemctl edit' to modify the auto-check cycle by @Antiz96 in https://github.com/Antiz96/arch-update/pull/84

### Fixes

- Add missing documentation for the old cached packages handling and pending kernel update processing features in the help message by @Antiz96 in https://github.com/Antiz96/arch-update/pull/88

### Other

- [Release Prep] v1.10.0 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/90
- Improve readability of documentation in README by @Antiz96 in https://github.com/Antiz96/arch-update/pull/91

## [1.9.1](https://github.com/Antiz96/arch-update/releases/tag/v1.9.1) - 2023-12-04

### Fixes

- Fix false positive 'pending kernel update' messages on EndeavourOS with systemd-boot by @Antiz96 in https://github.com/Antiz96/arch-update/pull/75

### Other

- [Release Prep] Bump the script to v1.9.1 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/76

## [1.9.0](https://github.com/Antiz96/arch-update/releases/tag/v1.9.0) - 2023-12-03

### Features

- Check if there are old or uninstalled cached packages in pacman's cache and offers to remove them if there are by @Antiz96 in https://github.com/Antiz96/arch-update/pull/71 (suggested by @Temet79 in https://github.com/Antiz96/arch-update/issues/70)

### Fixes

- Add the missing space in the 'kernel_reboot' function to keep a consistent style by @Antiz96 in https://github.com/Antiz96/arch-update/pull/72

### Other

- [Release Prep] Bump the script to v1.9.0 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/73

## [1.8.0](https://github.com/Antiz96/arch-update/releases/tag/v1.8.0) - 2023-12-01

### Features

- If both paru and yay are installed, use paru by default by @Antiz96 in https://github.com/Antiz96/arch-update/pull/64
- Check if a pending kernel update requires a reboot to be applied and, if there's one, offer to reboot by @Antiz96 in https://github.com/Antiz96/arch-update/pull/65

### Fixes

- Do not keep the `current_check` file in addition to the `last_check` one after the run of the check() function is finished as only the former is interesting/relevant to keep by @Antiz96 in https://github.com/Antiz96/arch-update/pull/66

### Other

- Add a link to the YouTube review of arch-update we made with @Cardiacman13 to the README (review in french) by @Antiz96 in https://github.com/Antiz96/arch-update/pull/67
- Restructuring the functions' calls in the script to make it more readable and easier to evolve/work with by @Antiz96 in https://github.com/Antiz96/arch-update/pull/68
- [Release Prep] Bump the script to v1.8.0 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/69

## [1.7.0](https://github.com/Antiz96/arch-update/releases/tag/v1.7.0) - 2023-11-24

- Only send desktop notification if the list of available updates differs from the last check by @Antiz96 in https://github.com/Antiz96/arch-update/pull/61

## [1.6.2](https://github.com/Antiz96/arch-update/releases/tag/v1.6.2) - 2023-11-21

- Make showing the version changes the default behaviour when listing available updates by @Antiz96 in https://github.com/Antiz96/arch-update/pull/58
- Make vim an optional dependency by @Antiz96 in https://github.com/Antiz96/arch-update/pull/59

## [1.6.1](https://github.com/Antiz96/arch-update/releases/tag/v1.6.1) - 2023-11-10

- Bugfix: Only print "No Flatpak unused package found" if flatpak is actually installed by @Antiz96 in https://github.com/Antiz96/arch-update/pull/57

## [1.6.0](https://github.com/Antiz96/arch-update/releases/tag/v1.6.0) - 2023-11-10

- Add Flatpak packages support (both for update and remove unused packages) by @Antiz96 in https://github.com/Antiz96/arch-update/pull/54
- Add styling to differentiate each steps of the main script more easily by @Antiz96 in https://github.com/Antiz96/arch-update/pull/55

## [1.5.7](https://github.com/Antiz96/arch-update/releases/tag/v1.5.7) - 2023-07-16

- Show more relevant info in a more readable way during the print of a news by @Antiz96 in https://github.com/Antiz96/arch-update/pull/39
- Add a '[NEW]' tag to each Arch news that are newer than 15 days by @Antiz96 in https://github.com/Antiz96/arch-update/pull/40
- Update documentation with the recently added features by @Antiz96 in https://github.com/Antiz96/arch-update/pull/42
- Bump the main script's version by @Antiz96 in https://github.com/Antiz96/arch-update/pull/43

## [1.5.6](https://github.com/Antiz96/arch-update/releases/tag/v1.5.6) - 2023-06-24

- Add codespell to the test suite ran by GH action by @Antiz96 in https://github.com/Antiz96/arch-update/pull/33
- Typo fixes by @Antiz96 in https://github.com/Antiz96/arch-update/pull/34
- Bump the main script version by @Antiz96 in https://github.com/Antiz96/arch-update/pull/35

## [1.5.5](https://github.com/Antiz96/arch-update/releases/tag/v1.5.5) - 2023-06-14

- Filter all special characters/symbols when parsing the Arch news urls to avoid ending with a wrong url by @Antiz96 in https://github.com/Antiz96/arch-update/pull/32

## [1.5.4](https://github.com/Antiz96/arch-update/releases/tag/v1.5.4) - 2023-06-13

- Add a GitHub action to run shellcheck on pull requests by @Antiz96 in https://github.com/Antiz96/arch-update/pull/24
- Add basic but useful information at the top of the main script by @Antiz96 in https://github.com/Antiz96/arch-update/pull/25
- Refactoring the script with functions by @Antiz96 in https://github.com/Antiz96/arch-update/pull/26
- Add a clear and concise help message (instead of simply printing the man page) for the --help option by @Antiz96 in https://github.com/Antiz96/arch-update/pull/27
- Use separated exit codes for each type of errors by @Antiz96 in https://github.com/Antiz96/arch-update/pull/28
- Switch from hq to htmlq to print Arch news during the update operation by @Antiz96 in https://github.com/Antiz96/arch-update/pull/29
- Bump the script to v1.5.4 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/30

## [1.5.3](https://github.com/Antiz96/arch-update/releases/tag/v1.5.3) - 2023-04-04

- Revert the required fix for the 'checkupdate' issue when using yay (implemented in #22) as it has been fixed/reverted by upstream (https://github.com/Antiz96/arch-update/pull/23)

## [1.5.2](https://github.com/Antiz96/arch-update/releases/tag/v1.5.2) - 2023-04-03

- Fix the 'checkupdate' issue when using yay by @Antiz96 in https://github.com/Antiz96/arch-update/pull/22

## [1.5.1](https://github.com/Antiz96/arch-update/releases/tag/v1.5.1) - 2023-02-10

- Make use of pacdiff to search for pacnew files by @Antiz96 in https://github.com/Antiz96/arch-update/pull/20

## [1.5.0](https://github.com/Antiz96/arch-update/releases/tag/v1.5.0) - 2023-02-09

- Add removing orphan packages support by @Antiz96 in https://github.com/Antiz96/arch-update/pull/15
- Make searching and processing orphan packages and pacnew files independent from updates by @Antiz96 in https://github.com/Antiz96/arch-update/pull/16
- Make the pacnew processing feature lists pacnew files before offering to process them by @Antiz96 in https://github.com/Antiz96/arch-update/pull/17
- Various improvements/optimisation to the main script, the README and the documentation by @Antiz96 in https://github.com/Antiz96/arch-update/pull/18
- Bump the script to v1.5.0 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/19

## [1.4.2](https://github.com/Antiz96/arch-update/releases/tag/v1.4.2) - 2022-11-30

- Bump the script's version to v1.4.2 by @Antiz96 in https://github.com/Antiz96/arch-update/pull/14

## [1.4.1](https://github.com/Antiz96/arch-update/releases/tag/v1.4.1) - 2022-11-28

- Corrected the arch-update.svg default icon by @Antiz96 in https://github.com/Antiz96/arch-update/pull/13

## [1.4.0](https://github.com/Antiz96/arch-update/releases/tag/v1.4.0) - 2022-11-26

- Add support for doas by @Antiz96 in https://github.com/Antiz96/arch-update/pull/10
- Add support for pacdiff to be able to process pacnew/pacsave files after an update by @Antiz96 in https://github.com/Antiz96/arch-update/pull/11
- Add a feature to read the latest Arch Linux news before updating the system by @Antiz96 in https://github.com/Antiz96/arch-update/pull/12

## [1.3.2](https://github.com/Antiz96/arch-update/releases/tag/v1.3.2) - 2022-09-15

- The repo has been restructured to better suit best practices.
- New install/uninstall method: The install.sh and uninstall.sh scripts have been removed in favor of a Makefile; which is cleaner, more standard and way easier to maintain.
- The wiki pages has been merged directly into the README to centralize information (the wiki has therefore been deleted).
- The "dependencies" (and overall) documentation has been improved.
- A LICENSE file has been added to the repo (GLP3).

## [1.3.1](https://github.com/Antiz96/arch-update/releases/tag/v1.3.1) - 2022-06-29

- Added some information to the man page/documentation.
- Typo fixes.

## [1.3.0](https://github.com/Antiz96/arch-update/releases/tag/v1.3.0) - 2022-06-27

### New features

- Now also supports [paru](https://aur.archlinux.org/packages/paru) as an optional dependency for the AUR support (in addition to [yay](https://aur.archlinux.org/packages/yay)).
- New [-v (or --version)](https://github.com/Antiz96/arch-update/wiki/Documentation#-v---version) option to print the current version.

### Code changes

- Messages printed by Arch-Update that relates to errors are now printed in the error output (2) instead of the standard output (which is more conventional).
- The install/update script has been completely re-written in a more elegant way. It now checks the integrity of the Arch-Update archive when performing an install or an update (based on its sha256 sum).
- The uninstall script has been completely re-written in a more elegant way.
- Miscellaneous little changes and fixes to the main Arch-Update script.

### Various changes

- The repository structure and the installation/update method has been modified in order to get cleaner, more conventional and secured, and easier to maintain.
- The man page is now zipped during the installation process (automatically done by pacman for the [AUR package](https://aur.archlinux.org/packages/arch-update)) instead of being already zipped in the archive.
- The versions number now follows the [semantic versioning principles](https://semver.org/).

## [1.2.4](https://github.com/Antiz96/arch-update/releases/tag/v1.2.4) - 2022-04-29

- Minor fixes

## [1.2.3](https://github.com/Antiz96/arch-update/releases/tag/v1.2.3) - 2022-04-21

- Minor fixes

## [1.2.2](https://github.com/Antiz96/arch-update/releases/tag/v1.2.2) - 2022-03-31

- Corrected and added some info in the man page

## [1.2.1](https://github.com/Antiz96/arch-update/releases/tag/v1.2.1) - 2022-03-31

- Corrected and added some info in the man page

## [1.2](https://github.com/Antiz96/arch-update/releases/tag/v1.2) - 2022-03-30

- Added correlation between "pkgver" and "source" in the PKGBUILD
- The archive is now uploaded as a release and not directly in the git repo

<!-- generated by git-cliff -->
