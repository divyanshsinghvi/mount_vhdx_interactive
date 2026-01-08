#!/bin/bash
#
# quick-fix.sh - Quick fix for .vhdx file association
#

set -e

echo "========================================="
echo "  VHDX Quick Fix - File Associations"
echo "========================================="
echo

# Check if we need to run install.sh first
if [ ! -f "/usr/share/applications/vhdx-mount.desktop" ]; then
    echo "Installation not complete. Running installer..."
    echo
    ./install.sh
    exit 0
fi

# Now fix associations
echo "Fixing file associations..."
echo

# Update databases first
echo "Updating MIME and desktop databases..."
sudo update-mime-database /usr/share/mime/ 2>/dev/null
sudo update-desktop-database /usr/share/applications/ 2>/dev/null

# Wait for databases to update
sleep 2

# Create necessary directories
mkdir -p ~/.config
mkdir -p ~/.local/share/applications

# Fix mimeapps.list in ~/.config
echo "Updating ~/.config/mimeapps.list..."
MIMEAPPS="$HOME/.config/mimeapps.list"
touch "$MIMEAPPS"

# Remove old entries
sed -i '/application\/x-vhdx/d' "$MIMEAPPS" 2>/dev/null || true

# Ensure sections exist
if ! grep -q "\[Default Applications\]" "$MIMEAPPS"; then
    echo "[Default Applications]" >> "$MIMEAPPS"
fi
if ! grep -q "\[Added Associations\]" "$MIMEAPPS"; then
    echo "" >> "$MIMEAPPS"
    echo "[Added Associations]" >> "$MIMEAPPS"
fi

# Add association to both sections
sed -i '/\[Default Applications\]/a application/x-vhdx=vhdx-mount.desktop' "$MIMEAPPS"
sed -i '/\[Added Associations\]/a application/x-vhdx=vhdx-mount.desktop;' "$MIMEAPPS"

# Also fix local mimeapps.list if it exists
LOCAL_MIMEAPPS="$HOME/.local/share/applications/mimeapps.list"
if [ -f "$LOCAL_MIMEAPPS" ]; then
    echo "Updating ~/.local/share/applications/mimeapps.list..."
    sed -i '/application\/x-vhdx/d' "$LOCAL_MIMEAPPS" 2>/dev/null || true
    if ! grep -q "\[Default Applications\]" "$LOCAL_MIMEAPPS"; then
        echo "[Default Applications]" >> "$LOCAL_MIMEAPPS"
    fi
    sed -i '/\[Default Applications\]/a application/x-vhdx=vhdx-mount.desktop' "$LOCAL_MIMEAPPS"
fi

# Set via xdg-mime
echo "Setting default via xdg-mime..."
xdg-mime default vhdx-mount.desktop application/x-vhdx 2>/dev/null || true

# Also try gio (GNOME)
if command -v gio &>/dev/null; then
    echo "Setting via gio..."
    gio mime application/x-vhdx vhdx-mount.desktop 2>/dev/null || true
fi

echo "✓ File associations fixed!"
echo

# Verify
echo "Verifying association..."
CURRENT=$(xdg-mime query default application/x-vhdx 2>/dev/null)
if [ "$CURRENT" = "vhdx-mount.desktop" ]; then
    echo "✓ Association verified: $CURRENT"
    echo "✓ .vhdx files should now open with Mount VHDX!"
else
    echo "⚠ Current association: ${CURRENT:-none}"
    echo "  Expected: vhdx-mount.desktop"
    echo
    echo "  This might work after logging out/in"
fi

echo
echo "========================================="
echo "  Final Steps"
echo "========================================="
echo
echo "1. LOG OUT and LOG BACK IN (required!)"
echo "   File associations are cached by your desktop"
echo
echo "2. After logging back in, test:"
echo "   - Double-click a .vhdx file"
echo "   - It should mount automatically!"
echo
echo "3. If STILL not working after logging back in:"
echo "   - Right-click the .vhdx file"
echo "   - Properties → Open With"
echo "   - Select 'Mount VHDX'"
echo "   - Click 'Set as default' + 'Apply'"
echo
echo "4. Manual test (always works):"
echo "   mount-vhdx-rw.sh /path/to/file.vhdx"
echo
echo "═══════════════════════════════════════════"
echo "  ⚠️  LOG OUT AND BACK IN NOW! ⚠️"
echo "═══════════════════════════════════════════"
echo
