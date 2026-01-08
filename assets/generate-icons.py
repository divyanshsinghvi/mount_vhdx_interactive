#!/usr/bin/env python3
"""
Simple icon generator using PIL/Pillow
Alternative to Inkscape if cairosvg is available
"""

import os
import sys

try:
    from PIL import Image
    import cairosvg
except ImportError:
    print("Error: Required libraries not found!")
    print("Install with: pip3 install pillow cairosvg")
    sys.exit(1)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SVG_FILE = os.path.join(SCRIPT_DIR, "icon.svg")
ICONS_DIR = os.path.join(SCRIPT_DIR, "icons")

# Sizes needed
SIZES = [16, 24, 32, 48, 64, 96, 128, 256, 512, 1024]

def generate_icons():
    """Generate PNG icons from SVG"""
    os.makedirs(ICONS_DIR, exist_ok=True)

    print("Generating icons from SVG...")
    print(f"Source: {SVG_FILE}")
    print(f"Output: {ICONS_DIR}\n")

    for size in SIZES:
        output_file = os.path.join(ICONS_DIR, f"icon-{size}x{size}.png")

        print(f"Generating {size}x{size}...")

        try:
            # Convert SVG to PNG using cairosvg
            png_data = cairosvg.svg2png(
                url=SVG_FILE,
                output_width=size,
                output_height=size
            )

            # Save the PNG
            with open(output_file, 'wb') as f:
                f.write(png_data)

            print(f"  ✓ Created: {output_file}")

        except Exception as e:
            print(f"  ✗ Failed: {e}")

    print("\n✓ Icon generation complete!")

if __name__ == "__main__":
    generate_icons()
