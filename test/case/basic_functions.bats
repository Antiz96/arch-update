export ARCH_UPDATE_LIBDIR="${PWD}/src/lib"

@test "version" {
	src/arch-update.sh --version
}

@test "help" {
	src/arch-update.sh --help
}
