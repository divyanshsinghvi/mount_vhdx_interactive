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
    echo
fi

# Now fix associations
echo "Fixing file associations..."
echo

# Update databases
sudo update-mime-database /usr/share/mime/
sudo update-desktop-database /usr/share/applications/

# Set default application
xdg-mime default vhdx-mount.desktop application/x-vhdx

# Update user mimeapps.list
mkdir -p ~/.config
MIMEAPPS="$HOME/.config/mimeapps.list"

# Remove old entries
sed -i '/application\/x-vhdx/d' "$MIMEAPPS" 2>/dev/null || true

# Add to [Default Applications]
if ! grep -q "\[Default Applications\]" "$MIMEAPPS" 2>/dev/null; then
    echo "[Default Applications]" >> "$MIMEAPPS"
fi
sed -i '/\[Default Applications\]/a application/x-vhdx=vhdx-mount.desktop' "$MIMEAPPS"

# Add to [Added Associations]
if ! grep -q "\[Added Associations\]" "$MIMEAPPS" 2>/dev/null; then
    echo "[Added Associations]" >> "$MIMEAPPS"
fi
sed -i '/\[Added Associations\]/a application/x-vhdx=vhdx-mount.desktop;' "$MIMEAPPS"

echo "✓ File associations fixed!"
echo

# Verify
echo "Verifying..."
CURRENT=$(xdg-mime query default application/x-vhdx)
if [ "$CURRENT" = "vhdx-mount.desktop" ]; then
    echo "✓ Association verified: $CURRENT"
else
    echo "⚠ Current association: $CURRENT"
fi

echo
echo "========================================="
echo "  Next Steps"
echo "========================================="
echo
echo "1. IMPORTANT: Log out and log back in"
echo "   (This refreshes your desktop session)"
echo
echo "2. After logging back in:"
echo "   - Find a .vhdx file"
echo "   - Double-click it"
echo "   - Should open with Mount VHDX!"
echo
echo "3. If still not working, right-click the .vhdx file:"
echo "   - Properties → Open With"
echo "   - Select 'Mount VHDX'"
echo "   - Click 'Set as default'"
echo
echo "4. Or test manually:"
echo "   mount-vhdx.sh /path/to/file.vhdx"
echo
