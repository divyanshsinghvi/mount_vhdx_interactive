#!/bin/bash
#
# test-vhdx-association.sh - Test if VHDX file associations work
#

echo "========================================="
echo "  VHDX File Association Test"
echo "========================================="
echo

# Check if MIME type is registered
echo "[1/4] Checking MIME type registration..."
if grep -r "application/x-vhdx" /usr/share/mime/packages/ &>/dev/null; then
    echo "✓ MIME type registered"
else
    echo "✗ MIME type NOT registered"
    echo "  Run: sudo update-mime-database /usr/share/mime/"
fi

# Check if desktop file exists
echo
echo "[2/4] Checking desktop file..."
if [ -f "/usr/share/applications/vhdx-mount.desktop" ]; then
    echo "✓ Desktop file exists"

    # Validate desktop file
    if command -v desktop-file-validate &>/dev/null; then
        if desktop-file-validate /usr/share/applications/vhdx-mount.desktop 2>/dev/null; then
            echo "✓ Desktop file is valid"
        else
            echo "⚠ Desktop file has warnings:"
            desktop-file-validate /usr/share/applications/vhdx-mount.desktop
        fi
    fi
else
    echo "✗ Desktop file NOT found"
    echo "  Run: ./install.sh"
fi

# Check default application
echo
echo "[3/4] Checking default application..."
DEFAULT_APP=$(xdg-mime query default application/x-vhdx 2>/dev/null)
if [ -n "$DEFAULT_APP" ]; then
    echo "✓ Default app set to: $DEFAULT_APP"
    if [ "$DEFAULT_APP" = "vhdx-mount.desktop" ]; then
        echo "✓ Correct application!"
    else
        echo "⚠ Wrong application. Should be: vhdx-mount.desktop"
        echo "  Fix: xdg-mime default vhdx-mount.desktop application/x-vhdx"
    fi
else
    echo "✗ No default application set"
    echo "  Fix: xdg-mime default vhdx-mount.desktop application/x-vhdx"
fi

# Check if mount script exists
echo
echo "[4/4] Checking mount script..."
if [ -x "/usr/local/bin/mount-vhdx.sh" ]; then
    echo "✓ Mount script exists and is executable"
else
    echo "✗ Mount script NOT found or not executable"
    echo "  Run: ./install.sh"
fi

echo
echo "========================================="
echo "  Summary"
echo "========================================="
echo

# Overall status
if grep -r "application/x-vhdx" /usr/share/mime/packages/ &>/dev/null && \
   [ -f "/usr/share/applications/vhdx-mount.desktop" ] && \
   [ "$(xdg-mime query default application/x-vhdx)" = "vhdx-mount.desktop" ] && \
   [ -x "/usr/local/bin/mount-vhdx.sh" ]; then
    echo "✓ Everything is configured correctly!"
    echo
    echo "To test:"
    echo "  1. Find a .vhdx file in your file manager"
    echo "  2. Double-click it"
    echo "  3. It should mount automatically"
    echo
    echo "If it still doesn't work:"
    echo "  - Log out and log back in"
    echo "  - Or run: ./fix-associations.sh"
else
    echo "⚠ Some components are missing or misconfigured"
    echo
    echo "To fix:"
    echo "  ./install.sh"
    echo "  ./fix-associations.sh"
    echo "  Log out and log back in"
fi

echo
