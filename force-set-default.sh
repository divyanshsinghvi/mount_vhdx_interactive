#!/bin/bash
#
# force-set-default.sh - Forcefully set VHDX as default (run if quick-fix doesn't work)
#

echo "═══════════════════════════════════════════"
echo "  Force Set VHDX Default Application"
echo "═══════════════════════════════════════════"
echo

# Method 1: Via desktop file manager settings
if command -v xdg-mime &>/dev/null; then
    echo "[Method 1] Setting via xdg-mime..."
    xdg-mime default vhdx-mount.desktop application/x-vhdx
    echo "✓ Done"
fi

# Method 2: Via gio (GNOME)
if command -v gio &>/dev/null; then
    echo "[Method 2] Setting via gio..."
    gio mime application/x-vhdx vhdx-mount.desktop
    echo "✓ Done"
fi

# Method 3: Directly edit mimeapps.list files
echo "[Method 3] Directly editing mimeapps.list files..."

for MIMEAPPS in \
    "$HOME/.config/mimeapps.list" \
    "$HOME/.local/share/applications/mimeapps.list" \
    "$HOME/.local/share/applications/defaults.list"
do
    if [ -f "$MIMEAPPS" ] || mkdir -p "$(dirname "$MIMEAPPS")" 2>/dev/null; then
        echo "  Updating: $MIMEAPPS"

        # Create if doesn't exist
        touch "$MIMEAPPS"

        # Remove old vhdx entries
        sed -i '/application\/x-vhdx/d' "$MIMEAPPS" 2>/dev/null || true

        # Add Default Applications section if missing
        if ! grep -q "\[Default Applications\]" "$MIMEAPPS" 2>/dev/null; then
            echo "[Default Applications]" >> "$MIMEAPPS"
        fi

        # Add our association
        sed -i '/\[Default Applications\]/a application/x-vhdx=vhdx-mount.desktop' "$MIMEAPPS"
    fi
done

echo "✓ All mimeapps.list files updated"
echo

# Method 4: Update system defaults
echo "[Method 4] Creating system defaults..."
sudo bash -c 'echo "application/x-vhdx=vhdx-mount.desktop" >> /usr/share/applications/defaults.list' 2>/dev/null || true
echo "✓ Done"

# Method 5: Update desktop database
echo "[Method 5] Updating desktop database..."
sudo update-desktop-database /usr/share/applications/ 2>/dev/null
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
echo "✓ Done"

# Verify
echo
echo "═══════════════════════════════════════════"
echo "  Verification"
echo "═══════════════════════════════════════════"
CURRENT=$(xdg-mime query default application/x-vhdx 2>/dev/null)
echo "Current default: ${CURRENT:-none}"
if [ "$CURRENT" = "vhdx-mount.desktop" ]; then
    echo "✓ SUCCESS! VHDX files set to open with Mount VHDX"
else
    echo "⚠ Not set correctly yet"
    echo
    echo "Try these manual steps:"
    echo "1. Right-click any .vhdx file"
    echo "2. Properties → Open With"
    echo "3. Select 'Mount VHDX' from list"
    echo "4. Click 'Set as default'"
    echo "5. Click 'OK' or 'Apply'"
fi

echo
echo "═══════════════════════════════════════════"
echo "  IMPORTANT: LOG OUT AND BACK IN!"
echo "═══════════════════════════════════════════"
echo
