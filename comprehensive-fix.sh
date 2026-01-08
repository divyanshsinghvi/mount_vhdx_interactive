#!/bin/bash
#
# comprehensive-fix.sh - Complete VHDX file association fix
#

set -e

echo "═══════════════════════════════════════════════════"
echo "  COMPREHENSIVE VHDX FILE ASSOCIATION FIX"
echo "═══════════════════════════════════════════════════"
echo

# Check if running with proper permissions
if [ ! -f "/usr/share/applications/vhdx-mount.desktop" ]; then
    echo "ERROR: Installation not found!"
    echo "Please run: ./install.sh first"
    exit 1
fi

echo "[Step 1/7] Validating desktop file..."
# Validate desktop file
if command -v desktop-file-validate &>/dev/null; then
    if desktop-file-validate /usr/share/applications/vhdx-mount.desktop 2>&1; then
        echo "✓ Desktop file is valid"
    else
        echo "⚠ Desktop file has warnings (this is OK)"
    fi
else
    echo "✓ Desktop file exists"
fi

echo
echo "[Step 2/7] Updating system MIME database..."
# Update system MIME database
sudo update-mime-database /usr/share/mime/
echo "✓ System MIME database updated"

echo
echo "[Step 3/7] Updating desktop database..."
# Update desktop database
sudo update-desktop-database /usr/share/applications/
echo "✓ Desktop database updated"

# Wait for system to process
sleep 2

echo
echo "[Step 4/7] Setting system-wide defaults..."
# Create system defaults if needed
SYSTEM_DEFAULTS="/usr/share/applications/defaults.list"
if [ ! -f "$SYSTEM_DEFAULTS" ]; then
    sudo touch "$SYSTEM_DEFAULTS"
fi

# Add to system defaults (if not already there)
if ! sudo grep -q "application/x-vhdx=vhdx-mount.desktop" "$SYSTEM_DEFAULTS" 2>/dev/null; then
    echo "application/x-vhdx=vhdx-mount.desktop" | sudo tee -a "$SYSTEM_DEFAULTS" > /dev/null
    echo "✓ Added to system defaults"
else
    echo "✓ Already in system defaults"
fi

echo
echo "[Step 5/7] Setting user-level associations..."
# Create all necessary directories
mkdir -p ~/.config
mkdir -p ~/.local/share/applications

# Fix ~/.config/mimeapps.list
MIMEAPPS="$HOME/.config/mimeapps.list"
touch "$MIMEAPPS"

# Remove any existing vhdx lines
sed -i '/application\/x-vhdx/d' "$MIMEAPPS" 2>/dev/null || true

# Ensure both sections exist
if ! grep -q "^\[Default Applications\]" "$MIMEAPPS"; then
    echo "[Default Applications]" >> "$MIMEAPPS"
fi
if ! grep -q "^\[Added Associations\]" "$MIMEAPPS"; then
    echo "" >> "$MIMEAPPS"
    echo "[Added Associations]" >> "$MIMEAPPS"
fi

# Add to Default Applications
sed -i '/^\[Default Applications\]/a application/x-vhdx=vhdx-mount.desktop' "$MIMEAPPS"

# Add to Added Associations
sed -i '/^\[Added Associations\]/a application/x-vhdx=vhdx-mount.desktop;' "$MIMEAPPS"

echo "✓ Updated ~/.config/mimeapps.list"

# Also fix ~/.local/share/applications/mimeapps.list
LOCAL_MIMEAPPS="$HOME/.local/share/applications/mimeapps.list"
touch "$LOCAL_MIMEAPPS"
sed -i '/application\/x-vhdx/d' "$LOCAL_MIMEAPPS" 2>/dev/null || true
if ! grep -q "^\[Default Applications\]" "$LOCAL_MIMEAPPS"; then
    echo "[Default Applications]" >> "$LOCAL_MIMEAPPS"
fi
sed -i '/^\[Default Applications\]/a application/x-vhdx=vhdx-mount.desktop' "$LOCAL_MIMEAPPS"
echo "✓ Updated ~/.local/share/applications/mimeapps.list"

echo
echo "[Step 6/7] Setting via xdg-mime and gio..."
# Set via xdg-mime
xdg-mime default vhdx-mount.desktop application/x-vhdx 2>/dev/null && echo "✓ Set via xdg-mime" || echo "⚠ xdg-mime failed"

# Set via gio (GNOME)
if command -v gio &>/dev/null; then
    gio mime application/x-vhdx vhdx-mount.desktop 2>/dev/null && echo "✓ Set via gio" || echo "⚠ gio not available"
fi

echo
echo "[Step 7/7] Verifying configuration..."
# Verify MIME type exists
if grep -r "application/x-vhdx" /usr/share/mime/ &>/dev/null; then
    echo "✓ MIME type registered in system"
else
    echo "✗ MIME type NOT found in system!"
fi

# Verify desktop file
if [ -f "/usr/share/applications/vhdx-mount.desktop" ]; then
    echo "✓ Desktop file exists in system"
else
    echo "✗ Desktop file NOT found!"
fi

# Check what's currently set
CURRENT=$(xdg-mime query default application/x-vhdx 2>/dev/null)
echo
echo "Current default application: ${CURRENT:-NONE}"

if [ "$CURRENT" = "vhdx-mount.desktop" ]; then
    echo "✓ Association is correctly set!"
else
    echo "✗ Association not set correctly"
fi

# Show mimeapps.list contents
echo
echo "═══════════════════════════════════════════════════"
echo "  Current Configuration"
echo "═══════════════════════════════════════════════════"
echo
echo "~/.config/mimeapps.list:"
grep "vhdx" ~/.config/mimeapps.list 2>/dev/null || echo "  (no vhdx entries)"
echo
echo "~/.local/share/applications/mimeapps.list:"
grep "vhdx" ~/.local/share/applications/mimeapps.list 2>/dev/null || echo "  (no vhdx entries)"

echo
echo "═══════════════════════════════════════════════════"
echo "  NEXT STEPS"
echo "═══════════════════════════════════════════════════"
echo
echo "✅ Configuration updated!"
echo
echo "Now you MUST do ONE of these:"
echo
echo "Option A: Restart desktop session (fastest)"
echo "  1. Press Ctrl+Alt+F2 (or F3)"
echo "  2. Login"
echo "  3. Type: DISPLAY=:0 killall gnome-shell"
echo "     (or: killall plasmashell for KDE)"
echo "  4. Press Ctrl+Alt+F1 to return"
echo
echo "Option B: Log out and log back in"
echo "  Click your name → Log Out → Log back in"
echo
echo "Option C: Reboot (most reliable)"
echo "  sudo reboot"
echo
echo "═══════════════════════════════════════════════════"
echo
echo "If STILL not working after reboot:"
echo "  Run: ./show-manual-instructions.sh"
echo
