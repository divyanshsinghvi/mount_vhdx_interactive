#!/bin/bash
#
# generate-icons.sh - Generate PNG icons from SVG in various sizes
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SVG_FILE="$SCRIPT_DIR/icon.svg"
ICONS_DIR="$SCRIPT_DIR/icons"

# Check if ImageMagick or Inkscape is available
if command -v inkscape &> /dev/null; then
    CONVERTER="inkscape"
    echo "Using Inkscape for conversion..."
elif command -v convert &> /dev/null; then
    CONVERTER="imagemagick"
    echo "Using ImageMagick for conversion..."
else
    echo "Error: Neither Inkscape nor ImageMagick found!"
    echo "Please install one of them:"
    echo "  Ubuntu/Debian: sudo apt install inkscape"
    echo "  or: sudo apt install imagemagick"
    echo "  Fedora: sudo dnf install inkscape"
    echo "  Arch: sudo pacman -S inkscape"
    exit 1
fi

# Create icons directory
mkdir -p "$ICONS_DIR"

echo "Generating icons from SVG..."
echo "Source: $SVG_FILE"
echo "Output: $ICONS_DIR"
echo

# Sizes needed for different app stores
SIZES=(16 24 32 48 64 96 128 256 512 1024)

for size in "${SIZES[@]}"; do
    output_file="$ICONS_DIR/icon-${size}x${size}.png"

    echo "Generating ${size}x${size}..."

    if [ "$CONVERTER" = "inkscape" ]; then
        inkscape "$SVG_FILE" \
            --export-type=png \
            --export-filename="$output_file" \
            --export-width=$size \
            --export-height=$size \
            2>/dev/null
    else
        convert -background none \
            "$SVG_FILE" \
            -resize ${size}x${size} \
            "$output_file"
    fi

    if [ -f "$output_file" ]; then
        echo "  ✓ Created: $output_file"
    else
        echo "  ✗ Failed: $output_file"
    fi
done

echo
echo "Creating app-specific icon sizes..."

# Snap Store icons
mkdir -p "$ICONS_DIR/snap"
for size in 256 512; do
    cp "$ICONS_DIR/icon-${size}x${size}.png" "$ICONS_DIR/snap/icon-${size}.png"
done

# Flatpak icons
mkdir -p "$ICONS_DIR/flatpak"
for size in 128 256; do
    cp "$ICONS_DIR/icon-${size}x${size}.png" "$ICONS_DIR/flatpak/icon-${size}.png"
done

# Debian package icons
mkdir -p "$ICONS_DIR/hicolor"
for size in 16 24 32 48 64 128 256; do
    mkdir -p "$ICONS_DIR/hicolor/${size}x${size}/apps"
    cp "$ICONS_DIR/icon-${size}x${size}.png" \
       "$ICONS_DIR/hicolor/${size}x${size}/apps/vhdx-mount.png"
done

# Copy SVG for scalable
mkdir -p "$ICONS_DIR/hicolor/scalable/apps"
cp "$SVG_FILE" "$ICONS_DIR/hicolor/scalable/apps/vhdx-mount.svg"

echo
echo "✓ Icon generation complete!"
echo
echo "Generated icons:"
ls -lh "$ICONS_DIR"/icon-*.png
echo
echo "Icons are ready for:"
echo "  - Snap Store (snap/)"
echo "  - Flatpak (flatpak/)"
echo "  - Debian packages (hicolor/)"
echo
