#!/bin/bash
#
# Installation script for VHDX Mount tool
#

set -e

echo "========================================="
echo "  VHDX Mount Tool - Installation"
echo "========================================="
echo

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a regular user (not root)."
    echo "You will be prompted for sudo password when needed."
    exit 1
fi

# Detect package manager and install dependencies
echo "[1/6] Checking dependencies..."

if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    INSTALL_CMD="sudo apt-get install -y"
    PACKAGES="qemu-utils zenity ntfs-3g"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
    PACKAGES="qemu-img zenity ntfs-3g"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
    PACKAGES="qemu zenity ntfs-3g"
elif command -v zypper &> /dev/null; then
    PKG_MANAGER="zypper"
    INSTALL_CMD="sudo zypper install -y"
    PACKAGES="qemu-tools zenity ntfs-3g"
else
    echo "Warning: Could not detect package manager."
    echo "Please manually install: qemu-utils (or qemu-img), zenity, ntfs-3g"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check and install missing packages
if [ -n "$PKG_MANAGER" ]; then
    MISSING_PACKAGES=""

    # Check qemu-nbd
    if ! command -v qemu-nbd &> /dev/null; then
        MISSING_PACKAGES="$MISSING_PACKAGES qemu"
    fi

    # Check zenity (or kdialog as alternative)
    if ! command -v zenity &> /dev/null && ! command -v kdialog &> /dev/null; then
        if [ "$PKG_MANAGER" = "apt" ] || [ "$PKG_MANAGER" = "dnf" ]; then
            MISSING_PACKAGES="$MISSING_PACKAGES zenity"
        fi
    fi

    # Check ntfs-3g
    if ! command -v ntfs-3g &> /dev/null; then
        MISSING_PACKAGES="$MISSING_PACKAGES ntfs-3g"
    fi

    if [ -n "$MISSING_PACKAGES" ]; then
        echo "Installing missing packages:$MISSING_PACKAGES"
        $INSTALL_CMD $MISSING_PACKAGES
        echo "✓ Dependencies installed"
    else
        echo "✓ All dependencies already installed"
    fi
fi

# Install scripts
echo
echo "[2/6] Installing scripts..."
sudo install -m 755 mount-vhdx.sh /usr/local/bin/mount-vhdx.sh
sudo install -m 755 unmount-vhdx.sh /usr/local/bin/unmount-vhdx.sh
sudo install -m 755 list-vhdx-mounts.sh /usr/local/bin/list-vhdx-mounts.sh
echo "✓ Scripts installed to /usr/local/bin/"

# Install MIME type
echo
echo "[3/6] Installing MIME type..."
sudo install -m 644 vhdx.xml /usr/share/mime/packages/vhdx.xml
sudo update-mime-database /usr/share/mime/
echo "✓ VHDX MIME type registered"

# Install .desktop files
echo
echo "[4/6] Installing desktop entries..."
sudo install -m 644 vhdx-mount.desktop /usr/share/applications/vhdx-mount.desktop
sudo install -m 644 vhdx-unmount.desktop /usr/share/applications/vhdx-unmount.desktop
sudo update-desktop-database /usr/share/applications/
echo "✓ Desktop entries installed"

# Set default application for .vhdx files
echo
echo "[5/6] Setting default application..."
xdg-mime default vhdx-mount.desktop application/x-vhdx
echo "✓ Default application set"

# Install file manager scripts
echo
echo "[6/6] Installing file manager integration..."

# Nautilus (GNOME Files)
if command -v nautilus &> /dev/null; then
    NAUTILUS_SCRIPTS_DIR="$HOME/.local/share/nautilus/scripts"
    mkdir -p "$NAUTILUS_SCRIPTS_DIR"
    install -m 755 nautilus-scripts/Mount-VHDX "$NAUTILUS_SCRIPTS_DIR/Mount VHDX"
    install -m 755 nautilus-scripts/Unmount-VHDX "$NAUTILUS_SCRIPTS_DIR/Unmount VHDX"
    echo "  ✓ Nautilus scripts installed"
fi

# Dolphin (KDE)
if command -v dolphin &> /dev/null; then
    DOLPHIN_SERVICEMENU_DIR="$HOME/.local/share/kservices5/ServiceMenus"
    mkdir -p "$DOLPHIN_SERVICEMENU_DIR"
    install -m 644 dolphin-servicemenu/vhdx-mount.desktop "$DOLPHIN_SERVICEMENU_DIR/vhdx-mount.desktop"
    echo "  ✓ Dolphin service menu installed"
fi

# Thunar (XFCE)
if command -v thunar &> /dev/null; then
    THUNAR_ACTIONS_DIR="$HOME/.config/Thunar"
    mkdir -p "$THUNAR_ACTIONS_DIR"
    cat > "$THUNAR_ACTIONS_DIR/uca.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<actions>
<action>
  <icon>drive-harddisk</icon>
  <name>Mount VHDX</name>
  <command>/usr/local/bin/mount-vhdx.sh %f</command>
  <description>Mount VHDX virtual disk</description>
  <patterns>*.vhdx;*.VHDX</patterns>
  <other-files/>
  <directories/>
</action>
<action>
  <icon>drive-harddisk</icon>
  <name>Unmount VHDX</name>
  <command>/usr/local/bin/unmount-vhdx.sh %f</command>
  <description>Unmount VHDX virtual disk</description>
  <patterns>*.vhdx;*.VHDX</patterns>
  <other-files/>
  <directories/>
</action>
</actions>
EOF
    echo "  ✓ Thunar custom actions installed"
fi

echo
echo "========================================="
echo "  Installation Complete!"
echo "========================================="
echo
echo "You can now mount VHDX files by:"
echo "  1. Double-clicking a .vhdx file in your file manager"
echo "  2. Right-clicking a .vhdx file and selecting 'Mount VHDX'"
echo "  3. Running: mount-vhdx.sh <file.vhdx>"
echo
echo "To unmount:"
echo "  - Right-click and select 'Unmount VHDX'"
echo "  - Run: unmount-vhdx.sh"
echo "  - Run: list-vhdx-mounts.sh (to see all mounted VHDX)"
echo
echo "IMPORTANT: Currently you will be prompted for sudo password."
echo
echo "─────────────────────────────────────────"
echo "For FULLY AUTOMATIC mounting without password:"
echo "─────────────────────────────────────────"
echo
read -p "Setup passwordless mounting? (Y/n) " -n 1 -r
echo
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    if [ -f "setup-passwordless.sh" ]; then
        ./setup-passwordless.sh
    else
        echo "Note: Run ./setup-passwordless.sh later for passwordless mounting"
    fi
else
    echo "You can enable passwordless mounting later by running:"
    echo "  ./setup-passwordless.sh"
    echo
fi
echo
