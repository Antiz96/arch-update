_arch-update() {
	local arg="${2}"
	local -a opts
	opts=('-c --check
	       -l --list
	       -d --devel
	       -n --news
	       -D --debug
	       --gen-config
	       -h --help
	       -V --version')

	COMPREPLY=( $(compgen -W "${opts[*]}" -- "${arg}") )
}

complete -F _arch-update arch-update
