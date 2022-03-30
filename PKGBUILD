# Maintainer: Robin Candau <robincandau@protonmail.com>
pkgname=arch-update
pkgver=1.0
pkgrel=1
pkgdesc="A clickeable icon that automatically changes to act as an update notifier/applier"
arch=('any')
url="https://github.com/Antiz96/arch-update"
license=('GPL3')
depends=('pacman-contrib')
optdepends=('yay: AUR support'
	    'libnotify: Desktop notification support'
	   )
source=($url/$pkgname.tar.gz)
sha256sums=()

package() {
  cd "$srcdir"

  install -Dm 755 "bin/$pkgname.sh" "$pkgdir/usr/bin/$pkgname"

  install -Dm 666 "icon/$pkgname*.svg" "$pkgdir/usr/share/icons/$pkgname/"

  install -Dm 644 "desktop/$pkgname.desktop" "$pkgdir/usr/share/applications/"

  install -Dm 644 "systemd/$pkgname.*" "$pkgdir/usr/lib/systemd/user/"

  install -Dm 644 "man/$pkgname.1.gz" "$pkgdir/usr/share/man/man1/"
}
