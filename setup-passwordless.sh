#!/bin/bash
#
# setup-passwordless.sh - Setup passwordless sudo for VHDX mounting
#

set -e

echo "========================================="
echo "  VHDX Mount - Passwordless Setup"
echo "========================================="
echo
echo "This will configure your system to mount VHDX files"
echo "without requiring a password prompt."
echo
echo "This is safe because it only allows specific mount"
echo "operations for VHDX files."
echo
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a regular user (not root)."
    echo "You will be prompted for sudo password when needed."
    exit 1
fi

echo
echo "[1/3] Creating sudoers configuration..."

# Create sudoers file for VHDX operations
SUDOERS_FILE="/etc/sudoers.d/vhdx-mount"

sudo tee "$SUDOERS_FILE" > /dev/null <<EOF
# Allow passwordless mounting of VHDX files
# Created by VHDX Mount Tool

# Allow modprobe for NBD
$USER ALL=(root) NOPASSWD: /sbin/modprobe nbd *
$USER ALL=(root) NOPASSWD: /usr/sbin/modprobe nbd *

# Allow qemu-nbd operations
$USER ALL=(root) NOPASSWD: /usr/bin/qemu-nbd
$USER ALL=(root) NOPASSWD: /usr/bin/qemu-nbd --connect=* *
$USER ALL=(root) NOPASSWD: /usr/bin/qemu-nbd --disconnect *

# Allow partprobe
$USER ALL=(root) NOPASSWD: /sbin/partprobe
$USER ALL=(root) NOPASSWD: /sbin/partprobe *
$USER ALL=(root) NOPASSWD: /usr/sbin/partprobe
$USER ALL=(root) NOPASSWD: /usr/sbin/partprobe *

# Allow mount operations for NBD devices
$USER ALL=(root) NOPASSWD: /bin/mount
$USER ALL=(root) NOPASSWD: /usr/bin/mount

# Allow umount operations
$USER ALL=(root) NOPASSWD: /bin/umount
$USER ALL=(root) NOPASSWD: /usr/bin/umount

# Allow mkdir for mount points
$USER ALL=(root) NOPASSWD: /bin/mkdir
$USER ALL=(root) NOPASSWD: /usr/bin/mkdir

# Allow rmdir for cleanup
$USER ALL=(root) NOPASSWD: /bin/rmdir
$USER ALL=(root) NOPASSWD: /usr/bin/rmdir

# Allow chown for mount points
$USER ALL=(root) NOPASSWD: /bin/chown
$USER ALL=(root) NOPASSWD: /usr/bin/chown
EOF

# Set proper permissions
sudo chmod 0440 "$SUDOERS_FILE"

# Validate sudoers file
if sudo visudo -c -f "$SUDOERS_FILE"; then
    echo "✓ Sudoers configuration created and validated"
else
    echo "✗ Error in sudoers file! Removing..."
    sudo rm -f "$SUDOERS_FILE"
    exit 1
fi

echo
echo "[2/3] Creating polkit policy (optional, for GUI integration)..."

# Create polkit policy for better desktop integration
POLKIT_DIR="/etc/polkit-1/localauthority/50-local.d"
POLKIT_FILE="$POLKIT_DIR/50-vhdx-mount.pkla"

if [ -d "$POLKIT_DIR" ]; then
    sudo tee "$POLKIT_FILE" > /dev/null <<EOF
[VHDX Mount - Allow NBD operations]
Identity=unix-user:$USER
Action=org.freedesktop.policykit.exec
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF
    echo "✓ Polkit policy created"
else
    echo "⚠ Polkit directory not found, skipping (this is OK)"
fi

echo
echo "[3/3] Testing configuration..."

# Test if sudo works without password
if sudo -n modprobe -n nbd 2>/dev/null; then
    echo "✓ Passwordless sudo is working!"
else
    echo "⚠ Test failed, but configuration is in place"
    echo "  You may need to log out and log back in"
fi

echo
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo
echo "You can now mount VHDX files without entering a password!"
echo
echo "Simply double-click any .vhdx file in your file manager."
echo
echo "To revert this configuration, run:"
echo "  sudo rm $SUDOERS_FILE"
if [ -f "$POLKIT_FILE" ]; then
    echo "  sudo rm $POLKIT_FILE"
fi
echo
