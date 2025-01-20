pkgname=arch-update
_pkgname=Arch-Update

PREFIX ?= /usr/local

.PHONY: build test install clean uninstall

build:
	# Generate man pages
	scdoc < "doc/man/${pkgname}.1.scd" > "doc/man/${pkgname}.1"
	scdoc < "doc/man/${pkgname}.conf.5.scd" > "doc/man/${pkgname}.conf.5"
	scdoc < "doc/man/fr/${pkgname}.1.scd" > "doc/man/fr/${pkgname}.1"
	scdoc < "doc/man/fr/${pkgname}.conf.5.scd" > "doc/man/fr/${pkgname}.conf.5"

	# Archive man pages
	gzip -c "doc/man/${pkgname}.1" > "doc/man/${pkgname}.1.gz"
	gzip -c "doc/man/${pkgname}.conf.5" > "doc/man/${pkgname}.conf.5.gz"
	gzip -c "doc/man/fr/${pkgname}.1" > "doc/man/fr/${pkgname}.1.gz"
	gzip -c "doc/man/fr/${pkgname}.conf.5" > "doc/man/fr/${pkgname}.conf.5.gz"

	# Generate translations files
	msgfmt po/fr.po -o po/fr.mo
	msgfmt po/sv.po -o po/sv.mo

test:
	# Run some simple unit tests on basic functions
	bats test/case/basic_functions.bats

install:
	# Install main script
	install -Dm 755 "src/${pkgname}.sh" "${DESTDIR}${PREFIX}/bin/${pkgname}"

	# Install libraries
	install -Dm 755 src/lib/* -t "${DESTDIR}${PREFIX}/share/${pkgname}/lib/"

	# Install icons
	install -Dm 664 res/icons/"${pkgname}"*.svg -t "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/"
	install -Dm 664 res/icons/"${pkgname}"_updates-available*.svg -t "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/"

	# Install .desktop files
	install -Dm 644 "res/desktop/${pkgname}.desktop" "${DESTDIR}${PREFIX}/share/applications/${pkgname}.desktop"
	install -Dm 644 "res/desktop/${pkgname}-tray.desktop" "${DESTDIR}${PREFIX}/share/applications/${pkgname}-tray.desktop"

	# Install systemd units
	install -Dm 644 "res/systemd/${pkgname}.service" "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.service"
	install -Dm 644 "res/systemd/${pkgname}.timer" "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.timer"
	install -Dm 644 "res/systemd/${pkgname}-tray.service" "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}-tray.service"
  
	# Install shell completions
	install -Dm 644 "res/completions/${pkgname}.bash" "${DESTDIR}${PREFIX}/share/bash-completion/completions/${pkgname}"
	install -Dm 644 "res/completions/${pkgname}.zsh" "${DESTDIR}${PREFIX}/share/zsh/site-functions/_${pkgname}"
	install -Dm 644 "res/completions/${pkgname}.fish" "${DESTDIR}${PREFIX}/share/fish/vendor_completions.d/${pkgname}.fish"

	# Install man pages
	install -Dm 644 "doc/man/${pkgname}.1.gz" "${DESTDIR}${PREFIX}/share/man/man1/${pkgname}.1.gz"
	install -Dm 644 "doc/man/${pkgname}.conf.5.gz" "${DESTDIR}${PREFIX}/share/man/man5/${pkgname}.conf.5.gz"
	install -Dm 644 "doc/man/fr/${pkgname}.1.gz" "${DESTDIR}${PREFIX}/share/man/fr/man1/${pkgname}.1.gz"
	install -Dm 644 "doc/man/fr/${pkgname}.conf.5.gz" "${DESTDIR}${PREFIX}/share/man/fr/man5/${pkgname}.conf.5.gz"

	# Install translations files
	# Translations files are installed as "Arch-Update.mo" to avoid conflicting with the "arch-update.mo" files shipped by the arch-update Gnome extension (https://extensions.gnome.org/extension/1010/archlinux-updates-indicator/)
	install -Dm 644 po/fr.mo "${DESTDIR}${PREFIX}/share/locale/fr/LC_MESSAGES/${_pkgname}.mo"
	install -Dm 644 po/sv.mo "${DESTDIR}${PREFIX}/share/locale/sv/LC_MESSAGES/${_pkgname}.mo"

	# Install documentation
	install -Dm 644 README.md "${DESTDIR}${PREFIX}/share/doc/${pkgname}/README.md"
	install -Dm 644 README-fr.md "${DESTDIR}${PREFIX}/share/doc/${pkgname}/fr/README.md"

	# Install example config
	install -Dm 644 "res/config/${pkgname}.conf.example" "${DESTDIR}${PREFIX}/share/${pkgname}/config/${pkgname}.conf.example"

clean:
	# Delete generated and archived man pages
	rm -f "doc/man/${pkgname}.1"{,.gz}
	rm -f "doc/man/${pkgname}.conf.5"{,.gz}
	rm -f "doc/man/fr/${pkgname}.1"{,.gz}
	rm -f "doc/man/fr/${pkgname}.conf.5"{,.gz}

	# Delete generated translations files
	rm -f po/fr.mo
	rm -f po/sv.mo

uninstall:
	# Delete main script
	rm -f "${DESTDIR}${PREFIX}/bin/${pkgname}"

	# Delete data folder (which stores libraries and example config)
	rm -rf "${DESTDIR}${PREFIX}/share/${pkgname}/"

	# Delete icons
	rm -f "${DESTDIR}${PREFIX}"/share/icons/hicolor/scalable/apps/"${pkgname}"*.svg
	rm -f "${DESTDIR}${PREFIX}"/share/icons/hicolor/scalable/apps/"${pkgname}"_updates-available*.svg

	# Delete .desktop files
	rm -f "${DESTDIR}${PREFIX}/share/applications/${pkgname}.desktop"
	rm -f "${DESTDIR}${PREFIX}/share/applications/${pkgname}-tray.desktop"

	# Delete systemd units
	rm -f "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.service"
	rm -f "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.timer"
	rm -f "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}-tray.service"

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

	# Delete documentation folder
	rm -rf "${DESTDIR}${PREFIX}/share/doc/${pkgname}/"
