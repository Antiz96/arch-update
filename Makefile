pkgname=arch-update
_pkgname=Arch-Update
locales = de es fr hu ja ka nb nl pt_BR pt_PT ru sv zh_CN zh_TW

PREFIX ?= /usr/local

.PHONY: build test install clean uninstall

build:
	# Generate man pages
	scdoc < "doc/man/${pkgname}.1.scd" > "doc/man/${pkgname}.1"
	scdoc < "doc/man/${pkgname}.conf.5.scd" > "doc/man/${pkgname}.conf.5"

	# Generate translation files
	for locale in $(locales); do \
		msgfmt "po/$${locale}.po" -o "po/$${locale}.mo"; \
	done

test:
	# Run some simple unit tests on basic functions
	bats test/case/basic_functions.bats

install:
	# Install main script
	install -Dm 755 "src/${pkgname}.sh" "${DESTDIR}${PREFIX}/bin/${pkgname}"

	# Install libraries
	install -Dm 755 src/lib/* -t "${DESTDIR}${PREFIX}/share/${pkgname}/lib/"

	# Install icons
	install -Dm 664 "res/icons/cachy-update-blue.svg" "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update-blue.svg"
	install -Dm 664 "res/icons/cachy-update_updates-available-blue.svg" "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-blue.svg"
	install -Dm 664 "res/icons/cachy-update_updates-available-blue-cb.svg" "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-blue-cb.svg"
	install -Dm 664 "res/icons/cachy-update-light.svg" "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update-light.svg"
	install -Dm 664 "res/icons/cachy-update_updates-available-light.svg" "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-light.svg"
	install -Dm 664 "res/icons/cachy-update_updates-available-light-cb.svg" "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-light-cb.svg"
	install -Dm 664 "res/icons/cachy-update-dark.svg" "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update-dark.svg"
	install -Dm 664 "res/icons/cachy-update_updates-available-dark.svg" "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-dark.svg"
	install -Dm 664 "res/icons/cachy-update_updates-available-dark-cb.svg" "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-dark-cb.svg"

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
	install -Dm 644 "doc/man/${pkgname}.1" "${DESTDIR}${PREFIX}/share/man/man1/${pkgname}.1"
	install -Dm 644 "doc/man/${pkgname}.conf.5" "${DESTDIR}${PREFIX}/share/man/man5/${pkgname}.conf.5"

	# Install translation files
	# Translation files are installed as "Arch-Update.mo" to avoid conflicting with the "arch-update.mo" files shipped by the arch-update Gnome extension (https://extensions.gnome.org/extension/1010/archlinux-updates-indicator/)
	for locale in $(locales); do \
		install -Dm 644 "po/$${locale}.mo" "${DESTDIR}${PREFIX}/share/locale/$${locale}/LC_MESSAGES/${_pkgname}.mo"; \
	done

	# Install documentation
	install -Dm 644 README.md "${DESTDIR}${PREFIX}/share/doc/${pkgname}/README.md"

	# Install example config
	install -Dm 644 "res/config/${pkgname}.conf.example" "${DESTDIR}${PREFIX}/share/${pkgname}/config/${pkgname}.conf.example"

clean:
	# Delete generated man pages
	rm -f "doc/man/${pkgname}.1"
	rm -f "doc/man/${pkgname}.conf.5"

	# Delete generated translation files
	for locale in $(locales); do \
		rm -f "po/$${locale}.mo"; \
	done

uninstall:
	# Delete main script
	rm -f "${DESTDIR}${PREFIX}/bin/${pkgname}"

	# Delete share folder (contains libraries and example config)
	rm -rf "${DESTDIR}${PREFIX}/share/${pkgname}/"

	# Delete icons
	rm -f "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update-blue.svg"
	rm -f "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-blue.svg"
	rm -f "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-blue-cb.svg"
	rm -f "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update-light.svg"
	rm -f "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-light.svg"
	rm -f "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-light-cb.svg"
	rm -f "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update-dark.svg"
	rm -f "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-dark.svg"
	rm -f "${DESTDIR}${PREFIX}/share/icons/hicolor/scalable/apps/cachy-update_updates-available-dark-cb.svg"

	# Delete .desktop files
	rm -f "${DESTDIR}${PREFIX}/share/applications/${pkgname}.desktop"
	rm -f "${DESTDIR}${PREFIX}/share/applications/${pkgname}-tray.desktop"

	# Delete systemd units
	rm -f "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.service"
	rm -f "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.timer"
	rm -f "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}-tray.service"

	# Delete .mo files
	for locale in $(locales); do \
		rm -f "${DESTDIR}${PREFIX}/share/locale/$${locale}/LC_MESSAGES/${_pkgname}.mo"; \
	done

	# Delete shell completions
	rm -f "${DESTDIR}${PREFIX}/share/bash-completion/completions/${pkgname}"
	rm -f "${DESTDIR}${PREFIX}/share/zsh/site-functions/_${pkgname}"
	rm -f "${DESTDIR}${PREFIX}/share/fish/vendor_completions.d/${pkgname}.fish"

	# Delete man pages
	rm -f "${DESTDIR}${PREFIX}/share/man/man1/${pkgname}.1"
	rm -f "${DESTDIR}${PREFIX}/share/man/man5/${pkgname}.conf.5"

	# Delete documentation folder
	rm -rf "${DESTDIR}${PREFIX}/share/doc/${pkgname}/"
