pkgname=arch-update

PREFIX ?= /usr/local

.PHONY: all install uninstall

all:

install:
	install -Dm 755 "src/script/${pkgname}.sh" "${DESTDIR}${PREFIX}/bin/${pkgname}"
	
	install -Dm 666 "src/img/${pkgname}.svg" "${DESTDIR}${PREFIX}/share/icons/${pkgname}/${pkgname}.svg"
	install -Dm 666 "src/img/${pkgname}_checking.svg" "${DESTDIR}${PREFIX}/share/icons/${pkgname}/${pkgname}_checking.svg"
	install -Dm 666 "src/img/${pkgname}_installing.svg" "${DESTDIR}${PREFIX}/share/icons/${pkgname}/${pkgname}_installing.svg"
	install -Dm 666 "src/img/${pkgname}_up-to-date.svg" "${DESTDIR}${PREFIX}/share/icons/${pkgname}/${pkgname}_up-to-date.svg"
	install -Dm 666 "src/img/${pkgname}_updates-available.svg" "${DESTDIR}${PREFIX}/share/icons/${pkgname}/${pkgname}_updates-available.svg"

	install -Dm 644 "res/desktop/${pkgname}.desktop" "${DESTDIR}${PREFIX}/share/applications/${pkgname}.desktop"

	install -Dm 644 "res/systemd/${pkgname}.service" "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.service"
	install -Dm 644 "res/systemd/${pkgname}.timer" "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.timer"

	gzip -c "doc/man/${pkgname}.1" > "${pkgname}.1.gz"
	install -Dm 644 "${pkgname}.1.gz" "${DESTDIR}${PREFIX}/share/man/man1/${pkgname}.1.gz"
	rm -f "${pkgname}.1.gz"
	
	install -Dm 644 README.md "${DESTDIR}${PREFIX}/share/doc/${pkgname}/README.md"

uninstall:
	rm -f "${DESTDIR}${PREFIX}/bin/${pkgname}"
	rm -f "${DESTDIR}${PREFIX}/share/man/man1/${pkgname}.1.gz"
	rm -rf "${DESTDIR}${PREFIX}/share/doc/${pkgname}/"

test:
	"src/script/${pkgname}.sh" --help
