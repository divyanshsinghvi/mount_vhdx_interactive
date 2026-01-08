# VHDX Mount Tool - Assets

This directory contains all visual assets for the application.

## Icon Files

### Source
- `icon.svg` - Master SVG icon (scalable vector graphic)

### Generated Icons
Run `./generate-icons.sh` or `python3 generate-icons.py` to generate all required icon sizes.

The following sizes will be generated:
- 16x16, 24x24, 32x32, 48x48, 64x64, 96x96, 128x128, 256x256, 512x512, 1024x1024

### Directory Structure After Generation

```
assets/
├── icon.svg                    # Master SVG source
├── icons/
│   ├── icon-16x16.png         # All standard sizes
│   ├── icon-24x24.png
│   ├── ... (other sizes)
│   ├── snap/                   # Snap Store specific
│   │   ├── icon-256.png
│   │   └── icon-512.png
│   ├── flatpak/                # Flatpak specific
│   │   ├── icon-128.png
│   │   └── icon-256.png
│   └── hicolor/                # FreeDesktop icon theme
│       ├── 16x16/apps/
│       ├── 24x24/apps/
│       ├── ... (other sizes)
│       └── scalable/apps/
├── screenshots/                # App store screenshots
│   ├── screenshot1.png
│   ├── screenshot2.png
│   └── screenshot3.png
└── banner.png                  # Optional store banner
```

## Icon Design

The icon features:
- **Blue hard disk** representing VHDX virtual disk files
- **Green mount badge** with checkmark indicating successful mounting
- **Linux penguin silhouette** showing Linux platform
- **VHDX label** for clear identification
- **Activity LEDs** suggesting disk activity

## Generating Icons

### Method 1: Using Inkscape (Recommended)
```bash
sudo apt install inkscape     # Ubuntu/Debian
./generate-icons.sh
```

### Method 2: Using ImageMagick
```bash
sudo apt install imagemagick  # Ubuntu/Debian
./generate-icons.sh
```

### Method 3: Using Python/Pillow
```bash
pip3 install pillow cairosvg
python3 generate-icons.py
```

## Screenshots

To create great screenshots for app stores:

1. **Launch the application**
   ```bash
   python3 vhdx_viewer.py
   ```

2. **Take screenshots showing:**
   - Main application window
   - Double-click mounting in action
   - File manager showing mounted VHDX
   - Context menu with "Mount VHDX" option

3. **Save to `screenshots/` directory**

### Screenshot Guidelines

- **Size**: 1920x1080 or 1280x720
- **Format**: PNG (preferred) or JPEG
- **Count**: At least 3-5 screenshots
- **Content**: Show actual usage, not just the interface
- **Annotations**: Add arrows/text to highlight features (optional)

### Example Screenshot Names
```
screenshot1-main-window.png       # Main GUI application
screenshot2-file-manager.png      # Mounted VHDX in file manager
screenshot3-context-menu.png      # Right-click context menu
screenshot4-notification.png      # Desktop notification
screenshot5-mounted-contents.png  # Contents of mounted VHDX
```

## Banner/Hero Image (Optional)

For some app stores, you may want a banner image:
- **Size**: 1920x640 or similar wide aspect ratio
- **Content**: App name, icon, key features
- **Style**: Match the icon color scheme

## Usage in Packages

### Snap
The icon is automatically included via `snapcraft.yaml`:
```yaml
icon: assets/icons/snap/icon-512.png
```

### Flatpak
Referenced in the manifest:
```yaml
icon: com.github.divyanshsinghvi.VHDXMount
```

### Debian/Ubuntu
Installed to standard icon directories:
```bash
/usr/share/icons/hicolor/*/apps/vhdx-mount.png
```

## Updating the Icon

If you modify `icon.svg`:
1. Edit the SVG file
2. Run `./generate-icons.sh` to regenerate all sizes
3. Commit all generated icons to git
4. Rebuild and republish packages

## License

The icon is part of the VHDX Mount Tool project and is licensed under the MIT License.
