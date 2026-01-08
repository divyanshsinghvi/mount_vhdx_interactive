# Usage Guide - VHDX Mount Tool

## 📖 Mounting Modes

The VHDX Mount Tool supports two mounting modes:

### 🖊️ Read-Write Mode (Default)
- **Can modify, create, and delete files** inside the VHDX
- **Changes are saved** back to the VHDX file
- Use when you need to edit files or make changes
- ⚠️ **Warning:** Changes are permanent!

### 👁️ Read-Only Mode (Safe)
- **Cannot modify files** - viewing only
- **Safe for inspection** - no accidental changes
- Use when you just want to browse/copy files
- Recommended for backups or sensitive data

---

## 🖱️ Usage Methods

### Method 1: Double-Click (Easiest)

1. **Double-click a .vhdx file**
2. Choose mount mode in the dialog:
   - **Yes** = Read-Write (can edit files)
   - **No** = Read-Only (safe mode)
3. Files automatically open in file manager

---

### Method 2: Right-Click Context Menu

Right-click a .vhdx file and choose:

- **"Mount VHDX"** - Asks for mode (read-write or read-only)
- **"Mount VHDX (Read-Write)"** - Direct read-write access
- **"Mount VHDX (Read-Only)"** - Direct read-only access
- **"Unmount VHDX"** - Safely unmount

---

### Method 3: Command Line

```bash
# Default (read-write)
mount-vhdx.sh /path/to/disk.vhdx

# Explicit read-write
mount-vhdx.sh /path/to/disk.vhdx rw
mount-vhdx-rw.sh /path/to/disk.vhdx

# Read-only (safe mode)
mount-vhdx.sh /path/to/disk.vhdx ro
mount-vhdx-ro.sh /path/to/disk.vhdx

# Unmount
unmount-vhdx.sh /path/to/disk.vhdx

# List all mounted VHDX
list-vhdx-mounts.sh
```

---

## 📂 Where Files Are Mounted

```
/media/$USER/vhdx/<filename>/
```

**Example:**
```bash
# Mounting windows.vhdx will be accessible at:
/media/yourusername/vhdx/windows/

# If multiple partitions:
/media/yourusername/vhdx/windows/partition1/
/media/yourusername/vhdx/windows/partition2/
```

---

## ✏️ Editing Files in VHDX

### Read-Write Mode (Can Overwrite)

```bash
# Mount with write access
mount-vhdx-rw.sh disk.vhdx

# Navigate to mounted location
cd /media/$USER/vhdx/disk/

# Edit files directly
nano somefile.txt
echo "new content" > file.txt

# Changes are saved to the VHDX immediately!
```

### Important Notes:
- ✅ Changes are **immediately written** to the VHDX
- ✅ You can **create, modify, delete** files
- ✅ File permissions are preserved
- ⚠️ Changes are **permanent** - be careful!
- ⚠️ Don't force-unmount while writing

---

## 🔒 Read-Only vs Read-Write

| Feature | Read-Write | Read-Only |
|---------|-----------|-----------|
| View files | ✅ | ✅ |
| Copy files out | ✅ | ✅ |
| Modify files | ✅ | ❌ |
| Create files | ✅ | ❌ |
| Delete files | ✅ | ❌ |
| Safe for backups | ⚠️ | ✅ |
| Changes saved | ✅ | N/A |

---

## 💡 Common Use Cases

### Case 1: Extract Files from Windows VHDX
```bash
# Mount read-only (safe)
mount-vhdx-ro.sh windows-backup.vhdx

# Copy files to Linux
cp /media/$USER/vhdx/windows-backup/Users/Documents/file.pdf ~/

# Unmount
unmount-vhdx.sh
```

### Case 2: Modify Files in VHDX
```bash
# Mount read-write
mount-vhdx-rw.sh project.vhdx

# Edit files
cd /media/$USER/vhdx/project/
vim config.txt

# Changes are saved automatically
# Unmount when done
unmount-vhdx.sh
```

