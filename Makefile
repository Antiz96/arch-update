pkgname=arch-update
_pkgname=Arch-Update

PREFIX ?= /usr/local

.PHONY: all install uninstall

all:

install:
	# Install the main script
	install -Dm 755 "src/script/${pkgname}.sh" "${DESTDIR}${PREFIX}/bin/${pkgname}"

	# Install icons
	install -Dm 666 "src/icons/${pkgname}.svg" "${DESTDIR}${PREFIX}/share/icons/${pkgname}/${pkgname}.svg"
	install -Dm 666 "src/icons/${pkgname}_checking.svg" "${DESTDIR}${PREFIX}/share/icons/${pkgname}/${pkgname}_checking.svg"
	install -Dm 666 "src/icons/${pkgname}_installing.svg" "${DESTDIR}${PREFIX}/share/icons/${pkgname}/${pkgname}_installing.svg"
	install -Dm 666 "src/icons/${pkgname}_up-to-date.svg" "${DESTDIR}${PREFIX}/share/icons/${pkgname}/${pkgname}_up-to-date.svg"
	install -Dm 666 "src/icons/${pkgname}_updates-available.svg" "${DESTDIR}${PREFIX}/share/icons/${pkgname}/${pkgname}_updates-available.svg"

	# Install the .desktop file
	install -Dm 644 "res/desktop/${pkgname}.desktop" "${DESTDIR}${PREFIX}/share/applications/${pkgname}.desktop"

	# Install systemd units
	install -Dm 644 "res/systemd/${pkgname}.service" "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.service"
	install -Dm 644 "res/systemd/${pkgname}.timer" "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.timer"
	
	# Generate and install .mo files for translations
	# .mo files are installed as "Arch-Update.mo" to avoid conflicting with the "arch-update.mo" files shipped by the arch-update Gnome extension (https://extensions.gnome.org/extension/1010/archlinux-updates-indicator/)
	msgfmt po/fr.po -o po/fr.mo
	install -Dm 644 po/fr.mo "${DESTDIR}${PREFIX}/share/locale/fr/LC_MESSAGES/${_pkgname}.mo"
	rm -f po/fr.mo

	# Install shell completions
	install -Dm 644 "res/completions/${pkgname}.bash" "${DESTDIR}${PREFIX}/share/bash-completion/completions/${pkgname}"
	install -Dm 644 "res/completions/${pkgname}.zsh" "${DESTDIR}${PREFIX}/share/zsh/site-functions/_${pkgname}"
	install -Dm 644 "res/completions/${pkgname}.fish" "${DESTDIR}${PREFIX}/share/fish/vendor_completions.d/${pkgname}.fish"

	# Archive and install man pages
	gzip -c "doc/man/${pkgname}.1" > "doc/man/${pkgname}.1.gz"
	gzip -c "doc/man/${pkgname}.conf.5" > "doc/man/${pkgname}.conf.5.gz"
	gzip -c "doc/man/fr/${pkgname}.1" > "doc/man/fr/${pkgname}.1.gz"
	gzip -c "doc/man/fr/${pkgname}.conf.5" > "doc/man/fr/${pkgname}.conf.5.gz"
	install -Dm 644 "doc/man/${pkgname}.1.gz" "${DESTDIR}${PREFIX}/share/man/man1/${pkgname}.1.gz"
	install -Dm 644 "doc/man/${pkgname}.conf.5.gz" "${DESTDIR}${PREFIX}/share/man/man5/${pkgname}.conf.5.gz"
	install -Dm 644 "doc/man/fr/${pkgname}.1.gz" "${DESTDIR}${PREFIX}/share/man/fr/man1/${pkgname}.1.gz"
	install -Dm 644 "doc/man/fr/${pkgname}.conf.5.gz" "${DESTDIR}${PREFIX}/share/man/fr/man5/${pkgname}.conf.5.gz"
	rm -f "doc/man/${pkgname}.1.gz"
	rm -f "doc/man/${pkgname}.conf.5.gz"
	rm -f "doc/man/fr/${pkgname}.1.gz"
	rm -f "doc/man/fr/${pkgname}.conf.5.gz"

	# Install documentation and examples
	install -Dm 644 README.md "${DESTDIR}${PREFIX}/share/doc/${pkgname}/README.md"
	install -Dm 644 README-fr.md "${DESTDIR}${PREFIX}/share/doc/${pkgname}/fr/README.md"
	install -Dm 644 "res/config/${pkgname}.conf.example" "${DESTDIR}${PREFIX}/share/doc/${pkgname}/${pkgname}.conf.example"

uninstall:
	# Delete the main script
	rm -f "${DESTDIR}${PREFIX}/bin/${pkgname}"

	# Delete icons
	rm -rf "${DESTDIR}${PREFIX}/share/icons/${pkgname}/"

	# Delete the .desktop file
	rm -f "${DESTDIR}${PREFIX}/share/applications/${pkgname}.desktop"

	# Delete systemd units
	rm -f "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.service"
	rm -f "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.timer"

	# Delete .mo files
	rm -f "${DESTDIR}${PREFIX}/usr/share/locale/fr/LC_MESSAGES/${_pkgname}.mo"

	# Delete shell completions
	rm -f "${DESTDIR}${PREFIX}/share/bash-completion/completions/${pkgname}"
	rm -f "${DESTDIR}${PREFIX}/share/zsh/site-functions/_${pkgname}"
	rm -f "${DESTDIR}${PREFIX}/share/fish/vendor_completions.d/${pkgname}.fish"

	# Delete man pages
	rm -f "${DESTDIR}${PREFIX}/share/man/man1/${pkgname}.1.gz"
	rm -f "${DESTDIR}${PREFIX}/share/man/man5/${pkgname}.conf.5.gz"
	rm -f "${DESTDIR}${PREFIX}/share/man/fr/man1/${pkgname}.1.gz"
	rm -f "${DESTDIR}${PREFIX}/share/man/fr/man5/${pkgname}.conf.5.gz"
	
	# Delete documentation and examples
	rm -rf "${DESTDIR}${PREFIX}/share/doc/${pkgname}/"

test:
	# Run the help function of the main script as a simple test
	"src/script/${pkgname}.sh" --help
