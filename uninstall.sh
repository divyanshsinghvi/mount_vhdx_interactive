#!/bin/bash
#
# Uninstallation script for VHDX Mount tool
#

set -e

echo "========================================="
echo "  VHDX Mount Tool - Uninstallation"
echo "========================================="
echo

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a regular user (not root)."
    echo "You will be prompted for sudo password when needed."
    exit 1
fi

# Unmount any active VHDX mounts
echo "[1/6] Checking for active mounts..."
MOUNT_FILES=(/tmp/vhdx_mount_*.info)
if [ -f "${MOUNT_FILES[0]}" ]; then
    echo "Found active VHDX mounts. Unmounting..."
    for info_file in "${MOUNT_FILES[@]}"; do
        [ -f "$info_file" ] || continue
        /usr/local/bin/unmount-vhdx.sh 2>/dev/null || true
    done
    echo "✓ Active mounts cleaned up"
else
    echo "✓ No active mounts found"
fi

# Remove scripts
echo
echo "[2/6] Removing scripts..."
sudo rm -f /usr/local/bin/mount-vhdx.sh
sudo rm -f /usr/local/bin/unmount-vhdx.sh
sudo rm -f /usr/local/bin/list-vhdx-mounts.sh
echo "✓ Scripts removed"

# Remove MIME type
echo
echo "[3/6] Removing MIME type..."
sudo rm -f /usr/share/mime/packages/vhdx.xml
sudo update-mime-database /usr/share/mime/ 2>/dev/null || true
echo "✓ VHDX MIME type removed"

# Remove .desktop files
echo
echo "[4/6] Removing desktop entries..."
sudo rm -f /usr/share/applications/vhdx-mount.desktop
sudo rm -f /usr/share/applications/vhdx-unmount.desktop
sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
echo "✓ Desktop entries removed"

# Remove default application association
echo
echo "[5/6] Removing default application..."
if [ -f "$HOME/.config/mimeapps.list" ]; then
    for MIME_TYPE in application/x-vhdx application/vnd.ms-vhdx application/x-vhdx-disk; do
        sed -i "\|$MIME_TYPE|d" "$HOME/.config/mimeapps.list" 2>/dev/null || true
    done
fi
echo "✓ Default application association removed"

# Remove file manager scripts
echo
echo "[6/6] Removing file manager integration..."

# Nautilus
rm -f "$HOME/.local/share/nautilus/scripts/Mount VHDX" 2>/dev/null || true
rm -f "$HOME/.local/share/nautilus/scripts/Unmount VHDX" 2>/dev/null || true

# Dolphin
rm -f "$HOME/.local/share/kservices5/ServiceMenus/vhdx-mount.desktop" 2>/dev/null || true

# Thunar
if [ -f "$HOME/.config/Thunar/uca.xml" ]; then
    # Remove VHDX actions from uca.xml (this is simplified, may need manual cleanup)
    echo "  Note: Thunar custom actions may need manual cleanup in ~/.config/Thunar/uca.xml"
fi

echo "✓ File manager integration removed"

echo
echo "========================================="
echo "  Uninstallation Complete!"
echo "========================================="
echo
