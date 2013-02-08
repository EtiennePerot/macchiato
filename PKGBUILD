# Maintainer: Etienne Perot <etienne@perot.me>
pkgname=macchiato-git
pkgver=20130207
pkgrel=1
pkgdesc='MAC spoofing with a restricted range of OUI prefixes'
arch=('i686' 'x86_64')
url='https://github.com/EtiennePerot/macchiato'
license=('BSD')
depends=('bash' 'iproute2')
makedepends=('git')

_gitroot='git://perot.me/macchiato'
_gitname='macchiato'

build() {
	cd "$srcdir"
	msg "Connecting to GIT server...."

	if [[ -d "$_gitname" ]]; then
		cd "$_gitname" && git pull origin
		msg "The local files are updated."
	else
		git clone "$_gitroot" "$_gitname"
	fi

	msg "Starting build..."

	rm -rf "$srcdir/$_gitname-build"
	git clone "$srcdir/$_gitname" "$srcdir/$_gitname-build"
	cd "$srcdir/$_gitname-build"
}

package() {
	cd "$srcdir/$_gitname-build"
	install -D -m644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
	install -D -m755 macchiato "${pkgdir}/usr/share/macchiato/macchiato"
	install -D -m755 install-udev-rules.sh "${pkgdir}/usr/share/macchiato/install-udev-rules.sh"
	for _oui in oui/*; do
		install -D -m644 "$_oui" "${pkgdir}/usr/share/macchiato/$_oui"
	done
	install -D -m644 systemd/macchiato.service "${pkgdir}/usr/lib/systemd/system/macchiato.service"
	install -D -m644 conf/sample.sh.example "${pkgdir}/usr/share/macchiato/conf/sample.sh.example"
	install -D -m644 conf/sample.sh.example "${pkgdir}/etc/macchiato.d/sample.sh.example"
}
