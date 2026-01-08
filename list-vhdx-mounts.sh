#!/bin/bash
#
# list-vhdx-mounts.sh - List all mounted VHDX files
#

echo "=== Mounted VHDX Files ==="
echo

MOUNT_FILES=(/tmp/vhdx_mount_*.info)
FOUND=0

for info_file in "${MOUNT_FILES[@]}"; do
    if [ -f "$info_file" ]; then
        source "$info_file"
        VHDX_NAME=$(basename "$VHDX_FILE" .vhdx)

        echo "Name: $VHDX_NAME"
        echo "File: $VHDX_FILE"
        echo "Device: $NBD_DEVICE"
        echo "Mounted at: $MOUNT_DIR"

        # Check if actually mounted
        if mountpoint -q "$MOUNT_DIR" 2>/dev/null; then
            echo "Status: ✓ Mounted"

            # Show disk usage
            df -h "$MOUNT_DIR" 2>/dev/null | tail -n 1 | awk '{print "Size: "$2" Used: "$3" Available: "$4" ("$5" used)"}'
        else
            echo "Status: ✗ Not mounted (stale)"
        fi

        echo
        FOUND=1
    fi
done

if [ $FOUND -eq 0 ]; then
    echo "No mounted VHDX files found."
fi

echo "To unmount, run: ./unmount-vhdx.sh"
