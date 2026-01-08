#!/bin/bash
#
# unmount-vhdx.sh - Unmount a VHDX file with GUI notifications
#

VHDX_FILE="$1"

# Check if zenity is available for GUI dialogs
if command -v zenity &> /dev/null; then
    HAS_ZENITY=1
elif command -v kdialog &> /dev/null; then
    HAS_KDIALOG=1
elif command -v notify-send &> /dev/null; then
    HAS_NOTIFY=1
fi

notify() {
    local title="$1"
    local message="$2"
    local type="${3:-info}"

    echo "[$title] $message"

    if [ -n "$HAS_ZENITY" ]; then
        if [ "$type" = "error" ]; then
            zenity --error --title="$title" --text="$message" --width=400 2>/dev/null || true
        else
            zenity --info --title="$title" --text="$message" --width=400 --timeout=5 2>/dev/null || true
        fi
    elif [ -n "$HAS_KDIALOG" ]; then
        if [ "$type" = "error" ]; then
            kdialog --error "$message" --title "$title" 2>/dev/null || true
        else
            kdialog --passivepopup "$message" 5 --title "$title" 2>/dev/null || true
        fi
    elif [ -n "$HAS_NOTIFY" ]; then
        if [ "$type" = "error" ]; then
            notify-send -u critical "$title" "$message" 2>/dev/null || true
        else
            notify-send "$title" "$message" 2>/dev/null || true
        fi
    fi
}

error_exit() {
    notify "VHDX Unmount Error" "$1" "error"
    exit 1
}

# If no file specified, show list of mounted VHDX
if [ -z "$VHDX_FILE" ]; then
    MOUNT_FILES=(/tmp/vhdx_mount_*.info)

    if [ ${#MOUNT_FILES[@]} -eq 0 ] || [ ! -f "${MOUNT_FILES[0]}" ]; then
        error_exit "No mounted VHDX files found."
    fi

    # Build list for selection
    if [ -n "$HAS_ZENITY" ]; then
        CHOICES=""
        for info_file in "${MOUNT_FILES[@]}"; do
            [ -f "$info_file" ] || continue
            source "$info_file"
            VHDX_NAME=$(basename "$VHDX_FILE" .vhdx)
            CHOICES="$CHOICES FALSE $VHDX_NAME $MOUNT_DIR"
        done

        SELECTED=$(zenity --list --radiolist --title="Unmount VHDX" \
                   --text="Select VHDX to unmount:" \
                   --column="Select" --column="Name" --column="Mount Point" \
                   $CHOICES 2>/dev/null)

        [ -z "$SELECTED" ] && exit 0

        # Find the info file for selected VHDX
        for info_file in "${MOUNT_FILES[@]}"; do
            source "$info_file"
            VHDX_NAME=$(basename "$VHDX_FILE" .vhdx)
            if [ "$VHDX_NAME" = "$SELECTED" ]; then
                MOUNT_INFO_FILE="$info_file"
                break
            fi
        done
    else
        # Use first mounted VHDX
        MOUNT_INFO_FILE="${MOUNT_FILES[0]}"
        source "$MOUNT_INFO_FILE"
    fi
else
    # Find mount info by VHDX filename
    VHDX_FILE=$(readlink -f "$VHDX_FILE")
    VHDX_NAME=$(basename "$VHDX_FILE" .vhdx)
    MOUNT_INFO_FILE="/tmp/vhdx_mount_${VHDX_NAME}.info"

    if [ ! -f "$MOUNT_INFO_FILE" ]; then
        error_exit "Mount info not found for: $VHDX_NAME\n\nIt may not be mounted."
    fi

    source "$MOUNT_INFO_FILE"
fi

notify "VHDX Unmount" "Unmounting $(basename "$VHDX_FILE" .vhdx)..."

# Unmount all mounts under MOUNT_DIR
if [ -d "$MOUNT_DIR" ]; then
    for mount in $(mount | grep "$MOUNT_DIR" | awk '{print $3}' | sort -r); do
        echo "Unmounting $mount..."
        sudo umount "$mount" 2>/dev/null || true
    done
fi

# Disconnect NBD device
if [ -n "$NBD_DEVICE" ] && [ -e "$NBD_DEVICE" ]; then
    echo "Disconnecting $NBD_DEVICE..."
    sudo qemu-nbd --disconnect "$NBD_DEVICE" 2>/dev/null || true
fi

# Clean up mount directory
if [ -d "$MOUNT_DIR" ]; then
    sudo rmdir "$MOUNT_DIR" 2>/dev/null || true
fi

# Remove mount info file
rm -f "$MOUNT_INFO_FILE"

notify "VHDX Unmounted" "Successfully unmounted: $(basename "$VHDX_FILE" .vhdx)"

exit 0
