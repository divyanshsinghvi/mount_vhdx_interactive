#!/bin/bash
#
# mount-vhdx-ro.sh - Mount VHDX with READ-ONLY access (safe mode)
#

# Simply call mount-vhdx.sh with 'ro' parameter
exec "$(dirname "$0")/mount-vhdx.sh" "$@" ro
