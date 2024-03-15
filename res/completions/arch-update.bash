_arch-update() {
	local arg="${2}"
	local -a opts
	opts=('-c --check
		   -d --devel
	       -n --news
	       -h --help
	       -V --version')

	COMPREPLY=( $(compgen -W "${opts[*]}" -- "${arg}") )
}

complete -F _arch-update arch-update
