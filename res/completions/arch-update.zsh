#compdef arch-update

local -a opts
opts=(
    {-c,--check}'[Check for available updates]'
    {-d, --devel}'[Update AUR development packages]'
    {-n,--news}'[Display latest Arch news]'
    {-h,--help}'[Display the help message]'
    {-V,--version}'[Display version information]'
)

_arguments $opts
