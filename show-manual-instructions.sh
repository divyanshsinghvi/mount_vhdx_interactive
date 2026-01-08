#!/bin/bash
#
# show-manual-instructions.sh - Show how to manually set default app
#

cat <<'EOF'

═══════════════════════════════════════════════════
  MANUAL SETUP INSTRUCTIONS
═══════════════════════════════════════════════════

If automatic association still doesn't work, you need to
set it manually ONE TIME. After that, it will stick.

╔═══════════════════════════════════════════════════╗
║  For GNOME / Nautilus (Ubuntu, Fedora, etc.)     ║
╚═══════════════════════════════════════════════════╝

1. Find any .vhdx file in Files (Nautilus)

2. RIGHT-CLICK the .vhdx file

3. Select "Properties"

4. Click the "Open With" tab

5. Look for "Mount VHDX" in the list

   If you DON'T see "Mount VHDX":
   - Click "Show Other Applications"
   - Or click "View All Applications"
   - Scroll to find "Mount VHDX"

6. Click on "Mount VHDX" to select it

7. Click "Set as default" button

8. Click "Close" or "OK"

✅ Done! Now ALL .vhdx files will open with Mount VHDX!

╔═══════════════════════════════════════════════════╗
║  For KDE / Dolphin (Kubuntu, etc.)                ║
╚═══════════════════════════════════════════════════╝

1. Find any .vhdx file in Dolphin

2. RIGHT-CLICK the .vhdx file

3. Select "Properties"

4. Click "File Type Options" or "Open With"

5. Click "Add Application"

6. Find and select "Mount VHDX"

7. Move it to the top of the list (if needed)

8. Check "Remember application association"

9. Click "OK" or "Apply"

✅ Done!

╔═══════════════════════════════════════════════════╗
║  For XFCE / Thunar                                 ║
╚═══════════════════════════════════════════════════╝

1. Right-click any .vhdx file

2. Select "Open With Other Application"

3. Find "Mount VHDX" in the list

4. Check "Use as default for this kind of file"

5. Click "Open"

✅ Done!

╔═══════════════════════════════════════════════════╗
║  Alternative: Command Line Method                  ║
╚═══════════════════════════════════════════════════╝

Run these commands:

xdg-mime default vhdx-mount.desktop application/x-vhdx

gio mime application/x-vhdx vhdx-mount.desktop

Then log out and back in.

╔═══════════════════════════════════════════════════╗
║  Test if it worked                                 ║
╚═══════════════════════════════════════════════════╝

xdg-mime query default application/x-vhdx

Should show: vhdx-mount.desktop

═══════════════════════════════════════════════════

After setting it manually ONE TIME:
→ All .vhdx files will open automatically
→ Works forever (no need to repeat)
→ Survives system updates

═══════════════════════════════════════════════════

Still need help? The scripts work directly:

  mount-vhdx-rw.sh /path/to/file.vhdx

This always works, no setup needed!

═══════════════════════════════════════════════════

EOF
