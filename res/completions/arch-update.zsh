#compdef arch-update

local -a opts
opts=(
    {-c,--check}'[Check for available updates]'
    {-l,--list}'[Display the list of pending updates]'
    {-d,--devel}'[Include AUR development packages updates]'
    {-n,--news}'[Display latest Arch news]'
    {-D,--debug}'[Display debug traces]'
    {--gen-config}'[Generate a default/example configuration file]'
    {--show-config}'[Display the current configuration file]'
    {--tray}'[Launch the Arch-Update systray applet]'
    {-h,--help}'[Display the help message]'
    {-V,--version}'[Display version information]'
)

_arguments $opts
