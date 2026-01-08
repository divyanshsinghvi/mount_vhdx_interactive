# Maintainer: Divyansh Singhvi <divyanshsinghvi@gmail.com>

pkgname=vhdx-mount
pkgver=1.0.0
pkgrel=1
pkgdesc="Mount VHDX virtual disk files with one click on Linux"
arch=('any')
url="https://github.com/divyanshsinghvi/mount_vhdx_interactive"
license=('MIT')
depends=('qemu' 'ntfs-3g' 'zenity' 'python' 'tk')
optdepends=(
    'nautilus: GNOME Files integration'
    'dolphin: KDE file manager integration'
    'thunar: XFCE file manager integration'
)
source=("git+https://github.com/divyanshsinghvi/mount_vhdx_interactive.git")
sha256sums=('SKIP')

package() {
    cd "$srcdir/mount_vhdx_interactive"

    # Install scripts
    install -Dm755 mount-vhdx.sh "$pkgdir/usr/local/bin/mount-vhdx.sh"
    install -Dm755 unmount-vhdx.sh "$pkgdir/usr/local/bin/unmount-vhdx.sh"
    install -Dm755 list-vhdx-mounts.sh "$pkgdir/usr/local/bin/list-vhdx-mounts.sh"
    install -Dm755 setup-passwordless.sh "$pkgdir/usr/local/bin/setup-passwordless.sh"
    install -Dm755 vhdx_viewer.py "$pkgdir/usr/local/bin/vhdx_viewer.py"

    # Install desktop files
    install -Dm644 vhdx-mount.desktop "$pkgdir/usr/share/applications/vhdx-mount.desktop"
    install -Dm644 vhdx-unmount.desktop "$pkgdir/usr/share/applications/vhdx-unmount.desktop"
    install -Dm644 vhdx-viewer.desktop "$pkgdir/usr/share/applications/vhdx-viewer.desktop"

    # Install MIME type
    install -Dm644 vhdx.xml "$pkgdir/usr/share/mime/packages/vhdx.xml"

    # Install Nautilus scripts
    install -Dm755 nautilus-scripts/Mount-VHDX "$pkgdir/usr/share/nautilus/scripts/Mount-VHDX"
    install -Dm755 nautilus-scripts/Unmount-VHDX "$pkgdir/usr/share/nautilus/scripts/Unmount-VHDX"

    # Install Dolphin service menu
    install -Dm644 dolphin-servicemenu/vhdx-mount.desktop "$pkgdir/usr/share/kservices5/ServiceMenus/vhdx-mount.desktop"

    # Install documentation
    install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
    install -Dm644 QUICKSTART.md "$pkgdir/usr/share/doc/$pkgname/QUICKSTART.md"
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}

post_install() {
    echo "==> VHDX Mount Tool installed successfully!"
    echo "==> Run 'setup-passwordless.sh' to enable automatic mounting without password"
    echo "==> Usage: Just double-click any .vhdx file in your file manager"
    update-mime-database /usr/share/mime &> /dev/null || true
    update-desktop-database -q || true
}

post_upgrade() {
    post_install
}

post_remove() {
    update-mime-database /usr/share/mime &> /dev/null || true
    update-desktop-database -q || true
}
