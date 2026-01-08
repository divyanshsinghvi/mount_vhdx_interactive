#!/bin/bash
#
# mount-vhdx-rw.sh - Mount VHDX with READ-WRITE access (can modify files)
#

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Call mount-vhdx.sh with 'rw' parameter and skip the dialog
"$SCRIPT_DIR/mount-vhdx.sh" "$1" rw skip-dialog
