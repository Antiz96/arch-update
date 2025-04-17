complete -c arch-update -f

complete -c arch-update -s c -l check -d 'Check for available updates'
complete -c arch-update -s l -l list -d 'Display the list of pending updates'
complete -c arch-update -s d -l devel -d 'Include AUR development packages updates'
complete -c arch-update -s n -l news -d 'Display latest Arch news'
complete -c arch-update -s s -l services -d 'Check for services requiring a post upgrade restart'
complete -c arch-update -s D -l debug -d 'Display debug traces'
complete -c arch-update -l gen-config -d 'Generate a default / example configuration file'
complete -c arch-update -l show-config -d 'Display the current configuration file'
complete -c arch-update -l edit-config -d 'Edit the current configuration file'
complete -c arch-update -l tray -d 'Launch the Arch-Update systray applet'
complete -c arch-update -s h -l help -d 'Display the help message'
complete -c arch-update -s V -l version -d 'Display version information'
