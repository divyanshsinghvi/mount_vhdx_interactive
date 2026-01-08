# 🚀 Quick Start Guide - VHDX Mount Tool

Get started in **2 minutes** and mount VHDX files with just a click!

## Step 1: Install (30 seconds)

```bash
cd mount_vhdx_interactive
chmod +x install.sh
./install.sh
```

When asked: **"Setup passwordless mounting?"** → Press **Y** (recommended!)

## Step 2: Use It! (That's it!)

### Option A: Double-Click (Easiest!)
1. Find any `.vhdx` file in your file manager
2. **Double-click it**
3. Done! The file automatically mounts and opens 🎉

### Option B: Right-Click
1. Right-click any `.vhdx` file
2. Select **"Mount VHDX"**
3. Done! 🎉

## What You'll See

```
📂 /media/yourusername/vhdx/yourfile/
   └── All your VHDX contents here!
```

The file manager opens automatically showing your files.

## To Unmount

### Option 1: Right-Click
- Right-click the .vhdx file → Select **"Unmount VHDX"**

### Option 2: Command Line
```bash
unmount-vhdx.sh
```

### Option 3: List All Mounts
```bash
list-vhdx-mounts.sh
```

## Troubleshooting

### "Permission denied" or password prompts?
Run the passwordless setup:
```bash
./setup-passwordless.sh
```

### Nothing happens when I double-click?
Check if the default app is set:
```bash
xdg-mime default vhdx-mount.desktop application/x-vhdx
```

### "qemu-nbd not found"?
Install dependencies:
```bash
# Ubuntu/Debian
sudo apt install qemu-utils ntfs-3g zenity

# Fedora
sudo dnf install qemu-img ntfs-3g zenity

# Arch
sudo pacman -S qemu ntfs-3g zenity
```

## That's It!

You're ready to use VHDX files on Linux as easily as on Windows!

**Pro Tip**: Create a desktop shortcut to your .vhdx files for even faster access!

---

Need more details? Check the full [README.md](README.md)
