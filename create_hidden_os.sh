#!/bin/bash
# Create a VeraCrypt hidden volume containing the Internet Computer OS ISO.
# The Internet Computer repository must be checked out adjacent to this one
# and built before running this script.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IC_DIR="$SCRIPT_DIR/../internetcomputer"
ISO="$IC_DIR/build/anonymOS.iso"
OUTER_VOL="$SCRIPT_DIR/anonymOS_outer.hc"
HIDDEN_VOL="$SCRIPT_DIR/anonymOS_hidden.hc"
MOUNT_DIR="$SCRIPT_DIR/hidden_mount"

if [ ! -f "$ISO" ]; then
    echo "OS ISO not found at $ISO"
    echo "Build it first: (cd \"$IC_DIR\" && make build)"
    exit 1
fi

read -rsp "Outer volume password: " OUTER_PASS
echo
read -rsp "Hidden volume password: " HIDDEN_PASS
echo

# Create outer volume
veracrypt --text --create "$OUTER_VOL" --volume-type=normal \
    --size=2048M --password="$OUTER_PASS" --pim=0 \
    --hash=SHA-512 --encryption=AES --filesystem=FAT --non-interactive

# Add hidden volume inside the outer one
veracrypt --text --create "$OUTER_VOL" --volume-type=hidden \
    --size=2048M --password="$HIDDEN_PASS" --pim=0 \
    --hash=SHA-512 --encryption=AES --filesystem=FAT \
    --protect-hidden=no --non-interactive

mkdir -p "$MOUNT_DIR"
veracrypt --text --password="$HIDDEN_PASS" --mount "$OUTER_VOL" "$MOUNT_DIR"

cp "$ISO" "$MOUNT_DIR/"

veracrypt --text --dismount "$MOUNT_DIR"
rmdir "$MOUNT_DIR"

mv "$OUTER_VOL" "$HIDDEN_VOL"

echo "Hidden OS volume created at $HIDDEN_VOL"
