#!/bin/bash
#
# mount-vhdx-ro.sh - Mount VHDX with READ-ONLY access (safe mode)
#

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Call mount-vhdx.sh with 'ro' parameter and skip the dialog
"$SCRIPT_DIR/mount-vhdx.sh" "$1" ro skip-dialog
