#!/bin/bash
#
# mount-vhdx.sh - Mount a VHDX file with GUI notifications
#

set -e

VHDX_FILE="$1"
MOUNT_MODE="${2:-rw}"  # Default to read-write (rw), can be 'ro' for read-only
SKIP_DIALOG="${3:-}"   # If set to "skip-dialog", don't ask user for mode
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    local type="${3:-info}"  # info, warning, error

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
    notify "VHDX Mount Error" "$1" "error"
    exit 1
}

# Check if file provided
if [ -z "$VHDX_FILE" ]; then
    if [ -n "$HAS_ZENITY" ]; then
        VHDX_FILE=$(zenity --file-selection --title="Select VHDX File" \
                    --file-filter="VHDX files (*.vhdx) | *.vhdx" \
                    --file-filter="All files | *" 2>/dev/null)
        [ -z "$VHDX_FILE" ] && exit 0

        # Ask for mount mode only if not skipping dialog
        if [ "$SKIP_DIALOG" != "skip-dialog" ]; then
            if zenity --question --title="Mount Mode" \
                      --text="Mount with write access?\n\nYes = Read-Write (can modify files)\nNo = Read-Only (safe mode)" \
                      --width=400 2>/dev/null; then
                MOUNT_MODE="rw"
            else
                MOUNT_MODE="ro"
            fi
        fi
    else
        error_exit "No VHDX file specified.\n\nUsage: $0 <vhdx-file> [rw|ro]\n\nExamples:\n  $0 disk.vhdx rw    # Read-write (default)\n  $0 disk.vhdx ro    # Read-only"
    fi
fi

# Check if file exists
if [ ! -f "$VHDX_FILE" ]; then
    error_exit "File not found: $VHDX_FILE"
fi

# Get absolute path
VHDX_FILE=$(readlink -f "$VHDX_FILE")
VHDX_NAME=$(basename "$VHDX_FILE" .vhdx)

# Check for required tools
if ! command -v qemu-nbd &> /dev/null; then
    error_exit "qemu-nbd not found!\n\nInstall with:\n  sudo apt install qemu-utils  (Debian/Ubuntu)\n  sudo dnf install qemu-img  (Fedora)\n  sudo pacman -S qemu  (Arch)"
fi

# Display mount mode
MODE_TEXT="Read-Write (can modify files)"
if [ "$MOUNT_MODE" = "ro" ]; then
    MODE_TEXT="Read-Only (safe mode)"
fi

# Load NBD module
notify "VHDX Mount" "Mounting $VHDX_NAME...\nMode: $MODE_TEXT"
sudo modprobe nbd max_part=8 2>/dev/null || error_exit "Failed to load NBD kernel module.\n\nRun: sudo modprobe nbd max_part=8"

# Find available NBD device
NBD_DEVICE=""
for i in {0..15}; do
    if [ ! -e "/sys/block/nbd$i/pid" ]; then
        NBD_DEVICE="/dev/nbd$i"
        break
    fi
done

if [ -z "$NBD_DEVICE" ]; then
    error_exit "No available NBD device found.\n\nTry unmounting other VHDX files first."
fi

# Connect VHDX to NBD device
sudo qemu-nbd --connect="$NBD_DEVICE" "$VHDX_FILE" || error_exit "Failed to connect VHDX to $NBD_DEVICE"

# Wait for device to be ready
sleep 2

# Probe for partitions
sudo partprobe "$NBD_DEVICE" 2>/dev/null || true
sleep 1

# Create mount directory
MOUNT_BASE="/media/$USER/vhdx"
MOUNT_DIR="$MOUNT_BASE/$VHDX_NAME"
sudo mkdir -p "$MOUNT_DIR"

# Try to detect and mount partitions
MOUNTED=0
if [ -e "${NBD_DEVICE}p1" ]; then
    # Has partitions
    for part in ${NBD_DEVICE}p*; do
        [ -e "$part" ] || continue

        PART_NUM=$(echo "$part" | grep -o '[0-9]*$')
        PART_MOUNT="$MOUNT_DIR"

        if [ $(ls ${NBD_DEVICE}p* 2>/dev/null | wc -l) -gt 1 ]; then
            PART_MOUNT="$MOUNT_DIR/partition$PART_NUM"
            sudo mkdir -p "$PART_MOUNT"
        fi

        # Try mounting with different filesystems
        if sudo mount -o $MOUNT_MODE "$part" "$PART_MOUNT" 2>/dev/null; then
            echo "Mounted $part to $PART_MOUNT ($MOUNT_MODE)"
            MOUNTED=1
        elif sudo mount -t ntfs-3g -o $MOUNT_MODE,uid=$(id -u),gid=$(id -g) "$part" "$PART_MOUNT" 2>/dev/null; then
            echo "Mounted $part (NTFS) to $PART_MOUNT ($MOUNT_MODE)"
            MOUNTED=1
        fi
    done
else
    # No partitions, try mounting device directly
    if sudo mount -o $MOUNT_MODE "$NBD_DEVICE" "$MOUNT_DIR" 2>/dev/null; then
        echo "Mounted $NBD_DEVICE to $MOUNT_DIR ($MOUNT_MODE)"
        MOUNTED=1
    elif sudo mount -t ntfs-3g -o $MOUNT_MODE,uid=$(id -u),gid=$(id -g) "$NBD_DEVICE" "$MOUNT_DIR" 2>/dev/null; then
        echo "Mounted $NBD_DEVICE (NTFS) to $MOUNT_DIR ($MOUNT_MODE)"
        MOUNTED=1
    fi
fi

if [ $MOUNTED -eq 0 ]; then
    sudo qemu-nbd --disconnect "$NBD_DEVICE"
    error_exit "Failed to mount any partitions.\n\nThe VHDX may use an unsupported filesystem."
fi

# Save mount info for unmounting
MOUNT_INFO_FILE="/tmp/vhdx_mount_${VHDX_NAME}.info"
echo "NBD_DEVICE=$NBD_DEVICE" > "$MOUNT_INFO_FILE"
echo "MOUNT_DIR=$MOUNT_DIR" >> "$MOUNT_INFO_FILE"
echo "VHDX_FILE=$VHDX_FILE" >> "$MOUNT_INFO_FILE"

# Change ownership
sudo chown -R $USER:$USER "$MOUNT_DIR" 2>/dev/null || true

# Success notification
MODE_DESC="Read-Write ✍"
[ "$MOUNT_MODE" = "ro" ] && MODE_DESC="Read-Only 👁"
notify "VHDX Mounted" "Mounted: $VHDX_NAME\nLocation: $MOUNT_DIR\nMode: $MODE_DESC\n\nOpening file manager..."

# Open in file manager
if command -v xdg-open &> /dev/null; then
    xdg-open "$MOUNT_DIR" &
elif command -v nautilus &> /dev/null; then
    nautilus "$MOUNT_DIR" &
elif command -v dolphin &> /dev/null; then
    dolphin "$MOUNT_DIR" &
elif command -v thunar &> /dev/null; then
    thunar "$MOUNT_DIR" &
fi

exit 0
