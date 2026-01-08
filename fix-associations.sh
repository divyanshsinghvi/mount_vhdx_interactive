#!/bin/bash
#
# fix-associations.sh - Fix .vhdx file associations
#

set -e

echo "========================================="
echo "  Fixing VHDX File Associations"
echo "========================================="
echo

# Update MIME database
echo "[1/5] Updating MIME database..."
sudo update-mime-database /usr/share/mime/
echo "✓ MIME database updated"

# Update desktop database
echo
echo "[2/5] Updating desktop database..."
sudo update-desktop-database /usr/share/applications/
echo "✓ Desktop database updated"

# Set default application for current user
echo
echo "[3/5] Setting default application..."
xdg-mime default vhdx-mount.desktop application/x-vhdx
echo "✓ Default application set"

# Verify association
echo
echo "[4/5] Verifying association..."
CURRENT_APP=$(xdg-mime query default application/x-vhdx)
if [ "$CURRENT_APP" = "vhdx-mount.desktop" ]; then
    echo "✓ Association verified: $CURRENT_APP"
else
    echo "⚠ Warning: Association is: $CURRENT_APP"
    echo "  Expected: vhdx-mount.desktop"
fi

# Update user's mimeapps.list
echo
echo "[5/5] Updating user MIME applications..."
mkdir -p ~/.config
MIMEAPPS="$HOME/.config/mimeapps.list"

# Remove old associations
sed -i '/application\/x-vhdx/d' "$MIMEAPPS" 2>/dev/null || true

# Add new association
if ! grep -q "application/x-vhdx=vhdx-mount.desktop" "$MIMEAPPS" 2>/dev/null; then
    # Ensure [Default Applications] section exists
    if ! grep -q "\[Default Applications\]" "$MIMEAPPS" 2>/dev/null; then
        echo "[Default Applications]" >> "$MIMEAPPS"
    fi

    # Add association
    sed -i '/\[Default Applications\]/a application/x-vhdx=vhdx-mount.desktop' "$MIMEAPPS"
fi

echo "✓ User MIME applications updated"

echo
echo "========================================="
echo "  Troubleshooting"
echo "========================================="
echo
echo "If .vhdx files still don't open:"
echo
echo "1. Log out and log back in (recommended)"
echo "   - This refreshes all desktop associations"
echo
echo "2. Or manually set association:"
echo "   - Right-click a .vhdx file"
echo "   - Properties → Open With"
echo "   - Choose 'Mount VHDX'"
echo "   - Click 'Set as default'"
echo
echo "3. Check current association:"
echo "   xdg-mime query default application/x-vhdx"
echo
echo "4. Test manually:"
echo "   mount-vhdx.sh /path/to/file.vhdx"
echo
