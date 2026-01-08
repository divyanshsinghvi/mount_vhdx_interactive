#!/bin/bash
#
# mount-vhdx-rw.sh - Mount VHDX with READ-WRITE access (can modify files)
#

# Simply call mount-vhdx.sh with 'rw' parameter
exec "$(dirname "$0")/mount-vhdx.sh" "$@" rw
