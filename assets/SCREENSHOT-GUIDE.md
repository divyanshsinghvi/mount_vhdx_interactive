# Screenshot Guide for VHDX Mount Tool

Take these screenshots to make your app store listings attractive!

## Required Screenshots

### 1. Main Application Window (vhdx_viewer.py)
**File:** `screenshot1-main-window.png`

**How to capture:**
```bash
python3 vhdx_viewer.py
# Take screenshot showing:
# - Clean interface
# - File selection dialog
# - Mount/Unmount buttons
# - Status log area
```

**What to show:**
- Full application window
- No errors in the log
- Professional, clean appearance

---

### 2. File Manager - Double Click Action
**File:** `screenshot2-double-click.png`

**How to capture:**
1. Open your file manager (Nautilus, Dolphin, etc.)
2. Navigate to a folder with a .vhdx file
3. Hover over the .vhdx file (or select it)
4. Take screenshot showing the file with the custom VHDX icon

**What to show:**
- .vhdx file with custom icon (if visible)
- Clean file manager interface
- Shows that VHDX files are recognized

---

### 3. Right-Click Context Menu
**File:** `screenshot3-context-menu.png`

**How to capture:**
1. Right-click on a .vhdx file
2. Take screenshot showing context menu with "Mount VHDX" option
3. Make sure the menu is clearly visible

**What to show:**
- Right-click menu
- "Mount VHDX" and "Unmount VHDX" options highlighted
- Shows integration with file manager

---

### 4. Desktop Notification
**File:** `screenshot4-notification.png`

**How to capture:**
1. Run: `mount-vhdx.sh /path/to/test.vhdx`
2. When notification appears, take screenshot quickly
3. Or use: `zenity --info --text="VHDX Mounted Successfully" --title="VHDX Mount"` to test

**What to show:**
- Desktop notification popup
- Success message
- Professional appearance

---

### 5. Mounted VHDX Contents
**File:** `screenshot5-mounted-contents.png`

**How to capture:**
1. Mount a VHDX file
2. Open the mounted location in file manager
3. Take screenshot showing the contents
4. URL/path bar should show: `/media/$USER/vhdx/filename/`

**What to show:**
- File manager showing mounted VHDX contents
- Files and folders inside the VHDX
- Clear evidence that mounting works

---

## Optional Screenshots

### 6. Terminal Usage
**File:** `screenshot6-terminal.png`

**How to capture:**
```bash
mount-vhdx.sh /path/to/disk.vhdx
# Take screenshot of terminal showing success messages
```

**What to show:**
- Clean terminal output
- Success messages
- Professional CLI interface

---

### 7. Passwordless Setup
**File:** `screenshot7-passwordless-setup.png`

**How to capture:**
```bash
./setup-passwordless.sh
# Screenshot showing the setup process
```

**What to show:**
- Easy setup process
- Clear instructions
- Confirmation of success

---

## Screenshot Tips

### General Guidelines
1. **Resolution**: Use 1920x1080 or 1280x720
2. **Clean Desktop**: Remove clutter, use neutral wallpaper
3. **Consistent Theme**: Use the same theme for all screenshots
4. **No Personal Data**: Don't show real file names/data
5. **Good Lighting**: Use default/light themes for clarity

### Tools for Taking Screenshots

**GNOME Screenshot:**
```bash
gnome-screenshot -w  # Current window
gnome-screenshot -a  # Select area
```

**KDE Spectacle:**
```bash
spectacle -a  # Active window
spectacle -r  # Region
```

**Flameshot (Universal):**
```bash
sudo apt install flameshot
flameshot gui
# Allows annotations and editing!
```

### Adding Annotations (Optional)

Use tools like:
- **Flameshot** - Built-in annotation tools
- **GIMP** - Full image editor
- **Inkscape** - Vector annotations
- **Pinta** - Simple paint program

Add:
- Arrows pointing to key features
- Text labels for important UI elements
- Red circles/boxes to highlight features
- Blur sensitive information

### Example Annotation Script

```bash
#!/bin/bash
# annotate-screenshot.sh
# Requires: imagemagick

convert screenshot1-main-window.png \
    -pointsize 40 -fill red \
    -annotate +50+50 "1. Select VHDX File" \
    -annotate +50+150 "2. Click Mount" \
    screenshot1-annotated.png
```

## Creating a Demo GIF (Bonus!)

Show the full workflow in an animated GIF:

```bash
# Install Peek (screen recorder)
sudo apt install peek

# Record:
# 1. Double-click .vhdx file
# 2. Show auto-mounting
# 3. File manager opens
# 4. Show contents
# 5. Right-click to unmount

# Save as: demo.gif
```

This is VERY impressive for app store listings!

## Checklist

Before submitting to app stores:

- [ ] At least 3 screenshots taken
- [ ] All screenshots are 1280x720 or higher
- [ ] Screenshots saved as PNG
- [ ] No personal/sensitive data visible
- [ ] Screenshots show actual functionality
- [ ] Optional: Annotations added
- [ ] Optional: Demo GIF created
- [ ] All files in `assets/screenshots/` directory

## After Taking Screenshots

Update these files with screenshot paths:
- `snap/snapcraft.yaml` - Add screenshots section
- `com.github.divyanshsinghvi.VHDXMount.yml` - Add screenshots
- `DISTRIBUTION.md` - Reference screenshot locations

## Example: Good vs Bad Screenshots

### ❌ Bad Screenshot
- Blurry or low resolution
- Shows errors or broken functionality
- Contains personal file names
- Desktop is cluttered
- Window is partially cut off

### ✅ Good Screenshot
- Sharp, high resolution
- Shows working feature
- Generic test filenames
- Clean desktop
- Entire window visible
- Optional helpful annotations

---

**Ready to take screenshots?** Just follow this guide in order, and you'll have professional app store materials in 15 minutes!