### Case 3: Share VHDX with Windows
```bash
# Edit on Linux
mount-vhdx-rw.sh shared.vhdx
echo "Hello from Linux" > /media/$USER/vhdx/shared/message.txt
unmount-vhdx.sh

# Transfer VHDX to Windows
# Files will be there!
```

### Case 4: Browse VM Disk
```bash
# Mount VM disk read-only (safe)
mount-vhdx-ro.sh vm-disk.vhdx

# Browse without risk
nautilus /media/$USER/vhdx/vm-disk/
```

---

## ⚠️ Safety Tips

### Do's ✅
- ✅ Mount read-only when just browsing
- ✅ Use read-write when you need to edit
- ✅ Always unmount properly before moving VHDX file
- ✅ Keep backups of important VHDX files
- ✅ Check available space before writing

### Don'ts ❌
- ❌ Don't force shutdown while VHDX is mounted
- ❌ Don't delete/move VHDX file while mounted
- ❌ Don't mount same VHDX multiple times
- ❌ Don't edit system VHDX files unless you know what you're doing
- ❌ Don't mount untrusted VHDX files without scanning

---

## 🐛 Troubleshooting

### "Cannot write to file"
```bash
# Check if mounted read-only
mount | grep vhdx

# If shows "ro", unmount and remount read-write
unmount-vhdx.sh
mount-vhdx-rw.sh disk.vhdx
```

### "Disk is full"
```bash
# Check VHDX free space
df -h /media/$USER/vhdx/*/

# VHDX size is fixed - cannot expand on Linux
# Either free up space or use a larger VHDX
```

### "Permission denied"
```bash
# Files are owned by you after mount
# If still issues, check:
ls -la /media/$USER/vhdx/*/

# For NTFS, ownership is set via uid/gid options
# Already configured in mount-vhdx.sh
```

---

## 🔧 Advanced Usage

### Mount Multiple VHDX Files
```bash
# You can mount up to 16 VHDX files
mount-vhdx.sh disk1.vhdx rw
mount-vhdx.sh disk2.vhdx ro
mount-vhdx.sh disk3.vhdx rw

# List all
list-vhdx-mounts.sh

# Unmount all
unmount-vhdx.sh  # Select from list
```

### Specify Custom Mount Point
```bash
# Edit mount-vhdx.sh and change:
# MOUNT_BASE="/media/$USER/vhdx"
# to your preferred location
```

### Passwordless Mounting
```bash
# Enable once for automatic mounting
./setup-passwordless.sh

# Now mounting requires no password!
```

---

## 📊 Performance

- **Small files (<100MB):** Instant access
- **Large files (1-10GB):** 2-5 seconds to mount
- **Reading:** Same speed as native disk
- **Writing:** Slightly slower than native (NBD overhead)
- **NTFS:** May be slower than ext4 on Linux

---

## 🎯 Quick Reference

| Task | Command |
|------|---------|
| Mount read-write | `mount-vhdx-rw.sh disk.vhdx` |
| Mount read-only | `mount-vhdx-ro.sh disk.vhdx` |
| Unmount | `unmount-vhdx.sh` |
| List mounts | `list-vhdx-mounts.sh` |
| Default mode | Read-write |

---

## 🚀 Tips & Tricks

1. **Batch Operations**
   ```bash
   # Mount all VHDX in folder
   for vhdx in *.vhdx; do
       mount-vhdx-ro.sh "$vhdx"
   done
   ```

2. **Create Symlinks**
   ```bash
   # Quick access to mounted VHDX
   ln -s /media/$USER/vhdx/project ~/vhdx-project
   ```

3. **Watch for Changes**
   ```bash
   # Monitor VHDX contents
   watch -n 1 ls -lh /media/$USER/vhdx/disk/
   ```

4. **Sync Files**
   ```bash
   # Copy entire VHDX contents
   rsync -av /media/$USER/vhdx/disk/ ~/backup/
   ```

---

**Remember:** With great power comes great responsibility! Use read-write mode carefully. 🦸
