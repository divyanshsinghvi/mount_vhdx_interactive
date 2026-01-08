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
sudo install -m 755 mount-vhdx-rw.sh /usr/local/bin/mount-vhdx-rw.sh
sudo install -m 755 mount-vhdx-ro.sh /usr/local/bin/mount-vhdx-ro.sh
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
sudo install -m 644 vhdx-mount-rw.desktop /usr/share/applications/vhdx-mount-rw.desktop
sudo install -m 644 vhdx-mount-ro.desktop /usr/share/applications/vhdx-mount-ro.desktop
sudo install -m 644 vhdx-unmount.desktop /usr/share/applications/vhdx-unmount.desktop
sudo update-desktop-database /usr/share/applications/
echo "✓ Desktop entries installed"

# Set default application for .vhdx files
echo
echo "[5/6] Setting default application..."
MIME_TYPES=("application/x-vhdx" "application/vnd.ms-vhdx" "application/x-vhdx-disk")

# First, update databases to ensure desktop file is recognized
sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
sudo update-mime-database /usr/share/mime/ 2>/dev/null || true

# Wait a moment for databases to update
sleep 1

# Set via xdg-mime
for MIME_TYPE in "${MIME_TYPES[@]}"; do
    xdg-mime default vhdx-mount.desktop "$MIME_TYPE" 2>/dev/null || true
done

# Also update mimeapps.list directly (multiple locations for compatibility)
mkdir -p ~/.config
mkdir -p ~/.local/share/applications

# Update user's mimeapps.list
MIMEAPPS="$HOME/.config/mimeapps.list"
touch "$MIMEAPPS"

# Remove any existing vhdx associations
for MIME_TYPE in "${MIME_TYPES[@]}"; do
    sed -i "\|$MIME_TYPE|d" "$MIMEAPPS" 2>/dev/null || true
done

# Ensure sections exist
if ! grep -q "\[Default Applications\]" "$MIMEAPPS" 2>/dev/null; then
    echo "[Default Applications]" >> "$MIMEAPPS"
fi
if ! grep -q "\[Added Associations\]" "$MIMEAPPS" 2>/dev/null; then
    echo "" >> "$MIMEAPPS"
    echo "[Added Associations]" >> "$MIMEAPPS"
fi

# Add to both sections
for MIME_TYPE in "${MIME_TYPES[@]}"; do
    sed -i "/\[Default Applications\]/a $MIME_TYPE=vhdx-mount.desktop" "$MIMEAPPS"
    sed -i "/\[Added Associations\]/a $MIME_TYPE=vhdx-mount.desktop;" "$MIMEAPPS"
done

# Also update local applications list
LOCAL_MIMEAPPS="$HOME/.local/share/applications/mimeapps.list"
if [ -f "$LOCAL_MIMEAPPS" ]; then
    for MIME_TYPE in "${MIME_TYPES[@]}"; do
        sed -i "\|$MIME_TYPE|d" "$LOCAL_MIMEAPPS" 2>/dev/null || true
    done
    if ! grep -q "\[Default Applications\]" "$LOCAL_MIMEAPPS" 2>/dev/null; then
        echo "[Default Applications]" >> "$LOCAL_MIMEAPPS"
    fi
    for MIME_TYPE in "${MIME_TYPES[@]}"; do
        sed -i "/\[Default Applications\]/a $MIME_TYPE=vhdx-mount.desktop" "$LOCAL_MIMEAPPS"
    done
fi

# Verify the association was set
DEFAULT_OK="false"
for MIME_TYPE in "${MIME_TYPES[@]}"; do
    CURRENT_APP=$(xdg-mime query default "$MIME_TYPE" 2>/dev/null)
    if [ "$CURRENT_APP" = "vhdx-mount.desktop" ]; then
        DEFAULT_OK="true"
        break
    fi
done
if [ "$DEFAULT_OK" = "true" ]; then
    echo "✓ Default application set successfully"
else
    echo "⚠ Default set to: ${CURRENT_APP:-none}, expected vhdx-mount.desktop"
    echo "  You may need to log out and back in"
fi

# Install file manager scripts
echo
echo "[6/6] Installing file manager integration..."

# Nautilus (GNOME Files)
if command -v nautilus &> /dev/null; then
    NAUTILUS_SCRIPTS_DIR="$HOME/.local/share/nautilus/scripts"
    mkdir -p "$NAUTILUS_SCRIPTS_DIR"
    install -m 755 nautilus-scripts/Mount-VHDX "$NAUTILUS_SCRIPTS_DIR/Mount VHDX"
    install -m 755 nautilus-scripts/Mount-VHDX-ReadWrite "$NAUTILUS_SCRIPTS_DIR/Mount VHDX (Read-Write)"
    install -m 755 nautilus-scripts/Mount-VHDX-ReadOnly "$NAUTILUS_SCRIPTS_DIR/Mount VHDX (Read-Only)"
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
echo "IMPORTANT NEXT STEPS:"
echo "─────────────────────────────────────────"
echo
echo "1. LOG OUT and LOG BACK IN (required!)"
echo "   This refreshes your desktop file associations"
echo
echo "2. After logging back in, test by:"
echo "   - Double-clicking any .vhdx file"
echo "   - It should mount automatically!"
echo
echo "If .vhdx files still don't open automatically:"
echo "   - Run: xdg-mime default vhdx-mount.desktop application/x-vhdx"
echo "   - Run: xdg-mime default vhdx-mount.desktop application/vnd.ms-vhdx"
echo "   - Run: xdg-mime default vhdx-mount.desktop application/x-vhdx-disk"
echo "   - Then log out/in again"
echo
echo "─────────────────────────────────────────"
echo "For FULLY AUTOMATIC mounting without password:"
echo "─────────────────────────────────────────"
echo
read -p "Setup passwordless mounting now? (Y/n) " -n 1 -r
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
echo "═══════════════════════════════════════════"
echo "  ⚠️  REMEMBER TO LOG OUT AND BACK IN! ⚠️"
echo "═══════════════════════════════════════════"
echo
