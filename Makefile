pkgname=arch-update

PREFIX ?= /usr/local

.PHONY: all install uninstall

all:

install:
	install -Dm 755 "src/script/${pkgname}.sh" "${DESTDIR}${PREFIX}/bin/${pkgname}"
	
	install -Dm 666 "src/icons/${pkgname}.svg" "${DESTDIR}/usr/share/icons/${pkgname}/${pkgname}.svg"
	install -Dm 666 "src/icons/${pkgname}_checking.svg" "${DESTDIR}/usr/share/icons/${pkgname}/${pkgname}_checking.svg"
	install -Dm 666 "src/icons/${pkgname}_installing.svg" "${DESTDIR}/usr/share/icons/${pkgname}/${pkgname}_installing.svg"
	install -Dm 666 "src/icons/${pkgname}_up-to-date.svg" "${DESTDIR}/usr/share/icons/${pkgname}/${pkgname}_up-to-date.svg"
	install -Dm 666 "src/icons/${pkgname}_updates-available.svg" "${DESTDIR}/usr/share/icons/${pkgname}/${pkgname}_updates-available.svg"
	
	install -Dm 644 "res/desktop/${pkgname}.desktop" "${DESTDIR}${PREFIX}/share/applications/${pkgname}.desktop"
	
	install -Dm 644 "res/systemd/${pkgname}.service" "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.service"
	install -Dm 644 "res/systemd/${pkgname}.timer" "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.timer"
	
	gzip -c "doc/man/${pkgname}.1" > "${pkgname}.1.gz"
	gzip -c "doc/man/${pkgname}.conf.5" > "${pkgname}.conf.5.gz"
	install -Dm 644 "${pkgname}.1.gz" "${DESTDIR}${PREFIX}/share/man/man1/${pkgname}.1.gz"
	install -Dm 644 "${pkgname}.conf.5.gz" "${DESTDIR}${PREFIX}/share/man/man5/${pkgname}.conf.5.gz"
	rm -f "${pkgname}.1.gz"
	rm -f "${pkgname}.conf.5.gz"
	
	install -Dm 644 README.md "${DESTDIR}${PREFIX}/share/doc/${pkgname}/README.md"

uninstall:
	rm -f "${DESTDIR}${PREFIX}/bin/${pkgname}"
	rm -rf "${DESTDIR}/usr/share/icons/${pkgname}/" 
	rm -f "${DESTDIR}${PREFIX}/share/applications/${pkgname}.desktop"
	rm -f "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.service"
	rm -f "${DESTDIR}${PREFIX}/lib/systemd/user/${pkgname}.timer"
	rm -f "${DESTDIR}${PREFIX}/share/man/man1/${pkgname}.1.gz"
	rm -rf "${DESTDIR}${PREFIX}/share/doc/${pkgname}/"

test:
	"src/script/${pkgname}.sh" --help
